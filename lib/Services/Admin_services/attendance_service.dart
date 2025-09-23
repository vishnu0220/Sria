import 'dart:convert';
import 'package:flow_sphere/Services/login_api_services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class AttendanceApiService {
  static const String baseUrl =
      "https://leave-backend-vbw6.onrender.com/api/attendance";

  static Future<List<Map<String, dynamic>>> getAttendanceByDate(
    String date,
  ) async {
    final AuthService authService = AuthService();
    final token = await authService.getToken();

    // Call both APIs
    final historyUrl = Uri.parse("$baseUrl/history?date=$date");
    final byDateUrl = Uri.parse("$baseUrl/by-date?date=$date");

    final historyResponse = await http.get(
      historyUrl,
      headers: {"Authorization": "Bearer $token"},
    );

    final byDateResponse = await http.get(
      byDateUrl,
      headers: {"Authorization": "Bearer $token"},
    );

    if (historyResponse.statusCode == 200 && byDateResponse.statusCode == 200) {
      final historyJson = json.decode(historyResponse.body);
      final byDateJson = json.decode(byDateResponse.body);

      // Attendance records with check-in/out
      final List<dynamic> byDateData = byDateJson;
      final Map<String, dynamic> byDateMap = {
        for (var record in byDateData) record["user"]["_id"]: record,
      };

      // Full employee list from history
      final List<dynamic> employeesData = historyJson["employees"] ?? [];
      final List<dynamic> onLeaveIds = (historyJson["onLeaveEmployees"] ?? [])
          .map((e) => e["_id"])
          .toList();

      return employeesData.map((emp) {
        final String empId = emp["_id"];
        final byDateRecord = byDateMap[empId];

        String status;
        if (onLeaveIds.contains(empId)) {
          status = "On Leave";
        } else if (byDateRecord != null) {
          status = "Present";
        } else {
          status = "Absent";
        }

        // Format time
        String formatTime(String? rawDate) {
          if (rawDate == null) return "N/A";
          try {
            DateTime utcDate = DateTime.parse(rawDate);
            DateTime istDate = utcDate.toLocal();
            return DateFormat('hh:mm a').format(istDate);
          } catch (_) {
            return "N/A";
          }
        }

        return {
          "id": empId,
          "name": emp["name"] ?? "Unknown",
          "department": emp["department"] ?? "Unknown",
          "role": emp["role"] ?? "EMPLOYEE",
          "checkIn": byDateRecord != null
              ? formatTime(byDateRecord["check_in_at"])
              : "N/A",
          "checkOut": byDateRecord != null
              ? formatTime(byDateRecord["check_out_at"])
              : "N/A",
          "task": byDateRecord?["task"] ?? "NILL",
          "status": status,
        };
      }).toList();
    } else {
      throw Exception(
        "Failed to load attendance data. "
        "History: ${historyResponse.statusCode}, ByDate: ${byDateResponse.statusCode}",
      );
    }
  }
}
