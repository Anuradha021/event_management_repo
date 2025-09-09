import 'dart:convert';
import 'package:event_management_app1/core/config/api_config.dart';
import 'package:event_management_app1/core/services/auth_storage_service.dart';
import 'package:http/http.dart' as http;

class ZoneService {
  static Future<List<Map<String, dynamic>>> getZones(String eventId) async {
    final token = await AuthStorageService.getToken();
    if (token == null) {
      throw Exception('No authentication token');
    }

    final url = Uri.parse('${ApiConfig.baseUrl}/zones?eventId=$eventId');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded['success'] == true) {
          return List<Map<String, dynamic>>.from(
            decoded['data']['zones'] ?? [],
          );
        } else {
          throw Exception(decoded['error'] ?? 'Failed to fetch zones');
        }
      } else {
        throw Exception('Failed to fetch zones: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<Map<String, dynamic>> createZone(
    String eventId,
    String title,
    String description,
  ) async {
    final token = await AuthStorageService.getToken();
    if (token == null) {
      return {'success': false, 'message': 'No authentication token'};
    }

    final url = Uri.parse('${ApiConfig.baseUrl}/zones');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'eventId': eventId,
          'title': title,
          'description': description,
        }),
      );

      final decoded = jsonDecode(response.body);
      return {
        'success': decoded['success'] ?? false,
        'message': decoded['message'] ?? decoded['error'] ?? 'Unknown error',
        'data': decoded['data'],
      };
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> updateZone(
    String eventId,
    String zoneId,
    String title,
    String description,
  ) async {
    final token = await AuthStorageService.getToken();
    if (token == null) {
      return {'success': false, 'message': 'No authentication token'};
    }

    final url = Uri.parse('${ApiConfig.baseUrl}/zones/$zoneId');

    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'eventId': eventId,
          'title': title,
          'description': description,
        }),
      );

      final decoded = jsonDecode(response.body);
      return {
        'success': decoded['success'] ?? false,
        'message': decoded['message'] ?? decoded['error'] ?? 'Unknown error',
        'data': decoded['data'],
      };
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> deleteZone(
    String eventId,
    String zoneId,
  ) async {
    final token = await AuthStorageService.getToken();
    if (token == null) {
      return {'success': false, 'message': 'No authentication token'};
    }

    try {
      final encodedEventId = Uri.encodeComponent(eventId);
      final url = Uri.parse('${ApiConfig.baseUrl}/zones/$zoneId?eventId=$encodedEventId');

      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final decoded = jsonDecode(response.body);

      return {
        'success': decoded['success'] ?? false,
        'message': decoded['message'] ?? decoded['error'] ?? 'Unknown error',
        'data': decoded['data'],
      };
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }
}
