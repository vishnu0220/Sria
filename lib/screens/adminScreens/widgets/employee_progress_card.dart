import 'package:flow_sphere/screens/adminScreens/widgets/task_item.dart';
import 'package:flutter/material.dart';

// Represents a single employee's progress from API
class EmployeeProgress {
  final String id;
  final String initials;
  final String name;
  final String department;
  final String email;
  final double overallProgress;
  final int totalTasks;
  final int completedTasks;
  final List<EmployeeTask> tasks;
  final String dailyNotes;
  final DateTime date;

  EmployeeProgress({
    required this.id,
    required this.initials,
    required this.name,
    required this.department,
    required this.email,
    required this.overallProgress,
    required this.totalTasks,
    required this.completedTasks,
    required this.tasks,
    required this.dailyNotes,
    required this.date,
  });

  factory EmployeeProgress.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>;
    final tasksData = json['tasks'] as List<dynamic>? ?? [];
    
    // Parse tasks
    final tasks = tasksData.map((taskJson) => EmployeeTask.fromJson(taskJson)).toList();
    
    // Calculate completed tasks
    final completedTasks = tasks.where((task) => task.isCompleted).length;
    
    // Generate initials from name
    final name = user['name'] ?? '';
    final initials = _generateInitials(name);

    return EmployeeProgress(
      id: json['_id'] ?? '',
      initials: initials,
      name: name,
      department: user['department'] ?? '',
      email: user['email'] ?? '',
      overallProgress: ((json['overallProgress'] ?? 0) / 100.0).toDouble(),
      totalTasks: tasks.length,
      completedTasks: completedTasks,
      tasks: tasks,
      dailyNotes: json['dailyNotes'] ?? '',
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
    );
  }

  static String _generateInitials(String name) {
    if (name.isEmpty) return '??';
    
    final words = name.split(' ').where((word) => word.isNotEmpty).toList();
    if (words.isEmpty) return '??';
    
    if (words.length == 1) {
      return words[0].substring(0, words[0].length >= 2 ? 2 : 1).toUpperCase();
    }
    
    // Take first letter of first two words
    return (words[0][0] + (words.length > 1 ? words[1][0] : '')).toUpperCase();
  }
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
                      '${employee.completedTasks}/${employee.totalTasks} tasks completed',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6b7280),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Added spacing
            // Show daily notes if available
            if (employee.dailyNotes.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Daily Notes:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Color(0xFF6b7280),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      employee.dailyNotes,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            // Moved the "View Details" button to a new line
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton.icon(
                onPressed: () {
                  _showEmployeeDetailsDialog(context, employee);
                },
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
            if (employee.tasks.isNotEmpty) ...[
              const Divider(height: 32, thickness: 1),
              ...employee.tasks.take(3).map((task) => TaskItem(task: task)),
              if (employee.tasks.length > 3)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    '... and ${employee.tasks.length - 3} more tasks',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  void _showEmployeeDetailsDialog(BuildContext context, EmployeeProgress employee) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(24),
          constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          employee.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${employee.department} • ${employee.email}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6b7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              // Progress summary
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Overall Progress',
                          style: TextStyle(fontSize: 12, color: Color(0xFF6b7280)),
                        ),
                        Text(
                          '${(employee.overallProgress * 100).toInt()}%',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'Tasks Completed',
                          style: TextStyle(fontSize: 12, color: Color(0xFF6b7280)),
                        ),
                        Text(
                          '${employee.completedTasks}/${employee.totalTasks}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Daily notes if available
              if (employee.dailyNotes.isNotEmpty) ...[
                const Text(
                  'Daily Notes',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Text(employee.dailyNotes),
                ),
                const SizedBox(height: 20),
              ],
              
              // Tasks list
              const Text(
                'Tasks',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              
              Expanded(
                child: employee.tasks.isEmpty
                    ? const Center(
                        child: Text(
                          'No tasks assigned',
                          style: TextStyle(color: Color(0xFF6b7280)),
                        ),
                      )
                    : ListView.builder(
                        itemCount: employee.tasks.length,
                        itemBuilder: (context, index) {
                          final task = employee.tasks[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: task.isCompleted 
                                  ? Colors.green.shade50 
                                  : Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: task.isCompleted 
                                    ? Colors.green.shade200 
                                    : Colors.orange.shade200,
                              ),
                            ),
                            child: TaskItem(task: task),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}