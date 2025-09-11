import 'package:flow_sphere/screens/adminScreens/widgets/admin_navigation_drawer.dart';
import 'package:flow_sphere/screens/adminScreens/widgets/department_progress_card.dart';
import 'package:flow_sphere/screens/adminScreens/widgets/employee_progress_card.dart';
import 'package:flow_sphere/screens/adminScreens/widgets/export_progress_dialog.dart';
import 'package:flow_sphere/screens/adminScreens/widgets/summary_card.dart';
import 'package:flow_sphere/screens/adminScreens/widgets/task_item.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// ignore: depend_on_referenced_packages
import 'package:collection/collection.dart';
import '../userScreens/custom_appbar.dart';

class AdminProgressScreen extends StatefulWidget {
  const AdminProgressScreen({super.key});

  @override
  State<AdminProgressScreen> createState() => _AdminProgressScreenState();
}

class _AdminProgressScreenState extends State<AdminProgressScreen> {
  // NOTE: This is where you would call your backend API to fetch real-time data.
  // The lists below are for demonstration purposes. Replace this with your API fetch logic.
  final List<EmployeeProgress> _staticEmployees = [
    EmployeeProgress(
      initials: 'PR',
      name: 'Padmakar Reddy Abaka',
      department: 'SAP',
      overallProgress: 1.0,
      totalTasks: 2,
      completedTasks: 2,
      tasks: [
        EmployeeTask(
          description: 'Outlook user management',
          isCompleted: true,
          progress: 1.0,
        ),
        EmployeeTask(
          description: 'User management and explained few topics for new BA...',
          isCompleted: true,
          progress: 1.0,
        ),
      ],
    ),
    EmployeeProgress(
      initials: 'AN',
      name: 'Anitha Narappagari',
      department: 'SAP',
      overallProgress: 0.5,
      totalTasks: 1,
      completedTasks: 0,
      tasks: [
        EmployeeTask(
          description: 'ZCHQDPR_SUMMARY',
          isCompleted: false,
          progress: 0.5,
        ),
      ],
    ),
    EmployeeProgress(
      initials: 'NKS',
      name: 'Nithin Kumar Sandala',
      department: 'Development',
      overallProgress: 0.75,
      totalTasks: 1,
      completedTasks: 0,
      tasks: [
        EmployeeTask(
          description: 'Connected meeting with LVK Pharma, discussed major...',
          isCompleted: false,
          progress: 0.75,
        ),
      ],
    ),
    EmployeeProgress(
      initials: 'SG',
      name: 'Sridevi Gedela',
      department: 'Development',
      overallProgress: 0.63,
      totalTasks: 2,
      completedTasks: 1,
      tasks: [
        EmployeeTask(
          description: 'Trained the interns and assign tasks to them',
          isCompleted: true,
          progress: 1.0,
        ),
        EmployeeTask(
          description:
              'Working on implementation of payment tracking in the B...',
          isCompleted: false,
          progress: 0.25,
        ),
      ],
    ),
    EmployeeProgress(
      initials: 'RV',
      name: 'Rithwika Veera',
      department: 'Development',
      overallProgress: 1.0,
      totalTasks: 1,
      completedTasks: 1,
      tasks: [
        EmployeeTask(
          description: 'Worked on 7 Hills Indian Restaurant Website',
          isCompleted: true,
          progress: 1.0,
        ),
      ],
    ),
    EmployeeProgress(
      initials: 'VK',
      name: 'Varaprasad Karnati',
      department: 'SAP',
      overallProgress: 0.75,
      totalTasks: 1,
      completedTasks: 1,
      tasks: [
        EmployeeTask(description: 'SAP', isCompleted: true, progress: 1.0),
      ],
    ),
  ];

  late List<EmployeeProgress> _filteredEmployees;
  String _searchQuery = '';
  String? _selectedDepartment;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _filteredEmployees = _staticEmployees;
  }

  // Group employees by department for the department overview.
  Map<String, List<EmployeeProgress>> get _departmentGroupedData {
    return groupBy(_staticEmployees, (employee) => employee.department);
  }

  // Filter employees based on search query and selected department.
  void _filterEmployees() {
    final List<EmployeeProgress> employees = _staticEmployees;

    setState(() {
      _filteredEmployees = employees.where((employee) {
        final matchesSearch = employee.name.toLowerCase().contains(
          _searchQuery.toLowerCase(),
        );
        final matchesDepartment =
            _selectedDepartment == null ||
            _selectedDepartment == 'All' ||
            employee.department == _selectedDepartment;
        // In a real app, you would also filter by date. For this example, we'll
        // assume all data is for the selected date.
        return matchesSearch && matchesDepartment;
      }).toList();
    });
  }

  // Function to show the date picker.
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(), // Disable future dates
      helpText: 'Select Progress Date',
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: const Color(0xFF0d6efd), // Header background color
            colorScheme: const ColorScheme.light(primary: Color(0xFF0d6efd)),
            buttonTheme: const ButtonThemeData(
              textTheme: ButtonTextTheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        // In a real app, you would refetch data for the new date here.
        // For this example, we'll just update the displayed date.
      });
    }
  }

  // Function to show the export dialog
  Future<void> _showExportDialog() async {
    await showDialog(
      context: context,
      builder: (context) {
        return const ExportProgressDialog();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: CustomAppBar(),
      drawer: AdminNavigationDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Team Progress\nDashboard',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1f2937),
                      ),
                    ),
                    Text(
                      'Monitor team productivity and\nprogress across departments',
                      style: TextStyle(fontSize: 14, color: Color(0xFF6b7280)),
                    ),
                  ],
                ),
                OutlinedButton.icon(
                  onPressed: _showExportDialog,
                  icon: const Icon(Icons.download),
                  label: const Text('Export Progress'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF374151),
                    side: const BorderSide(color: Color(0xFF9ca3af)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                SummaryCard(
                  title: 'Active Employees',
                  value: _staticEmployees.length.toString(),
                  icon: Icons.people_outline,
                  iconColor: const Color(0xFF0d6efd),
                ),
                SummaryCard(
                  title: 'Avg Progress',
                  value:
                      '${((_staticEmployees.map((e) => e.overallProgress).average * 100).toInt())}%',
                  icon: Icons.trending_up,
                  iconColor: Colors.green.shade700,
                ),
                SummaryCard(
                  title: 'Total Tasks',
                  value: _staticEmployees
                      .map((e) => e.totalTasks)
                      .sum
                      .toString(),
                  icon: Icons.list_alt,
                  iconColor: const Color(0xFFf59e0b),
                ),
                SummaryCard(
                  title: 'Completed Tasks',
                  value: _staticEmployees
                      .map((e) => e.completedTasks)
                      .sum
                      .toString(),
                  icon: Icons.check_circle_outline,
                  iconColor: const Color(0xFF8b5cf6),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withAlpha(25),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  TextField(
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                        _filterEmployees();
                      });
                    },
                    decoration: const InputDecoration(
                      hintText: 'Search employees...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Color(0xFFf3f4f6),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: _selectedDepartment,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: const Color(0xFFf3f4f6),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                            ),
                          ),
                          hint: const Text('All Departments'),
                          items: [
                            const DropdownMenuItem(
                              value: 'All',
                              child: Text('All Departments'),
                            ),
                            ..._staticEmployees
                                .map((e) => e.department)
                                .toSet()
                                .map((department) {
                                  return DropdownMenuItem(
                                    value: department,
                                    child: Text(department),
                                  );
                                })
                                // ignore: unnecessary_to_list_in_spreads
                                .toList(),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedDepartment = value;
                              _filterEmployees();
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      GestureDetector(
                        onTap: () => _selectDate(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFf3f4f6),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.calendar_today,
                                color: Colors.grey,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                DateFormat(
                                  'MMM dd, yyyy',
                                ).format(_selectedDate),
                                style: const TextStyle(color: Colors.black),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Employee Progress',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1f2937),
              ),
            ),
            Text(
              '${DateFormat('EEEE, MMMM dd, yyyy').format(_selectedDate)} - ${_filteredEmployees.length} employees',
              style: const TextStyle(fontSize: 14, color: Color(0xFF6b7280)),
            ),
            const SizedBox(height: 16),
            ..._filteredEmployees.map(
              (employee) => EmployeeProgressCard(employee: employee),
            ),
            const SizedBox(height: 24),
            // Department Overview Section - Moved here as requested
            const Text(
              'Department Overview',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1f2937),
              ),
            ),
            Text(
              'Progress breakdown by department for ${DateFormat('MMM dd, yyyy').format(_selectedDate)}',
              style: const TextStyle(fontSize: 14, color: Color(0xFF6b7280)),
            ),
            const SizedBox(height: 16),
            ..._departmentGroupedData.entries.map((entry) {
              final department = entry.key;
              final employeesInDept = entry.value;
              final avgProgress = employeesInDept
                  .map((e) => e.overallProgress)
                  .average;
              final totalTasks = employeesInDept.map((e) => e.totalTasks).sum;
              return DepartmentProgressCard(
                departmentName: department,
                employeeCount: employeesInDept.length,
                avgProgress: avgProgress,
                totalTasks: totalTasks,
              );
            // ignore: unnecessary_to_list_in_spreads
            }).toList(),
          ],
        ),
      ),
    );
  }
}
