import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:event_management_app1/core/services/auth_storage_service.dart';
import 'package:event_management_app1/core/config/api_config.dart';

class ProfileService {
  static Future<Map<String, String>> _getAuthHeaders() async {
    final token = await AuthStorageService.getToken();

    if (token == null) {
      throw Exception('No authentication token found');
    }

    final cleanToken = token.replaceAll('\n', '').replaceAll(' ', '').trim();

    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $cleanToken',
    };
  }

  static Future<bool> checkAuthentication() async {
    try {
      final headers = await _getAuthHeaders();
      final url = Uri.parse('${ApiConfig.baseUrl}/auth/check');
      final response = await http.get(url, headers: headers);
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final headers = await _getAuthHeaders();
      final url = Uri.parse('${ApiConfig.baseUrl}/user/profile');
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['error'] ?? 'Failed to fetch profile');
      }
    } catch (e) {
      rethrow;
    }
  }
}
