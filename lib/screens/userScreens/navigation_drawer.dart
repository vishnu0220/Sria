import 'package:flow_sphere/Services/Admin_services/login_api_services.dart';
import 'package:flow_sphere/screens/userScreens/calender_screen.dart';
import 'package:flow_sphere/screens/userScreens/dashboard_screen.dart';
import 'package:flow_sphere/screens/userScreens/profile_screen.dart';
import 'package:flow_sphere/screens/userScreens/progress_screen.dart';
import 'package:flow_sphere/screens/userScreens/requests_screen.dart';
import 'package:flutter/material.dart';

class CustomNavigationDrawer extends StatefulWidget {
  const CustomNavigationDrawer({super.key});

  @override
  State<CustomNavigationDrawer> createState() => _CustomNavigationDrawerState();
}

class _CustomNavigationDrawerState extends State<CustomNavigationDrawer> {
  String userName = '';
  String userRole = '';
  @override
  void initState() {
    super.initState();
    getUser();
  }

  @override
  Widget build(BuildContext context) {
    // Get current route name
    final currentRoute = ModalRoute.of(context)?.settings.name ?? '';

    return Drawer(
      child: Container(
        color: const Color(0xFF162339),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with App Logo
            DrawerHeader(
              decoration: const BoxDecoration(color: Color(0xFF162339)),
              child: Image.asset(
                'assets/images/flowsphere_logo.png',
                height: 48,
              ),
            ),
            // Workspace Label
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Workspace',
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            _buildDrawerItem(
              context,
              icon: Icons.dashboard,
              label: 'Dashboard',
              routeName: '/userDashboard',
              destination: const DashboardScreen(),
              currentRoute: currentRoute,
            ),
            _buildDrawerItem(
              context,
              icon: Icons.bar_chart,
              label: 'Progress',
              routeName: '/progress',
              destination: const ProgressScreen(),
              currentRoute: currentRoute,
            ),
            _buildDrawerItem(
              context,
              icon: Icons.request_page,
              label: 'Requests',
              routeName: '/requests',
              destination: const RequestsScreen(),
              currentRoute: currentRoute,
            ),
            _buildDrawerItem(
              context,
              icon: Icons.calendar_today,
              label: 'Calendar',
              routeName: '/calendar',
              destination: const CalendarScreen(),
              currentRoute: currentRoute,
            ),
            _buildDrawerItem(
              context,
              icon: Icons.person_outline,
              label: 'Profile',
              routeName: '/profile',
              destination: const ProfileScreen(),
              currentRoute: currentRoute,
            ),

            const Spacer(),

            // User Info
            Container(
              margin: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 10.0,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF19304d),
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.teal,
                  child: Icon(Icons.person, color: Colors.white),
                ),
                title: Text(
                  userName,
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                subtitle: Text(userRole, style: TextStyle(color: Colors.grey)),
              ),
            ),

            // Sign Out Button
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF162339),
                  foregroundColor: Colors.white,
                  elevation: 3,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: const Icon(Icons.logout),
                label: const Text('Sign Out'),
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/login');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String routeName,
    required Widget destination,
    required String currentRoute,
  }) {
    final bool isActive = (currentRoute == routeName);

    return ListTile(
      leading: Icon(icon, color: isActive ? Colors.tealAccent : Colors.white),
      title: Text(
        label,
        style: TextStyle(
          color: isActive ? Colors.tealAccent : Colors.white,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isActive,
      selectedTileColor: Colors.teal.withAlpha(52),
      onTap: () {
        Navigator.pop(context);
        if (!isActive) {
          Navigator.pushNamed(context, routeName);
        }
      },
    );
  }

  void getUser() async {
    final authService = AuthService();
    final user = await authService.getStoredUser();
    setState(() {
      userName = user?['name'];
      userRole = user?['role'];
    });
  }
}
