import 'package:flutter/material.dart';

class EmployeeCard extends StatelessWidget {
  final Map<String, dynamic> emp;

  const EmployeeCard({super.key, required this.emp});

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
            Text("In: ${emp["checkIn"]} | Out: ${emp["checkOut"]}"),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emp["task"]),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: emp["status"] == "Present"
                    ? Colors.green.shade100
                    : Colors.red.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                emp["status"],
                style: TextStyle(
                  color: emp["status"] == "Present" ? Colors.green : Colors.red,
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
