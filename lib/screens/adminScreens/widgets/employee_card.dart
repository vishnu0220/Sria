import 'package:flutter/material.dart';

class EmployeeCard extends StatelessWidget {
  final Map<String, dynamic> emp;

  const EmployeeCard({super.key, required this.emp});

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case "present":
        return Colors.green;
      case "absent":
        return Colors.red;
      case "on leave":
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(emp["name"].toString().substring(0, 2).toUpperCase()),
        ),
        title: Text(emp["name"]),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(emp["role"]),
            Text(emp["department"]),
            // Text("In: ${emp["checkIn"]} | Out: ${emp["checkOut"]}"),
            Text(
              "In: ${emp["checkIn"]}",
              style: TextStyle(color: Colors.green),
            ),
            Text(
              "Out: ${emp["checkOut"]}",
              style: TextStyle(color: Colors.red),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Text(emp["task"]),
            // const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                // ignore: deprecated_member_use
                color: _getStatusColor(emp["status"]).withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                emp["status"],
                style: TextStyle(
                  color: _getStatusColor(emp["status"]),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
