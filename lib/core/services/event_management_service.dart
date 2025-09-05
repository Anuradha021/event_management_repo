import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_storage_service.dart';

class EventManagementService {
  static final String baseUrl = 'http://localhost:3001/api/v1';
  static Future<Map<String, dynamic>> publishEvent(String eventId) async {
    try {
      final token = await AuthStorageService.getToken();
      if (token == null) {
        return {'success': false, 'message': 'Not authenticated'};
      }
      final response = await http.post(
        Uri.parse('$baseUrl/organizer/publish-event'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({'eventId': eventId}),
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {
          'success': false,
          'message':
              'Failed to publish event: ${response.statusCode} - ${response.body}',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  static Future<Map<String, dynamic>> getEventManagementData(
    String eventId,
  ) async {
    try {
      final token = await AuthStorageService.getToken();
      if (token == null) {
        return {'success': false, 'message': 'Not authenticated'};
      }
      final response = await http.get(
        Uri.parse(
          '$baseUrl/organizer/get-event-management-data?eventId=$eventId',
        ),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {
          'success': false,
          'message':
              'Failed to get event data: ${response.statusCode} - ${response.body}',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }
}
