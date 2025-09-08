import 'dart:convert';
import 'package:event_management_app1/core/services/auth_storage_service.dart';
import 'package:http/http.dart' as http;

class AdminService {
  static const String baseUrl = "http://localhost:3001";

  static Future<Map<String, dynamic>> _authenticatedRequest(
    String endpoint, {
    String method = 'GET',
    Map<String, dynamic>? body,
  }) async {
    final token = await AuthStorageService.getToken();
    if (token == null) {
      return {'success': false, 'message': 'No authentication token'};
    }

    try {
      final uri = Uri.parse('$baseUrl/api/v1/admin/$endpoint');

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      http.Response response;

      switch (method.toUpperCase()) {
        case 'POST':
          response = await http.post(
            uri,
            headers: headers,
            body: jsonEncode(body),
          );
          break;
        case 'PATCH':
          response = await http.patch(
            uri,
            headers: headers,
            body: jsonEncode(body),
          );
          break;
        case 'PUT':
          response = await http.put(
            uri,
            headers: headers,
            body: jsonEncode(body),
          );
          break;
        case 'DELETE':
          response = await http.delete(uri, headers: headers);
          break;
        default:
          response = await http.get(uri, headers: headers);
          break;
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        return {'success': true, 'data': responseData};
      } else {
        return {
          'success': false,
          'message': 'Server error: ${response.statusCode} - ${response.body}',
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> getEventRequests({
    String? status,
    String? search,
  }) async {
    String endpoint = 'event-requests';
    final params = <String>[];
    if (status != null && status != 'all') params.add('status=$status');
    if (search != null && search.isNotEmpty) params.add('search=$search');

    if (params.isNotEmpty) {
      endpoint += '?${params.join('&')}';
    }

    return _authenticatedRequest(endpoint);
  }

  static Future<Map<String, dynamic>> updateRequestStatus(
    String requestId,
    String status,
  ) async {
    return _authenticatedRequest(
      'event-requests/$requestId/status',
      method: 'PATCH',
      body: {'status': status},
    );
  }

  static Future<Map<String, dynamic>> approveEventRequest(
    String requestId,
  ) async {
    return _authenticatedRequest(
      'event-requests/$requestId/approve',
      method: 'POST',
    );
  }

  static Future<Map<String, dynamic>> getUsers() async {
    return _authenticatedRequest('users');
  }

  static Future<Map<String, dynamic>> updateUserRole(
    String userId, {
    String? role,
    bool? isOrganizer,
  }) async {
    return _authenticatedRequest(
      'users/$userId/role',
      method: 'PATCH',
      body: {
        if (role != null) 'role': role,
        if (isOrganizer != null) 'isOrganizer': isOrganizer,
      },
    );
  }

  static Future<Map<String, dynamic>> createEvent({
    required String eventTitle,
    required String eventDescription,
    required DateTime eventDate,
    required String location,
    required String organizerEmail,
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
        'organizerEmail': organizerEmail,
        'category': category,
      },
    );
  }
}
