import 'dart:async';

import 'package:flow_sphere/Services/Admin_services/admin_api_service.dart';
import 'package:flow_sphere/Services/login_api_services.dart';
import 'package:flow_sphere/screens/adminScreens/widgets/admin_navigation_drawer.dart';
import 'package:flow_sphere/screens/adminScreens/widgets/dashboard_state_card.dart';
import 'package:flow_sphere/screens/adminScreens/widgets/recent_activity_card.dart';
import 'package:flow_sphere/screens/userScreens/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final AdminApiService apiService = AdminApiService();
  final authService = AuthService();
  int totalEmployees = 0;
  int presentToday = 0;
  int onLeave = 0;
  int pendingRequests = 0;
  // List<String> recentActivity = [

  // ];
  List<Map<String, dynamic>> recentActivity = [];

  // Dummy user data
  String fullName = '';

  DateTime _currentTime = DateTime.now();
  late Timer _timer;

  String? token;

  Future<void> _initializeDashboard() async {
    // ✅ Step 1: get stored token
    final storedToken = await authService.getToken();
    // ignore: unused_local_variable
    final user = await authService.getStoredUser();
    fullName = user!['name'].toString();

    if (storedToken == null) {
      // No token found, redirect back to login
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Session expired, please login again")),
        );
        Navigator.pushReplacementNamed(context, "/login");
      }
      return;
    }

    setState(() {
      token = storedToken;
    });

    // ✅ Step 2: load dashboard data
    await _loadDashboardData();
  }

  @override
  void initState() {
    super.initState();
    // _loadDashboardData();
    _initializeDashboard();
    // Start a timer to update the current time every second
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _currentTime = DateTime.now();
        });
      }
    });
  }

  Future<void> _loadDashboardData() async {
    try {
      // Fetch attendance stats
      final history = await apiService.fetchAttendanceHistory(token!);
      setState(() {
        totalEmployees = history['totalEmployees'] ?? 0;
        presentToday = history['presentToday'] ?? 0;
        onLeave = history['onLeaveCount'] ?? 0;
        pendingRequests = history['pendingRequests'] ?? 0;
      });

      // Fetch recent activity
      final activities = await apiService.fetchRecentActivities(token!);
      setState(() {
        recentActivity = activities.cast<Map<String, dynamic>>();
      });
    } catch (e) {
      print("Error loading dashboard: $e");
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Format the current date and time
    final formattedDate = DateFormat('EEEE, MMMM d, y').format(DateTime.now());
    final formattedTime = DateFormat('hh:mm a').format(_currentTime);
    return Scaffold(
      appBar: CustomAppBar(),
      drawer: AdminNavigationDrawer(),
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hi, $fullName',
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Today is $formattedDate',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      formattedTime,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const Text(
                      'Current Time',
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            DashboardStatCard(
              title: 'Total Employees',
              count: totalEmployees,
              icon: Icons.person,
              iconColor: Colors.teal,
            ),

            DashboardStatCard(
              title: 'Present Today',
              count: presentToday,
              icon: Icons.check_circle_outline_rounded,
              iconColor: Colors.green,
            ),

            DashboardStatCard(
              title: 'On Leave',
              count: onLeave,
              icon: Icons.calendar_today,
              iconColor: Colors.orange,
            ),
            DashboardStatCard(
              title: 'Pending Requests',
              count: pendingRequests,
              icon: Icons.pending,
              iconColor: Colors.red,
            ),
            const SizedBox(height: 16),
            RecentActivityCard(
              activities: recentActivity
                  .map(
                    (a) => ActivityItem(
                      name: a['user']['name'],
                      action: a['action'],
                      time: DateFormat(
                        'hh:mm',
                      ).format(DateTime.parse(a['createdAt']).toLocal()),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}
