import 'dart:io';

import 'package:flow_sphere/Services/Admin_services/attendance_service.dart';
import 'package:flow_sphere/screens/adminScreens/widgets/admin_navigation_drawer.dart';
import 'package:flow_sphere/screens/adminScreens/widgets/employee_card.dart';
import 'package:flow_sphere/screens/userScreens/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shimmer/shimmer.dart';

class EmployeesScreen extends StatefulWidget {
  const EmployeesScreen({super.key});

  @override
  State<EmployeesScreen> createState() => _EmployeesScreenState();
}

class _EmployeesScreenState extends State<EmployeesScreen> {
  String selectedDepartment = "All Departments";
  String selectedStatus = "All";
  DateTime selectedDate = DateTime.now();
  String searchQuery = "";

  bool isLoading = false;
  bool hasInternetError = false;

  List<Map<String, dynamic>> employees = [];

  final List<String> departments = [
    "All Departments",
    "Development",
    "SAP",
    "Data Analytics",
  ];

  final List<String> statusOptions = ["All", "Present", "Absent", "On Leave"];

  @override
  void initState() {
    super.initState();
    fetchEmployees();
  }

  Future<void> fetchEmployees() async {
    setState(() {
      isLoading = true;
      hasInternetError = false;
    });
    try {
      final dateStr =
          "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}";
      print("Fetching attendance for date: $dateStr");
      final data = await AttendanceApiService.getAttendanceByDate(dateStr);
      setState(() {
        employees = data;
      });
    } on SocketException {
      // Catch network-specific errors
      if (mounted) {
        setState(() {
          isLoading = false;
          hasInternetError = true; // Set internet error state
        });
      }
    } catch (e) {
      print("Error fetching employees: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Date picker
  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2022),
      lastDate: DateTime.now(), // Future dates disabled
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
      fetchEmployees();
    }
  }

  // Filter bottom sheet
  void _openFilterSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Filter Employees",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // Department filter
              DropdownButtonFormField<String>(
                initialValue: selectedDepartment,
                decoration: const InputDecoration(
                  labelText: "Department",
                  border: OutlineInputBorder(),
                ),
                items: departments
                    .map(
                      (dep) => DropdownMenuItem(value: dep, child: Text(dep)),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedDepartment = value!;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Status filter
              DropdownButtonFormField<String>(
                initialValue: selectedStatus,
                decoration: const InputDecoration(
                  labelText: "Status",
                  border: OutlineInputBorder(),
                ),
                items: statusOptions
                    .map(
                      (status) =>
                          DropdownMenuItem(value: status, child: Text(status)),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedStatus = value!;
                  });
                },
              ),
              const SizedBox(height: 16),

              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Apply Filters"),
              ),
            ],
          ),
        );
      },
    );
  }

  // Refresh employees list
  void _refreshData() {
    setState(() {
      searchQuery = "";
      selectedDepartment = "All Departments";
      selectedStatus = "All";
      selectedDate = DateTime.now();
      isLoading = true; // start loader
    });
    fetchEmployees(); // re-fetch from API
  }

  @override
  Widget build(BuildContext context) {
    // Apply department + search + status filters
    final filteredEmployees = employees.where((emp) {
      final matchesDepartment =
          selectedDepartment == "All Departments" ||
          emp["department"] == selectedDepartment;
      final matchesSearch = emp["name"].toLowerCase().contains(
        searchQuery.toLowerCase(),
      );
      final matchesStatus =
          selectedStatus == "All" || emp["status"] == selectedStatus;
      return matchesDepartment && matchesSearch && matchesStatus;
    }).toList();

    return Scaffold(
      appBar: CustomAppBar(),
      drawer: AdminNavigationDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title + Subtitle + Refresh
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: const [
                    Icon(Icons.people, color: Colors.blue, size: 24),
                    SizedBox(width: 6),
                    Text(
                      "Employee Attendance Tracker",
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                // Refresh button
                IconButton(
                  onPressed: _refreshData,
                  icon: const Icon(Icons.refresh),
                  color: Colors.black,
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              "Monitor daily attendance, tasks, and employee status",
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 12),

            // Search bar
            TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: "Search employees...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Filter + Calendar Row
            Row(
              children: [
                TextButton.icon(
                  onPressed: _openFilterSheet,
                  icon: const Icon(Icons.filter_list, color: Color(0xFF0d6efd)),
                  label: const Text(
                    "Filter",
                    style: TextStyle(color: Color(0xFF0d6efd)),
                  ),
                ),
                const SizedBox(width: 16),
                TextButton.icon(
                  onPressed: () => _pickDate(context),
                  icon: const Icon(
                    Icons.calendar_today,
                    color: Color(0xFF0d6efd),
                  ),
                  label: Text(
                    "${selectedDate.day}-${selectedDate.month}-${selectedDate.year}",
                    style: const TextStyle(color: Color(0xFF0d6efd)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Employee list
            hasInternetError
                ? _buildNoInternetView()
                : isLoading
                ? employeeLoadingCard()
                : Expanded(
                    child: isLoading
                        // ? const Center(child: CircularProgressIndicator())
                        ? const Center(child: CircularProgressIndicator())
                        : filteredEmployees.isEmpty
                        ? const Center(
                            child: Text(
                              "No employees found",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          )
                        : ListView.builder(
                            itemCount: filteredEmployees.length,
                            itemBuilder: (context, index) {
                              final emp = filteredEmployees[index];
                              return EmployeeCard(emp: emp);
                            },
                          ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoInternetView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            'assets/lottie/choose-your-colors.json',
            repeat: true,
            width: 250,
            height: 250,
          ),
          const SizedBox(height: 20),
          Text(
            "No Internet Connection",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: fetchEmployees,
            icon: const Icon(Icons.refresh),
            label: const Text("Try Again"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget employeeLoadingCard() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 90,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            const SizedBox(height: 16),
            // Progress Card Skeleton
            Container(
              width: double.infinity,
              height: 90,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            const SizedBox(height: 16),
            // Action Cards Skeleton
            Container(
              width: double.infinity,
              height: 90,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            const SizedBox(height: 16),
            // Action Cards Skeleton
            Container(
              width: double.infinity,
              height: 45,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
