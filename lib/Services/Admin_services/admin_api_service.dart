import 'dart:convert';
import 'package:http/http.dart' as http;


class AdminApiService {
  final String baseUrl = "https://leave-backend-vbw6.onrender.com/api";

  // Login API
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse("$baseUrl/auth/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Login failed: ${response.body}");
    }
  }

  // Dashboard Attendance Summary
  Future<Map<String, dynamic>> fetchAttendanceHistory(String token) async {
    final response = await http.get(
      Uri.parse("$baseUrl/attendance/history"),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load attendance history: ${response.body}");
    }
  }

  // Recent Activity
  Future<List<dynamic>> fetchRecentActivities(String token) async {
    final response = await http.get(
      Uri.parse("$baseUrl/recent"),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load recent activities: ${response.body}");
    }
  }
}
