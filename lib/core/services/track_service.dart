import 'dart:convert';
import 'package:event_management_app1/core/config/api_config.dart';
import 'package:event_management_app1/core/services/auth_storage_service.dart';
import 'package:http/http.dart' as http;

class TrackService {
  static Future<List<Map<String, dynamic>>> getTracks(
    String eventId,
    String zoneId,
  ) async {
    final token = await AuthStorageService.getToken();
    if (token == null) {
      throw Exception('No authentication token');
    }

    final url = Uri.parse('${ApiConfig.baseUrl}/tracks?eventId=$eventId&zoneId=$zoneId');

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
            decoded['data']['tracks'] ?? [],
          );
        } else {
          throw Exception(decoded['error'] ?? 'Failed to fetch tracks');
        }
      } else {
        throw Exception('Failed to fetch tracks: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<Map<String, dynamic>> createTrack(
    String eventId,
    String zoneId,
    String title,
    String description,
  ) async {
    final token = await AuthStorageService.getToken();
    if (token == null) {
      return {'success': false, 'message': 'No authentication token'};
    }

    final url = Uri.parse('${ApiConfig.baseUrl}/tracks');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'eventId': eventId,
          'zoneId': zoneId,
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

  static Future<Map<String, dynamic>> updateTrack(
    String eventId,
    String zoneId,
    String trackId,
    String title,
    String description,
  ) async {
    final token = await AuthStorageService.getToken();
    if (token == null) {
      return {'success': false, 'message': 'No authentication token'};
    }

    final url = Uri.parse('${ApiConfig.baseUrl}/tracks/$trackId');

    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'eventId': eventId,
          'zoneId': zoneId,
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

  static Future<Map<String, dynamic>> deleteTrack(
    String eventId,
    String zoneId,
    String trackId,
  ) async {
    final token = await AuthStorageService.getToken();
    if (token == null) {
      return {'success': false, 'message': 'No authentication token'};
    }

    try {
      final url = Uri.parse(
        '${ApiConfig.baseUrl}/tracks/$trackId?eventId=$eventId&zoneId=$zoneId',
      );

      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final decoded = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': decoded['success'] ?? false,
          'message': decoded['message'] ?? decoded['error'] ?? 'Unknown error',
          'data': decoded['data'],
        };
      } else {
        return {
          'success': false,
          'message':
              decoded['message'] ??
              decoded['error'] ??
              'Failed to delete track: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }
}
