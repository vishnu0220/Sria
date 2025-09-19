import 'dart:convert';
import 'package:http/http.dart' as http;

class AdminApiService {
  static const String baseUrl = "https://leave-backend-vbw6.onrender.com/api/admin";

  // Fetch summary + departments
  static Future<Map<String, dynamic>> fetchStats() async {
    final url = Uri.parse("$baseUrl/stats");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load stats");
    }
  }

  // Fetch employees with tasks (paginated)
  static Future<Map<String, dynamic>> fetchEmployees(String date) async {
    final url = Uri.parse(
        "$baseUrl/all?date=$date&limit=50&page=1&sortBy=date&sortOrder=desc");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load employees");
    }
  }
}
