import 'dart:convert';
import 'package:flow_sphere/Services/login_api_services.dart';
import 'package:http/http.dart' as http;

class UserService {
  static const String baseUrl = 'https://leave-backend-vbw6.onrender.com';

  final AuthService _authService = AuthService();

  Future<Map<String, dynamic>> registerEmployee(
    Map<String, dynamic> payload,
  ) async {
    final token = await _authService.getToken();
    if (token == null) {
      return {'success': false, 'message': 'No token stored'};
    }

    final uri = Uri.parse('$baseUrl/api/admin/users');

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

      print("STATUS: ${res.statusCode}");
      print("BODY: ${res.body}");

      if (res.body.isEmpty) {
        return {'success': false, 'message': 'Empty response from server'};
      }

      try {
        final body = jsonDecode(res.body);
        if (res.statusCode == 200 || res.statusCode == 201) {
          return {'success': true, 'data': body};
        } else {
          final message = (body is Map && body['message'] != null)
              ? body['message']
              : 'Request failed (status ${res.statusCode})';
          return {'success': false, 'message': message};
        }
      } catch (e) {
        return {
          'success': false,
          'message': 'Invalid JSON response: ${res.body}',
        };
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }
}
