import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/chat_message.dart';
import '../services/gemini_service.dart';
import '../theme/app_theme.dart';
import '../widgets/message_bubble.dart';
import '../widgets/philosopher_avatar.dart';
import '../widgets/typing_indicator.dart';

/// The main chat experience — the user converses with Marcus Aurelius.
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  final List<ChatMessage> _messages = [];
  final GeminiService _gemini = GeminiService();

  bool _isTyping = false;
  bool _isLoading = true;
  late AnimationController _headerFade;

  @override
  void initState() {
    super.initState();
    _headerFade = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    _loadGreeting();
  }

  Future<void> _loadGreeting() async {
    setState(() => _isTyping = true);
    try {
      final greeting = await _gemini.getGreeting();
      if (mounted) {
        setState(() {
          _messages.add(ChatMessage(
            text: greeting,
            isUser: false,
            timestamp: DateTime.now(),
          ));
          _isTyping = false;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add(ChatMessage(
            text: 'স্বাগতম, বন্ধু। আমি মার্কাস অরেলিয়াস। আজ তোমার মনে কী চলছে?',
            isUser: false,
            timestamp: DateTime.now(),
          ));
          _isTyping = false;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _sendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty || _isTyping) return;

    _textController.clear();
    setState(() {
      _messages.add(ChatMessage(
        text: text,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _isTyping = true;
    });
    _scrollToBottom();

    try {
      final response = await _gemini.sendMessage(text);
      if (mounted) {
        setState(() {
          _messages.add(ChatMessage(
            text: response,
            isUser: false,
            timestamp: DateTime.now(),
          ));
          _isTyping = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add(ChatMessage(
            text: 'ক্ষমা করো — এই মুহূর্তে আমার চিন্তা মেঘাচ্ছন্ন। হয়তো আবার চেষ্টা করো।',
            isUser: false,
            timestamp: DateTime.now(),
          ));
          _isTyping = false;
        });
        _scrollToBottom();
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    _headerFade.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.obsidian,
      body: Column(
        children: [
          // -- Header bar --
          _buildHeader(context),

          // -- Divider --
          Container(height: 1, color: AppColors.divider),

          // -- Messages list --
          Expanded(
            child: _isLoading
                ? _buildLoadingState()
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.only(top: 20, bottom: 8),
                    itemCount: _messages.length + (_isTyping ? 1 : 0),
                    itemBuilder: (context, i) {
                      if (i < _messages.length) {
                        return MessageBubble(message: _messages[i]);
                      }
                      return const TypingIndicator();
                    },
                  ),
          ),

          // -- Input bar --
          _buildInputBar(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return FadeTransition(
      opacity: _headerFade,
      child: Container(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 10,
          left: 20,
          right: 20,
          bottom: 14,
        ),
        decoration: BoxDecoration(
          color: AppColors.navy,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            const PhilosopherAvatar(size: 44),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Marcus Aurelius',
                    style: GoogleFonts.playfairDisplay(
                      color: AppColors.cream,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.gold,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Ready to converse',
                        style: GoogleFonts.inter(
                          color: AppColors.parchment.withValues(alpha: 0.7),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Menu
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.gold.withValues(alpha: 0.08),
                border: Border.all(
                  color: AppColors.gold.withValues(alpha: 0.15),
                ),
              ),
              child: Icon(
                Icons.more_vert_rounded,
                color: AppColors.gold.withValues(alpha: 0.7),
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation(
                AppColors.gold.withValues(alpha: 0.5),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'The philosopher approaches...',
            style: GoogleFonts.playfairDisplay(
              color: AppColors.parchment.withValues(alpha: 0.6),
              fontSize: 14,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 14,
        right: 14,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: AppColors.navy,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Text input
          Expanded(
            child: TextField(
              controller: _textController,
              focusNode: _focusNode,
              style: GoogleFonts.inter(
                color: AppColors.cream,
                fontSize: 14.5,
              ),
              maxLines: 4,
              minLines: 1,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: 'Speak your mind...',
                hintStyle: GoogleFonts.inter(
                  color: AppColors.parchment.withValues(alpha: 0.45),
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),

          const SizedBox(width: 10),

          // Send button
          GestureDetector(
            onTap: _sendMessage,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _textController.text.trim().isNotEmpty
                    ? AppColors.gold
                    : AppColors.gold.withValues(alpha: 0.12),
                border: Border.all(
                  color: AppColors.gold.withValues(alpha: 0.35),
                  width: 1,
                ),
                boxShadow: [
                  if (_textController.text.trim().isNotEmpty)
                    BoxShadow(
                      color: AppColors.gold.withValues(alpha: 0.25),
                      blurRadius: 12,
                      spreadRadius: 1,
                    ),
                ],
              ),
              child: Icon(
                Icons.arrow_upward_rounded,
                color: _textController.text.trim().isNotEmpty
                    ? AppColors.obsidian
                    : AppColors.gold.withValues(alpha: 0.4),
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
