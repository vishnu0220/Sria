// reset_password_page.dart

import 'package:flow_sphere/Services/Admin_services/forgotpassword_api_service.dart';
import 'package:flutter/material.dart';

class ResetPasswordPage extends StatefulWidget {
  final String email;
  final String otp;
  const ResetPasswordPage({super.key, required this.email, required this.otp});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLengthValid = false;
  bool _isPasswordMatch = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Debug print to check if email and OTP are received correctly
    print("ResetPasswordPage - Email: ${widget.email}, OTP: ${widget.otp}");

    // Check if we have valid data
    if (widget.email.isEmpty || widget.otp.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Missing email or OTP. Please start the password reset process again.",
            ),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.popUntil(context, (route) => route.isFirst);
      });
    }
  }

  void _validatePassword(String value) {
    setState(() {
      _isLengthValid = value.length >= 6;
      _isPasswordMatch =
          value == _confirmPasswordController.text && value.isNotEmpty;
    });
  }

  void _validateConfirmPassword(String value) {
    setState(() {
      _isPasswordMatch = value == _passwordController.text && value.isNotEmpty;
    });
  }

  void _resetPassword() async {
    final password = _passwordController.text.trim();
    final confirm = _confirmPasswordController.text.trim();

    // Validation checks
    if (widget.email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Email is missing. Please start the process again."),
        ),
      );
      return;
    }

    if (widget.otp.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("OTP is missing. Please verify your code first."),
        ),
      );
      return;
    }

    if (password.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please enter a password")));
      return;
    }

    if (!_isLengthValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password must be at least 6 characters")),
      );
      return;
    }

    if (confirm.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please confirm your password")),
      );
      return;
    }

    if (!_isPasswordMatch) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Passwords do not match")));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final api = ApiService();
      final result = await api.resetPassword(
        widget.email,
        widget.otp,
        password,
        confirm,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? "Password reset successful"),
          backgroundColor: Colors.green,
        ),
      );

      // After success, navigate to login screen
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);

      // Navigator.popUntil(context, (route) => route.isFirst);
    } catch (e) {
      if (!mounted) return;

      String errorMessage = "Error resetting password";

      // Parse the error message for better user experience
      if (e.toString().contains("400")) {
        errorMessage =
            "Invalid request. Please check your details and try again.";
      } else if (e.toString().contains("404")) {
        errorMessage = "Invalid or expired verification code.";
      } else if (e.toString().contains("500")) {
        errorMessage = "Server error. Please try again later.";
      } else {
        errorMessage = e.toString();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset("assets/images/flowsphere_logo.png", height: 100),
              const SizedBox(height: 20),
              const Text(
                "Reset Password",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                "Create a new password for your account",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.lock_outline),
                        SizedBox(width: 6),
                        Text(
                          "New Password",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Choose a strong password to protect your account",
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 16),

                    const Text(
                      "New Password",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    // New password field
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      onChanged: _validatePassword,
                      decoration: InputDecoration(
                        hintText: "Enter new password",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    const Text(
                      "Confirm Password",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    // Confirm password field
                    TextField(
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirmPassword,
                      onChanged: _validateConfirmPassword,
                      decoration: InputDecoration(
                        hintText: "Confirm new password",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword =
                                  !_obscureConfirmPassword;
                            });
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Password Validation
                    Row(
                      children: [
                        Icon(
                          _isLengthValid
                              ? Icons.check_circle
                              : Icons.circle_outlined,
                          size: 18,
                          color: _isLengthValid ? Colors.green : Colors.grey,
                        ),
                        const SizedBox(width: 6),
                        const Text("At least 6 characters"),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          _isPasswordMatch
                              ? Icons.check_circle
                              : Icons.circle_outlined,
                          size: 18,
                          color: _isPasswordMatch ? Colors.green : Colors.grey,
                        ),
                        const SizedBox(width: 6),
                        const Text("Passwords match"),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: (_isLengthValid && _isPasswordMatch && !_isLoading)
                      ? _resetPassword
                      : null,
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          "Reset Password",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
