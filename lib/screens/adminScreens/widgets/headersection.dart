import 'package:flutter/material.dart';

class HeaderSection extends StatelessWidget {
  const HeaderSection({super.key});

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.person_add_alt, color: Colors.teal, size: 30),
            SizedBox(width: 8),
            Text(
              'Register New Employee',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      SizedBox(height: 8),
      Text(
        'Add a new employee to your FlowSphere workspace',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 17, color: Colors.grey[700]),
      ),
    ],
  );
}
