import 'package:flow_sphere/Services/Admin_services/login_api_services.dart';
import 'package:flow_sphere/screens/shimmer_widget.dart';
import 'package:flow_sphere/screens/userScreens/custom_appbar.dart';
import 'package:flow_sphere/screens/userScreens/navigation_drawer.dart';
import 'package:flow_sphere/screens/userScreens/time_tracking_card.dart';
import 'package:flow_sphere/Services/User_services/clockin_clockout_service.dart';
import 'package:flow_sphere/screens/userScreens/widgets/build_action_card.dart';
import 'package:flow_sphere/screens/userScreens/widgets/build_progress_card.dart';
import 'package:flow_sphere/screens/userScreens/widgets/user_info_card.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:intl/intl.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String? fullName;
  String token = '';
  bool _isUserLoading = true;

  // State for time tracking
  bool _isCheckedIn = false;
  bool _isLoading = false;

  DateTime _currentTime = DateTime.now();
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    getUser();
    // Start a timer to update the current time every second
    _timer = Timer.periodic(const Duration(seconds: 45), (timer) {
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

  final ClockinClockoutService clockinClockoutService =
      ClockinClockoutService();

  Future<void> _toggleCheckInOut() async {
    setState(() {
      _isLoading = true;
    });
    final msg = await clockinClockoutService.toggleCheckInOut(
      isCheckedIn: _isCheckedIn,
      token: token,
    );
    if (msg != null && msg.contains('only')) {
      setState(() {
        _isCheckedIn = false;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } else if (msg != null && msg.contains('success')) {
      setState(() {
        _isCheckedIn = !_isCheckedIn;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } else {
      setState(() {
        _isCheckedIn = true;
      });
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('EEEE, MMMM d, y').format(DateTime.now());
    final formattedTime = DateFormat('hh:mm a').format(_currentTime);

    return Scaffold(
      appBar: CustomAppBar(),
      drawer: CustomNavigationDrawer(),
      backgroundColor: Colors.grey[100],
      body: _isUserLoading
          ? ShimmerWidget()
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 24.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Section
                  UserInfo(
                    fullName: fullName,
                    formattedDate: formattedDate,
                    formattedTime: formattedTime,
                  ),
                  const SizedBox(height: 24),
                  // Time Tracking Card
                  TimeTrackingCard(
                    isCheckedIn: _isCheckedIn,
                    isLoading: _isLoading,
                    onToggleCheckInOut: _toggleCheckInOut,
                  ),
                  const SizedBox(height: 16),
                  // Today's Progress Card
                  BuildProgressCard(context: context),
                  const SizedBox(height: 16),
                  // Requests & This Week Cards
                  BuildActionCard(context: context),
                ],
              ),
            ),
    );
  }

  void getUser() async {
    final authService = AuthService();
    final storedToken = await authService.getToken();
    token = storedToken!;
    final user = await authService.getStoredUser();
    setState(() {
      fullName = user!['name'].toString();
      _isUserLoading = false;
    });
  }
}
