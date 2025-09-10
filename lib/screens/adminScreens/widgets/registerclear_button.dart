import 'package:flutter/material.dart';

class RegisterClearButtons extends StatelessWidget {
  final VoidCallback onClear;
  final VoidCallback onRegister;

  const RegisterClearButtons({super.key, required this.onClear, required this.onRegister});

  @override Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        flex: 3,
        child: ElevatedButton(
          onPressed: onRegister,
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF009688),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: Text('Register Employee', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        ),
      ),
      SizedBox(width: 16),
      Expanded(
        flex: 2,
        child: OutlinedButton(
          onPressed: onClear,
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: Color(0xFFF0F2F5), width: 2),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: Text('Clear', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500,color: Colors.black)),
        ),
      ),
    ],
  );
}
