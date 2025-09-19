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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        departmentName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1f2937),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$employeeCount ${employeeCount == 1 ? 'employee' : 'employees'}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF6b7280),
                        ),
                      ),
                    ],
                  ),
                ),
                // Department icon based on name
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _getDepartmentColor(departmentName).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getDepartmentIcon(departmentName),
                    color: _getDepartmentColor(departmentName),
                    size: 24,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Progress section
            Row(
              children: [
                const Text(
                  'Avg Progress',
                  style: TextStyle(fontSize: 14, color: Color(0xFF6b7280)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: LinearProgressIndicator(
                    value: avgProgress.clamp(0.0, 1.0),
                    backgroundColor: Colors.grey.shade300,
                    color: avgProgress >= 0.8
                        ? Colors.green.shade600
                        : avgProgress >= 0.6
                            ? Colors.orange.shade600
                            : Colors.red.shade600,
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${(avgProgress * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: avgProgress >= 0.8
                        ? Colors.green.shade700
                        : avgProgress >= 0.6
                            ? Colors.orange.shade700
                            : Colors.red.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Additional metrics
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildMetric(
                  'Total Tasks',
                  totalTasks.toString(),
                  Icons.list_alt,
                  Colors.blue.shade600,
                ),
                _buildMetric(
                  'Active Today',
                  employeeCount.toString(),
                  Icons.people_outline,
                  Colors.green.shade600,
                ),
                _buildMetric(
                  'Performance',
                  _getPerformanceLabel(avgProgress),
                  _getPerformanceIcon(avgProgress),
                  _getPerformanceColor(avgProgress),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetric(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: Color(0xFF6b7280),
          ),
        ),
      ],
    );
  }

  IconData _getDepartmentIcon(String department) {
    switch (department.toLowerCase()) {
      case 'development':
      case 'dev':
      case 'engineering':
        return Icons.code;
      case 'sap':
      case 'erp':
        return Icons.business;
      case 'design':
      case 'ui/ux':
        return Icons.design_services;
      case 'marketing':
        return Icons.campaign;
      case 'hr':
      case 'human resources':
        return Icons.people;
      case 'finance':
        return Icons.account_balance;
      case 'sales':
        return Icons.trending_up;
      case 'support':
        return Icons.support;
      case 'qa':
      case 'testing':
        return Icons.bug_report;
      default:
        return Icons.work;
    }
  }

  Color _getDepartmentColor(String department) {
    switch (department.toLowerCase()) {
      case 'development':
      case 'dev':
      case 'engineering':
        return Colors.blue;
      case 'sap':
      case 'erp':
        return Colors.purple;
      case 'design':
      case 'ui/ux':
        return Colors.pink;
      case 'marketing':
        return Colors.orange;
      case 'hr':
      case 'human resources':
        return Colors.green;
      case 'finance':
        return Colors.teal;
      case 'sales':
        return Colors.indigo;
      case 'support':
        return Colors.cyan;
      case 'qa':
      case 'testing':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getPerformanceLabel(double progress) {
    if (progress >= 0.9) return 'Excellent';
    if (progress >= 0.8) return 'Great';
    if (progress >= 0.7) return 'Good';
    if (progress >= 0.6) return 'Average';
    if (progress >= 0.4) return 'Below Avg';
    return 'Needs Attention';
  }

  IconData _getPerformanceIcon(double progress) {
    if (progress >= 0.8) return Icons.trending_up;
    if (progress >= 0.6) return Icons.trending_flat;
    return Icons.trending_down;
  }

  Color _getPerformanceColor(double progress) {
    if (progress >= 0.8) return Colors.green.shade600;
    if (progress >= 0.6) return Colors.orange.shade600;
    return Colors.red.shade600;
  }
}