// lib/services/progress_service.dart

import 'dart:convert';
import 'dart:io';
import 'package:flow_sphere/Services/Admin_services/login_api_services.dart';
import 'package:http/http.dart' as http;

class TaskItem {
  final String id;
  final String description;
  int progress;
  String status;

  TaskItem({
    required this.id,
    required this.description,
    this.progress = 0,
    this.status = "pending",
  });

  factory TaskItem.fromJson(Map<String, dynamic> json) {
    return TaskItem(
      id: json['id']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      progress: (json['progress'] ?? 0) is int
          ? json['progress']
          : int.tryParse(json['progress'].toString()) ?? 0,
      status: json['status']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'progress': progress,
      'status': status,
    };
  }
}

class ProgressData {
  final String user;
  final String date;
  final List<TaskItem> tasks;
  final String dailyNotes;
  final int overallProgress;

  ProgressData({
    required this.user,
    required this.date,
    required this.tasks,
    required this.dailyNotes,
    required this.overallProgress,
  });

  factory ProgressData.fromJson(Map<String, dynamic> json) {
    var tasksJson = json['tasks'] as List<dynamic>? ?? [];
    List<TaskItem> tasksList = tasksJson
        .map((e) => TaskItem.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    return ProgressData(
      user: json['user']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      tasks: tasksList,
      dailyNotes: json['dailyNotes']?.toString() ?? '',
      overallProgress: (json['overallProgress'] ?? 0) is int
          ? json['overallProgress']
          : int.tryParse(json['overallProgress'].toString()) ?? 0,
    );
  }
}

class ProgressService {
  static const String baseTodayUrl =
      "https://leave-backend-vbw6.onrender.com/api/me/today";
  static const String submitUrl =
      "https://leave-backend-vbw6.onrender.com/api/submit";

  // Get user ID from auth service
  static Future<String> getUserId() async {
    try {
      final authService = AuthService();
      final userId = await authService.getUserId();
      if (userId == null || userId.isEmpty) {
        throw Exception("No user ID available");
      }
      return userId;
    } catch (e) {
      throw Exception("Failed to get user ID: $e");
    }
  }

  // helper to build headers
  static Future<Map<String, String>> _headers({bool withJson = true}) async {
    final authService = AuthService();
    final token = await authService.getToken();
    if (token == null) {
      throw Exception("No authentication token available");
    }
    final headers = <String, String>{'Authorization': 'Bearer $token'};
    if (withJson) {
      headers['Content-Type'] = 'application/json';
      headers['Accept'] = 'application/json';
    }
    return headers;
  }

  static Future<ProgressData> fetchTodayProgress({
    required String date,
    required String userId,
  }) async {
    final uri = Uri.parse("$baseTodayUrl?date=$date&userId=$userId");
    final headers = await _headers(withJson: false); // GET no body

    print('Fetching progress for date: $date, userId: $userId');
    print('Request URL: $uri');

    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      print('Fetch response: $decoded');
      return ProgressData.fromJson(Map<String, dynamic>.from(decoded));
    } else {
      print('Fetch failed: ${response.statusCode} - ${response.body}');
      throw HttpException(
        "Failed to fetch progress: ${response.statusCode} ${response.reasonPhrase}",
      );
    }
  }

  static Future<ProgressData> submitProgress({
    required String date,
    required String userId,
    required List<TaskItem> tasks,
    required String dailyNotes,
    // required int progress,
  }) async {
    final uri = Uri.parse(submitUrl);
    final authService = AuthService();
    final token = await authService.getToken();
    final headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    };
    // final bodyMap = {
    //   'date': date,
    //   // 'user': userId,
    //   'tasks': tasks.map((t) => t.toJson()).toList(),
    //   'dailyNotes': dailyNotes,
    // };
    final Map<String, dynamic> bodyMap = {
      'date': date,
      'user': userId,
      'tasks': tasks.map((t) => t.toJson()).toList(),
      'dailyNotes': dailyNotes,
    };

    print('Submitting progress: $bodyMap');

    final response = await http.post(
      uri,
      headers: headers,
      body: jsonEncode(bodyMap),
    );
    print(response);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final decoded = json.decode(response.body);
      print('Submit response: $decoded');
      final progressJson = decoded['progress'];
      return ProgressData.fromJson(Map<String, dynamic>.from(progressJson));
    } else {
      print('Submit failed: ${response.statusCode} - ${response.body}');
      throw HttpException(
        "Failed to submit progress: ${response.statusCode} ${response.reasonPhrase}",
      );
    }
  }
}
