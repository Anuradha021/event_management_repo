import 'dart:convert';
import 'package:event_management_app1/core/config/api_config.dart';
import 'package:event_management_app1/core/services/auth_storage_service.dart';
import 'package:http/http.dart' as http;

class EventService {
  static Future<Map<String, dynamic>> _authenticatedRequest(
  String endpoint, {
  String method = 'GET',
  Map<String, dynamic>? body,
}) async {
  final token = await AuthStorageService.getToken();
  if (token == null) {
    return {
      'success': false,
      'message': 'No authentication token',
      'data': null,
    };
  }
  final url = Uri.parse("${ApiConfig.baseUrl}/$endpoint");
  final headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  };
  try {
    http.Response response;
    switch (method.toUpperCase()) {
      case 'POST':
        response = await http.post(
          url,
          headers: headers,
          body: jsonEncode(body),
        );
        break;
      case 'PUT':
        response = await http.put(
          url,
          headers: headers,
          body: jsonEncode(body),
        );
        break;
      case 'PATCH':
        response = await http.patch(
          url,
          headers: headers,
          body: jsonEncode(body),
        );
        break;
      case 'DELETE':
        response = await http.delete(url, headers: headers);
        break;
      default:
        response = await http.get(url, headers: headers);
    }
    
    final decoded = jsonDecode(response.body);
    
    if (response.statusCode == 200 || response.statusCode == 201) {
      if (decoded['success'] == true) {
        return {
          'success': true, 
          'data': decoded['data'], 
          'message': 'OK'
        };
      } else {
        return {
          'success': false,
          'message': decoded['error'] ?? 'Backend returned unsuccessful response',
          'data': null,
        };
      }
    } else {
      return {
        'success': false,
        'message': decoded['message'] ?? decoded['error'] ?? 'Server error: ${response.statusCode}',
        'data': null,
      };
    }
  } catch (e) {
    return {'success': false, 'message': 'Network error: $e', 'data': null};
  }
}

  static Future<Map<String, dynamic>> getPublishedEvents({
    String? search,
    String? category,
  }) async {
    String endpoint = 'events/get-published-events';
    final params = <String>[];
    if (search != null && search.isNotEmpty) params.add('search=$search');
    if (category != null && category != 'All') params.add('category=$category');
    if (params.isNotEmpty) {
      endpoint += '?${params.join('&')}';
    }
    final result = await _authenticatedRequest(endpoint);
    return result;
  }

  static Future<Map<String, dynamic>> getEvents({
    String? search,
    String? category,
  }) async {
    String endpoint = 'events/get-events';
    final params = <String>[];
    if (search != null && search.isNotEmpty) params.add('search=$search');
    if (category != null && category != 'All') params.add('category=$category');
    if (params.isNotEmpty) {
      endpoint += '?${params.join('&')}';
    }
    return _authenticatedRequest(endpoint);
  }

  static Future<Map<String, dynamic>> getEventDetails(String eventId) async {
    return _authenticatedRequest('events/$eventId');
  }

  static Future<Map<String, dynamic>> createEvent({
    required String eventTitle,
    required String eventDescription,
    required DateTime eventDate,
    required String location,
    required String category,
  }) async {
    return _authenticatedRequest(
      'events',
      method: 'POST',
      body: {
        'eventTitle': eventTitle,
        'eventDescription': eventDescription,
        'eventDate': eventDate.toIso8601String(),
        'location': location,
        'category': category,
      },
    );
  }

  static Future<Map<String, dynamic>> updateEvent(
    String eventId, {
    String? eventTitle,
    String? eventDescription,
    DateTime? eventDate,
    String? location,
    String? category,
  }) async {
    return _authenticatedRequest(
      'events/$eventId',
      method: 'PATCH',
      body: {
        if (eventTitle != null) 'eventTitle': eventTitle,
        if (eventDescription != null) 'eventDescription': eventDescription,
        if (eventDate != null) 'eventDate': eventDate.toIso8601String(),
        if (location != null) 'location': location,
        if (category != null) 'category': category,
      },
    );
  }

  static Future<Map<String, dynamic>> deleteEvent(String eventId) async {
    return _authenticatedRequest('events/$eventId', method: 'DELETE');
  }

  static Future<Map<String, dynamic>> getMyEvents() async {
    return _authenticatedRequest('organizer/get-my-events');
  }

  static Future<Map<String, dynamic>> updateEventStatus(
    String eventId,
    String status,
  ) async {
    return _authenticatedRequest(
      'organizer/update-event-status',
      method: 'PATCH',
      body: {'eventId': eventId, 'status': status},
    );
  }

  static Future<Map<String, dynamic>> getEventManagementData(
    String eventId,
  ) async {
    return _authenticatedRequest(
      'organizer/get-event-management-data?eventId=$eventId',
    );
  }

  static Future<Map<String, dynamic>> publishEvent(String eventId) async {
    return _authenticatedRequest(
      'organizer/publish-event',
      method: 'POST',
      body: {'eventId': eventId},
    );
  }
}
