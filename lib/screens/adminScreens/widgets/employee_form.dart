import 'package:flutter/material.dart';
import 'password_field.dart'; // Make sure this file exists in the correct path

class EmployeeForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController fullNameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final String? department;
  final String? role;
  final ValueChanged<String?> onDepartmentChanged;
  final ValueChanged<String?> onRoleChanged;

  const EmployeeForm({
    super.key,
    required this.formKey,
    required this.fullNameController,
    required this.emailController,
    required this.passwordController,
    required this.department,
    required this.role,
    required this.onDepartmentChanged,
    required this.onRoleChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Employee Details",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 6),
              Text(
                "Enter the employee information below. Login credentials will be sent via email.",
                style: TextStyle(color: Colors.grey[700], fontSize: 14),
              ),
              SizedBox(height: 18),
              // Full Name Field
              TextFormField(
                controller: fullNameController,
                decoration: InputDecoration(
                  labelText: "Full Name *",
                  hintText: "Enter employee's full name",
                  border: OutlineInputBorder(),
                ),
                validator: (value) => (value == null || value.isEmpty)
                    ? "Full name required"
                    : null,
              ),
              SizedBox(height: 14),
              // Email Field
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: "Email Address *",
                  hintText: "employee@company.com",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) => (value == null || value.isEmpty)
                    ? "Email is required"
                    : null,
              ),
              SizedBox(height: 14),
              // Department Dropdown
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: "Department *",
                  border: OutlineInputBorder(),
                ),
                initialValue: department,
                items: ['Development', 'SAP', 'Data Analytics']
                    .map(
                      (dept) =>
                          DropdownMenuItem(value: dept, child: Text(dept)),
                    )
                    .toList(),
                onChanged: onDepartmentChanged,
                validator: (value) =>
                    value == null ? "Select department" : null,
              ),
              SizedBox(height: 14),
              // Role Dropdown
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: "Role *",
                  border: OutlineInputBorder(),
                ),
                initialValue: role,
                items: ['Employee', 'Admin']
                    .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                    .toList(),
                onChanged: onRoleChanged,
                validator: (value) => value == null ? "Select role" : null,
              ),
              SizedBox(height: 14),
              // Password Field
              PasswordField(controller: passwordController),
              SizedBox(height: 8),
              Text(
                "Employee will receive this password via email and can change it after first login",
                style: TextStyle(color: Colors.grey[700], fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
