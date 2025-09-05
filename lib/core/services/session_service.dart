import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_storage_service.dart';

class SessionService {
  static final String baseUrl = 'http://localhost:3001/api/v1';

  static Future<Map<String, dynamic>> createSession({
    required String eventId,
    required String zoneId,
    required String trackId,
    required String title,
    required String description,
    required String speaker,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    final token = await AuthStorageService.getToken();
    if (token == null) {
      return {'success': false, 'message': 'No authentication token'};
    }

    final url = Uri.parse(
      '$baseUrl/events/$eventId/zones/$zoneId/tracks/$trackId/sessions',
    );

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'title': title,
          'description': description,
          'speaker': speaker,
          'startTime': startTime.toIso8601String(),
          'endTime': endTime.toIso8601String(),
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

  static Future<List<Map<String, dynamic>>> getSessions(
    String eventId,
    String zoneId,
    String trackId,
  ) async {
    final token = await AuthStorageService.getToken();
    if (token == null) {
      throw Exception('No authentication token');
    }

    final url = Uri.parse(
      '$baseUrl/events/$eventId/zones/$zoneId/tracks/$trackId/sessions',
    );

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
          final sessions = decoded['data']?['sessions'] ?? [];
          return List<Map<String, dynamic>>.from(sessions);
        } else {
          throw Exception(decoded['error'] ?? 'Failed to fetch sessions');
        }
      } else {
        throw Exception('Failed to fetch sessions: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<Map<String, dynamic>> updateSession({
    required String eventId,
    required String zoneId,
    required String trackId,
    required String sessionId,
    String? title,
    String? description,
    String? speaker,
    DateTime? startTime,
    DateTime? endTime,
  }) async {
    final token = await AuthStorageService.getToken();
    if (token == null) {
      return {'success': false, 'message': 'No authentication token'};
    }

    final url = Uri.parse(
      '$baseUrl/events/$eventId/zones/$zoneId/tracks/$trackId/sessions/$sessionId',
    );

    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          if (title != null) 'title': title,
          if (description != null) 'description': description,
          if (speaker != null) 'speaker': speaker,
          if (startTime != null) 'startTime': startTime.toIso8601String(),
          if (endTime != null) 'endTime': endTime.toIso8601String(),
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

  static Future<Map<String, dynamic>> deleteSession({
    required String eventId,
    required String zoneId,
    required String trackId,
    required String sessionId,
  }) async {
    final token = await AuthStorageService.getToken();
    if (token == null) {
      return {'success': false, 'message': 'No authentication token'};
    }

    final url = Uri.parse(
      '$baseUrl/events/$eventId/zones/$zoneId/tracks/$trackId/sessions/$sessionId',
    );

    try {
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
      };
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }
}
