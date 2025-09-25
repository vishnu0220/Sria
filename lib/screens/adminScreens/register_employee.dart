import 'package:flow_sphere/Services/Admin_services/register_employee_service.dart';
import 'package:flow_sphere/screens/adminScreens/widgets/admin_navigation_drawer.dart';
import 'package:flow_sphere/screens/adminScreens/widgets/employee_form.dart';
import 'package:flow_sphere/screens/adminScreens/widgets/headersection.dart';
import 'package:flow_sphere/screens/adminScreens/widgets/notification_banner.dart';
import 'package:flow_sphere/screens/adminScreens/widgets/registerclear_button.dart';
import 'package:flutter/material.dart';

class RegisterEmployeeScreen extends StatefulWidget {
  const RegisterEmployeeScreen({super.key});
  @override
  State<RegisterEmployeeScreen> createState() => _RegisterEmployeeScreenState();
}

class _RegisterEmployeeScreenState extends State<RegisterEmployeeScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String? department;
  String? role = 'Employee';
  bool isLoading = false;

  final UserService _userService = UserService();

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void clearForm() {
    _formKey.currentState?.reset();
    fullNameController.clear();
    emailController.clear();
    passwordController.clear();
    setState(() {
      department = null;
      role = null;
    });
  }

  Future<void> registerEmployee() async {
    print('In register employee function');
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => isLoading = true);

    final employeeData = {
      "name": fullNameController.text.trim(),
      "email": emailController.text.trim(),
      "password": passwordController.text.trim(),
      "department": department,
      "role": role,
    };

    final result = await _userService.registerEmployee(employeeData);
    if (result.toString().contains('Failed host lookup')) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Could not register employee ${employeeData['name']}\nPlease check your internet and try again",
          ),
        ),
      );
      return;
    }
    setState(() => isLoading = false);

    if (!mounted) return;

    if (result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Employee registered successfully')),
      );
      clearForm();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        // SnackBar(content: Text(result['message'] ?? 'Registration failed')),
        SnackBar(content: Text('Server is taking to much time')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: BackButton(color: Colors.black)),
      drawer: AdminNavigationDrawer(),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            HeaderSection(),
            SizedBox(height: 20),
            EmployeeForm(
              formKey: _formKey,
              fullNameController: fullNameController,
              emailController: emailController,
              passwordController: passwordController,
              department: department,
              role: role,
              onDepartmentChanged: (val) => setState(() => department = val),
              onRoleChanged: (val) => setState(() => role = val),
            ),

            SizedBox(height: 24),
            RegisterClearButtons(
              onClear: clearForm,
              onRegister: registerEmployee,
            ),
            SizedBox(height: 24),
            NotificationBanner(),
          ],
        ),
      ),
    );
  }
}
