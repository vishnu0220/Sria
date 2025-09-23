// main.dart
import 'package:flow_sphere/Services/login_api_services.dart';
import 'package:flow_sphere/splash_screen.dart';
import 'package:flutter/material.dart';

// Auth Screens
import 'package:flow_sphere/screens/authScreens/login_screen.dart';
import 'package:flow_sphere/screens/authScreens/password_reset_page.dart';

// Admin Screens
import 'package:flow_sphere/screens/adminScreens/admin_dashboard.dart';
import 'package:flow_sphere/screens/adminScreens/admin_progress_screen.dart';
import 'package:flow_sphere/screens/adminScreens/approval_screen.dart';
import 'package:flow_sphere/screens/adminScreens/employees_screen.dart';
import 'package:flow_sphere/screens/adminScreens/register_employee.dart';

// User Screens
import 'package:flow_sphere/screens/userScreens/dashboard_screen.dart';
import 'package:flow_sphere/screens/userScreens/progress_screen.dart';
import 'package:flow_sphere/screens/userScreens/requests_screen.dart';
import 'package:flow_sphere/screens/userScreens/calender_screen.dart';
import 'package:flow_sphere/screens/userScreens/profile_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AuthService _authService = AuthService();
  Widget _defaultScreen = const SplashScreen();

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final token = await _authService.getToken();
    final user = await _authService.getStoredUser();

    if (token != null && user != null) {
      if (user['role'] == 'ADMIN') {
        setState(() => _defaultScreen = const AdminDashboardScreen());
      } else {
        setState(() => _defaultScreen = const DashboardScreen());
      }
    } else {
      setState(() => _defaultScreen = const LoginScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flow Sphere',
      debugShowCheckedModeBanner: false,
      home: _defaultScreen,
      routes: {
        // Authentication
        '/login': (context) => const LoginScreen(),
        '/resetPassword': (context) => const PasswordResetPage(),

        // Admin Routes
        '/adminDashboard': (context) => const AdminDashboardScreen(),
        '/employees': (context) => const EmployeesScreen(),
        '/registerEmployee': (context) => const RegisterEmployeeScreen(),
        '/approvals': (context) => const ApprovalScreen(),
        '/adminProgress': (context) => const AdminProgressScreen(),

        // User Routes
        '/userDashboard': (context) => const DashboardScreen(),
        '/progress': (context) => const ProgressScreen(),
        '/requests': (context) => const RequestsScreen(),
        '/calendar': (context) => const CalendarScreen(),
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}
