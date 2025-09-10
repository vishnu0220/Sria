import 'package:flutter/material.dart';

// Represents an employee's task.
class EmployeeTask {
  final String description;
  final bool isCompleted;
  final double progress;

  EmployeeTask({
    required this.description,
    required this.isCompleted,
    required this.progress,
  });
}

class TaskItem extends StatelessWidget {
  final EmployeeTask task;

  const TaskItem({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(
            task.isCompleted ? Icons.check_circle_outline : Icons.access_time,
            color: task.isCompleted ? Colors.green : Colors.amber,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              task.description,
              style: TextStyle(color: Colors.grey.shade800),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            '${(task.progress * 100).toInt()}%',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
