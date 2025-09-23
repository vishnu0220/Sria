// import 'dart:convert';
// Import your existing auth service
import 'package:flow_sphere/Services/login_api_services.dart';


class RequestService {
  static final AuthService _authService = AuthService();

  // Fetch all user requests
  static Future<List<UserRequest>> fetchUserRequests() async {
    try {
      final result = await _authService.getProtected('/api/requests/me');
      
      if (result['success'] == true) {
        final List<dynamic> data = result['data'] as List<dynamic>;
        return data.map((json) => UserRequest.fromJson(json)).toList();
      } else {
        throw Exception(result['message'] ?? 'Failed to load requests');
      }
    } catch (e) {
      throw Exception('Error fetching requests: $e');
    }
  }

  // Fetch missed checkouts
  static Future<List<MissedCheckout>> fetchMissedCheckouts() async {
    try {
      final result = await _authService.getProtected('/api/missed-attendance');
      
      if (result['success'] == true) {
        final List<dynamic> data = result['data'] as List<dynamic>;
        return data.map((json) => MissedCheckout.fromJson(json)).toList();
      } else {
        throw Exception(result['message'] ?? 'Failed to load missed checkouts');
      }
    } catch (e) {
      throw Exception('Error fetching missed checkouts: $e');
    }
  }

  // Submit leave request
  static Future<Map<String, dynamic>> submitLeaveRequest({
    required String startDate,
    required String endDate,
    required String leaveType,
    required String reason,
  }) async {
    try {
      final payload = {
        'start_date': startDate,
        'end_date': endDate,
        'leave_type': leaveType,
        'reason': reason,
      };

      final result = await _authService.postProtected('/api/requests/leave', payload);
      return result;
    } catch (e) {
      return {'success': false, 'message': 'Error submitting leave request: $e'};
    }
  }

  // Submit early logoff request
  static Future<Map<String, dynamic>> submitEarlyLogoffRequest({
    required String startDate,
    required String endDate,
    required String expectedCheckoutTime,
    required String reason,
  }) async {
    try {
      final payload = {
        'start_date': startDate,
        'end_date': endDate,
        'expected_checkout_time': expectedCheckoutTime,
        'reason': reason,
      };

      final result = await _authService.postProtected('/api/requests/early-logoff', payload);
      return result;
    } catch (e) {
      return {'success': false, 'message': 'Error submitting early logoff request: $e'};
    }
  }

  // Submit clockout request for missed checkout
  static Future<Map<String, dynamic>> submitClockoutRequest({
    required String startDate,
    required String reason,
  }) async {
    try {
      final payload = {
        'start_date': startDate,
        'reason': reason,
      };

      final result = await _authService.postProtected('/api/request-clockout', payload);
      return result;
    } catch (e) {
      return {'success': false, 'message': 'Error submitting clockout request: $e'};
    }
  }
}

// Data models
class UserRequest {
  final String id;
  final String userId;
  final String type;
  final DateTime startDate;
  final DateTime endDate;
  final String? leaveType;
  final String? expectedCheckoutTime;
  final String reason;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? decidedAt;
  final String? decidedBy;

  UserRequest({
    required this.id,
    required this.userId,
    required this.type,
    required this.startDate,
    required this.endDate,
    this.leaveType,
    this.expectedCheckoutTime,
    required this.reason,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.decidedAt,
    this.decidedBy,
  });

  factory UserRequest.fromJson(Map<String, dynamic> json) {
    return UserRequest(
      id: (json['_id']?.toString()) ?? '',
      userId: (json['user']?.toString()) ?? '',
      type: (json['type']?.toString()) ?? '',
      startDate: json['start_date'] != null
          ? DateTime.parse(json['start_date'])
          : DateTime.fromMillisecondsSinceEpoch(0),
      endDate: json['end_date'] != null
          ? DateTime.parse(json['end_date'])
          : DateTime.fromMillisecondsSinceEpoch(0),
      leaveType: json['leave_type']?.toString(),
      expectedCheckoutTime: json['expected_checkout_time']?.toString(),
      reason: (json['reason']?.toString()) ?? '',
      status: (json['status']?.toString()) ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.fromMillisecondsSinceEpoch(0),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.fromMillisecondsSinceEpoch(0),
      decidedAt: json['decided_at'] != null
          ? DateTime.parse(json['decided_at'])
          : null,
      decidedBy: json['decided_by']?.toString(),
    );
  }
}


class MissedCheckout {
  final String id;
  final String userId;
  final String date;
  final DateTime checkInAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String day;

  MissedCheckout({
    required this.id,
    required this.userId,
    required this.date,
    required this.checkInAt,
    required this.createdAt,
    required this.updatedAt,
    required this.day,
  });

  factory MissedCheckout.fromJson(Map<String, dynamic> json) {
    return MissedCheckout(
      id: json['_id'],
      userId: json['user'],
      date: json['date'],
      checkInAt: DateTime.parse(json['check_in_at']),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      day: json['day'],
    );
  }
}