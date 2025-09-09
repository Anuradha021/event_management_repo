import 'dart:convert';
import 'package:event_management_app1/core/services/auth_storage_service.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:event_management_app1/core/config/api_config.dart';
import '../../features/events/models/ticket_model.dart';

class TicketService {
  static Future<Map<String, dynamic>> _authenticatedRequest(
    String endpoint, {
    String method = 'GET',
    Map<String, dynamic>? body,
  }) async {
    try {
      final token = await AuthStorageService.getToken();

      if (token == null) {
        return {'success': false, 'message': 'No token found'};
      }

      final url = Uri.parse('${ApiConfig.baseUrl}/$endpoint');

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      http.Response response;
      switch (method) {
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
        case 'DELETE':
          response = await http.delete(url, headers: headers);
          break;
        default:
          response = await http.get(url, headers: headers);
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body);
      } else {
        return {
          'success': false,
          'message': 'Request failed with status ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static List<dynamic> _extractDataFromResponse(
    Map<String, dynamic> response,
    String key,
  ) {
    if (response['success'] != true) {
      return [];
    }

    if (response['data'] != null && response['data'][key] is List) {
      return response['data'][key];
    }

    if (response[key] is List) {
      return response[key];
    }

    if (response['data'] is List) {
      return response['data'];
    }

    return [];
  }

  static Future<List<TicketType>> getAvailableTicketTypes(
    String eventId,
  ) async {
    try {
      final result = await _authenticatedRequest(
        'tickets/types?eventId=$eventId&availableOnly=true',
      );

      if (result['success'] == true) {
        List<dynamic> data = [];
        if (result['data'] != null && result['data']['ticketTypes'] != null) {
          data = result['data']['ticketTypes'];
        }

        return data.map((json) {
          try {
            return TicketType.fromJson(json);
          } catch (e) {
            final totalQuantity = json['totalQuantity'] ?? 0;
            final soldQuantity = json['soldQuantity'] ?? 0;
            final availableQuantity = totalQuantity - soldQuantity;
            final isActive = json['isActive'] ?? true;

            return TicketType(
              id: json['id'] ?? '',
              eventId: json['eventId'] ?? '',
              name: json['name'] ?? 'Unknown',
              description: json['description'] ?? '',
              price: (json['price'] ?? 0).toDouble(),
              totalQuantity: totalQuantity,
              soldQuantity: soldQuantity,
              availableQuantity: availableQuantity,
              isSoldOut: availableQuantity <= 0,
              isActive: isActive,
            );
          }
        }).toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  static Stream<List<Ticket>> getUserTicketsForEvent(String eventId) async* {
    try {
      final result = await _authenticatedRequest('tickets?eventId=$eventId');

      if (result['success'] == true) {
        final data = _extractDataFromResponse(result, 'tickets');
        yield data.map((json) => Ticket.fromJson(json)).toList();
      } else {
        yield [];
      }
    } catch (e) {
      yield [];
    }
  }

  static Future<List<TicketType>> getAvailableTickets(String eventId) async {
    try {
      final result = await _authenticatedRequest(
        'tickets/available?eventId=$eventId',
      );

      if (result['success'] == true) {
        List<dynamic> data = [];
        if (result['data'] != null && result['data']['tickets'] != null) {
          data = result['data']['tickets'];
        }

        final ticketTypes =
            data.map((json) {
              try {
                return TicketType.fromJson(json);
              } catch (e) {
                final totalQuantity = json['totalQuantity'] ?? 0;
                final soldQuantity = json['soldQuantity'] ?? 0;
                final availableQuantity = totalQuantity - soldQuantity;

                return TicketType(
                  id: json['id'] ?? '',
                  eventId: json['eventId'] ?? '',
                  name: json['name'] ?? 'Unknown',
                  description: json['description'] ?? '',
                  price: (json['price'] ?? 0).toDouble(),
                  totalQuantity: totalQuantity,
                  soldQuantity: soldQuantity,
                  availableQuantity: availableQuantity,
                  isActive: json['isActive'] ?? true,
                  isSoldOut: availableQuantity <= 0,
                );
              }
            }).toList();

        return ticketTypes;
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  static Stream<List<Ticket>> getUserTickets() async* {
    try {
      final result = await _authenticatedRequest('tickets');

      if (result['success'] == true) {
        final data = _extractDataFromResponse(result, 'tickets');
        yield data.map((json) => Ticket.fromJson(json)).toList();
      } else {
        yield [];
      }
    } catch (e) {
      yield [];
    }
  }

  static Future<Map<String, dynamic>> purchaseTicket({
    required String ticketTypeId,
    required String eventId,
    required String eventTitle,
  }) async {
    return _authenticatedRequest(
      'tickets/purchase',
      method: 'POST',
      body: {
        'ticketTypeId': ticketTypeId,
        'eventId': eventId,
        'eventTitle': eventTitle,
      },
    );
  }

  static Future<Map<String, dynamic>> validateTicket(String qrCode) async {
    return _authenticatedRequest(
      'tickets/validate',
      method: 'POST',
      body: {'qrCode': qrCode},
    );
  }

  static Future<Map<String, dynamic>> getEventStats(String eventId) async {
    return _authenticatedRequest('tickets/event-stats?eventId=$eventId');
  }

  static Future<Map<String, dynamic>> createTicketType({
    required String eventId,
    required String name,
    String description = '',
    required double price,
    required int totalQuantity,
  }) async {
    return _authenticatedRequest(
      'tickets/types',
      method: 'POST',
      body: {
        'eventId': eventId,
        'name': name,
        'description': description,
        'price': price,
        'totalQuantity': totalQuantity,
      },
    );
  }

  static Stream<List<TicketType>> getTicketTypesForOrganizer(
    String eventId,
  ) async* {
    try {
      final result = await _authenticatedRequest(
        'tickets/types?eventId=$eventId&organizer=true',
      );

      if (result['success'] == true) {
        if (result['data'] != null && result['data']['ticketTypes'] != null) {
          final ticketTypes =
              (result['data']['ticketTypes'] as List)
                  .map((json) => TicketType.fromJson(json))
                  .toList();
          yield ticketTypes;
        } else {
          yield [];
        }
      } else {
        yield [];
      }
    } catch (e) {
      yield [];
    }
  }

  static Future<Map<String, dynamic>> updateTicketType({
    required String ticketTypeId,
    required String name,
    required double price,
    required int totalQuantity,
  }) async {
    return _authenticatedRequest(
      'tickets/types/$ticketTypeId',
      method: 'PUT',
      body: {'name': name, 'price': price, 'totalQuantity': totalQuantity},
    );
  }

  static Future<Map<String, dynamic>> deleteTicketType(
    String ticketTypeId,
  ) async {
    try {
      final result = await _authenticatedRequest(
        'tickets/types/$ticketTypeId',
        method: 'DELETE',
      );

      return result;
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Stream<List<Ticket>> getTicketsForEvent(String eventId) async* {
    try {
      final result = await _authenticatedRequest(
        'tickets/sold?eventId=$eventId',
      );

      if (result['success'] == true) {
        List<dynamic> data = [];

        if (result['data'] != null && result['data']['tickets'] != null) {
          data = result['data']['tickets'];
        } else if (result['data'] != null && result['data'] is List) {
          data = result['data'];
        }

        yield data.map((json) => Ticket.fromJson(json)).toList();
      } else {
        yield [];
      }
    } catch (e) {
      yield [];
    }
  }

  static Future<Map<String, dynamic>> getEventData(String eventId) async {
    try {
      final result = await _authenticatedRequest('events/$eventId');
      if (result['success'] == true) return result['data'] ?? {};
      return {};
    } catch (e) {
      return {};
    }
  }
}
