import 'dart:convert';
import 'package:flow_sphere/Services/login_api_services.dart';
import 'package:flow_sphere/screens/shimmer_widget.dart';
import 'package:flow_sphere/screens/userScreens/custom_appbar.dart';
import 'package:flow_sphere/screens/userScreens/navigation_drawer.dart';
import 'package:flow_sphere/screens/userScreens/time_tracking_card.dart';
import 'package:flow_sphere/Services/User_services/clockin_clockout_service.dart';
import 'package:flow_sphere/screens/userScreens/widgets/build_action_card.dart';
import 'package:flow_sphere/screens/userScreens/widgets/build_progress_card.dart';
import 'package:flow_sphere/screens/userScreens/widgets/user_info_card.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String? fullName;
  String token = '';
  bool _isUserLoading = true;
  int progressPercent = 0;
  bool internetIssue = false;

  // State for time tracking
  bool _isCheckedIn = false;
  bool _isLoading = false;

  DateTime _currentTime = DateTime.now();
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    // Start a timer to update the current time every second
    _timer = Timer.periodic(const Duration(seconds: 45), (timer) {
      if (mounted) {
        setState(() {
          _currentTime = DateTime.now();
        });
      }
    });
    getUserInfo();
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
    } else if (msg != null && msg.contains('Checked in successfully')) {
      setState(() {
        _isCheckedIn = !_isCheckedIn;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Your scheduled work period for today has started'),
        ),
      );
    } else if (msg != null && msg.contains('Checked out successfully')) {
      setState(() {
        _isCheckedIn = !_isCheckedIn;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('The completion of your shift has been recorded'),
        ),
      );
    } else {
      setState(() {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Your shift is completed for today')),
        );
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
      body: internetIssue
          ? Center(
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
                    onPressed: () {
                      setState(() {
                        internetIssue = false; // reset issue
                        _isUserLoading = true; // show shimmer again
                      });
                      getUserInfo(); // retry fetching
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text("Try Again"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            )
          : _isUserLoading
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
                  BuildProgressCard(
                    context: context,
                    todayProgressPercent: progressPercent,
                  ),
                  const SizedBox(height: 16),
                  // Requests & This Week Cards
                  BuildActionCard(context: context),
                ],
              ),
            ),
    );
  }

  void getUserInfo() async {
    final authService = AuthService();
    final storedToken = await authService.getToken();
    token = storedToken!;
    final user = await authService.getStoredUser();
    _isCheckedIn = await getCheckStatus(token: token);
    progressPercent = await getTodayProgressStatus(token: token);
    setState(() {
      fullName = user!['name'].toString();
      _isUserLoading = false;
    });
  }

  Future<bool> getCheckStatus({required String token}) async {
    final url = "https://leave-backend-vbw6.onrender.com/api/attendance/me";
    try {
      await http.get(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );
    } catch (e) {
      if (e.toString().contains("Failed host lookup")) {
        setState(() {
          internetIssue = true;
        });
      }
      // debugPrint('Internet Error aagya bhai : $e');
    }
    final response = await http.get(
      Uri.parse(url),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );
    String todayDate = _currentTime.toString().split(' ')[0];
    String userData = jsonDecode(response.body).toString();

    if (userData.contains(todayDate)) {
      Map<String, dynamic> todayData = jsonDecode(response.body)[0];
      if (todayData['check_out_at'] == null) {
        return true;
      } else {
        return false;
      }
    }
    return false;
  }

  Future<int> getTodayProgressStatus({required String token}) async {
    final url = "https://leave-backend-vbw6.onrender.com/api/me/today";
    final response = await http.get(
      Uri.parse(url),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );
    Map<String, dynamic> userData = jsonDecode(response.body);
    return userData['overallProgress'];
  }
}
