import 'package:flutter/material.dart';

class NotificationBanner extends StatelessWidget {
  const NotificationBanner({super.key});

  @override Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(11)),
    padding: EdgeInsets.all(12),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.mail_outline, color: Colors.blue),
        SizedBox(width: 11),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Automatic Email Notification',
                style: TextStyle(fontWeight: FontWeight.bold)),
            Text(
              'Upon successful registration, the new employee will receive an email with their login credentials and instructions to access their FlowSphere account.',
              style: TextStyle(fontSize: 13),
            ),
          ]),
        ),
      ],
    ),
  );
}
