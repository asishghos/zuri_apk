// // This file contains day event specific models
// // Note: Main event models are defined in event_model.dart

// // DayEventDetailsResponse for backward compatibility
// class DayEventDetailsResponse {
//   final String message;
//   final DayEventDetails event;

//   DayEventDetailsResponse({required this.message, required this.event});

//   factory DayEventDetailsResponse.fromJson(Map<String, dynamic> json) {
//     return DayEventDetailsResponse(
//       message: json['message'],
//       event: DayEventDetails.fromJson(json['event']),
//     );
//   }
// }

// // DayEventDetails model for individual day events
// class DayEventDetails {
//   final String id;
//   final String parentEventId;
//   final String parentTitle;
//   final String parentOccasion;
//   final DateTime parentStartDate;
//   final DateTime parentEndDate;
//   final String title;
//   final DateTime date;
//   final String eventTime;
//   final String location;
//   final String description;
//   final ReminderInfo reminder;
//   final bool isDayEvent;
//   final bool isMultiDay;
//   final bool isStyled;
//   final List<String>? generatedImages;
//   final String timezone;
//   final DateTime createdAt;
//   final DateTime updatedAt;

//   DayEventDetails({
//     required this.id,
//     required this.parentEventId,
//     required this.parentTitle,
//     required this.parentOccasion,
//     required this.parentStartDate,
//     required this.parentEndDate,
//     required this.title,
//     required this.date,
//     required this.eventTime,
//     required this.location,
//     required this.description,
//     required this.reminder,
//     required this.isDayEvent,
//     required this.isMultiDay,
//     required this.isStyled,
//     required this.generatedImages,
//     required this.timezone,
//     required this.createdAt,
//     required this.updatedAt,
//   });

//   factory DayEventDetails.fromJson(Map<String, dynamic> json) {
//     return DayEventDetails(
//       id: json['_id'] ?? json['id'],
//       parentEventId: json['parentEventId'],
//       parentTitle: json['parentTitle'],
//       parentOccasion: json['parentOccasion'],
//       parentStartDate: DateTime.parse(json['parentStartDate']),
//       parentEndDate: DateTime.parse(json['parentEndDate']),
//       title: json['title'],
//       date: DateTime.parse(json['date']),
//       eventTime: json['eventTime'],
//       location: json['location'],
//       description: json['description'],
//       reminder: ReminderInfo.fromJson(json['reminder']),
//       isDayEvent: json['isDayEvent'],
//       isMultiDay: json['isMultiDay'],
//       isStyled: json['isStyled'] ?? false,
//       generatedImages:
//           json['generatedImages'] != null
//               ? List<String>.from(json['generatedImages'])
//               : [],
//       timezone: json['timezone'] ?? 'UTC',
//       createdAt: DateTime.parse(json['createdAt']),
//       updatedAt: DateTime.parse(json['updatedAt']),
//     );
//   }
// }

// // ReminderInfo model for day events
// class ReminderInfo {
//   final int value;
//   final String type;
//   final String text;
//   final bool isSent;

//   ReminderInfo({
//     required this.value,
//     required this.type,
//     required this.text,
//     required this.isSent,
//   });

//   factory ReminderInfo.fromJson(Map<String, dynamic> json) {
//     return ReminderInfo(
//       value: json['value'],
//       type: json['type'],
//       text: json['text'],
//       isSent: json['isSent'] ?? false,
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {'value': value, 'type': type, 'text': text, 'isSent': isSent};
//   }
// }
