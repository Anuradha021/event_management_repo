import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_storage_service.dart';

class AuthUser {
  final String id;
  final String? email;
  final String? name;
  final String role;

  AuthUser({required this.id, this.email, this.name, required this.role});

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'] ?? '',
      email: json['email'],
      name: json['name'],
      role: (json['role'] ?? 'USER').toString().toUpperCase(),
    );
  }
}

class AuthResult {
  final bool isSuccess;
  final String? message;
  final AuthUser? user;
  final String? token;

  AuthResult({required this.isSuccess, this.message, this.user, this.token});

  factory AuthResult.fromJson(Map<String, dynamic> json) {
    return AuthResult(
      isSuccess: json['isSuccess'] == true,
      message: json['message'],
      user: json['user'] != null ? AuthUser.fromJson(json['user']) : null,
      token: json['token'],
    );
  }
}

class AuthService {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3001',
  );

  static Future<String?> getToken() async {
    return await AuthStorageService.getToken();
  }

  Future<AuthResult> login({required String email, required String password}) async {
  final uri = Uri.parse('$baseUrl/api/v1/auth/login');
  
  try {
    final resp = await http.post(
      uri, 
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    ).timeout(Duration(seconds: 10));

    if (resp.body.contains('<!DOCTYPE') || resp.body.contains('<html')) {
      return AuthResult(
        isSuccess: false, 
        message: "Server returned HTML. Check if backend is running on $baseUrl"
      );
    }
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        
        if (data['token'] != null && data['uid'] != null) {
          String customToken = data['token'];
          String uid = data['uid'];
        
          final me = await meWithToken(customToken);
          if (me.isSuccess && me.user != null) {
            await AuthStorageService.saveSession(
              token: customToken, 
              role: me.user!.role,
              name: me.user!.name,
              email: me.user!.email,
              userId: me.user!.id,
            );
            return AuthResult(
              isSuccess: true,
              message: "Login successful",
              user: me.user,
              token: customToken,
            );
          }
          return AuthResult(isSuccess: false, message: "Failed to get user details");
        }
        return AuthResult(isSuccess: false, message: "Invalid response format: ${resp.body}");
      } else {
        return AuthResult(isSuccess: false, message: "Login failed: ${resp.statusCode} - ${resp.body}");
      }
    } catch (e) {
      return AuthResult(isSuccess: false, message: "Failed to connect: $e");
    }
  }

  Future<AuthResult> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    final uri = Uri.parse('$baseUrl/api/v1/auth/signup');
    try {
      final resp = await http.post(
        uri, 
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': name, 'email': email, 'password': password}),
      );

      if (resp.statusCode == 201) {
        final data = jsonDecode(resp.body);
        
        if (data['token'] != null && data['uid'] != null) {
          String token = data['token'];
          String uid = data['uid'];
        
          final me = await meWithToken(token);
          if (me.isSuccess && me.user != null) {
            await AuthStorageService.saveSession(
              token: token,
              role: me.user!.role,
              name: me.user!.name,
              email: me.user!.email,
              userId: me.user!.id,
            );
            return AuthResult(
              isSuccess: true,
              message: "Signup successful",
              user: me.user,
              token: token,
            );
          }
          return AuthResult(isSuccess: false, message: "Failed to get user details after signup");
        }
        return AuthResult(isSuccess: false, message: "No token received in signup response");
      } else {
        return AuthResult(isSuccess: false, message: "Signup failed: ${resp.statusCode} - ${resp.body}");
      }
    } catch (e) {
      return AuthResult(isSuccess: false, message: "Signup failed: $e");
    }
  }

  Future<AuthResult> me() async {
    final token = await AuthStorageService.getToken();
    if (token == null) {
      return AuthResult(isSuccess: false, message: "No token");
    }
    return meWithToken(token);
  }

  Future<AuthResult> meWithToken(String token) async {
    final uri = Uri.parse('$baseUrl/api/v1/auth/me');
    try {
      final resp = await http.get(
        uri, 
        headers: {'Authorization': 'Bearer $token'}
      );
      
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        
        if (data['uid'] != null) {
          return AuthResult(
            isSuccess: true,
            message: "Success",
            user: AuthUser(
              id: data['uid'],
              email: data['email'],
              name: data['name'],
              role: (data['role'] ?? 'USER').toString().toUpperCase(),
            ),
            token: token,
          );
        }
      }
      return AuthResult(isSuccess: false, message: "Failed to fetch user data: ${resp.body}");
    } catch (e) {
      return AuthResult(isSuccess: false, message: "Error fetching user: $e");
    }
  }

  Future<void> logout() async {
    await AuthStorageService.clear();
  }
}