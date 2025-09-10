import 'package:flow_sphere/screens/userScreens/custom_appbar.dart';
import 'package:flow_sphere/screens/userScreens/navigation_drawer.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  final TextEditingController _taskController = TextEditingController();
  bool _isTaskNotEmpty = false;

  @override
  void initState() {
    super.initState();
    _taskController.addListener(() {
      setState(() {
        _isTaskNotEmpty = _taskController.text.trim().isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Colors to be used in this screen
    const Color bootstrapPrimaryBlue = Color(0xFF0D6EFD);

    DateTime now = DateTime.now();

    String todayDate = DateFormat('EEEE, MMMM d, yyyy').format(now);

    Future<void> selectDate(BuildContext context) async {
      final DateTime today = DateTime.now();
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: today,
        firstDate: DateTime(2020), // Calender shows from 2020
        lastDate: today, // disables days after current day
      );

      if (!context.mounted) return; // safe check after async gap

      String selectedDate = picked.toString().split(' ')[0];
      if (picked != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Fetching the progress of you on $selectedDate"),
          ),
        );
      }
    }

    return Scaffold(
      appBar: CustomAppBar(),
      drawer: CustomNavigationDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress Tracker Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Progress Tracker",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.calendar_month,
                        color: bootstrapPrimaryBlue,
                      ),
                      onPressed: () => selectDate(context),
                    ),
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        backgroundColor: bootstrapPrimaryBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {},
                      icon: const Icon(
                        Icons.save_alt,
                        size: 18,
                        color: Colors.white,
                      ),
                      label: const Text("Save Progress"),
                    ),
                  ],
                ),
              ],
            ),

            // Today's Progress Card
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Today's Progress",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(todayDate),
                    const SizedBox(height: 12),
                    const Text("50%   0 of 0 tasks completed"),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: 0.5, // Value range for 0.0 to 1
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(6),
                      color: bootstrapPrimaryBlue,
                      backgroundColor: Colors.grey[300],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Add New Task Card
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Add New Task",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text("What are you working on today?"),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _taskController,
                            decoration: InputDecoration(
                              hintText: "Describe your task...",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        CircleAvatar(
                          backgroundColor: _isTaskNotEmpty
                              ? bootstrapPrimaryBlue
                              : Colors.grey, // disabled state
                          // backgroundColor: bootstrapPrimaryBlue,
                          child: IconButton(
                            icon: const Icon(Icons.add, color: Colors.white),
                            onPressed: _isTaskNotEmpty
                                ? () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          "Task Added: ${_taskController.text}",
                                        ),
                                      ),
                                    );
                                    _taskController.clear();
                                  }
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Today's Tasks Card (full width)
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "Today's Tasks",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text("Track your progress throughout the day"),
                    SizedBox(height: 20),
                    Center(
                      child: Icon(
                        Icons.access_time,
                        size: 40,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text("No tasks for today. Add your first task above!"),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Daily Notes",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text("Note down thoughts, blockers, or achievements"),
                    const SizedBox(height: 12),
                    TextField(
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: "Write your notes here...",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.all(12),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Quick Stats Card
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "Quick Stats",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [Text("Total Tasks"), Text("0")],
                    ),
                    SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Completed"),
                        Text("0", style: TextStyle(color: Colors.green)),
                      ],
                    ),
                    SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("In Progress"),
                        Text("0", style: TextStyle(color: Colors.orange)),
                      ],
                    ),
                    SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Pending"),
                        Text("0", style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
