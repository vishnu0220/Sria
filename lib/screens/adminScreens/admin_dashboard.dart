import 'dart:async';

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
  int totalEmployees = 38;
  int presentToday = 34;
  int onLeave = 0;
  int pendingRequests = 1;
  List<String> recentActivity = [
    'Padmakar Reddy Abaka - CHECK_IN at 13:53',
    'Kollu VishnuVardhan - CHECK_IN at 12:46',
  ];

  // Dummy user data
  final _fullName = 'Admin User';

  DateTime _currentTime = DateTime.now();
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    // Start a timer to update the current time every second
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _currentTime = DateTime.now();
        });
      }
    });
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
                        'Hi, $_fullName',
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
              count: 38,
              icon: Icons.person,
              iconColor: Colors.teal,
            ),

            DashboardStatCard(
              title: 'Present Today',
              count: 38,
              icon: Icons.check_circle_outline_rounded,
              iconColor: Colors.green,
            ),

            DashboardStatCard(
              title: 'On Leave',
              count: 0,
              icon: Icons.calendar_today,
              iconColor: Colors.orange,
            ),
            DashboardStatCard(
              title: 'Pending Requests',
              count: 1,
              icon: Icons.pending,
              iconColor: Colors.red,
            ),
            const SizedBox(height: 16),
            RecentActivityCard(
              activities: [
                ActivityItem(
                  name: 'Harika Veesam',
                  action: 'CHECK_IN',
                  time: '11:08',
                ),
                ActivityItem(
                  name: 'Snithija Raavi',
                  action: 'CHECK_OUT',
                  time: '11:06',
                ),
                ActivityItem(
                  name: 'Vineeth Erramalla',
                  action: 'CHECK_IN',
                  time: '11:05',
                ),
                ActivityItem(
                  name: 'Snithija Raavi',
                  action: 'CHECK_IN',
                  time: '11:06',
                ),
                ActivityItem(
                  name: 'Snithija Raavi',
                  action: 'CHECK_IN',
                  time: '11:06',
                ),
                ActivityItem(
                  name: 'Snithija Raavi',
                  action: 'CHECK_OUT',
                  time: '11:06',
                ),
                ActivityItem(
                  name: 'Snithija Raavi',
                  action: 'CHECK_IN',
                  time: '11:06',
                ),
                ActivityItem(
                  name: 'Snithija Raavi',
                  action: 'CHECK_OUt',
                  time: '11:06',
                ),

                ActivityItem(
                  name: 'Snithija Raavi',
                  action: 'CHECK_IN',
                  time: '11:06',
                ),
                ActivityItem(
                  name: 'Snithija Raavi',
                  action: 'CHECK_IN',
                  time: '11:06',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
