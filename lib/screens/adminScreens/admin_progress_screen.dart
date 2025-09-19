import 'dart:convert';
import 'package:flow_sphere/Services/login_api_services.dart';
import 'package:flow_sphere/screens/adminScreens/widgets/admin_navigation_drawer.dart';
import 'package:flow_sphere/screens/adminScreens/widgets/department_progress_card.dart';
import 'package:flow_sphere/screens/adminScreens/widgets/employee_progress_card.dart';
import 'package:flow_sphere/screens/adminScreens/widgets/export_progress_dialog.dart';
import 'package:flow_sphere/screens/adminScreens/widgets/summary_card.dart';
import 'package:flow_sphere/screens/adminScreens/widgets/task_item.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';
import '../userScreens/custom_appbar.dart';

class AdminProgressScreen extends StatefulWidget {
  const AdminProgressScreen({super.key});

  @override
  State<AdminProgressScreen> createState() => _AdminProgressScreenState();
}

class _AdminProgressScreenState extends State<AdminProgressScreen> {
  List<EmployeeProgress> _employees = [];
  late List<EmployeeProgress> _filteredEmployees;
  String _searchQuery = '';
  String? _selectedDepartment;
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = true;
  String? _error;
  
  // Summary data from API
  int _totalEmployees = 0;
  double _avgProgress = 0;
  int _totalTasks = 0;
  int _completedTasks = 0;
  List<DepartmentData> _departments = [];
  
  // Auth service instance
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Load data from API
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Load summary stats
      await _loadSummaryStats();
      
      // Load employee progress data
      await _loadEmployeeProgress();
      
    } catch (e) {
      setState(() {
        _error = 'Failed to load data: $e';
        _isLoading = false;
      });
    }
  }

  // Load summary statistics
  Future<void> _loadSummaryStats() async {
    try {
      final result = await _authService.getProtected('/api/admin/stats');
      
      if (result['success'] == true) {
        final data = result['data'];
        setState(() {
          _totalEmployees = data['today']['totalEmployees'] ?? 0;
          _avgProgress = (data['today']['avgProgress'] ?? 0).toDouble();
          _totalTasks = data['today']['totalTasks'] ?? 0;
          _completedTasks = data['today']['completedTasks'] ?? 0;
          
          // Parse departments data
          _departments = (data['departments'] as List<dynamic>? ?? [])
              .map((dept) => DepartmentData.fromJson(dept))
              .toList();
        });
      } else {
        throw Exception(result['message'] ?? 'Failed to load summary stats');
      }
    } catch (e) {
      print('Error loading summary stats: $e');
      rethrow;
    }
  }

  // Load employee progress data
  Future<void> _loadEmployeeProgress() async {
    try {
      final dateString = DateFormat('yyyy-MM-dd').format(_selectedDate);
      final result = await _authService.getProtected(
        '/api/admin/all?date=$dateString&limit=50&page=1&sortBy=date&sortOrder=desc'
      );
      
      if (result['success'] == true) {
        final data = result['data'];
        final records = data['records'] as List<dynamic>;
        
        setState(() {
          _employees = records.map((record) => EmployeeProgress.fromJson(record)).toList();
          _filteredEmployees = _employees;
          _isLoading = false;
        });
        
        _filterEmployees();
      } else {
        if (result['statusCode'] == 404) {
          // No data found for this date - this is normal
          setState(() {
            _employees = [];
            _filteredEmployees = [];
            _isLoading = false;
          });
        } else {
          throw Exception(result['message'] ?? 'Failed to load employee progress');
        }
      }
    } catch (e) {
      print('Error loading employee progress: $e');
      rethrow;
    }
  }

  // Group employees by department for the department overview
  Map<String, List<EmployeeProgress>> get _departmentGroupedData {
    return groupBy(_filteredEmployees, (employee) => employee.department);
  }

  // Filter employees based on search query and selected department
  void _filterEmployees() {
    setState(() {
      _filteredEmployees = _employees.where((employee) {
        final matchesSearch = employee.name.toLowerCase().contains(
          _searchQuery.toLowerCase(),
        );
        final matchesDepartment = _selectedDepartment == null ||
            _selectedDepartment == 'All' ||
            employee.department == _selectedDepartment;

        return matchesSearch && matchesDepartment;
      }).toList();
    });
  }

  // Function to show the date picker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      helpText: 'Select Progress Date',
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: const Color(0xFF0d6efd),
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
      });
      await _loadData(); // Reload data for new date
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
                      const SizedBox(height: 16),
                      Text(_error!, textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadData,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(10),
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
                              value: _employees.isNotEmpty ? _employees.length.toString() : _totalEmployees.toString(),
                              icon: Icons.people_outline,
                              iconColor: const Color(0xFF0d6efd),
                            ),
                            SummaryCard(
                              title: 'Avg Progress',
                              value: _employees.isNotEmpty 
                                  ? '${(_employees.map((e) => e.overallProgress).average * 100).toInt()}%'
                                  : '${_avgProgress.toInt()}%',
                              icon: Icons.trending_up,
                              iconColor: Colors.green.shade700,
                            ),
                            SummaryCard(
                              title: 'Total Tasks',
                              value: _employees.isNotEmpty
                                  ? _employees.map((e) => e.totalTasks).sum.toString()
                                  : _totalTasks.toString(),
                              icon: Icons.list_alt,
                              iconColor: const Color(0xFFf59e0b),
                            ),
                            SummaryCard(
                              title: 'Completed Tasks',
                              value: _employees.isNotEmpty
                                  ? _employees.map((e) => e.completedTasks).sum.toString()
                                  : _completedTasks.toString(),
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
                                      value: _selectedDepartment,
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
                                        ..._employees
                                            .map((e) => e.department)
                                            .toSet()
                                            .map((department) {
                                          return DropdownMenuItem(
                                            value: department,
                                            child: Text(department),
                                          );
                                        }).toList(),
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
                                            DateFormat('MMM dd').format(_selectedDate),
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
                        if (_filteredEmployees.isEmpty)
                          Center(
                            child: Column(
                              children: [
                                Icon(Icons.people_outline, size: 64, color: Colors.grey.shade300),
                                const SizedBox(height: 16),
                                const Text('No employees found for the selected criteria'),
                              ],
                            ),
                          )
                        else
                          ..._filteredEmployees.map(
                            (employee) => EmployeeProgressCard(employee: employee),
                          ),
                        const SizedBox(height: 24),
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
                        if (_departmentGroupedData.isEmpty)
                          Center(
                            child: Column(
                              children: [
                                Icon(Icons.business_outlined, size: 64, color: Colors.grey.shade300),
                                const SizedBox(height: 16),
                                const Text('No department data available'),
                              ],
                            ),
                          )
                        else
                          ..._departmentGroupedData.entries.map((entry) {
                            final department = entry.key;
                            final employeesInDept = entry.value;
                            final avgProgress = employeesInDept.isNotEmpty 
                                ? employeesInDept.map((e) => e.overallProgress).average
                                : 0.0;
                            final totalTasks = employeesInDept.map((e) => e.totalTasks).sum;

                            return DepartmentProgressCard(
                              departmentName: department,
                              employeeCount: employeesInDept.length,
                              avgProgress: avgProgress,
                              totalTasks: totalTasks,
                            );
                          }).toList(),
                      ],
                    ),
                  ),
                ),
    );
  }
}

// Data models for API responses
class DepartmentData {
  final String name;
  final int employeeCount;
  final double avgProgress;
  final int totalTasks;

  DepartmentData({
    required this.name,
    required this.employeeCount,
    required this.avgProgress,
    required this.totalTasks,
  });

  factory DepartmentData.fromJson(Map<String, dynamic> json) {
    return DepartmentData(
      name: json['name'] ?? '',
      employeeCount: json['employeeCount'] ?? 0,
      avgProgress: (json['avgProgress'] ?? 0).toDouble(),
      totalTasks: json['totalTasks'] ?? 0,
    );
  }
}