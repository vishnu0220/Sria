import 'package:flow_sphere/Services/Admin_services/login_api_services.dart';
import 'package:flow_sphere/screens/adminScreens/admin_dashboard.dart';
import 'package:flow_sphere/screens/adminScreens/admin_progress_screen.dart';
import 'package:flow_sphere/screens/adminScreens/approval_screen.dart';
import 'package:flow_sphere/screens/adminScreens/employees_screen.dart';
import 'package:flow_sphere/screens/adminScreens/register_employee.dart';
import 'package:flutter/material.dart';

class AdminNavigationDrawer extends StatefulWidget {
  const AdminNavigationDrawer({super.key});

  @override
  State<AdminNavigationDrawer> createState() => _AdminNavigationDrawerState();
}

class _AdminNavigationDrawerState extends State<AdminNavigationDrawer> {
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
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Administration',
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
              routeName: '/adminDashboard',
              destination: const AdminDashboardScreen(),
              currentRoute: currentRoute,
            ),
            _buildDrawerItem(
              context,
              icon: Icons.group,
              label: 'Employees',
              routeName: '/employees',
              destination: const EmployeesScreen(),
              currentRoute: currentRoute,
            ),
            _buildDrawerItem(
              context,
              icon: Icons.person_add_alt,
              label: 'Register Employee',
              routeName: '/registerEmployee',
              destination: const RegisterEmployeeScreen(),
              currentRoute: currentRoute,
            ),
            _buildDrawerItem(
              context,
              icon: Icons.check_box_outlined,
              label: 'Approvals',
              routeName: '/approvals',
              destination: const ApprovalScreen(),
              currentRoute: currentRoute,
            ),
            _buildDrawerItem(
              context,
              icon: Icons.bar_chart_outlined,
              label: 'Progress View',
              routeName: '/adminProgress',
              destination: const AdminProgressScreen(),
              currentRoute: currentRoute,
            ),
            _buildDrawerItem(
              context,
              icon: Icons.settings,
              label: 'Settings',
              routeName: '/settings',
              destination: AdminDashboardScreen(),
              currentRoute: currentRoute,
            ),

            const Spacer(),

            // Admin Info
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
                onPressed: () async {
                  final authService = AuthService();
                  await authService.logout();
                  // Navigator.pushReplacementNamed(context, '/login');

                  Navigator.pushNamedAndRemoveUntil(
                    // ignore: use_build_context_synchronously
                    context,
                    '/login',
                    (route) => false,
                  );
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
