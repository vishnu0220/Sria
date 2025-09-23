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
        final responseData = jsonDecode(response.body);

        // Extract attendanceId (_id) from response
        final attendanceId = responseData["_id"];

        // Log activity to /api/log
        final action = isCheckedIn ? "CHECK_OUT" : "CHECK_IN";
        final description = isCheckedIn
            ? "User checked out"
            : "User checked in";

        await http.post(
          Uri.parse("https://leave-backend-vbw6.onrender.com/api/log"),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
          body: jsonEncode({
            "action": action,
            "description": description,
            "metadata": {"attendanceId": attendanceId},
          }),
        );

        return responseData['message'];
      } else {
        return jsonDecode(response.body)['message'] ??
            "Failed with status: ${response.statusCode}";
      }
    } catch (e) {
      return "Error: $e";
    }
  }
}
