import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/chat_message.dart';
import '../services/marcus_chat_service.dart';
import '../theme/app_theme.dart';
import '../widgets/message_bubble.dart';
import '../widgets/philosopher_avatar.dart';
import '../widgets/typing_indicator.dart';

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
  final MarcusChatService _groq = MarcusChatService();

  bool _isTyping = false;
  bool _isLoading = true;
  bool _hasText = false;
  String? _lastFailedText;
  late AnimationController _headerFade;

  @override
  void initState() {
    super.initState();
    _headerFade = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    _textController.addListener(() {
      final hasText = _textController.text.trim().isNotEmpty;
      if (hasText != _hasText) {
        setState(() => _hasText = hasText);
      }
    });
    _loadGreeting();
  }

  String _friendlyErrorMessage(Object e) {
    if (e is NetworkException || e is ApiException) {
      return e.toString();
    }
    return 'ক্ষমা করো — এই মুহূর্তে আমার চিন্তা মেঘাচ্ছন্ন। হয়তো আবার চেষ্টা করো।';
  }

  Future<void> _loadGreeting() async {
    setState(() => _isTyping = true);
    try {
      final greeting = await _groq.getGreeting();
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

  Future<void> _sendMessage([String? retryText]) async {
    final text = retryText ?? _textController.text.trim();
    if (text.isEmpty || _isTyping) return;

    _lastFailedText = null;
    if (retryText == null) _textController.clear();

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
      final response = await _groq.sendMessage(text);
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
          _lastFailedText = text;
          _messages.add(ChatMessage(
            text: _friendlyErrorMessage(e),
            isUser: false,
            timestamp: DateTime.now(),
          ));
          _isTyping = false;
        });
        _scrollToBottom();
      }
    }
  }

  void _retryLastMessage() {
    if (_lastFailedText != null) {
      _sendMessage(_lastFailedText);
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
    _groq.dispose();
    _headerFade.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.obsidian,
      body: Column(
        children: [
          _buildHeader(context),

          Container(height: 1, color: AppColors.divider),

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

          if (_lastFailedText != null) _buildRetryBanner(),

          _buildInputBar(context),
        ],
      ),
    );
  }

  Widget _buildRetryBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: AppColors.navy,
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded,
              color: AppColors.gold.withValues(alpha: 0.8), size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'বার্তাটি পাঠানো যায়নি।',
              style: GoogleFonts.inter(
                color: AppColors.parchment.withValues(alpha: 0.75),
                fontSize: 12.5,
              ),
            ),
          ),
          GestureDetector(
            onTap: _retryLastMessage,
            child: Text(
              'আবার চেষ্টা করুন',
              style: GoogleFonts.inter(
                color: AppColors.gold,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
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
            onTap: (_hasText && !_isTyping) ? () => _sendMessage() : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: (_hasText && !_isTyping)
                    ? AppColors.gold
                    : AppColors.gold.withValues(alpha: 0.12),
                border: Border.all(
                  color: AppColors.gold.withValues(alpha: 0.35),
                  width: 1,
                ),
                boxShadow: [
                  if (_hasText && !_isTyping)
                    BoxShadow(
                      color: AppColors.gold.withValues(alpha: 0.25),
                      blurRadius: 12,
                      spreadRadius: 1,
                    ),
                ],
              ),
              child: Icon(
                Icons.arrow_upward_rounded,
                color: (_hasText && !_isTyping)
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