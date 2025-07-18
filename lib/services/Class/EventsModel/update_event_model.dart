// // This file contains update event specific models

// // UpdateEventRequest model for updating events
// class UpdateEventRequest {
//   final String? title;
//   final String? occasion;
//   final DateTime? startDate;
//   final DateTime? endDate;
//   final bool? isMultiDay;
//   final SingleDayDetails? singleDayDetails;
//   final Map<String, DaySpecificData>? daySpecificData;
//   final String? timezone;
//   final bool? isStyled;
//   final List<String>? generatedImages;

//   UpdateEventRequest({
//     this.title,
//     this.occasion,
//     this.startDate,
//     this.endDate,
//     this.isMultiDay,
//     this.singleDayDetails,
//     this.daySpecificData,
//     this.timezone,
//     this.isStyled,
//     this.generatedImages,
//   });

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> json = {};

//     if (title != null) json['title'] = title;
//     if (occasion != null) json['occasion'] = occasion;
//     if (startDate != null) json['startDate'] = startDate!.toIso8601String();
//     if (endDate != null) json['endDate'] = endDate!.toIso8601String();
//     if (isMultiDay != null) json['isMultiDay'] = isMultiDay;
//     if (timezone != null) json['timezone'] = timezone;
//     if (isStyled != null) json['isStyled'] = isStyled;
//     if (generatedImages != null) json['generatedImages'] = generatedImages;

//     if (isMultiDay == true && daySpecificData != null) {
//       json['daySpecificData'] = daySpecificData!.map(
//         (key, value) => MapEntry(key, value.toJson()),
//       );
//     } else if (isMultiDay == false && singleDayDetails != null) {
//       json['singleDayDetails'] = singleDayDetails!.toJson();
//     }

//     return json;
//   }
// }

// // DaySpecificData model for multi-day events
// class DaySpecificData {
//   final String eventName;
//   final String eventTime;
//   final String location;
//   final String description;
//   final ReminderData? reminder;

//   DaySpecificData({
//     required this.eventName,
//     required this.eventTime,
//     required this.location,
//     required this.description,
//     this.reminder,
//   });

//   Map<String, dynamic> toJson() {
//     return {
//       'eventName': eventName,
//       'eventTime': eventTime,
//       'location': location,
//       'description': description,
//       'reminder': reminder?.toJson(),
//     };
//   }
// }

// // ReminderData model for reminders
// class ReminderData {
//   final int value;
//   final String type;
//   final String text;

//   ReminderData({required this.value, required this.type, required this.text});

//   Map<String, dynamic> toJson() {
//     return {'value': value, 'type': type, 'text': text};
//   }
// }

// // SingleDayDetails model for single day events
// class SingleDayDetails {
//   final String? eventTime;
//   final String? location;
//   final String? description;
//   final ReminderDetails reminder;

//   SingleDayDetails({
//     this.eventTime,
//     this.location,
//     this.description,
//     required this.reminder,
//   });

//   factory SingleDayDetails.fromJson(Map<String, dynamic> json) {
//     return SingleDayDetails(
//       eventTime: json['eventTime'],
//       location: json['location'],
//       description: json['description'],
//       reminder: ReminderDetails.fromJson(json['reminder']),
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'eventTime': eventTime,
//       'location': location,
//       'description': description,
//       'reminder': reminder.toJson(),
//     };
//   }
// }

// // ReminderDetails model for detailed reminders
// class ReminderDetails {
//   final int value;
//   final String type;
//   final String text;
//   final bool isSent;

//   ReminderDetails({
//     required this.value,
//     required this.type,
//     required this.text,
//     required this.isSent,
//   });

//   factory ReminderDetails.fromJson(Map<String, dynamic> json) {
//     return ReminderDetails(
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
