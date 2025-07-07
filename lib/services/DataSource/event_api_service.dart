// services/event_api_service.dart
import 'dart:convert';
import 'dart:developer' as Developer;
import 'package:http/http.dart' as http;
import 'package:testing2/services/Class/event_model.dart';
import 'package:testing2/services/DataSource/auth_api.dart';
import 'package:testing2/services/api_routes.dart';

class EventApiService {
  // Add event API call
  static Future<EventResponse> addEvent(EventRequest eventRequest) async {
    try {
      final url = Uri.parse(ApiRoutes.addEvent);
      final body = json.encode(eventRequest.toJson());

      // Developer.log('Request URL: $url');
      // Developer.log('Request Body: $body');
      Developer.log("Event request created: ${eventRequest.toString()}");
      Developer.log(
        "Request Body (JSON): ${jsonEncode(eventRequest.toJson())}",
      );

      final response = await http.post(
        url,
        headers: await AuthApiService.getHeaders(includeAuth: true),
        body: body,
      );

      // Developer.log('Response Status: ${response.statusCode}');
      Developer.log('Response Body: ${response.body}');

      if (response.statusCode == 201) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return EventResponse.fromJson(responseData);
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        throw EventApiException(
          statusCode: response.statusCode,
          message:
              errorData['message'] ?? errorData['error'] ?? 'Unknown error',
          details: errorData,
        );
      }
    } catch (e) {
      if (e is EventApiException) {
        rethrow;
      }
      throw EventApiException(
        statusCode: 0,
        message: 'Network error: ${e.toString()}',
        details: {'error': e.toString()},
      );
    }
  }

  /// Fetches upcoming events for the authenticated user
  static Future<EventsResponse> getUpcomingEvents() async {
    try {
      final url = Uri.parse(ApiRoutes.getUpcomingEvents);
      final response = await http.get(
        url,
        headers: await AuthApiService.getHeaders(includeAuth: true),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        Developer.log(jsonData.toString());
        return EventsResponse.fromJson(jsonData);
      } else if (response.statusCode == 401) {
        throw EventServiceException(
          'Unauthorized - Please login again',
          statusCode: 401,
        );
      } else {
        final errorData = json.decode(response.body);
        throw EventServiceException(
          errorData['message'] ?? 'Failed to fetch upcoming events',
          statusCode: response.statusCode,
        );
      }
    } on EventServiceException {
      rethrow;
    } catch (e) {
      throw EventServiceException('Network error: ${e.toString()}');
    }
  }

  static Future<MultiDayEventCollectionResponse> getMultiDayEventCollection({
    required String eventId,
  }) async {
    final response = await http.get(
      Uri.parse("${ApiRoutes.getCollection}/$eventId"),
      headers: await AuthApiService.getHeaders(includeAuth: true),
    );
    // Developer.log(response.body.toString());
    if (response.statusCode == 200) {
      return MultiDayEventCollectionResponse.fromJson(
        jsonDecode(response.body),
      );
    } else {
      throw EventServiceException(
        "Failed to fetch",
        statusCode: response.statusCode,
      );
    }
  }

  static Future<EventResponse> getSingleEventDetails({
    required String eventId,
    required String dayEventId,
  }) async {
    final response = await http.get(
      Uri.parse("${ApiRoutes.getEventDetails}/$eventId/$dayEventId"),
      headers: await AuthApiService.getHeaders(includeAuth: true),
    );
    // Developer.log(response.body.toString());
    if (response.statusCode == 200) {
      return EventResponse.fromJson(jsonDecode(response.body));
    } else {
      throw EventServiceException(
        "Failed to fetch",
        statusCode: response.statusCode,
      );
    }
  }

  static Future<EventResponse> getSingleDayEventDetails({
    required String eventId,
  }) async {
    final response = await http.get(
      Uri.parse("${ApiRoutes.getEventDetails}/$eventId"),
      headers: await AuthApiService.getHeaders(includeAuth: true),
    );
    // Developer.log(response.body.toString());
    if (response.statusCode == 200) {
      return EventResponse.fromJson(jsonDecode(response.body));
    } else {
      throw EventServiceException(
        "Failed to fetch",
        statusCode: response.statusCode,
      );
    }
  }

  static Future<EventResponse> updateEvent({
    required String eventId,
    EventRequest? request,
    String? dayEventId,
  }) async {
    final response = await http.patch(
      Uri.parse(
        "${ApiRoutes.updateEvent}/$eventId${dayEventId != null ? '/$dayEventId' : ''}",
      ),
      headers: await AuthApiService.getHeaders(includeAuth: true),
      body: jsonEncode(request?.toJson()),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      Developer.log('Update Event Response: $data');
      return EventResponse.fromJson(data);
    } else {
      final data = jsonDecode(response.body);
      throw EventApiException(
        statusCode: response.statusCode,
        message: data['message'] ?? 'Failed to update event',
        details: data,
      );
    }
  }

  static Future<Map<String, dynamic>> deleteEvent({
    required String eventId,
    String? dayEventId,
  }) async {
    final response = await http.delete(
      Uri.parse(
        "${ApiRoutes.deleteEvent}/$eventId${dayEventId != null ? '/$dayEventId' : ''}",
      ),
      headers: await AuthApiService.getHeaders(includeAuth: true),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return {'success': true, 'message': data['message']};
    } else {
      throw EventApiException(
        statusCode: response.statusCode,
        message: data['message'] ?? 'Failed to delete event',
        details: data,
      );
    }
  }

  // Create single day event helper
  static EventRequest createSingleDayEvent({
    required String title,
    required String occasion,
    required DateTime date,
    required String time,
    required String location,
    required String description,
    String reminder = '1 day before',
    int reminderValue = 1,
    String reminderType = 'Days before',
    String timezone = 'UTC',
  }) {
    return EventRequest(
      title: title,
      occasion: occasion,
      startDate: date,
      endDate: date,
      isMultiDay: false,
      eventTime: time,
      location: location,
      description: description,
      reminder: reminder,
      reminderValue: reminderValue,
      reminderType: reminderType,
      timezone: timezone,
    );
  }

  // Create multi day event helper
  static EventRequest createMultiDayEvent({
    required String title,
    required String occasion,
    required DateTime startDate,
    required DateTime endDate,
    required Map<String, DaySpecificData> daySpecificData,
    String timezone = 'IST',
  }) {
    return EventRequest(
      title: title,
      occasion: occasion,
      startDate: startDate,
      endDate: endDate,
      isMultiDay: true,
      daySpecificData: daySpecificData,
      timezone: timezone,
    );
  }

  static Future<EventResponse?> addStyledImageToEvent({
    required String eventId,
    required List<String> styledImageUrls,
    String? dayEventId, // <-- optional for multi-day
  }) async {
    try {
      final String baseUrl = ApiRoutes.styleToEvent;
      final String url = dayEventId != null
          ? "$baseUrl/$eventId/$dayEventId"
          : "$baseUrl/$eventId";

      final uri = Uri.parse(url);

      // Send a single string if only 1 image, else send the full list
      final body = {
        "styledImageUrls": styledImageUrls.length == 1
            ? styledImageUrls[0]
            : styledImageUrls,
      };

      final response = await http.post(
        uri,
        headers: await AuthApiService.getHeaders(includeAuth: true)
          ..addAll({'Content-Type': 'application/json'}),
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        Developer.log("✅ Styled image(s) added to event successfully");
        Developer.log(response.body);
        final Map<String, dynamic> responseData = json.decode(response.body);
        return EventResponse.fromJson(responseData);
      } else {
        Developer.log(
          "❌ Failed to add styled image(s): ${response.statusCode} ${response.body}",
        );
        return null;
      }
    } catch (e) {
      Developer.log("❌ Exception in addStyledImageToEvent: $e");
      return null;
    }
  }
}
