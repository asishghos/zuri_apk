// import 'dart:convert';

import 'dart:developer' as Developer;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:testing2/Global/Colors/app_colors.dart';
import 'package:testing2/Global/Function/global_function.dart';
import 'package:testing2/Global/Widget/global_widget.dart';
import 'package:testing2/Pages/Events/add_or_edit_event_overlay.dart';
import 'package:testing2/Pages/Loading/loading_page.dart';
import 'package:testing2/services/Class/event_model.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:testing2/services/DataSource/event_api_service.dart';

class EventDetailsPage extends StatefulWidget {
  final EventResponse eventData;
  final int? index;
  final VoidCallback? onEventDeleted;
  final VoidCallback? onEventUpdated;
  final bool? timeToRefresh;
  const EventDetailsPage({
    Key? key,
    required this.eventData,
    this.index,
    this.onEventDeleted,
    this.onEventUpdated,
    this.timeToRefresh,
  }) : super(key: key);

  @override
  State<EventDetailsPage> createState() => _EventDetailsPageState();
}

class _EventDetailsPageState extends State<EventDetailsPage> {
  late EventResponse eventDataResult;
  PageController _pageController = PageController();
  int _currentIndex = 0;
  bool isLoading = false;

  // Future<void> _refreshEventData() async {
  //   setState(() {
  //     isLoading = true;
  //     eventDataResult = widget.eventData; // Or updated data passed in callback
  //   });

  //   await Future.delayed(
  //     Duration(milliseconds: 300),
  //   ); // Just to simulate delay (optional)

  //   setState(() {
  //     isLoading = false;
  //   });

  //   widget.onEventUpdated?.call();
  // }

  Future<void> _refreshEventData() async {
    setState(() {
      isLoading = true;
    });

    try {
      // if you have an API to fetch the updated event
      final updatedEvent;
      if (widget.eventData.event.isMultiDay) {
        updatedEvent = await EventApiService.getSingleDayEventDetails(
          eventId: widget.eventData.event.id,
        );
      } else {
        updatedEvent = await EventApiService.getSingleEventDetails(
          eventId: widget.eventData.event.id,
          dayEventId:
              widget.eventData.event.daySpecificData[widget.index ?? 0].id,
        );
      }
      setState(() {
        eventDataResult = updatedEvent;
      });
    } catch (e) {
      Developer.log('❌ Error refreshing event: $e');
      showErrorSnackBar(context, 'Failed to refresh event');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
    widget.onEventUpdated?.call();
  }

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
    eventDataResult = widget.eventData;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return LoadingPage();
    } else {
      return Container(
        height: MediaQuery.of(context).size.height * 0.95,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            // Drag handle
            Container(
              margin: EdgeInsets.only(top: 8),
              width: MediaQuery.of(context).size.width * 0.0995,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'View Details',
                    style: GoogleFonts.inter(
                      fontSize: MediaQuery.of(context).textScaler.scale(18),
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF394050),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Color(0xFF141B34),
                          width: 1.5,
                        ),
                      ),
                      child: HugeIcon(
                        icon: HugeIcons.strokeRoundedCancel01,
                        size: 16,
                        color: Color(0xFF141B34),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Add this horizontal line
            Container(
              height: 1.5,
              margin: EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(color: Color(0xFF9EA2AE)),
            ),

            // Content
            Expanded(
              child: Column(
                children: [
                  // Scrollable content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.only(
                        bottom: 16,
                        left: 16,
                        right: 16,
                        top: 16,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Event Header
                          _buildEventHeader(),

                          SizedBox(
                            height:
                                MediaQuery.of(context).size.height * 0.0274599,
                          ),

                          // Description Section
                          _buildDescriptionSection(),

                          SizedBox(
                            height:
                                MediaQuery.of(context).size.height * 0.0274599,
                          ),

                          _buildStyledLookSection(),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 20,
                      right: 20,
                      top: 8,
                      bottom: 8,
                    ),
                    child: (() {
                      // Safely extract image list
                      final List<String>? images =
                          eventDataResult.event.generatedImages?.isNotEmpty ==
                              true
                          ? eventDataResult.event.generatedImages
                          : (eventDataResult.event.daySpecificData.isNotEmpty &&
                                (widget.index ?? 0) <
                                    eventDataResult
                                        .event
                                        .daySpecificData
                                        .length)
                          ? eventDataResult
                                .event
                                .daySpecificData[widget.index ?? 0]
                                .daySpecificImage
                          : [];

                      final totalItems = images?.length ?? 0;

                      if (totalItems != 0) {
                        return GlobalPinkButton(
                          text: "Shop This Look",
                          onPressed: () {
                            final keywordsList = ['Yoga pants', 'Wristlet'];
                            context.goNamed(
                              'affiliate',
                              queryParameters: {
                                'keywords': keywordsList.join(','),
                              },
                            );
                          },
                        );
                      } else {
                        return GlobalPinkButton(
                          text: "Turn My Closet into a Look",
                          onPressed: () {
                            context.goNamed(
                              "myWardrobe",
                              extra: {
                                "isDialogBoxOpen": true,
                                "occasion": (eventDataResult.event.isMultiDay)
                                    ? eventDataResult
                                          .event
                                          .daySpecificData[widget.index ?? 0]
                                          .eventName
                                    : eventDataResult.event.occasion,
                                "description":
                                    (eventDataResult.event.isMultiDay)
                                    ? eventDataResult
                                          .event
                                          .daySpecificData[widget.index ?? 0]
                                          .description
                                    : eventDataResult
                                          .event
                                          .singleDayDetails
                                          ?.description,
                                "eventId": eventDataResult.event.id,
                                "location": (eventDataResult.event.isMultiDay)
                                    ? eventDataResult
                                          .event
                                          .daySpecificData[widget.index ?? 0]
                                          .location
                                    : eventDataResult
                                          .event
                                          .singleDayDetails
                                          ?.location,
                                "dayEventId": (eventDataResult.event.isMultiDay)
                                    ? eventDataResult
                                          .event
                                          .daySpecificData[widget.index ?? 0]
                                          .id
                                    : null,
                              },
                            );
                          },
                        );
                      }
                    })(),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.018306636,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildEventHeader() {
    final data = eventDataResult.event;
    String eventName = data.title;
    // Fix: Handle both single-day and multi-day events properly
    String eventTitle;
    if (data.isMultiDay) {
      eventTitle = data.daySpecificData[widget.index ?? 0].eventName;
    } else {
      eventTitle = data.title;
    }

    String eventDate = (data.isMultiDay)
        ? formatDate(data.daySpecificData[widget.index ?? 0].date)
        : formatDate(data.startDate);
    String eventTime = (data.isMultiDay)
        ? (eventDataResult.event.daySpecificData[widget.index ?? 0].eventTime
              .toString())
        : (data.singleDayDetails?.eventTime?.toString() ?? '');
    String eventLocation =
        data.singleDayDetails?.location ??
        data.daySpecificData[widget.index ?? 0].location;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Event name with icons
        Row(
          //--------------------------------------------------------- ---There I not follow figma style ...
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Show eventTitle (John's Wedding)
            Flexible(
              child: Text(
                GlobalFunction.capitalizeFirstLetter(eventTitle),
                style: GoogleFonts.inter(
                  fontSize: MediaQuery.of(context).textScaler.scale(20),
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF131927),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(width: 16),
            // Conditionally show event name (Wedding) with pink background
            if (eventDataResult.event.isMultiDay) ...[
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: Color(0xFFE25C7E),
                  borderRadius: BorderRadius.circular(32),
                ),
                child: Text(
                  GlobalFunction.capitalizeFirstLetter(
                    eventName,
                  ), // This will show "Wedding"
                  style: GoogleFonts.libreFranklin(
                    fontSize: 12,
                    letterSpacing: -0.01 * 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFFF9FAFB),
                  ),
                ),
              ),
              SizedBox(width: 16),
            ],
            GestureDetector(
              onTap: () => showGlobalDeleteConfirmationDialog(
                context: context,
                buttonText: "Delete",
                title: 'Delete Event',
                content:
                    'Are you sure you want to delete "${eventDataResult.event.title}"? This action cannot be undone.',
                onConfirm: () async {
                  if (eventDataResult.event.isMultiDay) {
                    if (eventDataResult.event.daySpecificData.length > 1) {
                      await deleteDayEvent(
                        eventDataResult.event.id,
                        widget
                            .eventData
                            .event
                            .daySpecificData[widget.index ?? 0]
                            .id,
                      );
                    } else {
                      await deleteEntireEvent(eventDataResult.event.id);
                    }
                  } else {
                    await deleteEntireEvent(eventDataResult.event.id);
                  }
                  widget.onEventDeleted?.call();
                  showSuccessSnackBar(context, "Event deleted successfully");
                },
              ),
              child: HugeIcon(
                icon: HugeIcons.strokeRoundedDelete03,
                size: 20,
                color: Color(0xFFFF5236),
              ),
            ),
            SizedBox(width: 16),
            GestureDetector(
              onTap: () => _openEditEvent(),
              child: HugeIcon(
                icon: HugeIcons.strokeRoundedEdit02,
                size: 20,
                color: Color(0xFF141B34),
              ),
            ),
          ],
        ),

        SizedBox(height: MediaQuery.of(context).size.height * 0.009153318),
        // Date, time and location on same line
        Row(
          children: [
            // Date and time
            Expanded(
              flex: 2,
              child: Text(
                eventDate,
                style: GoogleFonts.libreFranklin(
                  fontSize: 12,
                  color: Color(0xFF394050),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                eventTime,
                style: GoogleFonts.libreFranklin(
                  fontSize: 12,
                  color: Color(0xFF394050),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            // Location
            Expanded(
              flex: 3,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
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
            ),
          ],
        ),
      ],
    );
  }

  // Add these new methods to your _EventDetailsPageState class:

  void _openEditEvent() {
    showModalBottomSheet<bool>(
      // Changed to return bool
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
          isEditMode: true,
          eventData: eventDataResult,
          onEventUpdated: () {
            _refreshEventData();
            Developer.log("Event updated successfully");
          },
          onEventUpdatedCallBack: (updatedEventData) {
            setState(() {
              eventDataResult = updatedEventData;
            });
            _refreshEventData();
          },
        ),
      ),
    ).then((result) {
      // Only refresh if the event was actually updated
      if (result == true) {
        Developer.log("Edit event modal closed with success - refreshing data");
        _refreshEventData();
      }
    });
  }

  // void _showDeleteConfirmation() {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         backgroundColor: Colors.white,
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.circular(32),
  //         ),
  //         title: Text(
  //           'Delete Event',
  //           style: GoogleFonts.inter(
  //             fontSize: MediaQuery.of(context).textScaler.scale(18),
  //             fontWeight: FontWeight.w600,
  //             color: Color(0xFF131927),
  //           ),
  //         ),
  //         content: Text(
  //           'Are you sure you want to delete "${eventDataResult.event.title}"? This action cannot be undone.',
  //           style: GoogleFonts.libreFranklin(
  //             fontSize: MediaQuery.of(context).textScaler.scale(14),
  //             color: Color(0xFF394050),
  //           ),
  //         ),
  //         actions: [
  //           TextButton(
  //             onPressed: () {
  //               Navigator.of(context).pop(); // Close dialog
  //             },
  //             child: Text(
  //               'Cancel',
  //               style: GoogleFonts.libreFranklin(
  //                 fontSize: MediaQuery.of(context).textScaler.scale(14),
  //                 fontWeight: FontWeight.w500,
  //                 color: Color(0xFF394050),
  //               ),
  //             ),
  //           ),
  //           ElevatedButton(
  //             onPressed: () async {
  //               try {
  //                 if (eventDataResult.event.isMultiDay) {
  //                   if (eventDataResult.event.daySpecificData.length > 1) {
  //                     // If there are multiple days, delete only the specific day
  //                     await deleteDayEvent(
  //                       eventDataResult.event.id,
  //                       widget
  //                           .eventData
  //                           .event
  //                           .daySpecificData[widget.index ?? 0]
  //                           .id,
  //                     );
  //                     // context.pop();
  //                   } else {
  //                     await deleteEntireEvent(eventDataResult.event.id);
  //                     // context.pop();
  //                     // context.pop();
  //                   }
  //                 } else {
  //                   await deleteEntireEvent(eventDataResult.event.id);
  //                   // context.pop();
  //                   // context.pop();
  //                 }
  //                 widget.onEventDeleted?.call();
  //                 showSuccessSnackBar(context, "Event deleted successfully");
  //               } catch (e) {
  //                 Navigator.pop(context); // Close dialog
  //                 showErrorSnackBar(context, "Failed to delete event: $e");
  //               }
  //             },
  //             style: ElevatedButton.styleFrom(
  //               backgroundColor: Color(0xFFFF5236),
  //               foregroundColor: Colors.white,
  //               shape: RoundedRectangleBorder(
  //                 borderRadius: BorderRadius.circular(32),
  //               ),
  //               elevation: 0,
  //             ),
  //             child: Text(
  //               'Delete',
  //               style: GoogleFonts.libreFranklin(
  //                 fontSize: MediaQuery.of(context).textScaler.scale(14),
  //                 fontWeight: FontWeight.w600,
  //               ),
  //             ),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  Widget _buildDescriptionSection() {
    String description =
        eventDataResult.event.singleDayDetails?.description ??
        eventDataResult.event.daySpecificData[widget.index ?? 0].description;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description',
          style: GoogleFonts.libreFranklin(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 14),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: Color(0xFF394050), width: 1),
          ),
          child: Text(
            (description.isEmpty) ? "Description is Empty" : description,
            style: GoogleFonts.libreFranklin(
              fontSize: 12,
              color: (description.isEmpty)
                  ? AppColors.subTitleTextColor
                  : Color(0xFF394050),
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStyledLookSection() {
    // Safely extract image list
    final List<String>? images =
        eventDataResult.event.generatedImages?.isNotEmpty == true
        ? eventDataResult.event.generatedImages
        : (eventDataResult.event.daySpecificData.isNotEmpty &&
              (widget.index ?? 0) <
                  eventDataResult.event.daySpecificData.length)
        ? eventDataResult
              .event
              .daySpecificData[widget.index ?? 0]
              .daySpecificImage
        : [];

    final totalItems = images?.length ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your styled looks',
          style: GoogleFonts.inter(
            fontSize: MediaQuery.of(context).textScaler.scale(16),
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.018306636),

        // Show empty placeholder
        if (totalItems == 0)
          Container(
            height: MediaQuery.of(context).size.height * 0.4,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: Colors.grey[200]!, width: 1),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  HugeIcon(
                    icon: HugeIcons.strokeRoundedImage01,
                    size: 48,
                    color: Colors.grey[400]!,
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.009153318,
                  ),
                  Text(
                    'Your styled look will appear here',
                    style: GoogleFonts.libreFranklin(
                      fontSize: MediaQuery.of(context).textScaler.scale(14),
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
          )
        // Show styled image list
        else
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.45,
            child: PageView.builder(
              controller: _pageController,
              itemCount: totalItems,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemBuilder: (context, index) {
                final imageUrl = images![index];

                return Column(
                  children: [
                    Expanded(
                      child: Stack(
                        children: [
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: Colors.white,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: _buildBase64Image(
                                imageUrl,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

        // Dot indicators
        if (totalItems > 1)
          Container(
            padding: const EdgeInsets.only(top: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                totalItems,
                (index) => _buildDotIndicator(index == _currentIndex),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildBase64Image(
    String imageUrl, {
    BoxFit fit = BoxFit.contain,
    double? width,
    double? height,
  }) {
    if (imageUrl.isEmpty) {
      return Container(
        width: width,
        height: height,
        color: Color(0xFFFFD6D5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image_not_supported, size: 60, color: Color(0xFF8D6E63)),
            SizedBox(height: MediaQuery.of(context).size.height * 0.013729977),
            Text(
              'No image available',
              style: GoogleFonts.libreFranklin(
                color: Color(0xFF5D4037),
                fontSize: MediaQuery.of(context).textScaler.scale(14),
              ),
            ),
          ],
        ),
      );
    }

    try {
      // // Remove data:image/jpeg;base64, prefix if present
      // String cleanBase64 = base64String;
      // if (base64String.contains(',')) {
      //   cleanBase64 = base64String.split(',')[1];
      // }

      // Uint8List bytes = base64Decode(cleanBase64);
      return Image.network(
        imageUrl,
        fit: fit,
        width: width,
        height: height,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: width,
            height: height,
            color: Color(0xFFFFD6D5),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.broken_image, size: 60, color: Color(0xFF8D6E63)),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.013729977,
                ),
                Text(
                  'Failed to load image',
                  style: GoogleFonts.libreFranklin(
                    color: Color(0xFF5D4037),
                    fontSize: MediaQuery.of(context).textScaler.scale(14),
                  ),
                ),
              ],
            ),
          );
        },
      );
    } catch (e) {
      return Container(
        width: width,
        height: height,
        color: Color(0xFFFFD6D5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, size: 60, color: Color(0xFF8D6E63)),
            SizedBox(height: MediaQuery.of(context).size.height * 0.013729977),
            Text(
              'Invalid image data',
              style: GoogleFonts.libreFranklin(
                color: Color(0xFF5D4037),
                fontSize: MediaQuery.of(context).textScaler.scale(14),
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildDotIndicator(bool isActive) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      margin: EdgeInsets.symmetric(horizontal: 4),
      height: MediaQuery.of(context).size.height * 0.009153318,
      width: isActive ? 24 : 8,
      decoration: BoxDecoration(
        color: isActive ? AppColors.textPrimary : Colors.grey[300],
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
