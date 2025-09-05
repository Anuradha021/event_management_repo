import 'dart:convert';
import 'package:event_management_app1/core/services/auth_storage_service.dart';
import 'package:http/http.dart' as http;

class OrganizerEventService {
  static final String baseUrl = 'http://localhost:3001/api/v1';
  static Future<Map<String, dynamic>> getMyEvents({String? status}) async {
    try {
      final token = await AuthStorageService.getToken();
      if (token == null) {
        return {'success': false, 'message': 'Not authenticated'};
      }
      String url = '$baseUrl/organizer/get-my-events';
      if (status != null && status != 'all') {
        url += '?status=$status';
      }
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          return {'success': true, 'data': responseData};
        } else {
          return {
            'success': false,
            'message':
                responseData['error'] ??
                responseData['message'] ??
                'Unknown error',
          };
        }
      } else {
        return {
          'success': false,
          'message':
              'Failed to load events: ${response.statusCode} - ${response.body}',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  static Future<Map<String, dynamic>> getEventDetails(String eventId) async {
    try {
      final token = await AuthStorageService.getToken();
      if (token == null) {
        return {'success': false, 'message': 'Not authenticated'};
      }
      final response = await http.get(
        Uri.parse('$baseUrl/organizer/get-event-details?eventId=$eventId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          return {'success': true, 'data': responseData};
        } else {
          return {
            'success': false,
            'message':
                responseData['error'] ??
                responseData['message'] ??
                'Unknown error',
          };
        }
      } else {
        return {
          'success': false,
          'message':
              'Failed to load event details: ${response.statusCode} - ${response.body}',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  static Future<Map<String, dynamic>> updateEventStatus(
    String eventId,
    String status,
  ) async {
    try {
      final token = await AuthStorageService.getToken();
      if (token == null) {
        return {'success': false, 'message': 'Not authenticated'};
      }
      final response = await http.patch(
        Uri.parse('$baseUrl/organizer/update-event-status'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({'eventId': eventId, 'status': status}),
      );
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          return {'success': true, 'data': responseData};
        } else {
          return {
            'success': false,
            'message':
                responseData['error'] ??
                responseData['message'] ??
                'Unknown error',
          };
        }
      } else {
        return {
          'success': false,
          'message':
              'Failed to update event status: ${response.statusCode} - ${response.body}',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  static Future<Map<String, dynamic>> getPublishedEvents() async {
    try {
      final token = await AuthStorageService.getToken();
      if (token == null) {
        return {'success': false, 'message': 'Not authenticated'};
      }
      final response = await http.get(
        Uri.parse('$baseUrl/events/get-published-events'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          return {'success': true, 'data': responseData};
        } else {
          return {
            'success': false,
            'message':
                responseData['error'] ??
                responseData['message'] ??
                'Unknown error',
          };
        }
      } else {
        return {
          'success': false,
          'message':
              'Failed to load published events: ${response.statusCode} - ${response.body}',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }
}
