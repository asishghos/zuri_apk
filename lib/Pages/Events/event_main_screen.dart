import 'dart:developer' as Developer;

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
// import 'package:calendar_timeline/calendar_timeline.dart';
import 'package:testing2/Global/Colors/app_colors.dart';
import 'package:testing2/Global/Function/global_function.dart';
import 'package:testing2/Global/Widget/global_dialogbox.dart';
import 'package:testing2/Global/Widget/global_widget.dart';
import 'package:testing2/Pages/Events/scrollable_calendar_widget.dart';
import 'package:testing2/Pages/Loading/loading_page.dart';
import 'package:testing2/services/Class/event_model.dart';
import 'package:testing2/services/DataSource/auth_api.dart';
import 'package:testing2/services/DataSource/event_api_service.dart';
import 'event_details_screen.dart';
import 'add_or_edit_event_overlay.dart';
import 'multiday_events_screen.dart';

class CalendarEventsPage extends StatefulWidget {
  final String? eventId; // Optional eventId passed via route
  final String? dayEventId; // Optional dayEventId for multi-day events
  final bool?
  openDayEventDetails; // Optional flag to open specific day event details
  CalendarEventsPage({
    super.key,
    this.eventId,
    this.dayEventId,
    this.openDayEventDetails,
  });

  @override
  State<CalendarEventsPage> createState() => _CalendarEventsPageState();
}

class _CalendarEventsPageState extends State<CalendarEventsPage> {
  String username = '';
  SharedPreferences? prefs = null;
  List<Event> eventsList = [];
  bool isCalendarExpanded = false;
  DateTime selectedDay = DateTime.now();
  DateTime focusedDay = DateTime.now();
  CalendarFormat calendarFormat = CalendarFormat.month;
  final Map<DateTime, List<String>> sampleEvents = {
    DateTime.utc(2024, 10, 30): ['National Event 1'],
    DateTime.utc(2024, 11, 2): ['National Event 2'],
    DateTime.utc(2024, 11, 15): ['Sample Meeting'],
    DateTime.utc(2024, 11, 25): ['Holiday Event'],
  };

  bool _isLoggedIn = true; // Add this state variable
  bool _isloading = true; // Add loading state

  // Replace the _checkLoginStatus method:
  void _checkLoginStatus() async {
    setState(() {
      _isloading = true;
    });
    try {
      final isLoggedIn = await AuthApiService.isLoggedIn();
      setState(() {
        _isLoggedIn = isLoggedIn;
      });

      // Only fetch events if logged in
      if (isLoggedIn) {
        await _fetchUserEvents();
      }
    } catch (e) {
      setState(() {
        _isLoggedIn = false;
      });
    } finally {
      setState(() {
        _isloading = false;
      });
    }
  }

  // Replace the initState method:
  @override
  void initState() {
    super.initState();
    initPrefs();
    _checkLoginStatus();
    // Check for eventId and handle navigation to details screens
    if (widget.eventId != null) {
      _handleEventDetailsNavigation();
    }
  }

  Future<void> initPrefs() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {});
  }

  Future<void> _inits() async {}
  Future<void> _fetchUserEvents() async {
    setState(() => _isloading = true);
    try {
      final result = await EventApiService.getUpcomingEvents();
      setState(() {
        eventsList = result.message == "Upcoming events fetched successfully"
            ? result.events
            : [];
        if (eventsList.isNotEmpty) {
          showSuccessSnackBar(context, result.message);
        }
      });
    } catch (e) {
      showSuccessSnackBar(
        context,
        'Error occurred while fetching events. ${e}',
      );
      setState(() {
        eventsList = [];
      });
    } finally {
      setState(() => _isloading = false);
    }
  }

  Future<MultiDayEventCollectionResponse> fetchMultiDayEvent(
    BuildContext context,
    String eventId,
  ) async {
    try {
      final data = await EventApiService.getMultiDayEventCollection(
        eventId: eventId,
      );
      // Developer.log(data.toString());
      Developer.log("Multi-day event collection fetched successfully");
      return data;
    } catch (e) {
      Developer.log("Failed to fetch multi-day event: $e");
      showErrorSnackBar(context, "Error is ${e}");
      throw Exception("Failed to fetch multi-day event: $e");
    }
  }

  Future<EventResponse> fetchSingleDayEvent({required String eventId}) async {
    try {
      final data = await EventApiService.getSingleDayEventDetails(
        eventId: eventId,
      );
      // Developer.log(data.toString());
      Developer.log("Day event details fetched successfully");
      return data;
    } catch (e) {
      Developer.log("Failed to fetch multi-day event: $e");
      showErrorSnackBar(context, "Error is ${e}");
      throw Exception("Failed to fetch multi-day event: $e");
    }
  }

  Future<void> _refreshEventData() async {
    try {
      await _fetchUserEvents();
      Developer.log("✅ Page refreshed successfully");
    } catch (e) {
      Developer.log("❌ Error refreshing page: $e");
      showErrorSnackBar(context, "Failed to refresh data");
    }
  }

  // Handle navigation based on eventId and dayEventId
  Future<void> _handleEventDetailsNavigation() async {
    if (widget.eventId == null) return;

    setState(() => _isloading = true);
    try {
      if (widget.dayEventId != null) {
        MultiDayEventCollectionResponse response = await fetchMultiDayEvent(
          context,
          widget.eventId!,
        );
        // Pass dayEventId and openDayEventDetails flag to MultiDayEventsPage
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => MultiDayEventsPage(
              result: response,
              openDayEventDetails: true,
              dayEventId: widget.dayEventId,
            ),
          ),
        );
      } else {
        EventResponse responce = await fetchSingleDayEvent(
          eventId: widget.eventId!,
        );
        _showEventDetails(responce);
      }
    } catch (e) {
      Developer.log("❌ Error fetching event details: $e");
      showErrorSnackBar(context, "Failed to load event details.");
    } finally {
      setState(() => _isloading = false);
    }
  }

  List<String> _getEventsForDay(DateTime day) {
    return sampleEvents[DateTime.utc(day.year, day.month, day.day)] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    final double dh = MediaQuery.of(context).size.height;
    final double dw = MediaQuery.of(context).size.width;

    if (_isloading) {
      return LoadingPage();
    }
    return SafeArea(
      child: Stack(
        children: [
          Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: eventsList.isEmpty
                      ? _buildEmptyEventsUI(dh: dh, dw: dw)
                      : _buildEventsListUI(dh: dh),
                ),
              ),
            ],
          ),
          if (!_isLoggedIn)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: GlobalDialogBox(
                  title: "Please Sign Up to Continue",
                  description: "kqsxk sxkjbas kjhsaxjk",
                  buttonNeed: true,
                  buttonText: "Click to Scan and Sign Up",
                  onTap: () {
                    context.goNamed('scan&discover');
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Events',
            style: GoogleFonts.libreFranklin(
              color: AppColors.titleTextColor,
              fontSize: MediaQuery.of(context).textScaler.scale(18),
              fontWeight: FontWeight.w600,
            ),
          ),
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: const Color(0xFFFFEBEB),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFD34169), width: 0.63),
            ),
            child: Stack(
              children: [
                const Center(
                  child: HugeIcon(
                    icon: HugeIcons.strokeRoundedNotification01,
                    color: AppColors.textPrimary,
                    size: 28,
                  ),
                ),
                // Positioned(
                //   top: 5,
                //   right: 5,
                //   child: Container(
                //     width: 16,
                //     height: MediaQuery.of(context).size.height * 0.018306636,
                //     decoration: const BoxDecoration(
                //       color: AppColors.titleTextColor,
                //       shape: BoxShape.circle,
                //     ),
                //     child: Center(
                //       child: Text(
                //         '4',
                //         style: GoogleFonts.libreFranklin(
                //           color: Colors.white,
                //           fontSize: MediaQuery.of(context).textScaler.scale(8),
                //         ),
                //       ),
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyEventsUI({required double dh, required double dw}) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: AppColors.textPrimary),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Got an Event? Let's make it Fashion ✨.",
                style: GoogleFonts.libreFranklin(
                  fontSize: 12,
                  color: const Color(0xFF394050),
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.018306636,
              ),
              Text(
                'Hello, ${prefs?.getString("userFullName") ?? "User"}',
                style: GoogleFonts.libreFranklin(
                  fontSize: MediaQuery.of(context).textScaler.scale(20),
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.018306636,
              ),
              Text(
                'Whether it\'s your bestie\'s wedding 💅🏻 or a long-overdue vacation 🏝, Zuri\'s Events page helps you plan every "what to wear? 💭 moment" like a pro. 💃',
                style: GoogleFonts.libreFranklin(
                  fontSize: MediaQuery.of(context).textScaler.scale(14),
                  fontWeight: FontWeight.w500,
                  color: AppColors.titleTextColor,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.022883295),
        _buildCalendarWidget(dh: dh),
        SizedBox(height: MediaQuery.of(context).size.height * 0.022883295),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: AppColors.textPrimary),
          ),
          child: Column(
            children: [
              Text(
                "Tap that " +
                    " and let Zuri style your life's moments — one fabulous plan at a time.",
                textAlign: TextAlign.center,
                style: GoogleFonts.libreFranklin(
                  fontSize: MediaQuery.of(context).textScaler.scale(14),
                  color: Color(0xFF394050),
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.0343249),
              HugeIcon(
                icon: HugeIcons.strokeRoundedCalendarAdd01,
                size: 100.0,
                color: AppColors.textPrimary,
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.0274599),
              GlobalPinkButton(
                text: "Add Events",
                onPressed: _showAddEventOverlay,
                fontSize: 13.45,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEventsListUI({required double dh}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GlobalSearchBar(),
        SizedBox(height: MediaQuery.of(context).size.height * 0.022883295),
        _buildEventsGreetingCard(),
        SizedBox(height: MediaQuery.of(context).size.height * 0.022883295),
        _buildCalendarWidget(dh: dh),
        SizedBox(height: MediaQuery.of(context).size.height * 0.013729977),
        _buildUpcomingEventsSection(),
      ],
    );
  }

  Widget _buildEventsGreetingCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: AppColors.textPrimary, width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello, ${prefs?.getString("userFullName") ?? "User"}',
                  style: GoogleFonts.libreFranklin(
                    fontSize: MediaQuery.of(context).textScaler.scale(14),
                    color: Color(0xFF394050),
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.009153318,
                ),
                Text(
                  "Got an Event? Let's Make It Fashion",
                  style: GoogleFonts.libreFranklin(
                    fontSize: MediaQuery.of(context).textScaler.scale(20),
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF131927),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: _showAddEventOverlay,
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.textPrimary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: HugeIcon(
                icon: HugeIcons.strokeRoundedCalendarAdd01,
                size: 20.0,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingEventsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Upcoming Events',
          style: GoogleFonts.libreFranklin(
            fontSize: MediaQuery.of(context).textScaler.scale(14),
            fontWeight: FontWeight.w600,
            color: Color(0xFF394050),
          ),
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.009153318),
        eventsList.isEmpty
            ? _buildNoEventsFound()
            : ListView.separated(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: eventsList.length,
                separatorBuilder: (context, index) => SizedBox(
                  height: MediaQuery.of(context).size.height * 0.0205949,
                ),
                itemBuilder: (context, index) =>
                    _buildEventCard(eventsList[index], index),
              ),
      ],
    );
  }

  Widget _buildNoEventsFound() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24),
      child: Column(
        children: [
          HugeIcon(
            icon: HugeIcons.strokeRoundedCalendar03,
            size: 48.0,
            color: Color(0xFF6B7280),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.018306636),
          Text(
            'No events available',
            style: GoogleFonts.libreFranklin(
              fontSize: MediaQuery.of(context).textScaler.scale(16),
              fontWeight: FontWeight.w600,
              color: Color(0xFF394050),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(Event event, int index) {
    final String eventTitle = event.title;
    final String eventStartDate = formatDate(event.startDate);
    final String eventEndDate = formatDate(event.endDate);
    final bool isMultiDay =
        event.isMultiDay; // Use the isMultiDay flag directly

    // --- Safely get eventTime ---
    final String eventTime =
        event.singleDayDetails?.eventTime ??
        (event.daySpecificData.isNotEmpty
            ? event.daySpecificData[0].eventTime
            : 'No Time');

    // --- Safely get location ---
    final String eventLocation =
        event.singleDayDetails?.location ??
        (event.daySpecificData.isNotEmpty
            ? event.daySpecificData[0].location
            : 'Location');

    String _getFirstAvailableImage(Event event) {
      if (event.generatedImages != null && event.generatedImages!.isNotEmpty) {
        for (final img in event.generatedImages!) {
          if (img.trim().isNotEmpty) return img;
        }
      }
      if (event.daySpecificData.isNotEmpty) {
        for (int i = 0; i < event.daySpecificData.length; i++) {
          final images = event.daySpecificData[i].daySpecificImage;
          if (images != null) {
            for (final img in images) {
              if (img.trim().isNotEmpty) {
                return img;
              }
            }
          }
        }
      }
      return '';
    }

    final String eventImage = _getFirstAvailableImage(event);
    final bool shouldShowEnterDetails = eventImage.isEmpty;

    return Container(
      padding: EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: AppColors.textPrimary, width: 1),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // === Text Column ===
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    GlobalFunction.capitalizeFirstLetter(eventTitle),
                    style: GoogleFonts.libreFranklin(
                      fontSize: MediaQuery.of(context).textScaler.scale(20),
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF131927),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),

                  if (isMultiDay) ...[
                    Text(
                      '$eventStartDate - $eventEndDate',
                      style: GoogleFonts.libreFranklin(
                        fontSize: 12,
                        color: Color(0xFF394050),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(height: 4),
                  ] else ...[
                    Text(
                      '$eventStartDate | $eventTime',
                      style: GoogleFonts.libreFranklin(
                        fontSize: 12,
                        color: Color(0xFF394050),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(height: 4),
                  ],

                  // Location Row
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 12,
                        color: Color(0xFF6B7280),
                      ),
                      SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          eventLocation,
                          style: GoogleFonts.libreFranklin(
                            fontSize: 12,
                            color: Color(0xFF394050),
                            fontWeight: FontWeight.w400,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.018306636,
                  ),

                  // === View/Enter Details Button ===
                  GestureDetector(
                    onTap: () async {
                      if (isMultiDay) {
                        MultiDayEventCollectionResponse response =
                            await fetchMultiDayEvent(context, event.id);
                        _showMultiEventDetails(response, false);
                      } else {
                        EventResponse responce = await fetchSingleDayEvent(
                          eventId: event.id,
                        );
                        _showEventDetails(responce);
                      }
                    },
                    child: Container(
                      width: 150,
                      padding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: shouldShowEnterDetails
                            ? Color(0xFFF9FAFB)
                            : AppColors.textPrimary,
                        borderRadius: BorderRadius.circular(32),
                        border: shouldShowEnterDetails
                            ? Border.all(color: AppColors.textPrimary, width: 1)
                            : null,
                      ),
                      child: Center(
                        child: Text(
                          shouldShowEnterDetails
                              ? 'Enter Details'
                              : 'View Details',
                          style: GoogleFonts.libreFranklin(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: shouldShowEnterDetails
                                ? AppColors.textPrimary
                                : Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(width: 16),

            _isloading
                ? Center(
                    child: CircularProgressIndicator(
                      color: AppColors.textPrimary,
                    ),
                  )
                : Container(
                    width: MediaQuery.of(context).size.width * 0.248756,
                    height: 140,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(32),
                      color: shouldShowEnterDetails
                          ? Color(0xFFFDE7E9)
                          : Colors.grey[100],
                      image: !shouldShowEnterDetails && eventImage.isNotEmpty
                          ? DecorationImage(
                              image: NetworkImage(eventImage),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: shouldShowEnterDetails
                        ? Padding(
                            padding: EdgeInsets.all(8.0),
                            child: DottedBorder(
                              options: RoundedRectDottedBorderOptions(
                                dashPattern: [5, 5],
                                strokeWidth: 0.96,
                                radius: Radius.circular(32),
                                color: Color(0xFFD34169),
                                padding: EdgeInsets.all(8),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  HugeIcon(
                                    icon: HugeIcons.strokeRoundedAddCircle,
                                    size: 24,
                                    color: Color(0xFFE25C7E),
                                  ),
                                  SizedBox(
                                    height:
                                        MediaQuery.of(context).size.height *
                                        0.009153318,
                                  ),
                                  Text(
                                    "Style your \nlook",
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.libreFranklin(
                                      color: const Color(0xFFE25C7E),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : null, // No child when showing the image
                  ),
          ],
        ),
      ),
    );
  }

  void _showMultiEventDetails(
    MultiDayEventCollectionResponse response,
    bool? openDayEventDetails,
  ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: true,
      isDismissible: true,
      useSafeArea: true,
      barrierColor: Colors.white,
      elevation: 0,
      builder: (context) => MultiDayEventsPage(
        result: response,
        openDayEventDetails: openDayEventDetails,
      ),
    ).then((_) {
      // This runs when the modal is dismissed (user swipes down or taps outside)
      // Refresh the page even if modal is just closed
      _refreshEventData();
    });
  }

  void _showEventDetails(EventResponse response) {
    final event = response.event;
    final singleDay = event.singleDayDetails;
    if (singleDay == null && !event.isMultiDay) {
      showErrorSnackBar(context, "Event details are missing.");
      return;
    }
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: true,
      isDismissible: true,
      useSafeArea: true,
      barrierColor: Colors.black.withOpacity(0.5),
      elevation: 0,
      builder: (context) {
        return EventDetailsPage(
          eventData: response,
          onEventUpdated: _refreshEventData,
          onEventDeleted: () async {
            Navigator.pop(context);
            // Navigator.pop(context);
            await _refreshEventData();
          },
        );
      },
    ).then((_) {
      // This runs when the modal is dismissed (user swipes down or taps outside)
      // Refresh the page even if modal is just closed
      _refreshEventData();
    });
  }

  Widget _buildCalendarWidget({required double dh}) {
    return Column(
      children: [
        isCalendarExpanded
            ? _buildExpandedCalendar()
            : ScrollableCalendarWidget(
                initialDate: DateTime.now(),
                startDate: DateTime(2023, 1, 1),
                endDate: DateTime(2026, 12, 31),
                selectedColor: AppColors.textPrimary,
                todayColor: AppColors.blueAccent,
                itemWidth: 65.0,
                itemHeight: 75.0,
                onDateSelected: (date) {
                  print('Selected: $date');
                },
              ),

        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                // tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: () =>
                  setState(() => isCalendarExpanded = !isCalendarExpanded),
              child: Text(
                isCalendarExpanded ? 'View less' : 'View calendar',
                style: GoogleFonts.libreFranklin(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF2563EB),
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Widget _buildTimelineCalendar({required double dh}) {
  //   return SizedBox(
  //     height: dh * 0.1,
  //     child: CalendarTimeline(
  //       initialDate: selectedDay,
  //       firstDate: DateTime.now().subtract(const Duration(days: 365)),
  //       lastDate: DateTime.now().add(const Duration(days: 365)),
  //       onDateSelected: (date) => setState(() => selectedDay = date),
  //       monthColor: const Color(0xFF394050),
  //       dayColor: const Color(0xFF394050),
  //       dayNameColor: Colors.white,
  //       activeDayColor: Colors.white,
  //       activeBackgroundDayColor: AppColors.textPrimary,
  //       selectableDayPredicate: (date) => true,
  //       width: 55,
  //       height: 60,
  //       fontSize: MediaQuery.of(context).textScaler.scale(18),
  //       dayNamefontSize: MediaQuery.of(context).textScaler.scale(11),
  //       locale: 'en',
  //     ),
  //   );
  // }

  Widget _buildExpandedCalendar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: AppColors.textPrimary, width: 1),
      ),
      child: TableCalendar<String>(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: focusedDay,
        calendarFormat: calendarFormat,
        eventLoader: _getEventsForDay,
        startingDayOfWeek: StartingDayOfWeek.sunday,
        selectedDayPredicate: (day) => isSameDay(selectedDay, day),
        onDaySelected: (selected, focused) {
          if (!isSameDay(selectedDay, selected)) {
            setState(() {
              selectedDay = selected;
              focusedDay = focused;
            });
          }
        },
        onFormatChanged: (format) {
          if (calendarFormat != format) {
            setState(() => calendarFormat = format);
          }
        },
        onPageChanged: (focused) => focusedDay = focused,
        calendarStyle: CalendarStyle(
          outsideDaysVisible: false,
          weekendTextStyle: GoogleFonts.libreFranklin(
            color: const Color(0xFF394050),
          ),
          holidayTextStyle: GoogleFonts.libreFranklin(
            color: const Color(0xFF394050),
          ),
          defaultTextStyle: GoogleFonts.libreFranklin(
            color: const Color(0xFF394050),
          ),
          todayDecoration: const BoxDecoration(
            color: Colors.red,
            shape: BoxShape.circle,
          ),
          selectedDecoration: BoxDecoration(
            color: AppColors.textPrimary,
            shape: BoxShape.circle,
          ),
          markerDecoration: BoxDecoration(
            color: AppColors.textPrimary,
            shape: BoxShape.circle,
          ),
          markersMaxCount: 3,
          canMarkersOverflow: false,
        ),
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: GoogleFonts.libreFranklin(
            fontSize: MediaQuery.of(context).textScaler.scale(18),
            fontWeight: FontWeight.w600,
            color: const Color(0xFF394050),
          ),
          leftChevronIcon: const Icon(
            Icons.chevron_left,
            color: Color(0xFF394050),
          ),
          rightChevronIcon: const Icon(
            Icons.chevron_right,
            color: Color(0xFF394050),
          ),
        ),
        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: GoogleFonts.libreFranklin(
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
          weekendStyle: GoogleFonts.libreFranklin(
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  void _showAddEventOverlay() {
    showModalBottomSheet<bool>(
      // Change to return bool
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.95,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
          ),
        ),
        child: AddEventOverlay(
          isEditMode: false,
          onEventUpdated: () {
            // Navigator.pop(context, true);
            Developer.log("Event created callback triggered");
          },
        ),
      ),
    ).then((result) {
      // Only refresh if the event was actually created
      if (result == true) {
        Developer.log("Add event modal closed with success - refreshing data");
        _refreshEventData();
      }
    });
  }
}
