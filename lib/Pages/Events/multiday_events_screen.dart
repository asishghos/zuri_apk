import 'dart:developer' as Developer;

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:testing2/Global/Colors/app_colors.dart';
import 'package:testing2/Global/Function/global_function.dart';
import 'package:testing2/Global/Widget/global_widget.dart';
import 'package:testing2/services/Class/event_model.dart';
import 'package:testing2/services/DataSource/event_api_service.dart';
import 'event_details_screen.dart';

class MultiDayEventsPage extends StatefulWidget {
  final MultiDayEventCollectionResponse result;
  final bool? openDayEventDetails;
  final String? dayEventId;

  const MultiDayEventsPage({
    Key? key,
    required this.result,
    this.openDayEventDetails,
    this.dayEventId,
  }) : super(key: key);

  @override
  State<MultiDayEventsPage> createState() => _MultiDayEventsPageState();
}

class _MultiDayEventsPageState extends State<MultiDayEventsPage> {
  late MultiDayEventCollectionResponse resultResult;
  bool isLoading = false;

  Future<void> deleteEntireEvent(String eventId) async {
    try {
      final result = await EventApiService.deleteEvent(eventId: eventId);
      Developer.log('✅ ${result['message']}');
    } catch (e) {
      Developer.log('❌ Error deleting event: $e');
      rethrow; // Rethrow to handle in _showDeleteConfirmation
    }
  }

  Future<void> deleteDayEvent(String eventId, String dayEventId) async {
    try {
      final result = await EventApiService.deleteEvent(
        eventId: eventId,
        dayEventId: dayEventId,
      );
      Developer.log('✅ ${result['message']}');
    } catch (e) {
      Developer.log('❌ Error deleting day event: $e');
      rethrow; // Rethrow to handle in _showDeleteConfirmation
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.openDayEventDetails == true && widget.dayEventId != null) {
      _fetchSingleDayDetails(
        eventId: widget.result.parentEvent.id,
        dayEventId: widget.dayEventId!,
      ).then((result) {
        _openEventDetails(event: result); // index can be improved if needed
      });
    }
    resultResult = widget.result;
  }

  Future<MultiDayEventCollectionResponse> fetchMultiDayEvent(
    BuildContext context,
    String eventId,
  ) async {
    try {
      setState(() {
        isLoading = true;
      });

      final data = await EventApiService.getMultiDayEventCollection(
        eventId: eventId,
      );
      // Developer.log(data.toString());
      Developer.log("Multi-day event collection fetched successfully");

      setState(() {
        isLoading = false;
      });

      return data;
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      Developer.log("Failed to fetch multi-day event: $e");
      showErrorSnackBar(context, "Error is ${e}");
      throw Exception("Failed to fetch multi-day event: $e");
    }
  }

  Future<EventResponse> _fetchSingleDayDetails({
    required String eventId,
    required String dayEventId,
  }) async {
    try {
      final data = await EventApiService.getSingleEventDetails(
        eventId: eventId,
        dayEventId: dayEventId,
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

  // Universal refresh method
  Future<void> _refreshEventData() async {
    try {
      final refreshedData = await fetchMultiDayEvent(
        context,
        resultResult.parentEvent.id,
      );
      setState(() {
        resultResult = refreshedData;
      });
      Developer.log("✅ Page refreshed successfully");
    } catch (e) {
      Developer.log("❌ Error refreshing page: $e");
      showErrorSnackBar(context, "Failed to refresh data");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            margin: EdgeInsets.all(8),
            child: HugeIcon(
              icon: HugeIcons.strokeRoundedArrowLeft01,
              size: 20,
              color: Color(0xFF141B34),
            ),
          ),
        ),
        title: Text(
          GlobalFunction.capitalizeFirstLetter(resultResult.parentEvent.title),
          style: GoogleFonts.libreFranklin(
            fontSize: MediaQuery.of(context).textScaler.scale(18),
            fontWeight: FontWeight.w600,
            letterSpacing: -0.02 * 18,
            color: Color(0xFF394050),
          ),
        ),
        centerTitle: false,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: Color(0xFFE91E63)))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // "Your Upcoming events" header
                Padding(
                  padding: EdgeInsets.only(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    top: 16,
                  ),
                  child: Text(
                    'Your Upcoming events',
                    style: GoogleFonts.libreFranklin(
                      fontSize: MediaQuery.of(context).textScaler.scale(14),
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF394050),
                    ),
                  ),
                ),

                // Events list
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    itemCount: resultResult.dayEvents.length,
                    itemBuilder: (context, index) {
                      return _buildEventCard(
                        resultResult.dayEvents[index],
                        index == 0,
                        index,
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildEventCard(DayEventItem event, bool isFirst, int index) {
    bool isStyled = event.isStyled;
    String eventTitle = event.eventName;
    String eventDate = formatDate(event.date);
    String eventTime = event.eventTime;
    String eventLocation = event.location;
    String? eventImage;

    if (event.daySpecificImage != null && event.daySpecificImage!.isNotEmpty) {
      for (final img in event.daySpecificImage!) {
        if (img.trim().isNotEmpty) {
          eventImage = img;
          break;
        }
      }
    }

    // Show 'Enter Details' if image is missing or not styled
    bool shouldShowEnterDetails =
        eventImage == null || eventImage.isEmpty || isStyled == false;

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Color(0xFFE25C7E), width: 1.5),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            // Left side content
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Event title
                  Text(
                    GlobalFunction.capitalizeFirstLetter(eventTitle),
                    style: GoogleFonts.libreFranklin(
                      fontSize: MediaQuery.of(context).textScaler.scale(20),
                      letterSpacing: -0.02 * 20,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF131927),
                    ),
                  ),

                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.009153318,
                  ),

                  // Date and time
                  Text(
                    '$eventDate     |     $eventTime',
                    style: GoogleFonts.libreFranklin(
                      fontSize: 12,
                      color: Color(0xFF394050),
                    ),
                  ),

                  SizedBox(height: 6),

                  // Location
                  Row(
                    children: [
                      HugeIcon(
                        icon: HugeIcons.strokeRoundedLocation01,
                        size: 12,
                        color: Color(0xFF394050),
                      ),
                      SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          eventLocation,
                          style: GoogleFonts.libreFranklin(
                            fontSize: 12,
                            color: Color(0xFF394050),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.018306636,
                  ),

                  Container(
                    width: 150, // Fixed width
                    height: 36, // Fixed height for consistency
                    child: ElevatedButton(
                      onPressed: () async {
                        try {
                          final responce = await _fetchSingleDayDetails(
                            eventId: event.parentEventId,
                            dayEventId: event.id,
                          );
                          _openEventDetails(event: responce, index: index);
                        } catch (e) {}
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: shouldShowEnterDetails
                            ? Color(0xFFF9FAFB)
                            : Color(0xFFE25C7E),
                        foregroundColor: shouldShowEnterDetails
                            ? Color(0xFFE25C7E)
                            : Colors.white,
                        elevation: 0,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32),
                          side: shouldShowEnterDetails
                              ? BorderSide(color: Color(0xFFE25C7E), width: 1)
                              : BorderSide.none,
                        ),
                      ),
                      child: Text(
                        shouldShowEnterDetails
                            ? 'Enter Details'
                            : 'View Details',
                        style: GoogleFonts.libreFranklin(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(width: 16),

            // Right side - Image or placeholder - Fixed fallback logic
            isLoading
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
                      color: (eventImage == null || eventImage.isEmpty)
                          ? Color(0xFFFDE7E9) // Light pink when no image
                          : Colors.grey[100],
                      image: (eventImage != null && eventImage.isNotEmpty)
                          ? DecorationImage(
                              image: NetworkImage(eventImage),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: (eventImage == null || eventImage.isEmpty)
                        ? Padding(
                            padding: const EdgeInsets.all(8.0),
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
                                    color: const Color(0xFFE25C7E),
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
                        : null,
                  ),
          ],
        ),
      ),
    );
  }

  void _openEventDetails({required EventResponse event, int? index}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height:
            MediaQuery.of(context).size.height * 0.95, // 95% of screen height
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: EventDetailsPage(
          eventData: event,
          index: index,
          onEventUpdated: _refreshEventData,
          onEventDeleted: (event.event.daySpecificData.length > 1)
              ? () async {
                  Navigator.pop(context);
                  // Navigator.pop(context);
                  await _refreshEventData();
                }
              : () {
                  Navigator.pop(context);
                  // Navigator.pop(context);
                  Navigator.pop(context, true);
                },
        ),
      ),
    ).then((_) {
      _refreshEventData();
    });
  }
}
