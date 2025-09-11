// main.dart
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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FlowSphere',
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
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
