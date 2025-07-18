import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:testing2/Global/Colors/app_colors.dart';
import 'package:testing2/Pages/Loading/loading_page.dart';

// Model class for chat history item
class ChatHistoryItem {
  final String id;
  final String message;
  final String timeAgo;
  final int dayCount;

  ChatHistoryItem({
    required this.id,
    required this.message,
    required this.timeAgo,
    required this.dayCount,
  });

  // Factory constructor to create from JSON (for API integration)
  factory ChatHistoryItem.fromJson(Map<String, dynamic> json) {
    return ChatHistoryItem(
      id: json['id'] ?? '',
      message: json['message'] ?? '',
      timeAgo: json['timeAgo'] ?? '',
      dayCount: json['dayCount'] ?? 0,
    );
  }
}

class ChatHistoryScreen extends StatefulWidget {
  const ChatHistoryScreen({Key? key}) : super(key: key);

  @override
  State<ChatHistoryScreen> createState() => _ChatHistoryScreenState();
}

class _ChatHistoryScreenState extends State<ChatHistoryScreen> {
  // State variables for managing API call states
  bool _isLoading = false;
  bool _hasError = false;
  List<ChatHistoryItem> _chatHistory = [];
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    // Fetch chat history when screen loads
    _fetchChatHistory();
  }

  // Simulate API call with dummy data
  Future<void> _fetchChatHistory() async {
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });

      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      // Dummy API response - Replace this with your actual API call
      List<Map<String, dynamic>> dummyApiResponse = [
        {
          'id': '1',
          'message': 'Give me some suggestions for a pink dress',
          'timeAgo': 'Today',
          'dayCount': 0,
        },
        {
          'id': '2',
          'message': 'Give me some suggestions for a pink dress',
          'timeAgo': '1 day',
          'dayCount': 1,
        },
        {
          'id': '3',
          'message': 'Give me some suggestions for a pink dress',
          'timeAgo': '3 days',
          'dayCount': 3,
        },
        {
          'id': '4',
          'message': 'Give me some suggestions for a pink dress',
          'timeAgo': '5 days',
          'dayCount': 5,
        },
        {
          'id': '5',
          'message': 'Give me some suggestions for a pink dress',
          'timeAgo': '6 days',
          'dayCount': 6,
        },
        {
          'id': '6',
          'message': 'Give me some suggestions for a pink dress',
          'timeAgo': '7 days',
          'dayCount': 7,
        },
      ];

      // Uncomment below line to test empty state
      // dummyApiResponse = [];

      // Uncomment below line to test error state
      // throw Exception('Failed to load chat history');

      // Convert API response to ChatHistoryItem objects
      List<ChatHistoryItem> chatItems = dummyApiResponse
          .map((item) => ChatHistoryItem.fromJson(item))
          .toList();

      setState(() {
        _chatHistory = chatItems;
        _isLoading = false;
      });
    } catch (e) {
      // Handle API errors
      setState(() {
        _hasError = true;
        _isLoading = false;
        _errorMessage = 'Failed to load chat history. Please try again.';
      });
    }
  }

  // Refresh function for pull-to-refresh
  Future<void> _refreshChatHistory() async {
    await _fetchChatHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  // Header with back button, title and subtitle
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(bottom: 16, left: 16, right: 16, top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back button and title row
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.0049751244,
                  height: MediaQuery.of(context).size.height * 0.0274599,
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.arrow_back_ios,
                    size: 18,
                    color: Color(0xFF141B34),
                  ),
                ),
              ),
              SizedBox(width: 12),
              Text(
                'History',
                style: GoogleFonts.libreFranklin(
                  fontWeight: FontWeight.w600,
                  height: 2.0,
                  fontSize: MediaQuery.of(context).textScaler.scale(18),
                  color: AppColors.titleTextColor,
                  letterSpacing: -0.02 * 18,
                ),
              ),
            ],
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.013729977),
          // Subtitle aligned with title
          Padding(
            padding: EdgeInsets.only(
              left: 36,
            ), // 24 (back button) + 12 (spacing)
            child: Text(
              "While I'll cherish our chats forever, I can save them for only 30 days 💕\nSo please keep screenshots of our flirty engages for future reference! 💋",
              style: GoogleFonts.libreFranklin(
                fontWeight: FontWeight.w600,
                fontSize: MediaQuery.of(context).textScaler.scale(10),
                height: 1.4,
                color: AppColors.subTitleTextColor,
                letterSpacing: -0.01 * 10,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Main body content with different states
  Widget _buildBody() {
    if (_isLoading) {
      return _buildLoadingState();
    } else if (_hasError) {
      return _buildErrorState();
    } else if (_chatHistory.isEmpty) {
      return _buildEmptyState();
    } else {
      return _buildChatHistoryList();
    }
  }

  // Loading state
  Widget _buildLoadingState() {
    return LoadingPage();
  }

  // Error state
  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: MediaQuery.of(context).size.width * 0.199,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.textPrimary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(40),
              ),
              child: Icon(
                Icons.error_outline,
                size: 40,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.0274599),
            Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: GoogleFonts.libreFranklin(
                fontWeight: FontWeight.w600,
                fontSize: MediaQuery.of(context).textScaler.scale(16),
                color: AppColors.subTitleTextColor,
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.018306636),
            ElevatedButton(
              onPressed: _fetchChatHistory,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.textPrimary,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Try Again',
                style: GoogleFonts.libreFranklin(
                  fontWeight: FontWeight.w600,
                  fontSize: MediaQuery.of(context).textScaler.scale(14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Empty state
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: MediaQuery.of(context).size.height * 0.0137299770,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.textPrimary.withOpacity(0.1),
                    const Color(0xFFFBC8CF).withOpacity(0.3),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(60),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(
                    Icons.chat_bubble_outline_rounded,
                    size: 50,
                    color: AppColors.textPrimary,
                  ),
                  Positioned(
                    top: 20,
                    right: 25,
                    child: Icon(
                      Icons.auto_awesome,
                      size: 16,
                      color: AppColors.textPrimary.withOpacity(0.6),
                    ),
                  ),
                  Positioned(
                    bottom: 25,
                    left: 20,
                    child: Icon(
                      Icons.auto_awesome,
                      size: 12,
                      color: AppColors.textPrimary.withOpacity(0.4),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.036613272),
            Text(
              'No Chat History Yet',
              textAlign: TextAlign.center,
              style: GoogleFonts.libreFranklin(
                fontWeight: FontWeight.w600,
                fontSize: MediaQuery.of(context).textScaler.scale(24),
                color: Colors.black,
                letterSpacing: -0.4,
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.018306636),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: GoogleFonts.libreFranklin(
                  fontWeight: FontWeight.w500,
                  fontSize: MediaQuery.of(context).textScaler.scale(16),
                  height: 1.4,
                  color: AppColors.subTitleTextColor,
                ),
                children: [
                  TextSpan(text: 'Start a conversation with '),
                  TextSpan(
                    text: 'Zuri ',
                    style: GoogleFonts.libreFranklin(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextSpan(text: 'to see your\nchat history here.'),
                ],
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.036613272),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.textPrimary,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Start Chatting',
                style: GoogleFonts.libreFranklin(
                  fontWeight: FontWeight.w600,
                  fontSize: MediaQuery.of(context).textScaler.scale(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Chat history list
  Widget _buildChatHistoryList() {
    return RefreshIndicator(
      onRefresh: _refreshChatHistory,
      color: AppColors.textPrimary,
      child: ListView.separated(
        padding: EdgeInsets.zero,
        itemCount: _chatHistory.length,
        separatorBuilder: (context, index) => Container(
          height: 0.5,
          color: const Color(0xFFE5E7EB),
          margin: const EdgeInsets.only(left: 16),
        ),
        itemBuilder: (context, index) {
          return _buildChatHistoryItem(_chatHistory[index]);
        },
      ),
    );
  }

  // Individual chat history item matching the design exactly
  Widget _buildChatHistoryItem(ChatHistoryItem item) {
    return GestureDetector(
      onTap: () {
        // Handle chat item tap - navigate to chat
        print('Navigate to chat: ${item.id}');
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.only(bottom: 16, left: 16, right: 16, top: 16),
        color: Colors.white,
        child: Row(
          children: [
            // Main content area
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Chat message
                  Text(
                    item.message,
                    style: GoogleFonts.libreFranklin(
                      fontWeight: FontWeight.w600,
                      fontSize: MediaQuery.of(context).textScaler.scale(14),
                      color: AppColors.titleTextColor,
                      height: 1.6,
                      letterSpacing: -0.01 * 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.009153318,
                  ),
                  // Action row with time, edit, delete icons
                  Row(
                    children: [
                      // Time with clock icon
                      Icon(
                        Icons.access_time_outlined,
                        size: 14,
                        color: AppColors.subTitleTextColor,
                      ),
                      SizedBox(width: 4),
                      Text(
                        item.timeAgo,
                        style: GoogleFonts.libreFranklin(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                          height: 1.4,
                          letterSpacing: -0.01 * 12,
                          color: AppColors.subTitleTextColor,
                        ),
                      ),
                      SizedBox(width: 16),
                      // Edit button
                      GestureDetector(
                        onTap: () => _editChatHistory(item),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          child: Icon(
                            Icons.edit_outlined,
                            size: 16,
                            color: const Color(0xFF9CA3AF),
                          ),
                        ),
                      ),
                      SizedBox(width: 14),
                      // Delete button
                      GestureDetector(
                        onTap: () => _deleteChatHistory(item),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          child: Icon(
                            Icons.delete_outline,
                            size: 14,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: 12),
            // Right arrow
            Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: AppColors.textPrimary,
            ),
          ],
        ),
      ),
    );
  }

  // Handle edit chat history
  void _editChatHistory(ChatHistoryItem item) {
    print('Edit chat: ${item.id}');
    // TODO: Implement edit functionality
    // You can navigate to edit screen or show dialog here
  }

  // Handle delete chat history
  void _deleteChatHistory(ChatHistoryItem item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Text(
            'Delete Chat',
            style: GoogleFonts.libreFranklin(
              fontWeight: FontWeight.w600,
              fontSize: MediaQuery.of(context).textScaler.scale(18),
              color: Colors.black,
            ),
          ),
          content: Text(
            'Are you sure you want to delete this chat history?',
            style: GoogleFonts.libreFranklin(
              fontSize: MediaQuery.of(context).textScaler.scale(14),
              color: AppColors.subTitleTextColor,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: GoogleFonts.libreFranklin(
                  fontWeight: FontWeight.w600,
                  fontSize: MediaQuery.of(context).textScaler.scale(14),
                  color: AppColors.subTitleTextColor,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                // TODO: Implement actual delete API call
                setState(() {
                  _chatHistory.removeWhere((chat) => chat.id == item.id);
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Chat deleted successfully',
                      style: GoogleFonts.libreFranklin(),
                    ),
                    backgroundColor: AppColors.textPrimary,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                );
              },
              child: Text(
                'Delete',
                style: GoogleFonts.libreFranklin(
                  fontWeight: FontWeight.w600,
                  fontSize: MediaQuery.of(context).textScaler.scale(14),
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
