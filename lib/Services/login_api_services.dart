// lib/services/auth_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  // YOUR BASE URL
  static const String baseUrl = 'https://leave-backend-vbw6.onrender.com';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // --- Login ---
  // returns map: { success: bool, token?: String, user?: Map, message?: String }
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final uri = Uri.parse('$baseUrl/api/auth/login');
    try {
      final res = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(const Duration(seconds: 15));

      final body = jsonDecode(res.body);

      if (res.statusCode == 200 || res.statusCode == 201) {
        final token = body['token'] as String?;
        final user = body['user'];
        // store token and user securely
        if (token != null) await _storage.write(key: 'jwt', value: token);
        if (user != null) {
          await _storage.write(key: 'user', value: jsonEncode(user));
        }
        return {'success': true, 'token': token, 'user': user};
      } else {
        // backend usually returns { message: "..." }
        final message = (body is Map && body['message'] != null)
            ? body['message']
            : 'Login failed (status ${res.statusCode})';
        return {'success': false, 'message': message};
      }
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        String message =
            "We're having a temporary hiccup. \nPlease refresh or try again shortly!";
        return {'success': false, 'message': message};
      }
      return {'success': false, 'message': e.toString()};
    }
  }

  // --- Get stored token ---
  Future<String?> getToken() => _storage.read(key: 'jwt');

  // --- Get stored user (decoded) ---
  Future<Map<String, dynamic>?> getStoredUser() async {
    final s = await _storage.read(key: 'user');
    if (s == null) return null;
    return Map<String, dynamic>.from(jsonDecode(s));
  }

  // --- Logout ---
  Future<void> logout() async {
    await _storage.delete(key: 'jwt');
    await _storage.delete(key: 'user');
  }

  Future<String?> getUserId() async {
    try {
      final user = await getStoredUser();
      if (user != null) {
        // Try different possible field names for user ID
        String? userId =
            user['_id']?.toString() ??
            user['id']?.toString() ??
            user['userId']?.toString();
        return userId;
      }
      return null;
    } catch (e) {
      print('Error getting user ID: $e');
      return null;
    }
  }

  // --- Check if user is authenticated ---
  Future<bool> isAuthenticated() async {
    final token = await getToken();
    final user = await getStoredUser();
    return token != null && user != null;
  }

  // --- Simple protected GET helper ---
  // path must start with '/' e.g. '/api/profile'
  Future<Map<String, dynamic>> getProtected(String path) async {
    final token = await getToken();
    if (token == null) return {'success': false, 'message': 'No token stored'};

    final uri = Uri.parse('$baseUrl$path');
    try {
      final res = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      // .timeout(const Duration(seconds: 15));

      final body = res.body.isNotEmpty ? jsonDecode(res.body) : null;
      if (res.statusCode == 200) {
        return {'success': true, 'data': body};
      } else {
        final message = (body is Map && body['message'] != null)
            ? body['message']
            : 'Request failed (status ${res.statusCode})';
        return {
          'success': false,
          'message': message,
          'statusCode': res.statusCode,
        };
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // --- Generic protected POST helper ---
  Future<Map<String, dynamic>> postProtected(
    String path,
    Map<String, dynamic> payload,
  ) async {
    final token = await getToken();
    if (token == null) return {'success': false, 'message': 'No token stored'};
    final uri = Uri.parse('$baseUrl$path');
    try {
      final res = await http
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 15));

      final body = res.body.isNotEmpty ? jsonDecode(res.body) : null;
      if (res.statusCode == 200 || res.statusCode == 201) {
        return {'success': true, 'data': body};
      } else {
        final message = (body is Map && body['message'] != null)
            ? body['message']
            : 'Request failed (status ${res.statusCode})';
        return {
          'success': false,
          'message': message,
          'statusCode': res.statusCode,
        };
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }
}
