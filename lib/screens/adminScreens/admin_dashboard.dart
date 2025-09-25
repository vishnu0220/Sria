import 'dart:async';
import 'dart:io';

import 'package:flow_sphere/Services/Admin_services/admin_api_service.dart';
import 'package:flow_sphere/Services/login_api_services.dart';
import 'package:flow_sphere/screens/adminScreens/widgets/admin_navigation_drawer.dart';
import 'package:flow_sphere/screens/adminScreens/widgets/dashboard_state_card.dart';
import 'package:flow_sphere/screens/adminScreens/widgets/recent_activity_card.dart';
import 'package:flow_sphere/screens/shimmer_widget.dart';
import 'package:flow_sphere/screens/userScreens/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart'; // Make sure to add this dependency; // Assuming this is the correct path

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
  List<Map<String, dynamic>> recentActivity = [];
  String fullName = '';
  DateTime _currentTime = DateTime.now();
  late Timer _timer;
  String? token;

  // State variables for loading and errors
  bool _isLoading = true;
  bool _hasInternetError = false;

  @override
  void initState() {
    super.initState();
    _initializeDashboard();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _currentTime = DateTime.now();
        });
      }
    });
  }

  Future<void> _initializeDashboard() async {
    setState(() {
      _isLoading = true; // Start loading
      _hasInternetError = false; // Reset error state
    });

    final storedToken = await authService.getToken();
    final user = await authService.getStoredUser();

    if (user != null) {
      fullName = user['name'].toString();
    }

    if (storedToken == null) {
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

    await _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    try {
      final history = await apiService.fetchAttendanceHistory(token!);
      final activities = await apiService.fetchRecentActivities(token!);

      if (mounted) {
        setState(() {
          totalEmployees = history['totalEmployees'] ?? 0;
          presentToday = history['presentToday'] ?? 0;
          onLeave = history['onLeaveCount'] ?? 0;
          pendingRequests = history['pendingRequests'] ?? 0;
          recentActivity = activities.cast<Map<String, dynamic>>();
          _isLoading = false; // Data loaded, stop loading
        });
      }
    } on SocketException {
      // Catch network-specific errors
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasInternetError = true; // Set internet error state
        });
      }
    } catch (e) {
      print("Error loading dashboard: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
          // You could add a generic error state here if needed
        });
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
    final formattedDate = DateFormat('EEEE, MMMM d, y').format(DateTime.now());
    final formattedTime = DateFormat('hh:mm a').format(_currentTime);
    return Scaffold(
      appBar: CustomAppBar(),
      drawer: AdminNavigationDrawer(),
      backgroundColor: Colors.grey[100],
      body: _hasInternetError
          ? _buildNoInternetView()
          : _isLoading
          ? ShimmerWidget()
          : _buildDashboardContent(formattedDate, formattedTime),
    );
  }

  Widget _buildNoInternetView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            'assets/lottie/choose-your-colors.json',
            repeat: true,
            width: 250,
            height: 250,
          ),
          const SizedBox(height: 20),
          Text(
            "No Internet Connection",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _initializeDashboard,
            icon: const Icon(Icons.refresh),
            label: const Text("Try Again"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardContent(String formattedDate, String formattedTime) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
    );
  }
}
