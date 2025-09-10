import 'package:flow_sphere/screens/userScreens/custom_appbar.dart';
import 'package:flow_sphere/screens/userScreens/navigation_drawer.dart';
import 'package:flutter/material.dart';

class RequestsScreen extends StatefulWidget {
  const RequestsScreen({super.key});

  @override
  State<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen>
    with SingleTickerProviderStateMixin {
  int mainTabIndex = 0; // 0 -> Submit Request, 1 -> My Requests
  int subTabIndex = 0; // 0 -> Leave Request, 1 -> Early Logoff

  // Controllers / variables
  DateTime? startDate;
  DateTime? endDate;
  String? leaveType;
  String leaveReason = "";

  DateTime? logoffDate;
  TimeOfDay? logoffTime;
  String logoffReason = "";

  final List<String> leaveTypes = [
    "Casual Leave",
    "Sick Leave",
    "Earned Leave",
    "Work From Home",
  ];

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
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.black : Colors.grey[600],
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
          initialValue: leaveType,
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
              borderRadius: BorderRadius.circular(8), // 👈 slight radius
            ),
          ),
          onPressed: () {
            // handle leave request submit
          },
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
              borderRadius: BorderRadius.circular(8), // 👈 slight radius
            ),
          ),
          onPressed: () {
            // handle early logoff submit
          },
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

  Widget _buildDateField(
    String label,
    DateTime? date,
    VoidCallback onTap, {
    bool isTime = false,
  }) {
    String text = "Select ${isTime ? "time" : "date"}";
    if (!isTime && date != null) {
      text = "${date.day}/${date.month}/${date.year}";
    } else if (isTime && logoffTime != null) {
      text = logoffTime!.format(context);
    }
    return GestureDetector(
      onTap: onTap,
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
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24.0),
        child: Text(
          "You haven't submitted any requests yet.",
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      drawer: CustomNavigationDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "My Requests",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              "Submit and track your leave and early logoff request",
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 16),
            _buildMainTabs(),
            const SizedBox(height: 16),
            if (mainTabIndex == 0) _buildSubTabs(),
            const SizedBox(height: 16),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: mainTabIndex == 0
                    ? (subTabIndex == 0
                          ? _buildLeaveRequestForm()
                          : _buildEarlyLogoffForm())
                    : _buildMyRequests(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
