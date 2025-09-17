import 'dart:convert';
import 'package:flow_sphere/Services/login_api_services.dart';
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
                  const Text(
                    'Manage Requests',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1f2937),
                    ),
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
                        label: 'All Requests',
                        isSelected: _selectedFilter == 'All Requests',
                        onPressed: () => _updateFilter('All Requests'),
                      ),
                      _FilterButton(
                        label: 'Leave Requests',
                        isSelected: _selectedFilter == 'Leave Request',
                        onPressed: () => _updateFilter('Leave Request'),
                      ),
                      _FilterButton(
                        label: 'Early Logoff',
                        isSelected: _selectedFilter == 'Early Logoff Request',
                        onPressed: () => _updateFilter('Early Logoff Request'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: _filteredRequests.isEmpty
                        ? const Center(
                            child: Text(
                              "No requests found",
                              style: TextStyle(fontSize: 16),
                            ),
                          )
                        : ListView.builder(
                            itemCount: _filteredRequests.length,
                            itemBuilder: (context, index) {
                              return RequestCard(
                                request: _filteredRequests[index],
                              );
                            },
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
