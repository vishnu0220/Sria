import 'package:flow_sphere/screens/calender_screen.dart';
import 'package:flow_sphere/screens/dashboard_screen.dart';
import 'package:flow_sphere/screens/login_screen.dart';
import 'package:flow_sphere/screens/password_reset_page.dart';
import 'package:flow_sphere/screens/profile_screen.dart';
import 'package:flow_sphere/screens/progress_screen.dart';
import 'package:flow_sphere/screens/requests_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Root of the application
  @override
  Widget build(BuildContext context) {
    // return MaterialApp(
    //   debugShowCheckedModeBanner: false,
    //   title: 'FlowSphere',
    //   theme: ThemeData(
    //     colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
    //   ),
    //   home: const LoginScreen(),
    // );

    return MaterialApp(
      title: 'FlowSphere',
      initialRoute: '/dashboard',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/progress': (context) => const ProgressScreen(),
        '/requests': (context) => const RequestsScreen(),
        '/calendar': (context) => const CalendarScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/resetPassword': (context) => const PasswordResetPage(),
      },
    );
  }
}
