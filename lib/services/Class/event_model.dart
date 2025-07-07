// models/event_models.dart

// ========================================
// REQUEST MODELS
// ========================================

class EventRequest {
  final String title;
  final String occasion;
  final DateTime startDate;
  final DateTime endDate;
  final bool isMultiDay;
  final String? eventName;
  final String? eventTime;
  final String? location;
  final String? description;
  final String? reminder;
  final int? reminderValue;
  final String? reminderType;
  final Map<String, DaySpecificData>? daySpecificData;
  final String timezone;

  EventRequest({
    required this.title,
    required this.occasion,
    required this.startDate,
    required this.endDate,
    required this.isMultiDay,
    this.eventName,
    this.eventTime,
    this.location,
    this.description,
    this.reminder,
    this.reminderValue,
    this.reminderType,
    this.daySpecificData,
    this.timezone = 'UTC',
  });

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {
      'title': title,
      'occasion': occasion,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'isMultiDay': isMultiDay,
      'timezone': timezone,
    };

    if (isMultiDay && daySpecificData != null) {
      json['daySpecificData'] = daySpecificData!.map(
        (key, value) => MapEntry(key, value.toJson()),
      );
    } else {
      json.addAll({
        'eventName': eventName,
        'eventTime': eventTime,
        'location': location,
        'description': description,
        'reminder': reminder,
        'reminderValue': reminderValue,
        'reminderType': reminderType,
      });
    }

    return json;
  }
}

// ========================================
// RESPONSE MODELS
// ========================================

class EventResponse {
  final String message;
  final Event event;

  EventResponse({required this.message, required this.event});

  factory EventResponse.fromJson(Map<String, dynamic> json) {
    return EventResponse(
      message: json['message'],
      event: Event.fromJson(json['event']),
    );
  }
}

class Event {
  final String id;
  final String userId;
  final String title;
  final String occasion;
  final DateTime startDate;
  final DateTime endDate;
  final bool isMultiDay;
  final String timezone;
  final SingleDayDetails? singleDayDetails;
  final List<DaySpecificDetails> daySpecificData;
  final bool isStyled;
  final List<String>? generatedImages;

  Event({
    required this.id,
    required this.userId,
    required this.title,
    required this.occasion,
    required this.startDate,
    required this.endDate,
    required this.isMultiDay,
    required this.timezone,
    this.singleDayDetails,
    required this.daySpecificData,
    required this.isStyled,
    required this.generatedImages,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['_id'] ?? json['id'] ?? '',
      userId: json['userId'],
      title: json['title'],
      occasion: json['occasion'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      isMultiDay: json['isMultiDay'],
      timezone: json['timezone'],
      singleDayDetails: json['singleDayDetails'] != null
          ? SingleDayDetails.fromJson(json['singleDayDetails'])
          : null,
      daySpecificData: json['daySpecificData'] != null
          ? (json['daySpecificData'] as List)
                .map((item) => DaySpecificDetails.fromJson(item))
                .toList()
          : [],
      isStyled: json['isStyled'] ?? false,
      generatedImages: List<String>.from(json['generatedImages'] ?? []),
    );
  }
}

class DaySpecificDetails {
  final String id;
  final DateTime date;
  final String eventName;
  final String eventTime;
  final String location;
  final String description;
  final ReminderDetails reminder;
  final List<String>? daySpecificImage;

  DaySpecificDetails({
    required this.id,
    required this.date,
    required this.eventName,
    required this.eventTime,
    required this.location,
    required this.description,
    required this.reminder,
    this.daySpecificImage,
  });

  factory DaySpecificDetails.fromJson(Map<String, dynamic> json) {
    return DaySpecificDetails(
      id: json['_id'] ?? json['id'] ?? '',
      date: DateTime.parse(json['date']),
      eventName: json['eventName'],
      eventTime: json['eventTime'],
      location: json['location'],
      description: json['description'],
      reminder: ReminderDetails.fromJson(json['reminder']),
      daySpecificImage: List<String>.from(json['daySpecificImage'] ?? []),

      // daySpecificImage: json['daySpecificImage'],
    );
  }
}

// ========================================
// EVENTS LIST RESPONSE
// ========================================

class EventsResponse {
  final String message;
  final List<Event> events;

  EventsResponse({required this.message, required this.events});

  factory EventsResponse.fromJson(Map<String, dynamic> json) {
    return EventsResponse(
      message: json['message'] ?? '',
      events: (json['events'] as List? ?? [])
          .map((event) => Event.fromJson(event))
          .toList(),
    );
  }
}

// ========================================
// MULTI-DAY EVENT COLLECTION RESPONSE
// ========================================

class MultiDayEventCollectionResponse {
  final String message;
  final Event parentEvent;
  final List<DayEventItem> dayEvents;
  final int totalDayEvents;

  MultiDayEventCollectionResponse({
    required this.message,
    required this.parentEvent,
    required this.dayEvents,
    required this.totalDayEvents,
  });

  factory MultiDayEventCollectionResponse.fromJson(Map<String, dynamic> json) {
    return MultiDayEventCollectionResponse(
      message: json['message'] ?? '',
      parentEvent: Event.fromJson(json['parentEvent']),
      dayEvents: (json['dayEvents'] as List<dynamic>)
          .map((item) => DayEventItem.fromJson(item))
          .toList(),
      totalDayEvents: json['totalDayEvents'] ?? 0,
    );
  }
}

class DayEventItem {
  final String id;
  final String parentEventId;
  final String parentTitle;
  final String parentOccasion;
  final DateTime date;
  final String eventName;
  final String eventTime;
  final String location;
  final String description;
  final ReminderDetails reminder;
  final List<String>? daySpecificImage;
  final bool isStyled;
  final List<String> generatedImages;

  DayEventItem({
    required this.id,
    required this.parentEventId,
    required this.parentTitle,
    required this.parentOccasion,
    required this.date,
    required this.eventName,
    required this.eventTime,
    required this.location,
    required this.description,
    required this.reminder,
    this.daySpecificImage,
    required this.isStyled,
    required this.generatedImages,
  });

  factory DayEventItem.fromJson(Map<String, dynamic> json) {
    return DayEventItem(
      id: json['id'],
      parentEventId: json['parentEventId'],
      parentTitle: json['parentTitle'],
      parentOccasion: json['parentOccasion'],
      date: DateTime.parse(json['date']),
      eventName: json['eventName'],
      eventTime: json['eventTime'],
      location: json['location'],
      description: json['description'],
      reminder: ReminderDetails.fromJson(json['reminder']),
      daySpecificImage: List<String>.from(json['daySpecificImage'] ?? []),

      // daySpecificImage: json['daySpecificImage'],
      isStyled: json['isStyled'] ?? false,
      generatedImages: List<String>.from(json['generatedImages'] ?? []),
    );
  }
}

// // This file contains update event specific models

// // UpdateEventRequest model for updating events
class UpdateEventRequest {
  final String? title;
  final String? occasion;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool? isMultiDay;
  final SingleDayDetails? singleDayDetails;
  final Map<String, DaySpecificData>? daySpecificData;
  final String? timezone;
  final bool? isStyled;
  final List<String>? generatedImages;

  UpdateEventRequest({
    this.title,
    this.occasion,
    this.startDate,
    this.endDate,
    this.isMultiDay,
    this.singleDayDetails,
    this.daySpecificData,
    this.timezone,
    this.isStyled,
    this.generatedImages,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {};

    if (title != null) json['title'] = title;
    if (occasion != null) json['occasion'] = occasion;
    if (startDate != null) json['startDate'] = startDate!.toIso8601String();
    if (endDate != null) json['endDate'] = endDate!.toIso8601String();
    if (isMultiDay != null) json['isMultiDay'] = isMultiDay;
    if (timezone != null) json['timezone'] = timezone;
    if (isStyled != null) json['isStyled'] = isStyled;
    if (generatedImages != null) json['generatedImages'] = generatedImages;

    if (isMultiDay == true && daySpecificData != null) {
      json['daySpecificData'] = daySpecificData!.map(
        (key, value) => MapEntry(key, value.toJson()),
      );
    } else if (isMultiDay == false && singleDayDetails != null) {
      json['singleDayDetails'] = singleDayDetails!.toJson();
    }

    return json;
  }
}

// DaySpecificData model for multi-day events
class DaySpecificData {
  final String eventName;
  final String eventTime;
  final String location;
  final String description;
  final ReminderData? reminder;

  DaySpecificData({
    required this.eventName,
    required this.eventTime,
    required this.location,
    required this.description,
    this.reminder,
  });

  Map<String, dynamic> toJson() {
    return {
      'eventName': eventName,
      'eventTime': eventTime,
      'location': location,
      'description': description,
      'reminder': reminder?.toJson(),
    };
  }
}

// ReminderData model for reminders
class ReminderData {
  final int value;
  final String type;
  final String text;

  ReminderData({required this.value, required this.type, required this.text});

  Map<String, dynamic> toJson() {
    return {'value': value, 'type': type, 'text': text};
  }
}

// SingleDayDetails model for single day events
class SingleDayDetails {
  final String? eventTime;
  final String? location;
  final String? description;
  final ReminderDetails reminder;

  SingleDayDetails({
    this.eventTime,
    this.location,
    this.description,
    required this.reminder,
  });

  factory SingleDayDetails.fromJson(Map<String, dynamic> json) {
    return SingleDayDetails(
      eventTime: json['eventTime'],
      location: json['location'],
      description: json['description'],
      reminder: ReminderDetails.fromJson(json['reminder']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'eventTime': eventTime,
      'location': location,
      'description': description,
      'reminder': reminder.toJson(),
    };
  }
}

// ReminderDetails model for detailed reminders
class ReminderDetails {
  final int value;
  final String type;
  final String text;
  final bool isSent;

  ReminderDetails({
    required this.value,
    required this.type,
    required this.text,
    required this.isSent,
  });

  factory ReminderDetails.fromJson(Map<String, dynamic> json) {
    return ReminderDetails(
      value: json['value'],
      type: json['type'],
      text: json['text'],
      isSent: json['isSent'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {'value': value, 'type': type, 'text': text, 'isSent': isSent};
  }
}

// ========================================
// EVENT REMINDERS RESPONSE
// ========================================

class EventRemindersResponse {
  final String message;
  final List<EventReminder> reminders;

  EventRemindersResponse({required this.message, required this.reminders});

  factory EventRemindersResponse.fromJson(Map<String, dynamic> json) {
    return EventRemindersResponse(
      message: json['message'] ?? '',
      reminders: (json['reminders'] as List? ?? [])
          .map((reminder) => EventReminder.fromJson(reminder))
          .toList(),
    );
  }
}

class EventReminder {
  final String eventId;
  final String? dayEventId;
  final String eventName;
  final DateTime date;
  final ReminderDetails reminder;
  final bool isMultiDay;

  EventReminder({
    required this.eventId,
    this.dayEventId,
    required this.eventName,
    required this.date,
    required this.reminder,
    required this.isMultiDay,
  });

  factory EventReminder.fromJson(Map<String, dynamic> json) {
    return EventReminder(
      eventId: json['eventId'],
      dayEventId: json['dayEventId'],
      eventName: json['eventName'],
      date: DateTime.parse(json['date']),
      reminder: ReminderDetails.fromJson(json['reminder']),
      isMultiDay: json['isMultiDay'],
    );
  }
}

// ========================================
// EXCEPTION CLASSES
// ========================================

class EventApiException implements Exception {
  final int statusCode;
  final String message;
  final Map<String, dynamic>? details;

  EventApiException({
    required this.statusCode,
    required this.message,
    this.details,
  });

  @override
  String toString() {
    return 'EventApiException: $message (Status: $statusCode)';
  }
}

class EventServiceException implements Exception {
  final String message;
  final int? statusCode;

  EventServiceException(this.message, {this.statusCode});

  @override
  String toString() => 'EventServiceException: $message';
}
