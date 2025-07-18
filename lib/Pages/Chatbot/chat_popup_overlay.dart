// ignore_for_file: unnecessary_type_check

import 'dart:convert';
import 'dart:developer' as Developer;
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_indicator/loading_indicator.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_markdown/flutter_markdown.dart'; // Added for Markdown rendering
import 'package:permission_handler/permission_handler.dart';
import 'package:testing2/Global/Colors/app_colors.dart';
import 'package:testing2/Global/Widget/global_widget.dart';
import 'package:testing2/services/DataSource/auth_api.dart';
import 'package:testing2/services/DataSource/uploaded_look_api.dart';

// OpenAI Service Class with Login Check
class OpenAIService {
  static const String _baseUrl = 'https://api.openai.com/v1/chat/completions';
  static final String _apiKey = String.fromEnvironment('API_KEY');

  static final String _loggedInPrompt = '''## IDENTITY
You are **Zuri**, India's AI fashion stylist - a knowledgeable best friend who gives gracefully honest, confidence-building advice. Be playful, supportive, and constructively critical without being hurtful. No unnecessary flattery - just sharp, actionable styling guidance that elevates looks.

## TARGET AUDIENCE
Indian women aged 13+, all body types, budgets (student to luxury), cities (tier 1-4). Covers traditional, modern, and fusion preferences across students, professionals, homemakers, and entrepreneurs.

## CORE STYLING APPROACH
Personalize recommendations based on:
- **Body shape** (apple, pear, hourglass, rectangle, inverted triangle)
- **Skin tone** (warm/cool/neutral undertones)
- **Digital closet** (prioritize existing items)
- **Lifestyle, budget & cultural preferences**

Body-positive philosophy: **flatter, never change**

## RESPONSE STYLE
- **Bold** key terms, *italics* for emphasis
- Lists with `-` for outfit components
- Strategic emojis (👗👔👠✨) max 3-4 per response
- Conversational yet comprehensive
- Adapt language to user preference

## EXPERTISE AREAS
- Indian fashion context (traditional/western/fusion)
- Climate considerations & regional styles
- Current trends & influencer references
- Budget-friendly mix-and-match solutions
- Occasion-appropriate styling

## ENGAGEMENT PATTERN
Always end with specific follow-ups:
- "Want to explore more [topic] looks?"
- "Should we dive into color coordination?"
- "Ready to restyle your existing pieces?"

// Add this to the END of both prompts (replace any existing response format instructions):

## RESPONSE FORMAT - CRITICAL
You MUST respond with ONLY valid JSON in this exact format. Do not include any text before or after the JSON:

{
  "originalResponse": "your complete fashion advice response here",
  "keyWords": ["item1", "item2", "item3", "item4"]
}

IMPORTANT: 
- Return ONLY the JSON object, no additional text
- Do not wrap in markdown code blocks
- Do not repeat the response twice
- keyWords should be 3-4 clothing items from your advice. This should not empty.

## BOUNDARIES
- **On-topic**: Fashion, styling, wardrobe, beauty (fashion-related)
- **Off-topic**: "Style questions only, darling! For everything else, try your group chat 💕"

## PLATFORM INTEGRATION
- Prioritize user's digital closet
- Consider Indian market availability/pricing
- Suggest affiliate products when genuinely needed

## KEY PRINCIPLES
1. Build confidence through actionable advice
2. Be gracefully honest - constructive, not hurtful
3. Prioritize user's existing wardrobe
4. Celebrate Indian fashion diversity
5. Make styling accessible for all budgets''';

  static final String _notLoggedInPrompt = '''## IDENTITY
You are **Zuri**, India's AI fashion stylist - a knowledgeable best friend who gives gracefully honest, confidence-building advice. Be playful, supportive, and constructively critical without being hurtful. No unnecessary flattery - just sharp, actionable styling guidance that elevates looks.

## TARGET AUDIENCE
Indian women aged 13+, all body types, budgets (student to luxury), cities (tier 1-4). Covers traditional, modern, and fusion preferences across students, professionals, homemakers, and entrepreneurs.

## CORE STYLING APPROACH
Personalize recommendations based on:
- **Body shape** (apple, pear, hourglass, rectangle, inverted triangle)
- **Skin tone** (warm/cool/neutral undertones)
- **Digital closet** (prioritize existing items)
- **Lifestyle, budget & cultural preferences**

Body-positive philosophy: **flatter, never change**

## RESPONSE STYLE
- **Bold** key terms, *italics* for emphasis
- Lists with `-` for outfit components
- Strategic emojis (👗👔👠✨) max 3-4 per response
- Conversational yet comprehensive
- Adapt language to user preference

## EXPERTISE AREAS
- Indian fashion context (traditional/western/fusion)
- Climate considerations & regional styles
- Current trends & influencer references
- Budget-friendly mix-and-match solutions
- Occasion-appropriate styling

// Add this to the END of both prompts (replace any existing response format instructions):

## RESPONSE FORMAT - CRITICAL
You MUST respond with ONLY valid JSON in this exact format. Do not include any text before or after the JSON:

{
  "originalResponse": "your complete fashion advice response here",
  "keyWords": ["item1", "item2", "item3", "item4"]
}

IMPORTANT: 
- Return ONLY the JSON object, no additional text
- Do not wrap in markdown code blocks
- Do not repeat the response twice
- keyWords should be 3-4 clothing items from your advice. This should not empty.

## BOUNDARIES
- **On-topic**: Fashion, styling, wardrobe, beauty (fashion-related)
- **Off-topic**: "Style questions only, darling! For everything else, try your group chat 💕"

## PLATFORM INTEGRATION
- Prioritize user's digital closet
- Consider Indian market availability/pricing
- Suggest affiliate products when genuinely needed

## FORCE LOGIN INTEGRATION- End message of evry responce
IMPORTANT: In EVERY response, end with this login prompt:
"Want to unlock your full styling potential? 🔓 Login first to access personalized features like your digital closet, body shape analysis, skin tone matching, and saved looks! Your complete styling journey awaits."

**[Scan & Discover]** context.goNamed('scan&discover')
**[Login]** context.goNamed('login')
Replace all engagement follow-ups with this login CTA when user is not logged in.

## KEY PRINCIPLES
1. Build confidence through actionable advice
2. Be gracefully honest - constructive, not hurtful
3. Prioritize user's existing wardrobe
4. Celebrate Indian fashion diversity
5. Make styling accessible for all budgets''';

  static String encodeImageToBase64(File imageFile) {
    try {
      List<int> imageBytes = imageFile.readAsBytesSync();
      return base64Encode(imageBytes);
    } catch (e) {
      Developer.log('Error encoding image to base64: $e');
      throw Exception('Failed to encode image');
    }
  }

  static Future<Map> sendMessage(
    List<Map<String, String>> messages, {
    String? customSystemPrompt,
  }) async {
    try {
      final bool _isLoggedIn = await AuthApiService.isLoggedIn();
      Developer.log(_isLoggedIn.toString());

      String finalSystemPrompt;
      if (_isLoggedIn) {
        finalSystemPrompt = _loggedInPrompt;
      } else {
        finalSystemPrompt = _notLoggedInPrompt;
      }

      final updatedMessages = [
        {'role': 'system', 'content': finalSystemPrompt},
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
          'max_tokens': 1500,
          'temperature': 0.8,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String aiResponse = data['choices'][0]['message']['content'];

        // FIX: Clean the response to extract only the JSON part
        String cleanedResponse = _cleanAIResponse(aiResponse);

        // Try to parse as JSON
        try {
          final jsonResponse = jsonDecode(cleanedResponse);
          if (jsonResponse is Map &&
              jsonResponse.containsKey('originalResponse')) {
            return jsonResponse;
          } else {
            // If parsed but doesn't have expected structure, wrap it
            return {'originalResponse': aiResponse, 'keyWords': []};
          }
        } catch (e) {
          // If not valid JSON, wrap the original response
          return {'originalResponse': aiResponse, 'keyWords': []};
        }
      } else {
        Developer.log(
          'OpenAI API Error: ${response.statusCode} - ${response.body}',
        );
        return {
          'originalResponse':
              "Sorry for the slip-up! Let's hit refresh and talk fashion!",
          'keyWords': [],
        };
      }
    } catch (e) {
      Developer.log('OpenAI Service Error: $e');
      return {
        'originalResponse':
            "Sorry for the slip-up! Let's hit refresh and talk fashion!",
        'keyWords': [],
      };
    }
  }

  static Future<Map> sendMessageWithImage(
    List<Map<String, dynamic>> messages, {
    String? customSystemPrompt,
  }) async {
    try {
      final bool _isLoggedIn = await AuthApiService.isLoggedIn();

      String finalSystemPrompt = _isLoggedIn
          ? _loggedInPrompt
          : _notLoggedInPrompt;

      // FIXED: Properly construct the messages array
      final updatedMessages = [
        {'role': 'system', 'content': finalSystemPrompt},
        ...messages,
      ];

      Developer.log(
        'Sending request to OpenAI with ${messages.length} messages',
      );

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-4o', // Make sure this model supports vision
          'messages': updatedMessages,
          'max_tokens': 1500, // Increased token limit
          'temperature': 0.7,
        }),
      );

      Developer.log('OpenAI Response Status: ${response.statusCode}');
      Developer.log('OpenAI Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Check if response contains choices
        if (data['choices'] == null || data['choices'].isEmpty) {
          throw Exception('No choices in OpenAI response');
        }

        String aiResponse = data['choices'][0]['message']['content'];
        Developer.log('AI Response: $aiResponse');

        // Clean and parse response
        String cleanedResponse = _cleanAIResponse(aiResponse);

        try {
          final jsonResponse = jsonDecode(cleanedResponse);
          if (jsonResponse is Map &&
              jsonResponse.containsKey('originalResponse')) {
            return jsonResponse;
          } else {
            return {'originalResponse': aiResponse, 'keyWords': []};
          }
        } catch (e) {
          Developer.log('JSON parsing error: $e');
          return {'originalResponse': aiResponse, 'keyWords': []};
        }
      } else {
        // FIXED: Better error handling
        final errorData = jsonDecode(response.body);
        String errorMessage = errorData['error']?['message'] ?? 'Unknown error';
        Developer.log(
          'OpenAI API Error: ${response.statusCode} - $errorMessage',
        );

        return {
          'originalResponse':
              "I'm having trouble analyzing this image right now. Could you describe what you're wearing instead? 😊",
          'keyWords': [],
        };
      }
    } catch (e) {
      Developer.log('OpenAI Service Error: $e');
      return {
        'originalResponse':
            "I'm having trouble analyzing this image right now. Could you describe what you're wearing instead? 😊",
        'keyWords': [],
      };
    }
  }

  // ADD this helper method to clean the AI response:
  static String _cleanAIResponse(String response) {
    // Remove any text before the first {
    int startIndex = response.indexOf('{');
    if (startIndex == -1) return response;

    // Find the last } to get complete JSON
    int endIndex = response.lastIndexOf('}');
    if (endIndex == -1 || endIndex <= startIndex) return response;

    // Extract only the JSON part
    return response.substring(startIndex, endIndex + 1);
  }
}

// ChatOverlayManager (unchanged)
class ChatOverlayManager extends StatefulWidget {
  final Widget child;
  final Map<String, String?> firstQuery;
  final bool? initiallyVisible;
  final Function(List<String>)? onKeywordsUpdate;

  const ChatOverlayManager({
    Key? key,
    required this.child,
    required this.firstQuery,
    this.initiallyVisible,
    this.onKeywordsUpdate,
  }) : super(key: key);

  @override
  State<ChatOverlayManager> createState() => _ChatOverlayManagerState();
}

class _ChatOverlayManagerState extends State<ChatOverlayManager> {
  late bool _isChatVisible;

  @override
  void initState() {
    super.initState();
    _isChatVisible = widget.initiallyVisible ?? true;
  }

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
            firstQuery: widget.firstQuery,
            isVisible: _isChatVisible,
            onClose: _closeChat,
            onSendMessage: (message) {
              Developer.log('Message sent: $message');
            },
            onKeywordsUpdate: widget.onKeywordsUpdate,
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
                    SizedBox(width: 8),
                    Text(
                      'Ask Zuri',
                      style: GoogleFonts.libreFranklin(
                        color: AppColors.titleTextColor,
                        fontWeight: FontWeight.w500,
                        fontSize: MediaQuery.of(context).textScaler.scale(16),
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
  final VoidCallback? onClose;
  final bool isVisible;
  final Map<String, String?> firstQuery;
  final Function(String)? onSendMessage;
  final Function(List<String>)? onKeywordsUpdate;

  const ChatPopupOverlay({
    Key? key,
    required this.firstQuery,
    this.onClose,
    this.isVisible = false,
    this.onSendMessage,
    this.onKeywordsUpdate,
  }) : super(key: key);

  @override
  State<ChatPopupOverlay> createState() => _ChatPopupOverlayState();
}

class _ChatPopupOverlayState extends State<ChatPopupOverlay>
    with TickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<ChatMessage> _messages = [];
  List<Map<String, dynamic>> _conversationHistory = [];
  bool _isTyping = false;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  File? _uploadedImage;
  final ImagePicker _picker = ImagePicker();
  List<String> _quickPrompts = [
    "How does this outfit look on me? Any styling tips?",
    "What accessories would go well with this look?",
    "Is this appropriate for a formal event?",
  ];
  int? _selectedPromptIndex;

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
            _sendFirstQuery(widget.firstQuery);
          });
        }
      }
    });
  }

  bool _validateImage(File imageFile) {
    try {
      // Check if file exists
      if (!imageFile.existsSync()) {
        showErrorSnackBar(context, 'Image file not found');
        return false;
      }

      // Check file extension
      String extension = imageFile.path.split('.').last.toLowerCase();
      if (!['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(extension)) {
        showErrorSnackBar(
          context,
          'Unsupported image format. Please use JPG, PNG, GIF, or WebP',
        );
        return false;
      }

      // Check file size (20MB limit)
      int fileSizeInBytes = imageFile.lengthSync();
      int fileSizeInMB = fileSizeInBytes ~/ (1024 * 1024);

      if (fileSizeInMB > 20) {
        showErrorSnackBar(
          context,
          'Image too large (${fileSizeInMB}MB). Please use an image smaller than 20MB',
        );
        return false;
      }

      return true;
    } catch (e) {
      showErrorSnackBar(context, 'Error validating image: $e');
      return false;
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      if (source == ImageSource.camera) {
        var status = await Permission.camera.request();
        if (!status.isGranted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Camera permission denied'),
              backgroundColor: AppColors.error,
            ),
          );
          return;
        }
      } else if (source == ImageSource.gallery) {
        var status = await Permission.photos.request();
        if (!status.isGranted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gallery permission denied'),
              backgroundColor: AppColors.error,
            ),
          );
          return;
        }
      }

      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 85, // Slightly compress to reduce size
        maxWidth: 1024, // Limit width to reduce size
        maxHeight: 1024, // Limit height to reduce size
      );

      if (pickedFile != null) {
        File imageFile = File(pickedFile.path);

        if (_validateImage(imageFile)) {
          setState(() {
            _uploadedImage = imageFile;
            _selectedPromptIndex = null;
          });
        }
      }
    } catch (e) {
      debugPrint('Error in _pickImage: $e');
      showErrorSnackBar(context, 'Error picking image: $e');
    }
  }

  void _sendFirstQuery(Map<String, String?> query) {
    if (query['text']?.trim().isEmpty ?? true) return;

    setState(() {
      _messages.add(
        ChatMessage(
          text: query['text'] ?? '',
          image: query['image'] != null ? File(query['image']!) : null,
          isUser: true,
          timestamp: DateTime.now(),
        ),
      );
      _isTyping = true;
    });

    _scrollToBottom();
    if (query['image'] == null) {
      _sendToGPT(query['text'] ?? '');
    } else {
      _sendImageToGPT(query['text'] ?? '', File(query['image']!));
    }
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
  // In the _sendToGPT method, replace the response handling section:

  void _sendToGPT(String message) async {
    Map<String, dynamic> textMessage = {'role': 'user', 'content': message};
    _conversationHistory.add(textMessage);

    try {
      List<Map<String, String>> textOnlyHistory = _conversationHistory
          .where((msg) => msg['content'] is String)
          .map(
            (msg) => {
              'role': msg['role'] as String,
              'content': msg['content'] as String,
            },
          )
          .toList();

      final response = await OpenAIService.sendMessage(textOnlyHistory);

      if (mounted) {
        setState(() {
          _isTyping = false;

          // FIX: Extract only the originalResponse for display
          String displayText;
          if (response is Map && response.containsKey('originalResponse')) {
            displayText = response['originalResponse'];
          } else {
            displayText = "Sorry, couldn't fetch the response!";
          }

          _messages.add(
            ChatMessage(
              text: displayText,
              isUser: false,
              timestamp: DateTime.now(),
            ),
          );
        });

        // Store assistant response in conversation history
        String conversationText = response is Map
            ? response['originalResponse'] ?? response.toString()
            : response.toString();

        _conversationHistory.add({
          'role': 'assistant',
          'content': conversationText,
        });

        // Handle keywords
        if (response is Map && response['keyWords'] != null) {
          List<String> keywords = List<String>.from(response['keyWords']);
          _sendKeywordsToProductPage(keywords);
        }
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isTyping = false;
          _messages.add(
            ChatMessage(
              text:
                  "Sorry for the slip-up! Let's hit refresh and talk fashion!",
              isUser: false,
              timestamp: DateTime.now(),
            ),
          );
        });
        _scrollToBottom();
      }
    }
  }

  void _sendImageToGPT(String message, File imageFile) async {
    try {
      // FIXED: Better image validation
      if (!imageFile.existsSync()) {
        throw Exception('Image file does not exist');
      }

      // FIXED: Check file size (OpenAI has limits)
      int fileSizeInBytes = imageFile.lengthSync();
      int fileSizeInMB = fileSizeInBytes ~/ (1024 * 1024);

      if (fileSizeInMB > 20) {
        // OpenAI limit is 20MB
        throw Exception(
          'Image file is too large (${fileSizeInMB}MB). Please use a smaller image.',
        );
      }

      String base64Image = OpenAIService.encodeImageToBase64(imageFile);
      Developer.log(
        'Image encoded to base64, size: ${base64Image.length} characters',
      );

      // FIXED: Properly format the message with image
      Map<String, dynamic> messageWithImage = {
        'role': 'user',
        'content': [
          {
            'type': 'text',
            'text': message.isEmpty
                ? 'Analyze this outfit and give me styling advice'
                : message,
          },
          {
            'type': 'image_url',
            'image_url': {
              'url': 'data:image/jpeg;base64,$base64Image',
              'detail': 'high', // Use 'high' for better analysis
            },
          },
        ],
      };

      List<Map<String, dynamic>> conversationWithImage = [
        // Don't include previous text-only messages when sending image
        messageWithImage,
      ];

      Developer.log('Sending image message to OpenAI');

      final response = await OpenAIService.sendMessageWithImage(
        conversationWithImage,
      );

      if (mounted) {
        setState(() {
          _isTyping = false;

          String displayText;
          if (response is Map && response.containsKey('originalResponse')) {
            displayText = response['originalResponse'];
          } else {
            displayText =
                "I'm having trouble analyzing this image. Could you describe what you're wearing?";
          }

          _messages.add(
            ChatMessage(
              text: displayText,
              isUser: false,
              timestamp: DateTime.now(),
            ),
          );
        });

        // Handle keywords if available
        if (response is Map && response['keyWords'] != null) {
          List<String> keywords = List<String>.from(response['keyWords']);
          _sendKeywordsToProductPage(keywords);
        }
      }

      // Store the image message in history (simplified for image context)
      _conversationHistory.add({
        'role': 'user',
        'content': 'User shared an image and asked: $message',
      });

      // Store assistant response
      String conversationText = response is Map
          ? response['originalResponse'] ?? response.toString()
          : response.toString();

      _conversationHistory.add({
        'role': 'assistant',
        'content': conversationText,
      });

      _scrollToBottom();
    } catch (e) {
      Developer.log('Error in _sendImageToGPT: $e');
      if (mounted) {
        setState(() {
          _isTyping = false;
          _messages.add(
            ChatMessage(
              text: e.toString().contains('too large')
                  ? "The image is too large. Please try with a smaller image (under 20MB)."
                  : "I'm having trouble analyzing this image. Could you describe what you're wearing instead? 😊",
              isUser: false,
              timestamp: DateTime.now(),
            ),
          );
        });
        _scrollToBottom();
      }
    }
  }
  // Remove the unused _cleanResponseText method as it's no longer needed
  // void _sendToGPT(String message) async {
  //   _conversationHistory.add({'role': 'user', 'content': message});

  //   try {
  //     final response = await OpenAIService.sendMessage(_conversationHistory);
  //     Developer.log(response.toString());
  //     if (mounted) {
  //       setState(() {
  //         _isTyping = false;
  //         String displayText = response is Map
  //             ? response['originalResponse'] ?? response.toString()
  //             : response.toString();
  //         _messages.add(
  //           ChatMessage(
  //             text: displayText,
  //             isUser: false,
  //             timestamp: DateTime.now(),
  //           ),
  //         );
  //       });
  //       if (response['keyWords'] != null) {
  //         List<String> keywords = List<String>.from(response['keyWords']);
  //         _sendKeywordsToProductPage(keywords);
  //       }

  //       // Add original response to conversation history
  //       String conversationText;
  //       if (response is Map) {
  //         conversationText =
  //             response['originalResponse'] ?? response.toString();
  //       } else {
  //         conversationText = response.toString();
  //       }
  //       _conversationHistory.add({
  //         'role': 'assistant',
  //         'content': conversationText,
  //       });
  //       _scrollToBottom();
  //     }
  //   } catch (e) {
  //     if (mounted) {
  //       setState(() {
  //         _isTyping = false;
  //         _messages.add(
  //           ChatMessage(
  //             text:
  //                 "Sorry for the slip-up! Let’s hit refresh and talk fashion!",
  //             isUser: false,
  //             timestamp: DateTime.now(),
  //           ),
  //         );
  //       });
  //       _scrollToBottom();
  //     }
  //   }
  // }

  // void _sendImageToGPT(String message, File imageFile) async {
  //   try {
  //     String base64Image = OpenAIService.encodeImageToBase64(imageFile);

  //     // Create message with image
  //     Map<String, dynamic> messageWithImage = {
  //       'role': 'user',
  //       'content': [
  //         {'type': 'text', 'text': message},
  //         {
  //           'type': 'image_url',
  //           'image_url': {
  //             'url': 'data:image/jpeg;base64,$base64Image',
  //             'detail': 'high',
  //           },
  //         },
  //       ],
  //     };

  //     List<Map<String, dynamic>> conversationWithImage = [
  //       ..._conversationHistory.map(
  //         (msg) => {'role': msg['role'], 'content': msg['content']},
  //       ),
  //       messageWithImage,
  //     ];

  //     final response = await OpenAIService.sendMessageWithImage(
  //       conversationWithImage,
  //     );

  //     if (mounted) {
  //       setState(() {
  //         _isTyping = false;
  //         String displayText = response is Map
  //             ? response['originalResponse'] ?? response.toString()
  //             : response.toString();
  //         _messages.add(
  //           ChatMessage(
  //             text: displayText,
  //             image: imageFile,
  //             isUser: false,
  //             timestamp: DateTime.now(),
  //           ),
  //         );
  //       });

  //       if (response['keyWords'] != null) {
  //         List<String> keywords = List<String>.from(response['keyWords']);
  //         _sendKeywordsToProductPage(keywords);
  //       }

  //       // Add original response to conversation history
  //       String conversationText;
  //       if (response is Map) {
  //         conversationText =
  //             response['originalResponse'] ?? response.toString();
  //       } else {
  //         conversationText = response.toString();
  //       }
  //       _conversationHistory.add({
  //         'role': 'assistant',
  //         'content': conversationText,
  //       });
  //       _scrollToBottom();
  //     }
  //   } catch (e) {
  //     if (mounted) {
  //       setState(() {
  //         _isTyping = false;
  //         _messages.add(
  //           ChatMessage(
  //             text:
  //                 "Sorry for the slip-up! Let's hit refresh and talk fashion!",
  //             isUser: false,
  //             timestamp: DateTime.now(),
  //           ),
  //         );
  //       });
  //       _scrollToBottom();
  //     }
  //   }
  // }

  void _sendKeywordsToProductPage(List<String> keywords) async {
    try {
      Developer.log('Sending keywords to API: $keywords');
      if (widget.onKeywordsUpdate != null) {
        widget.onKeywordsUpdate!(keywords);
      }
    } catch (e) {
      Developer.log('Error sending keywords to API: $e');
    }
  }

  // SOLUTION 1: Upload in background (RECOMMENDED)
  void _sendImageWithPrompt(String prompt) async {
    if (_uploadedImage == null) return;

    // Store reference before clearing
    final imageToUpload = _uploadedImage!;

    // Add user message with image
    setState(() {
      _messages.add(
        ChatMessage(
          text: prompt,
          isUser: true,
          timestamp: DateTime.now(),
          image: _uploadedImage,
        ),
      );
      _isTyping = true;
    });

    _scrollToBottom();

    // Send to GPT immediately for fast response
    _sendImageToGPT(prompt, _uploadedImage!);

    // Upload in background without waiting
    _uploadImageInBackground(imageToUpload, prompt);

    // Clear the uploaded image after sending
    setState(() {
      _uploadedImage = null;
      _selectedPromptIndex = null;
    });
  }

  // Background upload method
  void _uploadImageInBackground(File imageFile, String prompt) {
    // Fire and forget - don't await
    UploadedLooksService.uploadLook(imageFile: imageFile, userQuery: prompt)
        .then((_) {
          Developer.log("Success to upload this picture");
        })
        .catchError((e) {
          Developer.log("Failed to upload this picture: $e");
        });
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
    if (!widget.isVisible) return SizedBox.shrink();

    return Positioned.fill(
      child: Material(
        color: Colors.black26,
        child: SafeArea(
          // Add SafeArea here
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
                    // Change this height calculation
                    height:
                        MediaQuery.of(context).size.height * 0.70 -
                        MediaQuery.of(context).viewInsets.bottom,
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
                          padding: const EdgeInsets.only(
                            left: 20.0,
                            right: 20.0,
                          ),
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
                          fontSize: MediaQuery.of(context).textScaler.scale(18),
                          color: Colors.black,
                        ),
                        children: [
                          const TextSpan(text: 'Ask '),
                          TextSpan(
                            text: 'Zuri',
                            style: GoogleFonts.libreFranklin(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                              fontSize: MediaQuery.of(
                                context,
                              ).textScaler.scale(18),
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
          SizedBox(height: MediaQuery.of(context).size.height * 0.009153318),
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

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(right: 330),
      child: LoadingIndicator(
        indicatorType: Indicator.ballPulseSync,
        colors: [AppColors.textPrimary],
        strokeWidth: 2,
      ),
    );
  }

  Widget _buildInputArea({required double dh}) {
    return Column(
      children: [
        // Image preview and quick prompts
        if (_uploadedImage != null) ...[
          Container(
            margin: EdgeInsets.only(bottom: 12),
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        _uploadedImage!,
                        width: MediaQuery.of(context).size.width * 0.1492537,
                        height: 60,
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Choose a quick prompt or type your own:',
                        style: GoogleFonts.libreFranklin(
                          fontSize: MediaQuery.of(context).textScaler.scale(14),
                          fontWeight: FontWeight.w500,
                          color: AppColors.titleTextColor,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _uploadedImage = null;
                          _selectedPromptIndex = null;
                        });
                      },
                      icon: Icon(
                        Icons.close,
                        size: 20,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.013729977,
                ),
                // Quick prompts
                ...List.generate(_quickPrompts.length, (index) {
                  return Container(
                    margin: EdgeInsets.only(bottom: 8),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedPromptIndex = index;
                        });
                        // Delay to allow UI to update before hiding preview
                        Future.delayed(Duration(milliseconds: 100), () {
                          setState(() {
                            _uploadedImage = null;
                          });
                        });
                        _sendImageWithPrompt(_quickPrompts[index]);
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: _selectedPromptIndex == index
                              ? AppColors.textPrimary
                              : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _selectedPromptIndex == index
                                ? AppColors.textPrimary
                                : Colors.grey[300]!,
                          ),
                        ),
                        child: Text(
                          _quickPrompts[index],
                          style: GoogleFonts.libreFranklin(
                            fontSize: 13,
                            color: _selectedPromptIndex == index
                                ? Colors.white
                                : AppColors.titleTextColor,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ],

        // Regular input field
        Container(
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
                    _showPicker();
                  },
                  child: Container(
                    width: 16,
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
                      hintText: _uploadedImage != null
                          ? 'Ask about this image'
                          : 'Ask Follow up question',
                      hintStyle: GoogleFonts.libreFranklin(
                        fontSize: MediaQuery.of(context).textScaler.scale(16),
                        color: AppColors.titleTextColor,
                      ),
                    ),
                    style: GoogleFonts.libreFranklin(
                      fontWeight: FontWeight.w500,
                      fontSize: MediaQuery.of(context).textScaler.scale(16),
                      color: Colors.black,
                    ),
                    onChanged: (value) {
                      setState(() {});
                    },
                    onSubmitted: (value) {
                      if (value.trim().isNotEmpty) {
                        if (_uploadedImage != null) {
                          _sendImageWithPrompt(value.trim());
                          _textController.clear();
                        } else {
                          _sendMessage();
                        }
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
                      if (_uploadedImage != null) {
                        _sendImageWithPrompt(_textController.text.trim());
                        _textController.clear();
                      } else {
                        _sendMessage();
                      }
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
        ),
      ],
    );
  }

  void _showPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Container(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Select Image Source',
                  style: GoogleFonts.libreFranklin(
                    fontSize: MediaQuery.of(context).textScaler.scale(18),
                    fontWeight: FontWeight.w600,
                    color: AppColors.titleTextColor,
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.022883295,
                ),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                          _pickImage(ImageSource.gallery);
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.photo_library,
                                size: 40,
                                color: AppColors.textPrimary,
                              ),
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height *
                                    0.009153318,
                              ),
                              Text(
                                'Gallery',
                                style: GoogleFonts.libreFranklin(
                                  fontSize: MediaQuery.of(
                                    context,
                                  ).textScaler.scale(16),
                                  color: AppColors.titleTextColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                          _pickImage(ImageSource.camera);
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.camera_alt,
                                size: 40,
                                color: AppColors.textPrimary,
                              ),
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height *
                                    0.009153318,
                              ),
                              Text(
                                'Camera',
                                style: GoogleFonts.libreFranklin(
                                  fontSize: MediaQuery.of(
                                    context,
                                  ).textScaler.scale(16),
                                  color: AppColors.titleTextColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.022883295,
                ),
              ],
            ),
          ),
        );
      },
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (message.image != null) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        message.image!,
                        width: 150,
                        height: 150,
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.009153318,
                    ),
                  ],
                  message.isUser
                      ? Text(
                          message.text,
                          style: GoogleFonts.libreFranklin(
                            fontSize: 15.21,
                            color: AppColors.titleTextColor,
                          ),
                        )
                      : MarkdownBody(
                          data: message.text,
                          styleSheet: MarkdownStyleSheet(
                            p: GoogleFonts.libreFranklin(
                              fontSize: MediaQuery.of(
                                context,
                              ).textScaler.scale(14),
                              color: Colors.black,
                              height: 1.4,
                            ),
                            strong: GoogleFonts.libreFranklin(
                              fontSize: MediaQuery.of(
                                context,
                              ).textScaler.scale(14),
                              color: Colors.black,
                              height: 1.4,
                              fontWeight: FontWeight.bold,
                            ),
                            listBullet: GoogleFonts.libreFranklin(
                              fontSize: MediaQuery.of(
                                context,
                              ).textScaler.scale(14),
                              color: Colors.black,
                              height: 1.4,
                            ),
                          ),
                        ),
                ],
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
  final File? image; // Add this field

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.image, // Add this parameter
  });
}
