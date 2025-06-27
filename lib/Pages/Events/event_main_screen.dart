import 'dart:developer' as Developer;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:table_calendar/table_calendar.dart';
// import 'package:calendar_timeline/calendar_timeline.dart';
import 'package:testing2/Global/Colors/app_colors.dart';
import 'package:testing2/Global/Widget/global_widget.dart';
import 'package:testing2/Pages/Events/scrollable_calendar_widget.dart';
import 'package:testing2/services/Class/event_model.dart';
import 'package:testing2/services/DataSource/event_api_service.dart';
import 'event_details_screen.dart';
import 'add_or_edit_event_overlay.dart';
import 'multiday_events_screen.dart';

class CalendarEventsPage extends StatefulWidget {
  const CalendarEventsPage({super.key});

  @override
  State<CalendarEventsPage> createState() => _CalendarEventsPageState();
}

class _CalendarEventsPageState extends State<CalendarEventsPage> {
  String username = '';
  List<Event> eventsList = [];
  bool isLoading = true;
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

  @override
  void initState() {
    super.initState();
    _fetchUserEvents();
  }

  Future<void> _fetchUserEvents() async {
    setState(() => isLoading = true);
    try {
      final result = await EventApiService.getUpcomingEvents();
      // Developer.log(result.events.toString());
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
      setState(() => eventsList = []);
    } finally {
      setState(() => isLoading = false);
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

  List<String> _getEventsForDay(DateTime day) {
    return sampleEvents[DateTime.utc(day.year, day.month, day.day)] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    final double dh = MediaQuery.of(context).size.height;
    final double dw = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : eventsList.isEmpty
                  ? _buildEmptyEventsUI(dh: dh, dw: dw)
                  : _buildEventsListUI(dh: dh),
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
              fontSize: 18,
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
                Positioned(
                  top: 5,
                  right: 5,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: const BoxDecoration(
                      color: AppColors.titleTextColor,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '4',
                        style: GoogleFonts.libreFranklin(
                          color: Colors.white,
                          fontSize: 8,
                        ),
                      ),
                    ),
                  ),
                ),
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
              const SizedBox(height: 16),
              Text(
                'Hello, $username',
                style: GoogleFonts.libreFranklin(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Whether it\'s your bestie\'s wedding 💅🏻 or a long-overdue vacation 🏝, Zuri\'s Events page helps you plan every "what to wear? 💭 moment" like a pro. 💃',
                style: GoogleFonts.libreFranklin(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.titleTextColor,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _buildCalendarWidget(dh: dh),
        const SizedBox(height: 20),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
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
                  fontSize: 14,
                  color: const Color(0xFF394050),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 30),
              const HugeIcon(
                icon: HugeIcons.strokeRoundedCalendarAdd01,
                size: 100.0,
                color: AppColors.textPrimary,
              ),
              const SizedBox(height: 24),
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
        const GlobalSearchBar(),
        const SizedBox(height: 20),
        _buildEventsGreetingCard(),
        const SizedBox(height: 20),
        _buildCalendarWidget(dh: dh),
        const SizedBox(height: 12),
        _buildUpcomingEventsSection(),
      ],
    );
  }

  Widget _buildEventsGreetingCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
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
                  'Hello, $username',
                  style: GoogleFonts.libreFranklin(
                    fontSize: 14,
                    color: const Color(0xFF394050),
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Got an Event? Let's Make It Fashion",
                  style: GoogleFonts.libreFranklin(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF131927),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: _showAddEventOverlay,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.textPrimary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const HugeIcon(
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
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF394050),
          ),
        ),
        const SizedBox(height: 8),
        eventsList.isEmpty
            ? _buildNoEventsFound()
            : ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: eventsList.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 18),
                itemBuilder: (context, index) =>
                    _buildEventCard(eventsList[index], index),
              ),
      ],
    );
  }

  Widget _buildNoEventsFound() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const HugeIcon(
            icon: HugeIcons.strokeRoundedCalendar03,
            size: 48.0,
            color: Color(0xFF6B7280),
          ),
          const SizedBox(height: 16),
          Text(
            'No events available',
            style: GoogleFonts.libreFranklin(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF394050),
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
    final bool isMultiDay = eventStartDate != eventEndDate;

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

    // --- Safely handle images ---
    final List<String> eventImages = event.generatedImages;
    final bool shouldShowEnterDetails =
        eventImages.isEmpty || eventImages[0].isEmpty;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
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
                    eventTitle,
                    style: GoogleFonts.libreFranklin(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF131927),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  if (isMultiDay) ...[
                    Text(
                      '$eventStartDate - $eventEndDate',
                      style: GoogleFonts.libreFranklin(
                        fontSize: 12,
                        color: const Color(0xFF394050),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 4),
                  ] else ...[
                    Text(
                      '$eventStartDate | $eventTime',
                      style: GoogleFonts.libreFranklin(
                        fontSize: 12,
                        color: const Color(0xFF394050),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],

                  // Location Row
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 12,
                        color: Color(0xFF6B7280),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          eventLocation,
                          style: GoogleFonts.libreFranklin(
                            fontSize: 12,
                            color: const Color(0xFF394050),
                            fontWeight: FontWeight.w400,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // === View/Enter Details Button ===
                  GestureDetector(
                    onTap: () async {
                      if (isMultiDay) {
                        MultiDayEventCollectionResponse response =
                            await fetchMultiDayEvent(context, event.id);
                        _showMultiEventDetails(response);
                      } else {
                        EventResponse responce = await fetchSingleDayEvent(
                          eventId: event.id,
                        );
                        _showEventDetails(responce);
                      }
                    },
                    child: Container(
                      width: 150,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: shouldShowEnterDetails
                            ? const Color(0xFFF9FAFB)
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

            const SizedBox(width: 16),

            // === Event Image ===
            Container(
              width: 100,
              height: 140,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(32),
                color: shouldShowEnterDetails
                    ? const Color(0xFFFDE7E9)
                    : Colors.grey[100],
                image: !shouldShowEnterDetails && eventImages.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(eventImages[0]),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: shouldShowEnterDetails
                  ? Center(
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const HugeIcon(
                          icon: HugeIcons.strokeRoundedAdd01,
                          size: 20,
                          color: Color(0xFFE91E63),
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  void _showMultiEventDetails(MultiDayEventCollectionResponse response) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: true,
      isDismissible: true,
      useSafeArea: true,
      barrierColor: Colors.white,
      elevation: 0,
      builder: (context) => MultiDayEventsPage(result: response),
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
            Navigator.pop(context); // close delete confirmation modal
            Navigator.pop(context); // Close details modal
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
  //       fontSize: 18,
  //       dayNameFontSize: 11,
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
            fontSize: 18,
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
    showModalBottomSheet<void>(
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
          onSave: () async {
            // Wait a bit to ensure the API call completes
            await Future.delayed(const Duration(milliseconds: 500));

            // Don't pop here - let AddEventOverlay handle it
            // Navigator.pop(context);

            // Refresh the data
            _refreshEventData();
          },
          onEventUpdated: () async {
            // This callback is for when the event is successfully created/updated
            Developer.log("Event updated callback triggered");
            _refreshEventData();
          },
        ),
      ),
    ).then((_) {
      // This runs when the modal is dismissed
      // Always refresh when modal closes
      Developer.log("Add event modal dismissed - refreshing data");
      _refreshEventData();
    });
  }
}
