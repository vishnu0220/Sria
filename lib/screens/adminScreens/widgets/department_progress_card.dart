// Department Progress Card Widget
import 'package:flutter/material.dart';

class DepartmentProgressCard extends StatelessWidget {
  final String departmentName;
  final int employeeCount;
  final double avgProgress;
  final int totalTasks;

  const DepartmentProgressCard({
    super.key,
    required this.departmentName,
    required this.employeeCount,
    required this.avgProgress,
    required this.totalTasks,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  departmentName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1f2937),
                  ),
                ),
                Text(
                  '$employeeCount employees',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6b7280),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text(
                  'Avg Progress',
                  style: TextStyle(fontSize: 14, color: Color(0xFF6b7280)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: LinearProgressIndicator(
                    value: avgProgress,
                    backgroundColor: Colors.grey.shade300,
                    color: avgProgress == 1.0
                        ? Colors.green.shade600
                        : Colors.blue.shade600,
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${(avgProgress * 100).toInt()}%',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1f2937),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '$totalTasks total tasks across department',
              style: const TextStyle(fontSize: 12, color: Color(0xFF6b7280)),
            ),
          ],
        ),
      ),
    );
  }
}
