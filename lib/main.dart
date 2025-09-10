import 'package:flow_sphere/screens/adminScreens/admin_dashboard.dart';
import 'package:flow_sphere/screens/adminScreens/register_employee.dart';
import 'package:flow_sphere/screens/authScreens/login_screen.dart';
import 'package:flow_sphere/screens/authScreens/password_reset_page.dart';
import 'package:flow_sphere/screens/userScreens/calender_screen.dart';
import 'package:flow_sphere/screens/userScreens/dashboard_screen.dart';
import 'package:flow_sphere/screens/userScreens/profile_screen.dart';
import 'package:flow_sphere/screens/userScreens/progress_screen.dart';
import 'package:flow_sphere/screens/userScreens/requests_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Root of the application
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FlowSphere',
      // initialRoute: '/dashboard',
      // routes: {
      //   '/login': (context) => const LoginScreen(),
      //   '/dashboard': (context) => const DashboardScreen(),
      //   '/progress': (context) => const ProgressScreen(),
      //   '/requests': (context) => const RequestsScreen(),
      //   '/calendar': (context) => const CalendarScreen(),
      //   '/profile': (context) => const ProfileScreen(),
      //   '/resetPassword': (context) => const PasswordResetPage(),
      // },
      home: RegisterEmployeeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
