import 'package:flow_sphere/screens/adminScreens/widgets/request_card.dart';
import 'package:flow_sphere/screens/adminScreens/widgets/review_request_dialog.dart';
import 'package:flow_sphere/screens/userScreens/custom_appbar.dart';
import 'package:flutter/material.dart';

class ApprovalScreen extends StatefulWidget {
  const ApprovalScreen({super.key});

  @override
  State<ApprovalScreen> createState() => _ApprovalScreenState();
}

class _ApprovalScreenState extends State<ApprovalScreen> {
  // NOTE: This is where you would call your backend API to fetch real-time data.
  // The list below is for demonstration purposes. Replace this with your API fetch logic.
  // A common approach is to use a StatefulWidget and call an asynchronous function in initState().
  final List<Request> _staticRequests = [
    Request(
      type: 'Leave Request',
      status: 'PENDING',
      name: 'Madhuri Bendi',
      email: 'bendimadhuri@gmail.com',
      date: 'Sep 10, 2025',
      leaveType: 'Casual Leave',
      reason: 'Need to visit Aadhar center.',
    ),
    Request(
      type: 'Leave Request',
      status: 'PENDING',
      name: 'Safura Samreen',
      email: 'safurasamreenshaik@gmail.com',
      date: 'Sep 12, 2025',
      leaveType: 'Sick Leave',
      reason: 'Due to severe headache...',
    ),
    Request(
      type: 'Leave Request',
      status: 'PENDING',
      name: 'Pasham Bharath Reddy',
      email: 'bharathreddy123.pasham@gmail.com',
      date: 'Sep 11, 2025 - Sep 12, 2025',
      leaveType: 'Casual Leave',
      reason: 'We are planning for the family...',
    ),
    Request(
      type: 'Leave Request',
      status: 'APPROVED',
      name: 'Chada Sitharam',
      email: 'chadasitharam@gmail.com',
      date: 'Sep 08, 2025',
      leaveType: 'Casual Leave',
      reason: 'I would like to request leave...',
    ),
    Request(
      type: 'Early Logoff Request',
      status: 'PENDING',
      name: 'John Doe',
      email: 'john.doe@example.com',
      date: 'Sep 13, 2025',
      leaveType: 'N/A',
      reason: 'Early logoff due to a doctor\'s appointment.',
    ),
    Request(
      type: 'Early Logoff Request',
      status: 'APPROVED',
      name: 'Jane Smith',
      email: 'jane.smith@example.com',
      date: 'Sep 09, 2025',
      leaveType: 'N/A',
      reason: 'Early logoff to pick up child from school.',
    ),
  ];

  String _selectedFilter = 'All Requests';

  List<Request> get _filteredRequests {
    if (_selectedFilter == 'All Requests') {
      return _staticRequests;
    }
    return _staticRequests
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
      // drawer: CustomNavigationDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
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
            Center(
              child: Row(
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
            ),
            const SizedBox(height: 24),
            ..._filteredRequests.map(
              (request) => RequestCard(request: request),
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
