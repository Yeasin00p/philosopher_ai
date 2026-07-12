import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const GROQ_API_KEY = Deno.env.get("GROQ_API_KEY")!;
const APP_SECRET = Deno.env.get("APP_SECRET")!;
const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

const TOKEN_BUDGET = 50_000; 
const WINDOW_HOURS = 3; 

const supabase = createClient(SUPABASE_URL, SERVICE_ROLE_KEY);

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type, x-app-secret, x-session-id",
};

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }
  if (req.method !== "POST") {
    return new Response("Method not allowed", { status: 405, headers: corsHeaders });
  }

  const appSecret = req.headers.get("x-app-secret");
  if (appSecret !== APP_SECRET) {
    return json({ error: "unauthorized" }, 401);
  }

  const sessionId = req.headers.get("x-session-id");
  if (!sessionId) {
    return json({ error: "missing_session_id" }, 400);
  }

  const now = new Date();

  let { data: row } = await supabase
    .from("usage_limits")
    .select("*")
    .eq("session_id", sessionId)
    .maybeSingle();

  if (!row) {
    const { data: inserted } = await supabase
      .from("usage_limits")
      .insert({ session_id: sessionId, window_start: now.toISOString(), tokens_used: 0 })
      .select()
      .single();
    row = inserted;
  }

  const windowStart = new Date(row.window_start);
  const windowEnd = new Date(windowStart.getTime() + WINDOW_HOURS * 60 * 60 * 1000);

  if (now >= windowEnd) {
    await supabase
      .from("usage_limits")
      .update({ window_start: now.toISOString(), tokens_used: 0 })
      .eq("session_id", sessionId);
    row.tokens_used = 0;
    row.window_start = now.toISOString();
  } else if (row.tokens_used >= TOKEN_BUDGET) {
    const resetsAt = new Date(windowStart.getTime() + WINDOW_HOURS * 60 * 60 * 1000);
    return json(
      {
        error: "usage_limit_reached",
        resets_at: resetsAt.toISOString(),
        tokens_used: row.tokens_used,
        token_budget: TOKEN_BUDGET,
      },
      429,
    );
  }

  let groqRes: Response;
  let groqData: any;
  try {
    const body = await req.json();
    groqRes = await fetch("https://api.groq.com/openai/v1/chat/completions", {
      method: "POST",
      headers: {
        Authorization: `Bearer ${GROQ_API_KEY}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify(body),
    });
    groqData = await groqRes.json();
  } catch (e) {
    return json({ error: "upstream_failure", detail: String(e) }, 502);
  }

  const usedTokens = groqData?.usage?.total_tokens ?? 0;
  if (groqRes.ok && usedTokens > 0) {
    await supabase
      .from("usage_limits")
      .update({ tokens_used: (row.tokens_used ?? 0) + usedTokens })
      .eq("session_id", sessionId);
  }

  return json(groqData, groqRes.status);
});

function json(body: unknown, status: number) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}