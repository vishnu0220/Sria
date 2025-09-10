import 'package:flow_sphere/screens/adminScreens/widgets/task_item.dart';
import 'package:flutter/material.dart';

// Represents a single employee's progress.
class EmployeeProgress {
  final String initials;
  final String name;
  final String department;
  final double overallProgress;
  final int totalTasks;
  final int completedTasks;
  final List<EmployeeTask> tasks;

  EmployeeProgress({
    required this.initials,
    required this.name,
    required this.department,
    required this.overallProgress,
    required this.totalTasks,
    required this.completedTasks,
    required this.tasks,
  });
}

class EmployeeProgressCard extends StatelessWidget {
  final EmployeeProgress employee;

  const EmployeeProgressCard({super.key, required this.employee});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.blue.shade100,
                  child: Text(
                    employee.initials,
                    style: TextStyle(
                      color: Colors.blue.shade800,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        employee.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '• ${employee.department}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF6b7280),
                        ),
                      ),
                    ],
                  ),
                ),
                // This column contains the progress info
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${(employee.overallProgress * 100).toInt()}%',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: employee.overallProgress == 1.0
                            ? Colors.green.shade800
                            : Colors.blue.shade800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    SizedBox(
                      width: 100, // You can adjust this width as needed
                      child: LinearProgressIndicator(
                        value: employee.overallProgress,
                        backgroundColor: Colors.grey.shade300,
                        color: employee.overallProgress == 1.0
                            ? Colors.green.shade600
                            : Colors.blue.shade600,
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${employee.completedTasks} tasks completed',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6b7280),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16), // Added spacing
            // Moved the "View Details" button to a new line
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.remove_red_eye_outlined),
                label: const Text('View Details'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.blue.shade700,
                  side: BorderSide(color: Colors.blue.shade700),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            const Divider(height: 32, thickness: 1),
            ...employee.tasks.map((task) => TaskItem(task: task)),
          ],
        ),
      ),
    );
  }
}
