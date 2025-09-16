// verify_code_page.dart

import 'package:flow_sphere/Services/forgotpassword_api_service.dart';
import 'package:flow_sphere/screens/authScreens/password_reset_page.dart';
import 'package:flow_sphere/screens/authScreens/reset_password.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class VerifyCodePage extends StatefulWidget {
  final String email;
  final String otp; // This parameter can be removed as it's not used
  const VerifyCodePage({super.key, required this.email, required this.otp});

  @override
  State<VerifyCodePage> createState() => _VerifyCodePageState();
}

class _VerifyCodePageState extends State<VerifyCodePage> {
  final TextEditingController codeController = TextEditingController();
  bool _isLoading = false;
  String? verifiedOtp; // Store the verified OTP

  @override
  void initState() {
    super.initState();
    print("VerifyCodePage - Email: ${widget.email}");
  }

  void _verifyCode() async {
    final otpInput = codeController.text.trim();

    if (otpInput.length != 6) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Enter 6-digit code")));
      return;
    }

    if (!RegExp(r'^[0-9]+$').hasMatch(otpInput)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Code should contain only numbers")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final api = ApiService();
      print("Verifying OTP: $otpInput for email: ${widget.email}");

      final result = await api.verifyOtp(widget.email, otpInput);

      if (!mounted) return;

      print("OTP verification successful: ${result['message']}");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? "Verification successful"),
          backgroundColor: Colors.green,
        ),
      );

      // Store the verified OTP
      verifiedOtp = otpInput;

      // Navigate to ResetPasswordPage with verified OTP
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResetPasswordPage(
            email: widget.email,
            otp: otpInput, // Pass the verified OTP
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      print("OTP verification failed: $e");

      String errorMessage = "Error verifying code";

      if (e.toString().contains("400")) {
        errorMessage = "Invalid verification code. Please check and try again.";
      } else if (e.toString().contains("404")) {
        errorMessage =
            "Verification code has expired. Please request a new one.";
      } else if (e.toString().contains("401")) {
        errorMessage = "Unauthorized request. Please start over.";
      } else {
        errorMessage = e.toString().replaceAll('Exception: ', '');
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

  void _resendCode() async {
    // Clear the current code input when resending
    codeController.clear();
    verifiedOtp = null;

    setState(() => _isLoading = true);

    try {
      final api = ApiService();
      print("Resending code to: ${widget.email}");

      final result = await api.forgotPassword(widget.email);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? "Code resent successfully"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      print("Resend code failed: $e");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Error resending code: ${e.toString().replaceAll('Exception: ', '')}",
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset("assets/images/flowsphere_logo.png", height: 100),
              const SizedBox(height: 20),
              const Text(
                "Verify Code",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                "Enter the verification code sent to",
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Text(
                widget.email,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.teal,
                ),
              ),
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.security_outlined),
                        SizedBox(width: 8),
                        Text(
                          "Enter Verification Code",
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Check your email for the 6-digit verification code",
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: codeController,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(6),
                      ],
                      decoration: const InputDecoration(
                        labelText: "Verification Code",
                        hintText: "Enter 6-digit code",
                        border: OutlineInputBorder(),
                        counterText: "", // Hide character counter
                      ),
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 18, letterSpacing: 2.0),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.teal,
                        ),
                        onPressed: _isLoading ? null : _verifyCode,
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
                                "Verify Code",
                                style: TextStyle(color: Colors.white),
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Center(
                      child: Text(
                        "Didn't receive the code?",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Center(
                      child: TextButton.icon(
                        onPressed: _isLoading ? null : _resendCode,
                        icon: const Icon(Icons.replay, color: Colors.teal),
                        label: const Text(
                          "Resend Code",
                          style: TextStyle(color: Colors.teal),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: TextButton.icon(
                        onPressed: () {
                          // Go back to the password reset (email entry) page
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const PasswordResetPage(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.arrow_back, color: Colors.grey),
                        label: const Text(
                          "Back to Email Entry",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
