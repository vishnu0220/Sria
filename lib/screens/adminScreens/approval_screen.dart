import 'dart:async';
import 'dart:convert';
import 'package:flow_sphere/Services/Admin_services/login_api_services.dart';
import 'package:flow_sphere/screens/adminScreens/widgets/admin_navigation_drawer.dart';
import 'package:flow_sphere/screens/adminScreens/widgets/request_card.dart';
import 'package:flow_sphere/screens/adminScreens/widgets/review_request_dialog.dart';
import 'package:flow_sphere/screens/userScreens/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class ApprovalScreen extends StatefulWidget {
  const ApprovalScreen({super.key});

  @override
  State<ApprovalScreen> createState() => _ApprovalScreenState();
}

class _ApprovalScreenState extends State<ApprovalScreen> {
  final AuthService _authService = AuthService();
  List<Request> _requests = [];
  String _selectedFilter = 'All Requests';
  bool _isLoading = true;
  String? _errorMessage;
  DateTime? _lastUpdated;

  @override
  void initState() {
    super.initState();
    _fetchRequests();
  }

  Future<void> _fetchRequests() async {
    try {
      final token = await _authService.getToken();

      if (token == null) {
        setState(() {
          _errorMessage = "No token found. Please log in again.";
          _isLoading = false;
        });
        return;
      }

      final response = await http.get(
        Uri.parse("https://leave-backend-vbw6.onrender.com/api/admin/requests"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        setState(() {
          _requests = data.map((json) {
            String formatDate(String? rawDate) {
              if (rawDate == null) return "N/A";
              try {
                DateTime utcDate = DateTime.parse(rawDate);
                DateTime istDate = utcDate.toLocal();
                return DateFormat('dd-MMM-yyyy').format(istDate);
              } catch (e) {
                return rawDate;
              }
            }

            String getTime(String? rawDate) {
              if (rawDate == null) return "N/A";
              try {
                DateTime utcDate = DateTime.parse(rawDate);
                DateTime istDate = utcDate.toLocal();
                return DateFormat(
                  'dd-MMM-yyyy, hh:mm a',
                ).format(istDate).split(',')[0];
              } catch (e) {
                return rawDate;
              }
            }

            return Request(
              id: json['_id'] ?? '',
              type: json['type'] ?? 'Unknown',
              status: json['status'] ?? 'PENDING',
              name: json['user']['name'] ?? 'Unknown',
              email: json['user']['email'] ?? 'Unknown',
              date: formatDate(json['start_date']),
              leaveType: json['type'] ?? 'N/A',
              reason: json['reason'] ?? 'No reason provided',
              endDate: json['end_date'] != null
                  ? formatDate(json['end_date'])
                  : null,
              actionDate: json['action_date'] != null
                  ? formatDate(json['action_date'])
                  : null,
              expectedLogoffTime: json['expected_checkout_time'] != null
                  ? getTime(json['expected_checkout_time'])
                  : null,
            );
          }).toList();
          _isLoading = false;
          _lastUpdated = DateTime.now();
        });
      } else {
        setState(() {
          _errorMessage =
              "Failed to load requests. Status Code: ${response.statusCode}";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Error: $e";
        _isLoading = false;
      });
    }
  }

  List<Request> get _filteredRequests {
    if (_selectedFilter == 'All Requests') {
      return _requests;
    }
    return _requests
        .where((request) => request.type == _selectedFilter)
        .toList();
  }

  void _updateFilter(String filter) {
    setState(() {
      _selectedFilter = filter;
    });
    _fetchRequests();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      drawer: AdminNavigationDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
            ? Center(
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Manage Requests',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1f2937),
                        ),
                      ),
                      if (_lastUpdated != null)
                        Text(
                          "Last updated\n${DateFormat('hh:mm a').format(_lastUpdated!)}",
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6b7280),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Review and approve employee leave and early logoff requests.',
                    style: TextStyle(fontSize: 16, color: Color(0xFF6b7280)),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _FilterButton(
                        label: 'All',
                        isSelected: _selectedFilter == 'All Requests',
                        onPressed: () => _updateFilter('All Requests'),
                      ),
                      _FilterButton(
                        label: 'Leave',
                        isSelected: _selectedFilter == 'LEAVE',
                        onPressed: () => _updateFilter('LEAVE'),
                      ),
                      _FilterButton(
                        label: 'Early Logoff',
                        isSelected: _selectedFilter == 'EARLY_LOGOFF',
                        onPressed: () => _updateFilter('EARLY_LOGOFF'),
                      ),
                      _FilterButton(
                        label: 'Check Out',
                        isSelected: _selectedFilter == 'CHECKOUT',
                        onPressed: () => _updateFilter('CHECKOUT'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: _fetchRequests,
                      child: _filteredRequests.isEmpty
                          ? const Center(child: Text("No requests found"))
                          : ListView.builder(
                              itemCount: _filteredRequests.length,
                              itemBuilder: (context, index) {
                                // Get the request from filtered list
                                final request = _filteredRequests[index];
                                return RequestCard(
                                  request: request,
                                  onUpdateStatus: (newStatus) {
                                    setState(() {
                                      // Update the status in the main _requests list
                                      final requestIndex = _requests.indexWhere(
                                        (r) => r.id == request.id,
                                      );
                                      if (requestIndex != -1) {
                                        _requests[requestIndex] =
                                            _requests[requestIndex].copyWith(
                                              status: newStatus,
                                            );
                                      }
                                    });
                                  },
                                );
                              },
                            ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onPressed;

  const _FilterButton({
    required this.label,
    required this.isSelected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: InkWell(
          onTap: onPressed,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFe5e7eb) : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              border: isSelected
                  ? Border.all(color: const Color(0xFF9ca3af))
                  : null,
            ),
            child: Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? const Color(0xFF374151)
                    : const Color(0xFF4b5563),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
