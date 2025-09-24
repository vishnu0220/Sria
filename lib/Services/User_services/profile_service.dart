// lib/services/profile_service.dart
import 'dart:convert';
import 'package:flow_sphere/Services/login_api_services.dart';
import 'package:http/http.dart' as http;

class ProfileService {
  static const String baseUrl = 'https://leave-backend-vbw6.onrender.com';
  final AuthService _authService = AuthService();

  // Get employee profile by ID
  Future<Map<String, dynamic>> getEmployeeProfile(String employeeId) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        return {'success': false, 'message': 'No authentication token found'};
      }

      final uri = Uri.parse('$baseUrl/api/employee/$employeeId');
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        final body = response.body.isNotEmpty ? jsonDecode(response.body) : null;
        final message = (body is Map && body['message'] != null)
            ? body['message']
            : 'Failed to fetch profile (status ${response.statusCode})';
        return {'success': false, 'message': message};
      }
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        return {
          'success': false,
          'message': 'Request timeout. Please check your connection and try again.'
        };
      }
      return {'success': false, 'message': 'Error: ${e.toString()}'};
    }
  }

  // Reset/Change password
  Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        return {'success': false, 'message': 'No authentication token found'};
      }

      final uri = Uri.parse('$baseUrl/api/auth/profile-reset-password');
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'email': email,
          'oldPassword': oldPassword,
          'newPassword': newPassword,
        }),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        final body = response.body.isNotEmpty ? jsonDecode(response.body) : null;
        final message = (body is Map && body['message'] != null)
            ? body['message']
            : 'Failed to update password (status ${response.statusCode})';
        return {'success': false, 'message': message};
      }
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        return {
          'success': false,
          'message': 'Request timeout. Please check your connection and try again.'
        };
      }
      return {'success': false, 'message': 'Error: ${e.toString()}'};
    }
  }

  // Update employee profile (if you have an update endpoint)
  Future<Map<String, dynamic>> updateEmployeeProfile({
    required String employeeId,
    required Map<String, dynamic> profileData,
  }) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        return {'success': false, 'message': 'No authentication token found'};
      }

      final uri = Uri.parse('$baseUrl/api/employee/$employeeId');
      final response = await http.put(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(profileData),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        final body = response.body.isNotEmpty ? jsonDecode(response.body) : null;
        final message = (body is Map && body['message'] != null)
            ? body['message']
            : 'Failed to update profile (status ${response.statusCode})';
        return {'success': false, 'message': message};
      }
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        return {
          'success': false,
          'message': 'Request timeout. Please check your connection and try again.'
        };
      }
      return {'success': false, 'message': 'Error: ${e.toString()}'};
    }
  }
}