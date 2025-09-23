import 'package:flow_sphere/Services/User_services/request_service.dart';
import 'package:flow_sphere/screens/userScreens/custom_appbar.dart';
import 'package:flow_sphere/screens/userScreens/navigation_drawer.dart';
// import 'package:flow_sphere/services/request_service.dart'; // Import your request service
import 'package:flutter/material.dart';

class RequestsScreen extends StatefulWidget {
  const RequestsScreen({super.key});

  @override
  State<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen>
    with SingleTickerProviderStateMixin {
  int mainTabIndex = 0; // 0 -> Submit Request, 1 -> My Requests
  int subTabIndex =
      0; // 0 -> Leave Request, 1 -> Early Logoff, 2 -> Clockout Request

  // Controllers / variables
  DateTime? startDate;
  DateTime? endDate;
  String? leaveType;
  String leaveReason = "";

  DateTime? logoffDate;
  TimeOfDay? logoffTime;
  String logoffReason = "";

  // Clockout request variables
  DateTime? selectedMissedCheckoutDate;
  String clockoutReason = "";

  // API data
  List<UserRequest> userRequests = [];
  List<MissedCheckout> missedCheckouts = [];
  bool isLoading = false;

  final List<String> leaveTypes = ["CASUAL", "SICK", "EARNED", "WFH"];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    try {
      // Try to fetch user requests
      List<UserRequest> requests = [];
      try {
        requests = await RequestService.fetchUserRequests();
        print(
          "Successfully fetched ${requests.length} user requests",
        ); // Debug log
      } catch (e) {
        print("Error fetching user requests: $e");
        // Don't throw here, just continue with empty list
      }

      // Try to fetch missed checkouts
      List<MissedCheckout> missed = [];
      try {
        missed = await RequestService.fetchMissedCheckouts();
        print(
          "Successfully fetched ${missed.length} missed checkouts",
        ); // Debug log
      } catch (e) {
        print("Error fetching missed checkouts: $e");
        // Don't throw here, just continue with empty list
      }

      setState(() {
        userRequests = requests;
        missedCheckouts = missed;
      });
    } catch (e) {
      print("General error in _loadData: $e"); // Debug log
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading some data: $e')));
    } finally {
      setState(() => isLoading = false);
    }
  }

  // Date Picker
  Future<void> _pickDate(
    BuildContext context,
    bool isStartDate, {
    bool isLogoff = false,
  }) async {
    DateTime today = DateTime.now();
    DateTime initialDate = today;

    // For End Date, make sure it can't be before Start Date
    if (!isStartDate && startDate != null) {
      initialDate = startDate!;
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: isStartDate || isLogoff ? today : (startDate ?? today),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        if (isLogoff) {
          logoffDate = picked;
        } else {
          if (isStartDate) {
            startDate = picked;
            // reset endDate if it's before the new startDate
            if (endDate != null && endDate!.isBefore(startDate!)) {
              endDate = null;
            }
          } else {
            endDate = picked;
          }
        }
      });
    }
  }

  // Time Picker
  Future<void> _pickTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        logoffTime = picked;
      });
    }
  }

  Widget _buildMainTabs() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildTabButton("Submit Request", 0, isMain: true),
        _buildTabButton("My Requests", 1, isMain: true),
      ],
    );
  }

  Widget _buildSubTabs() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildTabButton("Leave Request", 0),
        _buildTabButton("Early Logoff", 1),
        _buildTabButton("Clockout Request", 2),
      ],
    );
  }

  Widget _buildTabButton(String text, int index, {bool isMain = false}) {
    final isSelected = isMain ? mainTabIndex == index : subTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            if (isMain) {
              mainTabIndex = index;
              if (index == 1) {
                _loadData(); // Refresh data when switching to My Requests
              }
            } else {
              subTabIndex = index;
            }
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.grey[300],
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.black : Colors.grey[600],
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLeaveRequestForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),

        // Start Date
        _buildDateField("Start Date *", startDate, () {
          _pickDate(context, true);
        }),

        const SizedBox(height: 12),

        // Show End Date only if Start Date is selected
        if (startDate != null) ...[
          Row(
            children: [
              Expanded(
                child: _buildDateField("End Date (Optional)", endDate, () {
                  _pickDate(context, false);
                }),
              ),
              const SizedBox(width: 8),
              if (endDate != null)
                IconButton(
                  icon: const Icon(Icons.clear, color: Colors.red),
                  onPressed: () {
                    setState(() {
                      endDate = null;
                    });
                  },
                ),
            ],
          ),
          const SizedBox(height: 12),
        ],

        // Leave Type Dropdown
        DropdownButtonFormField<String>(
          value: leaveType,
          items: leaveTypes
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: (val) => setState(() => leaveType = val),
          decoration: const InputDecoration(
            labelText: "Leave Type *",
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),

        // Reason
        TextFormField(
          maxLines: 5,
          decoration: const InputDecoration(
            labelText: "Reason *",
            alignLabelWithHint: true,
            hintText: "Please provide a reason for your leave request...",
            border: OutlineInputBorder(),
          ),
          onChanged: (val) => leaveReason = val,
        ),

        const SizedBox(height: 20),

        // Submit Button
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
            backgroundColor: const Color.fromARGB(255, 0, 148, 133),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: _submitLeaveRequest,
          icon: Image.asset(
            'assets/images/send.png',
            width: 15,
            height: 15,
            color: Colors.white,
          ),
          label: const Text(
            "Submit Leave Request",
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildEarlyLogoffForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        _buildDateField("Date *", logoffDate, () {
          _pickDate(context, true, isLogoff: true);
        }),
        const SizedBox(height: 12),
        _buildDateField(
          "Expected Logoff Time *",
          logoffTime != null ? DateTime.now() : null,
          () {
            _pickTime(context);
          },
          isTime: true,
        ),
        const SizedBox(height: 12),
        TextFormField(
          maxLines: 5,
          decoration: const InputDecoration(
            labelText: "Reason *",
            alignLabelWithHint: true,
            hintText: "Please provide a reason for early logoff...",
            border: OutlineInputBorder(),
          ),
          onChanged: (val) => logoffReason = val,
        ),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
            backgroundColor: Color.fromARGB(255, 0, 148, 133),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: _submitEarlyLogoffRequest,
          icon: Image.asset(
            'assets/images/send.png',
            width: 15,
            height: 15,
            color: Colors.white,
          ),
          label: const Text(
            "Submit Early Logoff Request",
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildClockoutRequestForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),

        // Missed Checkouts section
        const Text(
          "Missed Check-outs",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

        if (isLoading)
          const Center(child: CircularProgressIndicator())
        else if (missedCheckouts.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: const Center(
              child: Text(
                "No missed check-outs found",
                style: TextStyle(color: Colors.grey),
              ),
            ),
          )
        else
          ...missedCheckouts.map((missed) => _buildMissedCheckoutCard(missed)),

        const SizedBox(height: 20),

        // Manual date selection if no missed checkouts or user wants to select different date
        const Text(
          "Or select a date manually:",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),

        // Date selection for clockout request
        GestureDetector(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: selectedMissedCheckoutDate ?? DateTime.now(),
              firstDate: DateTime.now().subtract(const Duration(days: 365)),
              lastDate: DateTime.now(),
            );
            if (picked != null) {
              setState(() {
                selectedMissedCheckoutDate = picked;
              });
            }
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  selectedMissedCheckoutDate != null
                      ? _formatDate(selectedMissedCheckoutDate!)
                      : "Select date for missed checkout",
                  style: TextStyle(
                    fontSize: 16,
                    color: selectedMissedCheckoutDate != null
                        ? Colors.black
                        : Colors.grey[600],
                  ),
                ),
                const Icon(Icons.calendar_today, color: Colors.grey),
              ],
            ),
          ),
        ),

        if (selectedMissedCheckoutDate != null) ...[
          const SizedBox(height: 16),

          // Reason field
          TextFormField(
            maxLines: 5,
            decoration: const InputDecoration(
              labelText: "Reason *",
              alignLabelWithHint: true,
              hintText: "Please explain why you missed the checkout...",
              border: OutlineInputBorder(),
            ),
            onChanged: (val) => clockoutReason = val,
            controller: TextEditingController(text: clockoutReason),
          ),
          const SizedBox(height: 20),

          // Submit Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 0, 148, 133),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              onPressed: isLoading ? null : _submitClockoutRequest,
              icon: isLoading
                  ? const SizedBox(
                      width: 15,
                      height: 15,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Image.asset(
                      'assets/images/send.png',
                      width: 15,
                      height: 15,
                      color: Colors.white,
                    ),
              label: Text(
                isLoading ? "Submitting..." : "Submit Clockout Request",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildMissedCheckoutCard(MissedCheckout missed) {
    final isSelected =
        selectedMissedCheckoutDate?.day == DateTime.parse(missed.date).day;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.red[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.schedule, color: Colors.red),
        ),
        title: Text(
          _formatDate(DateTime.parse(missed.date)),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          "Check-in: ${_formatTime(missed.checkInAt)}",
          style: const TextStyle(color: Colors.grey),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text(
            "Missing Checkout",
            style: TextStyle(color: Colors.white, fontSize: 12),
          ),
        ),
        tileColor: isSelected ? Colors.blue[50] : null,
        onTap: () {
          setState(() {
            selectedMissedCheckoutDate = DateTime.parse(missed.date);
            clockoutReason = ""; // Reset reason when selecting different date
          });
        },
      ),
    );
  }

  Widget _buildDateField(
    String label,
    DateTime? date,
    VoidCallback onTap, {
    bool isTime = false,
    bool readOnly = false,
  }) {
    String text = "Select ${isTime ? "time" : "date"}";
    if (!isTime && date != null) {
      text = "${date.day}/${date.month}/${date.year}";
    } else if (isTime && logoffTime != null) {
      text = logoffTime!.format(context);
    }
    return GestureDetector(
      onTap: readOnly ? null : onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(text),
            Icon(isTime ? Icons.access_time : Icons.calendar_today),
          ],
        ),
      ),
    );
  }

  Widget _buildMyRequests() {
    return Column(
      children: [
        // Tab buttons for Submit Request and My Requests
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      mainTabIndex = 0; // Switch to Submit Request
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      "Submit Request",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    // border: Border.all(color: const Color(0xFF00AC9F), width: 2),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    "My Requests",
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Requests list
        Expanded(
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : userRequests.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Text(
                      "You haven't submitted any requests yet.",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: userRequests.length,
                  itemBuilder: (context, index) {
                    final request = userRequests[index];
                    return _buildRequestCard(request);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildRequestCard(UserRequest request) {
    Color statusColor = _getStatusColor(request.status);
    String statusText = request.status.toUpperCase();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with title and status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _getTypeDisplayName(request.type),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D3748),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  statusText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Request details
          _buildDetailRow(
            "Date:",
            _formatDate(request.startDate) +
                (request.startDate.day != request.endDate.day
                    ? " - ${_formatDate(request.endDate)}"
                    : ""),
          ),

          if (request.type == "EARLY_LOGOFF" &&
              request.expectedCheckoutTime != null)
            _buildDetailRow("Checkout Time:", request.expectedCheckoutTime!),

          if (request.type == "LEAVE" && request.leaveType != null)
            _buildDetailRow(
              "Type:",
              _getLeaveTypeDisplayName(request.leaveType!),
            ),

          _buildDetailRow("Reason:", request.reason),

          if (request.decidedAt != null)
            _buildDetailRow("Decision Date:", _formatDate(request.decidedAt!)),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF718096),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF2D3748),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods for request submission
  Future<void> _submitLeaveRequest() async {
    if (startDate == null || leaveType == null || leaveReason.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }

    setState(() => isLoading = true);
    try {
      final result = await RequestService.submitLeaveRequest(
        startDate: startDate!.toIso8601String(),
        endDate: (endDate ?? startDate!).toIso8601String(),
        leaveType: leaveType!,
        reason: leaveReason,
      );

      print("Leave request submission result: $result"); // Debug log

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result['data']?['message'] ??
                  'Leave request submitted successfully',
            ),
          ),
        );
        // Reset form
        setState(() {
          startDate = null;
          endDate = null;
          leaveType = null;
          leaveReason = "";
        });
        // Reload requests to show the new one
        _loadData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error: ${result['message'] ?? 'Failed to submit request'}',
            ),
          ),
        );
      }
    } catch (e) {
      print("Exception in _submitLeaveRequest: $e"); // Debug log
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _submitEarlyLogoffRequest() async {
    if (logoffDate == null ||
        logoffTime == null ||
        logoffReason.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }

    setState(() => isLoading = true);
    try {
      final result = await RequestService.submitEarlyLogoffRequest(
        startDate: logoffDate!.toIso8601String(),
        endDate: logoffDate!.toIso8601String(), // Same day for early logoff
        expectedCheckoutTime:
            "${logoffTime!.hour.toString().padLeft(2, '0')}:${logoffTime!.minute.toString().padLeft(2, '0')}",
        reason: logoffReason,
      );

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result['data']?['message'] ??
                  'Early logoff request submitted successfully',
            ),
          ),
        );
        // Reset form
        setState(() {
          logoffDate = null;
          logoffTime = null;
          logoffReason = "";
        });
        // Reload requests to show the new one
        _loadData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error: ${result['message'] ?? 'Failed to submit request'}',
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _submitClockoutRequest() async {
    if (selectedMissedCheckoutDate == null || clockoutReason.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a date and provide a reason'),
        ),
      );
      return;
    }

    setState(() => isLoading = true);
    try {
      // Use the selected missed checkout date directly
      final result = await RequestService.submitClockoutRequest(
        startDate: selectedMissedCheckoutDate!.toIso8601String(),
        reason: clockoutReason,
      );

      print("Clockout request submission result: $result"); // Debug log

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result['data']?['message'] ??
                  'Clockout request submitted successfully',
            ),
          ),
        );
        // Reset form and reload data
        setState(() {
          selectedMissedCheckoutDate = null;
          clockoutReason = "";
        });
        _loadData(); // Reload to update missed checkouts and requests
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error: ${result['message'] ?? 'Failed to submit request'}',
            ),
          ),
        );
      }
    } catch (e) {
      print("Exception in _submitClockoutRequest: $e"); // Debug log
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => isLoading = false);
    }
  }

  // Helper methods
  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'APPROVED':
        return const Color(0xFF22C55E); // Green
      case 'REJECTED':
        return const Color(0xFFEF4444); // Red
      case 'PENDING':
      default:
        return const Color(0xFFF59E0B); // Orange/Yellow
    }
  }

  // ignore: unused_element
  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'LEAVE':
        return Icons.calendar_today;
      case 'EARLY_LOGOFF':
        return Icons.access_time;
      case 'CLOCKOUT':
        return Icons.schedule;
      default:
        return Icons.request_page;
    }
  }

  String _getTypeDisplayName(String type) {
    switch (type) {
      case 'LEAVE':
        return 'Leave Request';
      case 'EARLY_LOGOFF':
        return 'Early Logoff Request';
      case 'CLOCKOUT':
        return 'Clockout Request';
      default:
        return type;
    }
  }

  String _getLeaveTypeDisplayName(String type) {
    switch (type.toUpperCase()) {
      case 'CASUAL':
        return 'Casual Leave';
      case 'SICK':
        return 'Sick Leave';
      case 'EARNED':
        return 'Earned Leave';
      case 'WFH':
        return 'Work From Home';
      default:
        return type;
    }
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

  String _formatTime(DateTime time) {
    return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
  }

  // ignore: unused_element
  String _formatDateTime(DateTime dateTime) {
    return "${_formatDate(dateTime)} ${_formatTime(dateTime)}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      drawer: CustomNavigationDrawer(),
      backgroundColor: const Color(0xFFF7FAFC),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header section
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "My Requests",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3748),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Submit and track your requests.",
                  style: TextStyle(fontSize: 14, color: Color(0xFF718096)),
                ),
              ],
            ),
          ),

          // Main content
          Expanded(
            child: mainTabIndex == 0
                ? Container(
                    color: Colors.white,
                    child: Column(
                      children: [
                        const SizedBox(height: 16),
                        _buildMainTabs(),
                        const SizedBox(height: 16),
                        _buildSubTabs(),
                        const SizedBox(height: 16),
                        Expanded(
                          child: Container(
                            color: const Color(0xFFF7FAFC),
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.all(16),
                              child: subTabIndex == 0
                                  ? _buildLeaveRequestForm()
                                  : subTabIndex == 1
                                  ? _buildEarlyLogoffForm()
                                  : _buildClockoutRequestForm(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : _buildMyRequests(),
          ),
        ],
      ),
    );
  }
}
