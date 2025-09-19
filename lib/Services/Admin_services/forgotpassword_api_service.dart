// api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl =
      "https://leave-backend-vbw6.onrender.com/api/auth";

  Future<Map<String, dynamic>> forgotPassword(String email) async {
    final url = Uri.parse('$baseUrl/forgot-password');

    print("Sending forgot password request to: $url");
    print("Email: $email");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email}),
    );

    print(
      "Forgot password response: ${response.statusCode} - ${response.body}",
    );
    return _processResponse(response);
  }

  Future<Map<String, dynamic>> verifyOtp(String email, String otp) async {
    final url = Uri.parse('$baseUrl/verify-otp');

    print("Sending verify OTP request to: $url");
    print("Email: $email, OTP: $otp");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "otp": otp}),
    );

    print("Verify OTP response: ${response.statusCode} - ${response.body}");
    return _processResponse(response);
  }

  Future<Map<String, dynamic>> resetPassword(
    String email,
    String otp,
    String password,
    String confirmPassword,
  ) async {
    final url = Uri.parse('$baseUrl/reset-password');

    final requestBody = {
      "email": email,
      "otp": otp,
      "newPassword": password,
      // "confirmPassword": confirmPassword,
    };

    print("Sending reset password request to: $url");
    print("Request body: ${jsonEncode(requestBody)}");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(requestBody),
    );

    print("Reset password response: ${response.statusCode} - ${response.body}");
    return _processResponse(response);
  }

  Map<String, dynamic> _processResponse(http.Response response) {
    final body = response.body;
    final statusCode = response.statusCode;

    print("Processing response - Status: $statusCode, Body: $body");

    try {
      final Map<String, dynamic> data = jsonDecode(body);

      if (statusCode == 200 || statusCode == 201) {
        return data;
      } else {
        // Handle error responses with parsed JSON
        final errorMessage = data['message'] ?? 'Unknown error occurred';
        throw Exception('Error $statusCode: $errorMessage');
      }
    } catch (e) {
      if (e is Exception && e.toString().contains('Error')) {
        // Re-throw our custom exceptions
        rethrow;
      }

      // Handle cases where response is not valid JSON
      if (statusCode >= 400) {
        throw Exception('Error $statusCode: $body');
      } else {
        throw Exception("Failed to parse response: $e");
      }
    }
  }
}
