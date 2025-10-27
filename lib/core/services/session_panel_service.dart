import 'package:event_management_app1/core/config/api_config.dart';
import 'package:event_management_app1/core/services/auth_storage_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SessionPanelService {
  static Future<List<Map<String, dynamic>>> loadZones(String eventId) async {
    try {
      final token = await AuthStorageService.getToken();
      if (token == null) {
        throw Exception('No authentication token');
      }

      final url = Uri.parse('${ApiConfig.baseUrl}/zones?eventId=$eventId');

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
          final zones = decoded['data']?['zones'] ?? [];

          return List<Map<String, dynamic>>.from(zones);
        } else {
          throw Exception(decoded['error'] ?? decoded['message'] ?? 'Failed to fetch zones');
        }
      } else {
        throw Exception('Failed to fetch zones: ${response.statusCode}');
      }
    } catch (e) {
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> loadTracks(String eventId, String zoneId) async {
    try {
      final token = await AuthStorageService.getToken();
      if (token == null) {
        throw Exception('No authentication token');
      }

      final url = Uri.parse('${ApiConfig.baseUrl}/tracks?eventId=$eventId&zoneId=$zoneId');

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
          final tracks = decoded['data']?['tracks'] ?? [];

          return List<Map<String, dynamic>>.from(tracks);
        } else {
          throw Exception(decoded['error'] ?? decoded['message'] ?? 'Failed to fetch tracks');
        }
      } else {
        throw Exception('Failed to fetch tracks: ${response.statusCode}');
      }
    } catch (e) {
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> getSessions(
    String eventId,
    String zoneId,
    String trackId,
  ) async {
    try {
      final token = await AuthStorageService.getToken();
      if (token == null) {
        throw Exception('No authentication token');
      }

     final url = Uri.parse('${ApiConfig.baseUrl}/sessions/$eventId/zones/$zoneId/tracks/$trackId/sessions');

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
      return [];
    }
  }

  static Future<void> createSession(
    String eventId,
    String zoneId,
    String trackId,
    String title,
    String description,
    String speaker,
    DateTime startTime,
    DateTime endTime,
  ) async {
    try {
      final token = await AuthStorageService.getToken();
      if (token == null) {
        throw Exception('No authentication token');
      }

      final url = Uri.parse('${ApiConfig.baseUrl}/sessions/$eventId/zones/$zoneId/tracks/$trackId/sessions');

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

      if (response.statusCode != 201 || !decoded['success']) {
        throw Exception(decoded['error'] ?? decoded['message'] ?? 'Failed to create session');
      }
    } catch (e) {
      throw Exception('Failed to create session: $e');
    }
  }

  static Future<void> updateSession(
    String eventId,
    String zoneId,
    String trackId,
    String sessionId,
    String title,
    String description,
    String speaker,
  ) async {
    try {
      final token = await AuthStorageService.getToken();
      if (token == null) {
        throw Exception('No authentication token');
      }

     final url = Uri.parse('${ApiConfig.baseUrl}/sessions/$eventId/zones/$zoneId/tracks/$trackId/sessions/$sessionId');

      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({

          'title': title,
          'description': description,
          'speaker': speaker,
        }),
      );

      final decoded = jsonDecode(response.body);

      if (response.statusCode != 200 || !decoded['success']) {
        throw Exception(decoded['error'] ?? decoded['message'] ?? 'Failed to update session');
      }
    } catch (e) {
      throw Exception('Failed to update session: $e');
    }
  }

  static Future<void> deleteSession(
    String eventId,
    String zoneId,
    String trackId,
    String sessionId,
  ) async {
    try {
      final token = await AuthStorageService.getToken();
      if (token == null) {
        throw Exception('No authentication token');
      }

       final url = Uri.parse('${ApiConfig.baseUrl}/sessions/$eventId/zones/$zoneId/tracks/$trackId/sessions/$sessionId');

      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final decoded = jsonDecode(response.body);

      if (response.statusCode != 200 || !decoded['success']) {
        throw Exception(decoded['error'] ?? decoded['message'] ?? 'Failed to delete session');
      }
    } catch (e) {
      throw Exception('Failed to delete session: $e');
    }
  }
}
