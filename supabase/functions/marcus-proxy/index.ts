// supabase/functions/marcus-proxy/index.ts
//
// BFF (Backend-for-Frontend) proxy between the Flutter app and Groq.
// The Flutter app never sees the real Groq API key — it only knows this
// function's URL and a shared secret used to authenticate itself.
//
// Flow: Flutter app --(x-app-secret)--> this function --(Groq key)--> Groq

Deno.serve(async (req) => {
  // Only POST is meaningful here — this endpoint mirrors Groq's
  // chat-completions endpoint, which is POST-only.
  if (req.method !== "POST") {
    return new Response("Method not allowed", { status: 405 });
  }

  // First line of defense: reject anyone who doesn't know our shared
  // secret. This does not make the endpoint fully private (the secret
  // still ships inside the compiled app), but it blocks drive-by bots
  // and scanners from burning your Groq quota.
  const appSecret = req.headers.get("x-app-secret");
  if (appSecret !== Deno.env.get("APP_SHARED_SECRET")) {
    return new Response("Forbidden", { status: 403 });
  }

  // Forward the request body exactly as received — the Flutter app
  // already builds the correct Groq payload (model, messages,
  // temperature, etc.), so this function doesn't need to know or
  // validate its shape.
  const body = await req.text();

  let groqResp: Response;
  try {
    groqResp = await fetch(
      "https://api.groq.com/openai/v1/chat/completions",
      {
        method: "POST",
        headers: {
          Authorization: `Bearer ${Deno.env.get("GROQ_API_KEY")}`,
          "Content-Type": "application/json",
        },
        body,
      },
    );
  } catch (_err) {
    // Groq unreachable / DNS failure / etc. — surface a clean 502
    // instead of letting an unhandled rejection produce an opaque 500.
    return new Response(
      JSON.stringify({ error: "Upstream request to Groq failed" }),
      { status: 502, headers: { "Content-Type": "application/json" } },
    );
  }

  // Forward Groq's response (body + status) back to the app unchanged,
  // so existing Dart-side status handling (401/429/5xx) keeps working
  // exactly as it did when the app called Groq directly.
  const data = await groqResp.text();
  return new Response(data, {
    status: groqResp.status,
    headers: { "Content-Type": "application/json" },
  });
});