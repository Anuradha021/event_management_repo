import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:event_management_app1/core/config/api_config.dart';
import 'auth_storage_service.dart';

class OrganizerDashboardService {
  static Future<Map<String, dynamic>> checkApprovalStatus() async {
    try {
      final token = await AuthStorageService.getToken();
      if (token == null) {
        return {'success': false, 'message': 'Not authenticated'};
      }
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/organizer/check-approval'),
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
          'message': 'Failed to check approval status: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  static Future<Map<String, dynamic>> updatePopupStatus() async {
    try {
      final token = await AuthStorageService.getToken();
      if (token == null) {
        return {'success': false, 'message': 'Not authenticated'};
      }
      final response = await http.patch(
        Uri.parse('${ApiConfig.baseUrl}/organizer/update-popup-status'),
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
          'message': 'Failed to update popup status: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  static Future<Map<String, dynamic>> submitEventRequest({
    required String eventTitle,
    required String eventDescription,
    required String organizerName,
    required String organizerEmail,
    required String location,
    required DateTime eventDate,
  }) async {
    try {
      final token = await AuthStorageService.getToken();
      if (token == null) {
        return {'success': false, 'message': 'Not authenticated'};
      }
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/organizer/submit-event-request'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'eventTitle': eventTitle,
          'eventDescription': eventDescription,
          'organizerName': organizerName,
          'organizerEmail': organizerEmail,
          'location': location,
          'eventDate': eventDate.toIso8601String(),
        }),
      );
      if (response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        return {
          'success': false,
          'message':
              'Failed to submit event request: ${response.statusCode} - ${response.body}',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  static Future<Map<String, dynamic>> getAssignedEvents() async {
    try {
      final token = await AuthStorageService.getToken();
      if (token == null) {
        return {'success': false, 'message': 'Not authenticated'};
      }
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/organizer/get-assigned-events'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          if (responseData['data'] != null &&
              responseData['data']['events'] != null) {
            final events =
                List<Map<String, dynamic>>.from(
                  responseData['data']['events'],
                ).map((event) {
                  return _convertFirestoreTimestamps(event);
                }).toList();
            return {'success': true, 'data': events};
          } else {
            return {'success': true, 'data': []};
          }
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
          'message': 'Failed to get assigned events: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  static Future<Map<String, dynamic>> checkOrganizerStatus() async {
    final token = await AuthStorageService.getToken();
    if (token == null) {
      return {
        'success': false,
        'message': 'No authentication token',
        'data': null,
        'isOrganizer': false,
      };
    }
    final url = Uri.parse('${ApiConfig.baseUrl}/organizer/check-approval');
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
        final isOrganizer =
            decoded['isApproved'] == true ||
            decoded['approved'] == true ||
            decoded['isOrganizer'] == true;
        return {
          'success': true,
          'isOrganizer': isOrganizer,
          'data': decoded,
          'message': 'Organizer status fetched successfully',
        };
      } else {
        return {
          'success': false,
          'isOrganizer': false,
          'message': 'Failed to fetch organizer status',
          'data': null,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'isOrganizer': false,
        'message': 'Network error: $e',
        'data': null,
      };
    }
  }

  static Map<String, dynamic> _convertFirestoreTimestamps(
    Map<String, dynamic> event,
  ) {
    final convertedEvent = Map<String, dynamic>.from(event);
    if (event['eventDate'] is Map && event['eventDate']['_seconds'] != null) {
      convertedEvent['eventDate'] =
          DateTime.fromMillisecondsSinceEpoch(
            event['eventDate']['_seconds'] * 1000,
          ).toIso8601String();
    }
    if (event['createdAt'] is Map && event['createdAt']['_seconds'] != null) {
      convertedEvent['createdAt'] =
          DateTime.fromMillisecondsSinceEpoch(
            event['createdAt']['_seconds'] * 1000,
          ).toIso8601String();
    }
    if (event['updatedAt'] is Map && event['updatedAt']['_seconds'] != null) {
      convertedEvent['updatedAt'] =
          DateTime.fromMillisecondsSinceEpoch(
            event['updatedAt']['_seconds'] * 1000,
          ).toIso8601String();
    }
    return convertedEvent;
  }

  static Future<Map<String, dynamic>> publishEvent(String eventId) async {
    try {
      final token = await AuthStorageService.getToken();
      if (token == null) {
        return {'success': false, 'message': 'Not authenticated'};
      }
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/organizer/publish-event'),
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
          '${ApiConfig.baseUrl}/organizer/get-event-management-data?eventId=$eventId',
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
              'Failed to get event management data: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }
}
