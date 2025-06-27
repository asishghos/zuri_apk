// // This file contains multi-day event specific models
// // Note: Main event models are defined in event_model.dart

// // ParentEvent model for multi-day events
// class ParentEvent {
//   final String id;
//   final String title;
//   final String occasion;
//   final DateTime startDate;
//   final DateTime endDate;
//   final bool isStyled;
//   final List<String> generatedImages;

//   ParentEvent({
//     required this.id,
//     required this.title,
//     required this.occasion,
//     required this.startDate,
//     required this.endDate,
//     required this.isStyled,
//     required this.generatedImages,
//   });

//   factory ParentEvent.fromJson(Map<String, dynamic> json) {
//     return ParentEvent(
//       id: json['id'],
//       title: json['title'],
//       occasion: json['occasion'],
//       startDate: DateTime.parse(json['startDate']),
//       endDate: DateTime.parse(json['endDate']),
//       isStyled: json['isStyled'] ?? false,
//       generatedImages: List<String>.from(json['generatedImages'] ?? []),
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'title': title,
//       'occasion': occasion,
//       'startDate': startDate.toIso8601String(),
//       'endDate': endDate.toIso8601String(),
//       'isStyled': isStyled,
//       'generatedImages': generatedImages,
//     };
//   }
// }

// // class MultiDayEventCollectionResponse {
// //   final String message;
// //   final ParentEvent parentEvent;
// //   final List<DayEventItem> dayEvents;
// //   final int totalDayEvents;

// //   MultiDayEventCollectionResponse({
// //     required this.message,
// //     required this.parentEvent,
// //     required this.dayEvents,
// //     required this.totalDayEvents,
// //   });

// //   factory MultiDayEventCollectionResponse.fromJson(Map<String, dynamic> json) {
// //     return MultiDayEventCollectionResponse(
// //       message: json['message'] ?? '',
// //       parentEvent: ParentEvent.fromJson(json['parentEvent']),
// //       dayEvents:
// //           (json['dayEvents'] as List<dynamic>)
// //               .map((item) => DayEventItem.fromJson(item))
// //               .toList(),
// //       totalDayEvents: json['totalDayEvents'] ?? 0,
// //     );
// //   }
// // }

// // class DayEventItem {
// //   final String dayEventId;
// //   final String parentEventId;
// //   final String parentTitle;
// //   final String parentOccasion;
// //   final DateTime date;
// //   final String eventName;
// //   final String eventTime;
// //   final String location;
// //   final String description;
// //   final ReminderDetails reminder;
// //   final bool isStyled;
// //   final List<String> generatedImages;

// //   DayEventItem({
// //     required this.dayEventId,
// //     required this.parentEventId,
// //     required this.parentTitle,
// //     required this.parentOccasion,
// //     required this.date,
// //     required this.eventName,
// //     required this.eventTime,
// //     required this.location,
// //     required this.description,
// //     required this.reminder,
// //     required this.isStyled,
// //     required this.generatedImages,
// //   });

// //   factory DayEventItem.fromJson(Map<String, dynamic> json) {
// //     return DayEventItem(
// //       dayEventId: json['dayEventId'],
// //       parentEventId: json['parentEventId'],
// //       parentTitle: json['parentTitle'],
// //       parentOccasion: json['parentOccasion'],
// //       date: DateTime.parse(json['date']),
// //       eventName: json['eventName'],
// //       eventTime: json['eventTime'],
// //       location: json['location'],
// //       description: json['description'],
// //       reminder: ReminderDetails.fromJson(json['reminder']),
// //       isStyled: json['isStyled'] ?? false,
// //       generatedImages: List<String>.from(json['generatedImages'] ?? []),
// //     );
// //   }
// // }

// // class ReminderDetails {
// //   final int value;
// //   final String type;
// //   final String text;
// //   final bool isSent;

// //   ReminderDetails({
// //     required this.value,
// //     required this.type,
// //     required this.text,
// //     required this.isSent,
// //   });

// //   factory ReminderDetails.fromJson(Map<String, dynamic> json) {
// //     return ReminderDetails(
// //       value: json['value'],
// //       type: json['type'],
// //       text: json['text'],
// //       isSent: json['isSent'],
// //     );
// //   }
// // }
