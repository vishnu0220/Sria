import 'package:flutter/material.dart';

// Represents an employee's task from API
class EmployeeTask {
  final String id;
  final String description;
  final bool isCompleted;
  final double progress;
  final String status;
  final DateTime createdAt;

  EmployeeTask({
    required this.id,
    required this.description,
    required this.isCompleted,
    required this.progress,
    required this.status,
    required this.createdAt,
  });

  factory EmployeeTask.fromJson(Map<String, dynamic> json) {
    final status = json['status'] ?? 'in-progress';
    final progress = (json['progress'] ?? 0).toDouble();

    return EmployeeTask(
      id: json['id'] ?? '',
      description: json['description'] ?? '',
      isCompleted: status == 'completed',
      progress: progress / 100.0, // Convert percentage to decimal
      status: status,
      createdAt: DateTime.parse(
        json['timestamps']?['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }
}

class TaskItem extends StatelessWidget {
  final EmployeeTask task;

  const TaskItem({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            task.isCompleted ? Icons.check_circle : Icons.access_time,
            color: task.isCompleted
                ? Colors.green
                : task.progress > 0
                ? Colors.orange
                : Colors.grey,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.description,
                  style: TextStyle(color: Colors.grey.shade800, fontSize: 14),
                ),
                const SizedBox(height: 4),
                // Progress bar for incomplete tasks
                if (!task.isCompleted && task.progress > 0) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: LinearProgressIndicator(
                          value: task.progress,
                          backgroundColor: Colors.grey.shade200,
                          color: task.progress > 0.7
                              ? Colors.green.shade400
                              : task.progress > 0.4
                              ? Colors.orange.shade400
                              : Colors.red.shade400,
                          minHeight: 4,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${(task.progress * 100).toInt()}%',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
                // Status badge
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(task.status).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _getStatusColor(task.status).withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        _getStatusLabel(task.status),
                        style: TextStyle(
                          fontSize: 10,
                          color: _getStatusColor(task.status),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${(task.progress * 100).toInt()}%',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'in-progress':
        return Colors.orange;
      case 'pending':
        return Colors.grey;
      case 'blocked':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  String _getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'in-progress':
        return 'In Progress';
      case 'completed':
        return 'Completed';
      case 'pending':
        return 'Pending';
      case 'blocked':
        return 'Blocked';
      default:
        return status.toUpperCase();
    }
  }
}
