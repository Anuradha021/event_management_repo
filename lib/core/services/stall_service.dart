import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:event_management_app1/core/config/api_config.dart';
import 'package:event_management_app1/core/services/auth_storage_service.dart';

class StallApiService {
  static Future<Map<String, dynamic>> createStall(
    String eventId,
    String zoneId,
    String trackId,
    String name,
    String description,
  ) async {
    try {
      final token = await AuthStorageService.getToken();
      final response = await http.post(
        Uri.parse(
          '${ApiConfig.baseUrl}/events/$eventId/zones/$zoneId/tracks/$trackId/stalls',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'eventId': eventId,
          'zoneId': zoneId,
          'trackId': trackId,
          'name': name,
          'description': description,
        }),
      );

      final decoded = json.decode(response.body);

      if (response.statusCode == 201 && decoded['success'] == true) {
        return decoded;
      } else {
        throw Exception(decoded['message'] ?? 'Failed to create stall');
      }
    } catch (e) {
      throw Exception('Failed to create stall: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> getStalls(
    String eventId,
    String zoneId,
    String trackId,
  ) async {
    try {
      final token = await AuthStorageService.getToken();
      final response = await http.get(
        Uri.parse(
          '${ApiConfig.baseUrl}/events/$eventId/zones/$zoneId/tracks/$trackId/stalls',
        ),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);

        if (decoded is List) {
          return List<Map<String, dynamic>>.from(decoded);
        } else if (decoded['data'] != null) {
          if (decoded['data'] is List) {
            return List<Map<String, dynamic>>.from(decoded['data']);
          } else if (decoded['data']['stalls'] != null) {
            return List<Map<String, dynamic>>.from(decoded['data']['stalls']);
          }
        } else if (decoded['stalls'] != null) {
          return List<Map<String, dynamic>>.from(decoded['stalls']);
        }

        return [];
      } else {
        throw Exception('Failed to load stalls: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load stalls: $e');
    }
  }

  static Future<Map<String, dynamic>> updateStall(
    String eventId,
    String zoneId,
    String trackId,
    String stallId,
    String name,
    String description,
  ) async {
    try {
      final token = await AuthStorageService.getToken();
      final response = await http.put(
        Uri.parse(
          '${ApiConfig.baseUrl}/events/$eventId/zones/$zoneId/tracks/$trackId/stalls/$stallId',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'name': name, 'description': description}),
      );

      final decoded = json.decode(response.body);

      if (response.statusCode == 200 && decoded['success'] == true) {
        return decoded;
      } else {
        throw Exception(decoded['message'] ?? 'Failed to update stall');
      }
    } catch (e) {
      throw Exception('Failed to update stall: $e');
    }
  }

  static Future<void> deleteStall(
    String eventId,
    String zoneId,
    String trackId,
    String stallId,
  ) async {
    try {
      final token = await AuthStorageService.getToken();

      final response = await http.delete(
        Uri.parse(
          '${ApiConfig.baseUrl}/events/$eventId/zones/$zoneId/tracks/$trackId/stalls/$stallId',
        ),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.body.trim().startsWith('<!DOCTYPE') ||
          response.body.trim().startsWith('<html>')) {
        throw Exception(
          'Server error: Received HTML response. Check API endpoint or server status',
        );
      }

      try {
        final decoded = json.decode(response.body);

        if (response.statusCode == 200 && decoded['success'] == true) {
          return;
        } else {
          throw Exception(
            decoded['message'] ??
                'Failed to delete stall. Status: ${response.statusCode}',
          );
        }
      } catch (jsonError) {
        if (response.statusCode == 200 || response.statusCode == 204) {
          return;
        } else {
          throw Exception(
            'Failed to delete stall. Status: ${response.statusCode}, Response: ${response.body}',
          );
        }
      }
    } on http.ClientException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to delete stall: $e');
    }
  }

  static Future<Map<String, dynamic>> getStallDetails(
    String eventId,
    String zoneId,
    String trackId,
    String stallId,
  ) async {
    try {
      final token = await AuthStorageService.getToken();
      final response = await http.get(
        Uri.parse(
          '${ApiConfig.baseUrl}/events/$eventId/zones/$zoneId/tracks/$trackId/stalls/$stallId',
        ),
        headers: {'Authorization': 'Bearer $token'},
      );

      final decoded = json.decode(response.body);

      if (response.statusCode == 200 && decoded['success'] == true) {
        return decoded['data'] ?? {};
      } else {
        throw Exception(decoded['message'] ?? 'Failed to load stall details');
      }
    } catch (e) {
      throw Exception('Failed to load stall details: $e');
    }
  }
}
