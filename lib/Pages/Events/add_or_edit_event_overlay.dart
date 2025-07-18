import 'dart:developer' as Developer;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:testing2/Global/Colors/app_colors.dart';
import 'package:testing2/Global/Widget/global_widget.dart';
import 'package:testing2/Pages/Loading/loading_page.dart';
import 'package:testing2/services/Class/event_model.dart';
import 'package:testing2/services/DataSource/event_api_service.dart';

class AddEventOverlay extends StatefulWidget {
  final bool isEditMode;
  final EventResponse? eventData;
  final VoidCallback? onSave;
  final VoidCallback? onEventUpdated;
  final Function(EventResponse)? onEventUpdatedCallBack;
  final DateTime? selectedDate;
  final int? index;

  const AddEventOverlay({
    Key? key,
    required this.isEditMode,
    this.eventData,
    this.onEventUpdated,
    this.onEventUpdatedCallBack,
    this.onSave,
    this.selectedDate,
    this.index,
  }) : super(key: key);

  @override
  State<AddEventOverlay> createState() => _AddEventOverlayState();
}

class _AddEventOverlayState extends State<AddEventOverlay> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _eventController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _customOccasionController =
      TextEditingController();
  final TextEditingController _reminderController = TextEditingController(
    text: '1 day before',
  );
  final FocusNode _locationFocusNode = FocusNode();
  final FocusNode _descriptionFocusNode = FocusNode();

  DateTime? startDate;
  DateTime? endDate;
  String selectedOccasion = 'Celebration';
  DateTime? selectedPlanDate;
  Map<DateTime, Map<String, dynamic>> daySpecificData = {};
  bool isLoading = false;
  String _selectedTimezone = 'IST';
  String _reminderType = 'Days before';
  int _reminderValue = 1;
  bool _isMultiDay = false;
  List<MultiDayEventData> _multiDayEvents = [];
  final _formKey = GlobalKey<FormState>();

  final List<String> occasions = [
    'Anniversary',
    'Wedding',
    'Vacation',
    'Parties',
    'Date',
    'Interview',
    'Festival',
    'Movie night',
    'Others',
  ];

  @override
  void initState() {
    super.initState();
    startDate = widget.selectedDate ?? DateTime.now();
    endDate = widget.selectedDate ?? DateTime.now();
    selectedPlanDate = startDate;
    _timeController.text = '00:00 AM';
    _updateReminderText();
    _initializeDayData(startDate!);
    _initializeMultiDayEvents();
    if (widget.isEditMode && widget.eventData != null) {
      _populateFieldsForEdit();
    }
    _locationFocusNode.addListener(
      () => _scrollToFocusedField(_locationFocusNode),
    );
    _descriptionFocusNode.addListener(
      () => _scrollToFocusedField(_descriptionFocusNode),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _eventController.dispose();
    _timeController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    _reminderController.dispose();
    _customOccasionController.dispose();
    for (var event in _multiDayEvents) {
      event.dispose();
    }
    super.dispose();
    _locationFocusNode.dispose();
    _descriptionFocusNode.dispose();
  }

  void _scrollToFocusedField(FocusNode focusNode) {
    if (focusNode.hasFocus) {
      Future.delayed(Duration(milliseconds: 300), () {
        Scrollable.ensureVisible(
          focusNode.context!,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      });
    }
  }

  void _initializeDayData(DateTime date) {
    if (!daySpecificData.containsKey(date)) {
      daySpecificData[date] = {
        'event': '',
        'time': '00:00 AM',
        'location': '',
        'description': '',
        'reminder': '1 day before',
        'reminderValue': 1,
        'reminderType': 'Days before',
      };
    }
  }

  void _initializeMultiDayEvents() {
    _multiDayEvents.clear();
    for (DateTime date in _getDateRange()) {
      _initializeDayData(date);
      _multiDayEvents.add(
        MultiDayEventData(
            date: date,
            reminderValue: daySpecificData[date]!['reminderValue'] ?? 1,
            reminderType:
                daySpecificData[date]!['reminderType'] ?? 'Days before',
          )
          ..eventController.text = daySpecificData[date]!['event'] ?? ''
          ..timeController.text = daySpecificData[date]!['time'] ?? '00:00 AM'
          ..locationController.text = daySpecificData[date]!['location'] ?? ''
          ..descriptionController.text =
              daySpecificData[date]!['description'] ?? ''
          ..reminderController.text =
              daySpecificData[date]!['reminder'] ?? '1 day before',
      );
    }
  }

  void _populateFieldsForEdit() {
    final eventResponse = widget.eventData;
    if (eventResponse == null) return;
    final data = eventResponse.event;

    _titleController.text = data.title;
    selectedOccasion = data.occasion;
    if (!occasions.contains(selectedOccasion) && selectedOccasion.isNotEmpty) {
      selectedOccasion = 'Others';
      _customOccasionController.text = data.occasion;
    }
    startDate = data.startDate is String
        ? DateTime.parse(data.startDate.toString())
        : data.startDate;
    endDate = data.endDate is String
        ? DateTime.parse(data.endDate.toString())
        : data.endDate;
    _isMultiDay = data.isMultiDay == true;

    if (_isMultiDay && data.daySpecificData.isNotEmpty) {
      daySpecificData.clear();
      _multiDayEvents.clear();
      for (var dayData in data.daySpecificData) {
        DateTime date = dayData.date;
        _initializeDayData(date);
        daySpecificData[date] = {
          'event': dayData.eventName ?? '',
          'time': dayData.eventTime ?? '00:00 AM',
          'location': dayData.location ?? '',
          'description': dayData.description ?? '',
          'reminder': dayData.reminder.text ?? '1 day before',
          'reminderValue': dayData.reminder.value ?? 1,
          'reminderType': dayData.reminder.type ?? 'Days before',
        };
        _multiDayEvents.add(
          MultiDayEventData(
              date: date,
              reminderValue: dayData.reminder.value ?? 1,
              reminderType: dayData.reminder.type ?? 'Days before',
            )
            ..eventController.text = dayData.eventName ?? ''
            ..timeController.text = dayData.eventTime ?? '00:00 AM'
            ..locationController.text = dayData.location ?? ''
            ..descriptionController.text = dayData.description ?? ''
            ..reminderController.text = dayData.reminder.text ?? '1 day before',
        );
      }
      selectedPlanDate = startDate;
      _loadDataForSelectedDay(selectedPlanDate!);
    } else {
      _timeController.text = data.singleDayDetails?.eventTime ?? '00:00 AM';
      _locationController.text = data.singleDayDetails?.location ?? '';
      _descriptionController.text = data.singleDayDetails?.description ?? '';
      _reminderController.text =
          data.singleDayDetails?.reminder.text ?? '1 day before';
      _reminderValue = data.singleDayDetails?.reminder.value ?? 1;
      _reminderType = data.singleDayDetails?.reminder.type ?? 'Days before';
      _updateReminderText();
    }
  }

  void _saveCurrentDayData() {
    if (selectedPlanDate != null && _isMultiDay) {
      daySpecificData[selectedPlanDate!] = {
        'event': _eventController.text.trim(),
        'time': _timeController.text.trim(),
        'location': _locationController.text.trim(),
        'description': _descriptionController.text.trim(),
        'reminder': _reminderController.text.trim(),
        'reminderValue': _reminderValue,
        'reminderType': _reminderType,
      };
      final event = _multiDayEvents.firstWhere(
        (e) => e.date == selectedPlanDate,
      );
      event.eventController.text = _eventController.text.trim();
      event.timeController.text = _timeController.text.trim();
      event.locationController.text = _locationController.text.trim();
      event.descriptionController.text = _descriptionController.text.trim();
      event.reminderController.text = _reminderController.text.trim();
      event.reminderValue = _reminderValue;
      event.reminderType = _reminderType;
    }
  }

  void _loadDataForSelectedDay(DateTime date) {
    _initializeDayData(date);
    final dayData = daySpecificData[date]!;
    setState(() {
      selectedPlanDate = date;
      _eventController.text = dayData['event'] ?? '';
      _timeController.text = dayData['time'] ?? '00:00 AM';
      _locationController.text = dayData['location'] ?? '';
      _descriptionController.text = dayData['description'] ?? '';
      _reminderController.text = dayData['reminder'] ?? '1 day before';
      _reminderValue = dayData['reminderValue'] ?? 1;
      _reminderType = dayData['reminderType'] ?? 'Days before';
    });
  }

  bool get isMultiDayEvent =>
      startDate != null && endDate != null && !_isSameDay(startDate!, endDate!);

  bool get areRequiredFieldsFilled {
    bool occasionFilled =
        selectedOccasion.isNotEmpty &&
        (selectedOccasion != 'Others' ||
            _customOccasionController.text.trim().isNotEmpty);
    if (!_isMultiDay) {
      return _titleController.text.trim().isNotEmpty &&
          occasionFilled &&
          _timeController.text.trim().isNotEmpty &&
          _locationController.text.trim().isNotEmpty;
    } else {
      bool hasValidDayData = _multiDayEvents.any(
        (dayData) =>
            dayData.eventController.text.trim().isNotEmpty &&
            dayData.timeController.text.trim().isNotEmpty &&
            dayData.locationController.text.trim().isNotEmpty,
      );
      return _titleController.text.trim().isNotEmpty &&
          occasionFilled &&
          hasValidDayData;
    }
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  List<DateTime> _getDateRange() {
    if (startDate == null || endDate == null) return [];
    List<DateTime> dates = [];
    DateTime current = startDate!;
    while (current.isBefore(endDate!) || _isSameDay(current, endDate!)) {
      dates.add(current);
      current = current.add(Duration(days: 1));
    }
    debugPrint('Date Range: ${dates.map((d) => _formatDate(d)).join(", ")}');
    return dates;
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _getDateSuffix(int day) {
    if (day >= 11 && day <= 13) return 'th';
    switch (day % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }

  // void _updateReminderText() {
  //   String unit = reminderType.toLowerCase();
  //   if (reminderValue == 1) {
  //     unit = unit.substring(0, unit.length - 1); // Remove 's' for singular
  //   }
  //   _reminderController.text = '$reminderValue $unit before';
  // }

  void _updateReminderText() {
    String unit = _reminderType.toLowerCase();
    if (_reminderValue == 1) {
      unit = unit.substring(0, unit.length - 1);
    }
    _reminderController.text = '$_reminderValue $unit before';
  }

  Future<void> _selectDate(bool isStart) async {
    // Get the current date for comparison
    final DateTime today = DateTime.now();

    // Determine the initial date to show in the picker
    DateTime initialDate;
    if (isStart) {
      initialDate = startDate!;
    } else {
      initialDate = endDate!;
    }

    // If the initial date is before today, use today as the initial date
    // This handles the case where we're editing an event with past dates
    if (initialDate.isBefore(today)) {
      initialDate = today;
    }

    // Set firstDate - in edit mode, allow past dates, otherwise start from today
    DateTime firstDate;
    if (widget.isEditMode) {
      // In edit mode, allow selecting any date from the original event date or earlier
      firstDate = DateTime(2020, 1, 1); // Or use a reasonable minimum date
    } else {
      // In create mode, only allow future dates
      firstDate = today;
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: DateTime.now().add(Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Color(0xFFE25C7E),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          // Ensure we're using the exact date without time manipulation
          startDate = DateTime(picked.year, picked.month, picked.day);
          if (endDate!.isBefore(startDate!)) {
            endDate = DateTime(picked.year, picked.month, picked.day);
          }
        } else {
          // Ensure we're using the exact date without time manipulation
          endDate = DateTime(picked.year, picked.month, picked.day);
        }
        _isMultiDay = isMultiDayEvent;
        daySpecificData.clear();
        _initializeDayData(startDate!);
        _initializeMultiDayEvents();
        selectedPlanDate = startDate;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: 0, minute: 0),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Color(0xFFE25C7E),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _timeController.text = picked.format(context);
      });
      if (_isMultiDay && selectedPlanDate != null) {
        _saveCurrentDayData();
        showSuccessSnackBar(
          context,
          'Time saved for ${_formatDate(selectedPlanDate!)}',
        );
      }
    }
  }

  Future<void> _submitEvent() async {
    Developer.log('Starting event submission');

    if (!_formKey.currentState!.validate()) {
      showErrorSnackBar(context, 'Please fill all required fields');
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      EventRequest eventRequest;

      // Create event request
      if (_isMultiDay) {
        _saveCurrentDayData();
        final daySpecificData = <String, DaySpecificData>{};
        for (final event in _multiDayEvents) {
          final dateKey = DateFormat('yyyy-MM-dd').format(event.date);
          daySpecificData[dateKey] = DaySpecificData(
            eventName: event.eventController.text.trim(),
            eventTime: event.timeController.text.trim(),
            location: event.locationController.text.trim(),
            description: event.descriptionController.text.trim(),
            reminder: ReminderData(
              value: event.reminderValue,
              type: event.reminderType,
              text: event.reminderController.text.trim(),
            ),
          );
        }
        eventRequest = EventApiService.createMultiDayEvent(
          title: _titleController.text.trim(),
          occasion: selectedOccasion == 'Others'
              ? _customOccasionController.text.trim()
              : selectedOccasion,
          startDate: DateTime.utc(
            startDate!.year,
            startDate!.month,
            startDate!.day,
          ),
          endDate: DateTime.utc(endDate!.year, endDate!.month, endDate!.day),
          daySpecificData: daySpecificData,
          timezone: _selectedTimezone,
        );
        Developer.log("Sending startDate: ${startDate!.toIso8601String()}");
      } else {
        // Fix: Convert single day date to UTC as well
        final eventDate = DateTime.utc(
          startDate!.year,
          startDate!.month,
          startDate!.day,
        );

        eventRequest = EventApiService.createSingleDayEvent(
          title: _titleController.text.trim(),
          occasion: selectedOccasion == 'Others'
              ? _customOccasionController.text.trim()
              : selectedOccasion,
          date: eventDate, // Use UTC date
          time: _timeController.text.trim(),
          location: _locationController.text.trim(),
          description: _descriptionController.text.trim(),
          reminder: _reminderController.text.trim(),
          reminderValue: _reminderValue,
          reminderType: _reminderType,
          timezone: _selectedTimezone,
        );

        Developer.log(
          "Sending single day date: ${eventDate.toIso8601String()}",
        );
      }

      Developer.log("Event request created: ${eventRequest.toString()}");

      // Make API call
      final response;
      if (widget.isEditMode) {
        response = await EventApiService.updateEvent(
          eventId: widget.eventData!.event.id,
          request: eventRequest,
        );
        // Call callback BEFORE navigation
        if (widget.onEventUpdatedCallBack != null &&
            response is EventResponse) {
          widget.onEventUpdatedCallBack!(response);
        } else {
          // If no callback provided, call the general callback
          widget.onEventUpdated?.call();
        }
      } else {
        response = await EventApiService.addEvent(eventRequest);
      }

      Developer.log("API response: ${response.toString()}");

      if (mounted) {
        // Show success message
        final message = widget.isEditMode
            ? 'Event updated successfully'
            : 'Event created successfully';
        showSuccessSnackBar(context, message);

        // Call the callback to notify parent
        widget.onEventUpdated?.call();

        // Close the modal - this should work for both single and multiday
        Future.delayed(Duration.zero, () {
          Navigator.of(context).pop(true);
          if (_isMultiDay) {
            Navigator.of(context).pop(true);
          }
        });
      }
    } catch (e) {
      Developer.log("Error in _submitEvent: $e");
      if (mounted) {
        String errorMessage =
            'Failed to ${widget.isEditMode ? 'update' : 'create'} event';
        if (e is EventApiException) {
          errorMessage = e.message;
        }
        showErrorSnackBar(context, errorMessage);
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? LoadingPage()
        : Container(
            height: MediaQuery.of(context).size.height * 0.9,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width * 0.0995,
                    height: 4,
                    margin: EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Color(0xFF141B34),
                                width: 1.5,
                              ),
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                            child: Icon(
                              Icons.close,
                              size: 20,
                              color: Color(0xFF141B34),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.only(
                        left: 16,
                        right: 16,
                        bottom: MediaQuery.of(context).viewInsets.bottom,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTitleField(),
                          SizedBox(
                            height:
                                MediaQuery.of(context).size.height *
                                0.022883295,
                          ),
                          _buildOccasionSection(),
                          SizedBox(
                            height:
                                MediaQuery.of(context).size.height *
                                0.022883295,
                          ),
                          _buildDateSection(),
                          SizedBox(
                            height:
                                MediaQuery.of(context).size.height *
                                0.022883295,
                          ),
                          if (_isMultiDay) ...[
                            _buildPlanForSection(),
                            SizedBox(
                              height:
                                  MediaQuery.of(context).size.height *
                                  0.022883295,
                            ),
                            _buildEventField(),
                            SizedBox(
                              height:
                                  MediaQuery.of(context).size.height *
                                  0.022883295,
                            ),
                          ],
                          _buildTimeField(),
                          SizedBox(
                            height:
                                MediaQuery.of(context).size.height *
                                0.022883295,
                          ),
                          _buildLocationField(),
                          SizedBox(
                            height:
                                MediaQuery.of(context).size.height *
                                0.022883295,
                          ),
                          _buildDescriptionField(),
                          SizedBox(
                            height:
                                MediaQuery.of(context).size.height *
                                0.022883295,
                          ),
                          _buildReminderField(),
                          SizedBox(
                            height:
                                MediaQuery.of(context).size.height *
                                0.022883295,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(16),
                    child: SizedBox(
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height * 0.0572082,
                      child: ElevatedButton(
                        onPressed: (areRequiredFieldsFilled)
                            ? _submitEvent
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: areRequiredFieldsFilled
                              ? Color(0xFFE25C7E)
                              : Color(0xFF6B7280),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(32),
                          ),
                          elevation: 0,
                        ),
                        child:
                            // isLoading
                            //     ? SizedBox(
                            //         height: MediaQuery.of(context).size.height * 0.022883295,
                            //         width: MediaQuery.of(context).size.width * 0.049751243,
                            //         child: CircularProgressIndicator(
                            //           color: Colors.white,
                            //           strokewidth: MediaQuery.of(context).size.width * 0.004975124,
                            //         ),
                            //       )
                            Text(
                              (widget.isEditMode) ? 'Update' : 'Save',
                              style: GoogleFonts.libreFranklin(
                                fontSize: MediaQuery.of(
                                  context,
                                ).textScaler.scale(16),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.018306636,
                  ),
                ],
              ),
            ),
          );
  }

  void _showReminderDialog() {
    int tempValue = _reminderValue;
    String tempType = _reminderType;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(32),
              ),
              child: Container(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Set Reminder',
                          style: GoogleFonts.libreFranklin(
                            fontSize: MediaQuery.of(
                              context,
                            ).textScaler.scale(18),
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF131927),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Container(
                            padding: EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.grey[100],
                            ),
                            child: Icon(
                              Icons.close,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.0274599,
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(32),
                      ),
                      child: TextFormField(
                        initialValue: tempValue.toString(),
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.start,
                        style: GoogleFonts.libreFranklin(
                          fontSize: MediaQuery.of(context).textScaler.scale(16),
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        onChanged: (value) {
                          int? newValue = int.tryParse(value);
                          if (newValue != null && newValue > 0) {
                            setDialogState(() => tempValue = newValue);
                          }
                        },
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.022883295,
                    ),
                    Column(
                      children: [
                        _buildReminderOption(
                          'Weeks before',
                          'Weeks before',
                          tempType,
                          (value) => setDialogState(() => tempType = value),
                        ),
                        SizedBox(
                          height:
                              MediaQuery.of(context).size.height * 0.013729977,
                        ),
                        _buildReminderOption(
                          'Days before',
                          'Days before',
                          tempType,
                          (value) => setDialogState(() => tempType = value),
                        ),
                        SizedBox(
                          height:
                              MediaQuery.of(context).size.height * 0.013729977,
                        ),
                        _buildReminderOption(
                          'Hours before',
                          'Hours before',
                          tempType,
                          (value) => setDialogState(() => tempType = value),
                        ),
                        SizedBox(
                          height:
                              MediaQuery.of(context).size.height * 0.013729977,
                        ),
                        _buildReminderOption(
                          'No reminders, I ❤️ FOMO',
                          'No reminders, I ❤️ FOMO',
                          tempType,
                          (value) => setDialogState(() => tempType = value),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.0274599,
                    ),
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _reminderValue = tempValue;
                            _reminderType = tempType;
                            if (_reminderType == 'None') {
                              _reminderController.text = 'No reminder';
                            } else {
                              _updateReminderText();
                            }
                            if (_isMultiDay && selectedPlanDate != null) {
                              _saveCurrentDayData();
                              showSuccessSnackBar(
                                context,
                                'Reminder saved for ${_formatDate(selectedPlanDate!)}',
                              );
                            }
                          });
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFE25C7E),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(32),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Done',
                          style: GoogleFonts.libreFranklin(
                            fontSize: MediaQuery.of(
                              context,
                            ).textScaler.scale(16),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildReminderOption(
    String title,
    String value,
    String currentValue,
    Function(String) onChanged,
  ) {
    bool isSelected = currentValue == value;
    return GestureDetector(
      onTap: () => onChanged(value),
      child: Row(
        children: [
          Container(
            width: MediaQuery.of(context).size.width * 0.049751243,
            height: MediaQuery.of(context).size.height * 0.022883295,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? Color(0xFFE25C7E) : Colors.grey[400]!,
                width: MediaQuery.of(context).size.width * 0.004975124,
              ),
            ),
            child: isSelected
                ? Center(
                    child: Container(
                      width: 8,
                      height: MediaQuery.of(context).size.height * 0.009153318,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFE25C7E),
                      ),
                    ),
                  )
                : null,
          ),
          SizedBox(width: 12),
          Text(
            title,
            style: GoogleFonts.libreFranklin(
              fontSize: MediaQuery.of(context).textScaler.scale(14),
              fontWeight: FontWeight.w500,
              color: Color(0xFF131927),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Title',
              style: GoogleFonts.libreFranklin(
                fontSize: MediaQuery.of(context).textScaler.scale(18),
                fontWeight: FontWeight.w600,
                color: Color(0xFF394050),
              ),
            ),
            Text(
              ' *',
              style: GoogleFonts.libreFranklin(
                fontSize: MediaQuery.of(context).textScaler.scale(18),
                fontWeight: FontWeight.w600,
                color: Color(0xFFFF5236),
              ),
            ),
          ],
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.009153318),
        TextFormField(
          controller: _titleController,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Title is required';
            }
            return null;
          },
          onChanged: (value) => setState(() {}),
          decoration: InputDecoration(
            hintText: 'Eg. Sara\'s birthday party',
            hintStyle: GoogleFonts.libreFranklin(
              color: Colors.grey[400],
              fontSize: MediaQuery.of(context).textScaler.scale(14),
            ),
            filled: true,
            fillColor: const Color(0xFFF5F5F5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(32),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(32),
              borderSide: BorderSide(
                color: Color(0xFFD87A9B),
                width: MediaQuery.of(context).size.width * 0.004975124,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(32),
              borderSide: const BorderSide(color: Colors.red, width: 1),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOccasionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Occasion',
              style: GoogleFonts.libreFranklin(
                fontSize: MediaQuery.of(context).textScaler.scale(18),
                fontWeight: FontWeight.w600,
                color: Color(0xFF394050),
              ),
            ),
            Text(
              ' *',
              style: GoogleFonts.libreFranklin(
                fontSize: MediaQuery.of(context).textScaler.scale(16),
                fontWeight: FontWeight.w600,
                color: Colors.red,
              ),
            ),
          ],
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.013729977),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: occasions.map((occasion) {
            final isSelected = selectedOccasion == occasion;
            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedOccasion = occasion;
                });
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? Color(0xFFE25C7E) : Colors.transparent,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: Color(0xFFE25C7E)),
                ),
                child: Text(
                  occasion,
                  style: GoogleFonts.libreFranklin(
                    fontSize: MediaQuery.of(context).textScaler.scale(14),
                    fontWeight: FontWeight.w500,
                    color: isSelected ? Colors.white : Colors.grey[700],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        if (selectedOccasion == 'Others') ...[
          SizedBox(height: MediaQuery.of(context).size.height * 0.013729977),
          TextFormField(
            controller: _customOccasionController,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Custom occasion is required';
              }
              return null;
            },
            onChanged: (value) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Enter custom occasion',
              hintStyle: GoogleFonts.libreFranklin(
                color: Colors.grey[400],
                fontSize: MediaQuery.of(context).textScaler.scale(14),
              ),
              filled: true,
              fillColor: const Color(0xFFF5F5F5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(32),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(32),
                borderSide: BorderSide(
                  color: Color(0xFFD87A9B),
                  width: MediaQuery.of(context).size.width * 0.004975124,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(32),
                borderSide: const BorderSide(color: Colors.red, width: 1),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDateSection() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Start date',
                style: GoogleFonts.libreFranklin(
                  fontSize: MediaQuery.of(context).textScaler.scale(16),
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF131927),
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.009153318,
              ),
              GestureDetector(
                onTap: () => _selectDate(true),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDate(startDate!),
                        style: GoogleFonts.libreFranklin(
                          fontSize: MediaQuery.of(context).textScaler.scale(14),
                          color: Color(0xFF394050),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      HugeIcon(
                        icon: HugeIcons.strokeRoundedCalendar03,
                        color: const Color(0xFF394050),
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: MediaQuery.of(context).size.width * 0.049751243),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'End date',
                style: GoogleFonts.libreFranklin(
                  fontSize: MediaQuery.of(context).textScaler.scale(16),
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF131927),
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.009153318,
              ),
              GestureDetector(
                onTap: () => _selectDate(false),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(32),
                    color: const Color(0xFFF5F5F5),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDate(endDate!),
                        style: GoogleFonts.libreFranklin(
                          fontSize: MediaQuery.of(context).textScaler.scale(14),
                          color: Color(0xFF394050),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      HugeIcon(
                        icon: HugeIcons.strokeRoundedCalendar03,
                        color: const Color(0xFF394050),
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlanForSection() {
    final dates = _getDateRange();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Plan for',
          style: GoogleFonts.libreFranklin(
            fontSize: MediaQuery.of(context).textScaler.scale(16),
            fontWeight: FontWeight.w600,
            color: Color(0xFF131927),
          ),
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.013729977),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: dates.map((date) {
            final dateStr =
                '${date.day}${_getDateSuffix(date.day)} ${_formatDate(date).split(' ')[1]}';
            final isSelected =
                selectedPlanDate != null && _isSameDay(selectedPlanDate!, date);
            final hasData =
                daySpecificData.containsKey(date) &&
                (daySpecificData[date]!['event']?.isNotEmpty == true ||
                    daySpecificData[date]!['location']?.isNotEmpty == true);
            return GestureDetector(
              onTap: () {
                _saveCurrentDayData();
                _loadDataForSelectedDay(date);
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Color(0xFFE25C7E)
                      : hasData
                      ? Color(0xFFE25C7E).withOpacity(0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(
                    color: isSelected
                        ? Color(0xFFE25C7E)
                        : hasData
                        ? Color(0xFFE25C7E).withOpacity(0.3)
                        : Colors.grey[300]!,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      dateStr,
                      style: GoogleFonts.libreFranklin(
                        fontSize: MediaQuery.of(context).textScaler.scale(14),
                        fontWeight: FontWeight.w500,
                        color: isSelected
                            ? Colors.white
                            : hasData
                            ? Color(0xFFE25C7E)
                            : Colors.grey[700],
                      ),
                    ),
                    if (hasData && !isSelected) ...[
                      SizedBox(width: 4),
                      Icon(Icons.check, size: 12, color: Color(0xFFE25C7E)),
                    ],
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.013729977),
        if (selectedPlanDate != null) ...[
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Color(0xFFE25C7E).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.edit, size: 16, color: Color(0xFFE25C7E)),
                SizedBox(width: 8),
                Text(
                  'Planning for ${_formatDate(selectedPlanDate!)}',
                  style: GoogleFonts.libreFranklin(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFFE25C7E),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildEventField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Event',
              style: GoogleFonts.libreFranklin(
                fontSize: MediaQuery.of(context).textScaler.scale(16),
                fontWeight: FontWeight.w600,
                color: Color(0xFF131927),
              ),
            ),
            Text(
              ' *',
              style: GoogleFonts.libreFranklin(
                fontSize: MediaQuery.of(context).textScaler.scale(16),
                fontWeight: FontWeight.w600,
                color: Colors.red,
              ),
            ),
          ],
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.009153318),
        TextFormField(
          controller: _eventController,
          validator: (value) {
            if (_isMultiDay && (value == null || value.trim().isEmpty)) {
              return 'Event is required for multi-day events';
            }
            return null;
          },
          onChanged: (value) {
            setState(() {});
            if (_isMultiDay && selectedPlanDate != null) {
              _saveCurrentDayData();
              if (value.trim().isNotEmpty) {
                showSuccessSnackBar(
                  context,
                  'Event saved for ${_formatDate(selectedPlanDate!)}',
                );
              }
            }
          },
          decoration: InputDecoration(
            hintText: 'Eg. Mehndi',
            hintStyle: GoogleFonts.libreFranklin(
              color: Colors.grey[400],
              fontSize: MediaQuery.of(context).textScaler.scale(14),
            ),
            filled: true,
            fillColor: const Color(0xFFF5F5F5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(32),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(32),
              borderSide: BorderSide(
                color: Color(0xFFD87A9B),
                width: MediaQuery.of(context).size.width * 0.004975124,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(32),
              borderSide: const BorderSide(color: Colors.red, width: 1),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Time',
              style: GoogleFonts.libreFranklin(
                fontSize: MediaQuery.of(context).textScaler.scale(16),
                fontWeight: FontWeight.w600,
                color: Color(0xFF131927),
              ),
            ),
            Text(
              ' *',
              style: GoogleFonts.libreFranklin(
                fontSize: MediaQuery.of(context).textScaler.scale(16),
                fontWeight: FontWeight.w600,
                color: Colors.red,
              ),
            ),
          ],
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.009153318),
        GestureDetector(
          onTap: _selectTime,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(32),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _timeController.text,
                  style: GoogleFonts.libreFranklin(
                    fontSize: MediaQuery.of(context).textScaler.scale(14),
                    color: AppColors.titleTextColor,
                  ),
                ),
                HugeIcon(
                  icon: HugeIcons.strokeRoundedClock01,
                  color: AppColors.titleTextColor,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Location',
              style: GoogleFonts.libreFranklin(
                fontSize: MediaQuery.of(context).textScaler.scale(16),
                fontWeight: FontWeight.w600,
                color: Color(0xFF131927),
              ),
            ),
            Text(
              ' *',
              style: GoogleFonts.libreFranklin(
                fontSize: MediaQuery.of(context).textScaler.scale(16),
                fontWeight: FontWeight.w600,
                color: Colors.red,
              ),
            ),
          ],
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.009153318),
        TextFormField(
          controller: _locationController,
          focusNode: _locationFocusNode,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Location is required';
            }
            return null;
          },
          onChanged: (value) {
            setState(() {});
            if (_isMultiDay && selectedPlanDate != null) {
              _saveCurrentDayData();
              if (value.trim().isNotEmpty) {
                showSuccessSnackBar(
                  context,
                  'Location saved for ${_formatDate(selectedPlanDate!)}',
                );
              }
            }
          },
          decoration: InputDecoration(
            hintText: 'Eg. Gurugram',
            hintStyle: GoogleFonts.libreFranklin(
              color: Colors.grey[400],
              fontSize: MediaQuery.of(context).textScaler.scale(14),
            ),
            filled: true,
            fillColor: const Color(0xFFF5F5F5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(32),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(32),
              borderSide: BorderSide(
                color: Color(0xFFD87A9B),
                width: MediaQuery.of(context).size.width * 0.004975124,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(32),
              borderSide: const BorderSide(color: Colors.red, width: 1),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description',
          style: GoogleFonts.libreFranklin(
            fontSize: MediaQuery.of(context).textScaler.scale(16),
            fontWeight: FontWeight.w600,
            color: Color(0xFF131927),
          ),
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.009153318),
        TextFormField(
          controller: _descriptionController,
          focusNode: _descriptionFocusNode,
          maxLines: 3,
          onChanged: (value) {
            if (_isMultiDay && selectedPlanDate != null) {
              _saveCurrentDayData();
              if (value.trim().isNotEmpty) {
                showSuccessSnackBar(
                  context,
                  'Description saved for ${_formatDate(selectedPlanDate!)}',
                );
              }
            }
          },
          decoration: InputDecoration(
            hintText: 'The theme, what kind of look etc.',
            hintStyle: GoogleFonts.libreFranklin(
              color: Colors.grey[400],
              fontSize: MediaQuery.of(context).textScaler.scale(14),
            ),
            filled: true,
            fillColor: const Color(0xFFF5F5F5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(32),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(32),
              borderSide: BorderSide(
                color: Color(0xFFD87A9B),
                width: MediaQuery.of(context).size.width * 0.004975124,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(32),
              borderSide: const BorderSide(color: Colors.red, width: 1),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReminderField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Remind me',
          style: GoogleFonts.libreFranklin(
            fontSize: MediaQuery.of(context).textScaler.scale(16),
            fontWeight: FontWeight.w600,
            color: Color(0xFF131927),
          ),
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.009153318),
        GestureDetector(
          onTap: _showReminderDialog,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              color: const Color(0xFFF5F5F5),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _reminderController.text,
                  style: GoogleFonts.libreFranklin(
                    fontSize: MediaQuery.of(context).textScaler.scale(14),
                    color: AppColors.titleTextColor,
                  ),
                ),
                HugeIcon(
                  icon: HugeIcons.strokeRoundedArrowDown01,
                  color: AppColors.titleTextColor,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class MultiDayEventData {
  final DateTime date;
  final TextEditingController eventController;
  final TextEditingController timeController;
  final TextEditingController locationController;
  final TextEditingController descriptionController;
  final TextEditingController reminderController;
  int reminderValue;
  String reminderType;

  MultiDayEventData({
    required this.date,
    this.reminderValue = 1,
    this.reminderType = 'Days before',
  }) : eventController = TextEditingController(),
       timeController = TextEditingController(),
       locationController = TextEditingController(),
       descriptionController = TextEditingController(),
       reminderController = TextEditingController(text: '1 day before');

  void dispose() {
    eventController.dispose();
    timeController.dispose();
    locationController.dispose();
    descriptionController.dispose();
    reminderController.dispose();
  }
}
