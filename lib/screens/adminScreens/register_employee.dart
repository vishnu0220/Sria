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

  void registerEmployee() {
    if (_formKey.currentState?.validate() ?? false) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Employee registered successfully')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
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
