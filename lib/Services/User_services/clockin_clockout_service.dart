import 'dart:convert';
import 'package:http/http.dart' as http;

class ClockinClockoutService {
  Future<String?> toggleCheckInOut({
    required bool isCheckedIn,
    required String token,
  }) async {
    final url = isCheckedIn
        ? "https://leave-backend-vbw6.onrender.com/api/attendance/check-out"
        : "https://leave-backend-vbw6.onrender.com/api/attendance/check-in";
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body)['message'];
      } else {
        return jsonDecode(response.body)['message'] ??
            "Failed with status: ${response.statusCode}";
      }
    } catch (e) {
      return "Error: $e";
    }
  }
}
