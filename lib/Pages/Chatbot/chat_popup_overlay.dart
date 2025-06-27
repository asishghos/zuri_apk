import 'dart:convert';
import 'dart:developer' as Developer;
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_markdown/flutter_markdown.dart'; // Added for Markdown rendering
import 'package:testing2/Global/Colors/app_colors.dart';

// OpenAI Service Class (unchanged)
class OpenAIService {
  static const String _baseUrl = 'https://api.openai.com/v1/chat/completions';
  // static final String _apiKey = '${dotenv.env['openai_api_key']}';
  static final String _apiKey = 'ghghghghghhhhbvghftgbhg';

  static Future<String> sendMessage(
    List<Map<String, String>> messages, {
    String systemPrompt =
        '''You are Zuri, a specialized fashion stylist AI assistant for the Zuri platform.
          GUIDELINES:
          1. Keep responses concise, clear, and to the point and short.
          2. ONLY respond to queries related to styling, fashion, and outfit suggestions.
          3. If the user asks unrelated questions (e.g., coding, general knowledge, politics, 
             math, science, abuse, nonsense questions, etc.), politely inform them that you 
             are specialized in fashion advice only.
          4. You are the AI assistant of the 'Zuri' platform, where users input their body shape 
             and skin tone to receive personalized outfit recommendations.
          5. Help users feel confident and stylish based on their unique traits.
          
          RESPONSE FORMAT:
          - Use markdown formatting: *bold* for key fashion terms, lists with - for outfit components
          - Emphasize personalized recommendations
          - Keep responses under 150 words when possible
          - Use emojis sparingly to highlight important points (👗👔👠👕)
          
          When asked about body shapes, outfit recommendations, or styling advice, 
          provide genuinely helpful and personalized fashion guidance. 
          When off-topic, respond: "As Zuri, I'm specialized in fashion styling advice. 
          I'd be happy to help with outfit recommendations, fashion trends, or style guidance!''',
  }) async {
    try {
      final updatedMessages = [
        {'role': 'system', 'content': systemPrompt},
        ...messages,
      ];

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-4o',
          'messages': updatedMessages,
          'max_tokens': 800,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'];
      } else {
        Developer.log(
          'OpenAI API Error: ${response.statusCode} - ${response.body}',
        );
        return 'Sorry for the slip-up! Let’s hit refresh and talk fashion!';
      }
    } catch (e) {
      Developer.log('OpenAI Service Error: $e');
      return 'Sorry for the slip-up! Let’s hit refresh and talk fashion!';
    }
  }
}

// ChatOverlayManager (unchanged)
class ChatOverlayManager extends StatefulWidget {
  final Widget child;
  final String userName;
  final String firstQuery;

  const ChatOverlayManager({
    Key? key,
    required this.child,
    required this.userName,
    required this.firstQuery,
  }) : super(key: key);

  @override
  State<ChatOverlayManager> createState() => _ChatOverlayManagerState();
}

class _ChatOverlayManagerState extends State<ChatOverlayManager> {
  bool _isChatVisible = true;

  void _toggleChat() {
    setState(() {
      _isChatVisible = !_isChatVisible;
    });
  }

  void _closeChat() {
    setState(() {
      _isChatVisible = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    double dh = MediaQuery.of(context).size.height;
    double dw = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Stack(
        children: [
          widget.child,
          ChatPopupOverlay(
            userName: widget.userName,
            firstQuery: widget.firstQuery,
            isVisible: _isChatVisible,
            onClose: _closeChat,
            onSendMessage: (message) {
              print('Message sent: $message');
            },
          ),
        ],
      ),
      floatingActionButton: !_isChatVisible
          ? Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: AppColors.textPrimary),
              ),
              child: TextButton(
                onPressed: _toggleChat,
                style: TextButton.styleFrom(
                  // padding: const EdgeInsets.symmetric(
                  //   horizontal: 16,
                  //   vertical: 8,
                  // ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32),
                  ),
                  backgroundColor: Colors.transparent,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 42,
                      height: 42,
                      child: Lottie.asset(
                        'assets/images/chatbot/animation.json',
                        frameBuilder: (context, child, composition) {
                          if (composition != null) {
                            return child;
                          } else {
                            return const Icon(Icons.error, color: Colors.red);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Ask Zuri',
                      style: GoogleFonts.libreFranklin(
                        color: AppColors.titleTextColor,
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

// Updated ChatPopupOverlay
class ChatPopupOverlay extends StatefulWidget {
  final String userName;
  final VoidCallback? onClose;
  final bool isVisible;
  final String firstQuery;
  final Function(String)? onSendMessage;

  const ChatPopupOverlay({
    Key? key,
    required this.userName,
    required this.firstQuery,
    this.onClose,
    this.isVisible = false,
    this.onSendMessage,
  }) : super(key: key);

  @override
  State<ChatPopupOverlay> createState() => _ChatPopupOverlayState();
}

class _ChatPopupOverlayState extends State<ChatPopupOverlay>
    with TickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<ChatMessage> _messages = [];
  List<Map<String, String>> _conversationHistory = [];
  bool _isTyping = false;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    if (widget.isVisible) {
      _slideController.forward();
    }

    // Initialize conversation with system prompt (already handled in OpenAIService)
    // _conversationHistory.add({
    //   'role': 'system',
    //   'content':
    //       'You are Zuri, a helpful fashion assistant. You help users with style questions, outfit suggestions, and fashion advice. Be friendly, knowledgeable, and concise in your responses.',
    // });

    // Add initial greeting message and send first query
    _addInitialMessage();
  }

  @override
  void didUpdateWidget(ChatPopupOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVisible && !oldWidget.isVisible) {
      _slideController.forward();
    } else if (!widget.isVisible && oldWidget.isVisible) {
      _slideController.reverse();
    }
  }

  void _addInitialMessage() {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _scrollToBottom();

        // Send first query if provided
        if (widget.firstQuery.isNotEmpty) {
          Future.delayed(const Duration(milliseconds: 1000), () {
            _sendFirstQuery();
          });
        }
      }
    });
  }

  void _sendFirstQuery() {
    if (widget.firstQuery.trim().isEmpty) return;

    setState(() {
      _messages.add(
        ChatMessage(
          text: widget.firstQuery,
          isUser: true,
          timestamp: DateTime.now(),
        ),
      );
      _isTyping = true;
    });

    _scrollToBottom();
    _sendToGPT(widget.firstQuery);
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage() {
    if (_textController.text.trim().isEmpty) return;

    final messageText = _textController.text.trim();
    setState(() {
      _messages.add(
        ChatMessage(text: messageText, isUser: true, timestamp: DateTime.now()),
      );
      _isTyping = true;
    });

    _textController.clear();
    _scrollToBottom();

    if (widget.onSendMessage != null) {
      widget.onSendMessage!(messageText);
    }

    _sendToGPT(messageText);
  }

  void _sendToGPT(String message) async {
    _conversationHistory.add({'role': 'user', 'content': message});

    try {
      final response = await OpenAIService.sendMessage(_conversationHistory);

      if (mounted) {
        setState(() {
          _isTyping = false;
          _messages.add(
            ChatMessage(
              text: response,
              isUser: false,
              timestamp: DateTime.now(),
            ),
          );
        });

        _conversationHistory.add({'role': 'assistant', 'content': response});
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isTyping = false;
          _messages.add(
            ChatMessage(
              text:
                  "Sorry for the slip-up! Let’s hit refresh and talk fashion!",
              isUser: false,
              timestamp: DateTime.now(),
            ),
          );
        });
        _scrollToBottom();
      }
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double dh = MediaQuery.of(context).size.height;
    double dw = MediaQuery.of(context).size.width;
    if (!widget.isVisible) return const SizedBox.shrink();

    return Positioned.fill(
      child: Material(
        color: Colors.black26,
        child: GestureDetector(
          onTap: () {
            if (widget.onClose != null) {
              widget.onClose!();
            }
          },
          child: Container(
            alignment: Alignment.bottomCenter,
            child: GestureDetector(
              onTap: () {},
              child: SlideTransition(
                position: _slideAnimation,
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.70,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                  ),
                  child: Column(
                    children: [
                      _buildHeader(),
                      Expanded(child: _buildChatArea()),
                      Padding(
                        padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                        child: _buildInputArea(dh: dh),
                      ),
                      SizedBox(height: dh * 0.02),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.only(right: 20, left: 20),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      child: Column(
        children: [
          Divider(color: Color(0xFFD9D9D9), indent: 150, endIndent: 150),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: GoogleFonts.libreFranklin(
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                          color: Colors.black,
                        ),
                        children: [
                          const TextSpan(text: 'Ask '),
                          TextSpan(
                            text: 'Zuri',
                            style: GoogleFonts.libreFranklin(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'Your Style BFF',
                      style: GoogleFonts.libreFranklin(
                        fontSize: 12,
                        color: AppColors.titleTextColor,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: widget.onClose,
                icon: const HugeIcon(
                  icon: HugeIcons.strokeRoundedCancelCircle,
                  color: AppColors.titleTextColor,
                  size: 24,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Divider(color: Color(0xFF9EA2AE)),
        ],
      ),
    );
  }

  Widget _buildChatArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ListView.builder(
        controller: _scrollController,
        itemCount: _messages.length + (_isTyping ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _messages.length && _isTyping) {
            return _buildTypingIndicator();
          }
          return _buildMessageBubble(_messages[index]);
        },
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: message.isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: message.isUser ? const Color(0xFFE5E7EA) : Colors.white,
                borderRadius: BorderRadius.circular(16).copyWith(
                  bottomRight: message.isUser ? const Radius.circular(4) : null,
                  bottomLeft: message.isUser ? null : const Radius.circular(4),
                ),
              ),
              child: message.isUser
                  ? Text(
                      message.text,
                      style: GoogleFonts.libreFranklin(
                        fontSize: 15.21,
                        color: AppColors.titleTextColor,
                        height: 1.4,
                      ),
                    )
                  : MarkdownBody(
                      data: message.text,
                      styleSheet: MarkdownStyleSheet(
                        p: GoogleFonts.libreFranklin(
                          fontSize: 14,
                          color: Colors.black,
                          height: 1.4,
                        ),
                        strong: GoogleFonts.libreFranklin(
                          fontSize: 14,
                          color: Colors.black,
                          height: 1.4,
                          fontWeight: FontWeight.bold,
                        ),
                        listBullet: GoogleFonts.libreFranklin(
                          fontSize: 14,
                          color: Colors.black,
                          height: 1.4,
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(
                16,
              ).copyWith(bottomLeft: const Radius.circular(4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (index) => _buildTypingDot(index)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingDot(int index) {
    return AnimatedBuilder(
      animation: _slideController,
      builder: (context, child) {
        final animationValue = (_slideController.value * 3 - index).clamp(
          0.0,
          1.0,
        );
        return Container(
          margin: EdgeInsets.only(
            right: index < 2 ? 4 : 0,
            top: 2 * (1 - animationValue),
            bottom: 2 * (1 - animationValue),
          ),
          child: Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: AppColors.textPrimary,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInputArea({required double dh}) {
    return Container(
      height: dh * 0.065,
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        border: Border.all(color: AppColors.textPrimary),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 12, right: 8),
            child: GestureDetector(
              onTap: () {
                print('Attach button tapped');
              },
              child: Container(
                width: 22,
                height: 22,
                child: HugeIcon(
                  icon: HugeIcons.strokeRoundedFileAttachment,
                  color: AppColors.titleTextColor,
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: TextField(
                controller: _textController,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Ask Follow up question',
                  hintStyle: GoogleFonts.libreFranklin(
                    fontSize: 16,
                    color: AppColors.titleTextColor,
                  ),
                ),
                style: GoogleFonts.libreFranklin(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                  color: Colors.black,
                ),
                onChanged: (value) {
                  setState(() {});
                },
                onSubmitted: (value) {
                  if (value.trim().isNotEmpty) {
                    _sendMessage();
                  }
                },
              ),
            ),
          ),
          if (_textController.text.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: IconButton(
                onPressed: () {
                  Developer.log('Send message: ${_textController.text}');
                  _sendMessage();
                },
                icon: HugeIcon(
                  icon: HugeIcons.strokeRoundedArrowRight01,
                  color: AppColors.titleTextColor,
                  size: 28,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}
