import 'package:flow_sphere/screens/custom_appbar.dart';
import 'package:flow_sphere/screens/navigation_drawer.dart';
import 'package:flutter/material.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  // A variable to hold the future attendance data
  late Future<Map<int, String>> _futureDayStatus;

  // A variable to keep track of the currently displayed date
  late DateTime _currentDate;

  @override
  void initState() {
    super.initState();
    _currentDate = DateTime.now();
    // Initialize the future outside the build method
    _futureDayStatus = _fetchAttendanceData(_currentDate);
  }

  // This function simulates fetching data from a database
  Future<Map<int, String>> _fetchAttendanceData(DateTime date) async {
    // Simulating a network delay
    await Future.delayed(const Duration(milliseconds: 700));

    // Dummy data for the calendar. In a real application, this would be a
    // call to an API or database to get the attendance for the given month.
    if (date.month == 9 && date.year == 2025) {
      return {
        1: 'Present',
        2: 'Leave',
        3: 'Present',
        4: 'Present',
        5: 'Leave',
        6: 'Week Off',
        7: 'Week Off',
        8: 'Present',
        15: 'Present',
        16: 'Upcoming Leave',
        22: 'Week Off',
        23: 'Week Off',
      };
    } else if (date.month == 8 && date.year == 2025) {
      return {
        1: 'Present',
        2: 'Present',
        3: 'Week Off',
        4: 'Week Off',
        5: 'Present',
        6: 'Present',
        7: 'Leave',
        8: 'Present',
        9: 'Present',
        10: 'Week Off',
        11: 'Week Off',
        12: 'Leave',
        25: 'Present',
        26: 'Present',
        27: 'Present',
        28: 'Upcoming Leave',
      };
    }
    return {};
  }

  // Function to move to the previous month
  void _goToPreviousMonth() {
    setState(() {
      _currentDate = DateTime(_currentDate.year, _currentDate.month - 1);
      _futureDayStatus = _fetchAttendanceData(_currentDate);
    });
  }

  // Function to move to the current month
  void _goToCurrentMonth() {
    setState(() {
      _currentDate = DateTime.now();
      _futureDayStatus = _fetchAttendanceData(_currentDate);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      drawer: CustomNavigationDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with present/leave counts
            Row(
              children: [
                // Hardcoded values for the present and leaves
                _buildCountText('Present', 6, Colors.green),
                const SizedBox(width: 16),
                _buildCountText('Leaves', 0, Colors.red),
              ],
            ),
            const SizedBox(height: 24),
            // Calendar title and subtitle
            const Text(
              'Calendar',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const Text(
              'View your attendance history and schedule',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            // "Today" and "Previous Month" buttons
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: _goToCurrentMonth,
                  icon: const Icon(Icons.calendar_today, color: Colors.black),
                  label: const Text(
                    'Today',
                    style: TextStyle(color: Colors.black),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.grey),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: _goToPreviousMonth,
                  child: const Text('Previous Month'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Calendar Grid and navigation
            FutureBuilder<Map<int, String>>(
              future: _futureDayStatus,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.green),
                  );
                } else if (snapshot.hasError) {
                  return const Center(child: Text('Error loading data.'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text('No attendance data available.'),
                  );
                } else {
                  return _buildCalendarGrid(snapshot.data!);
                }
              },
            ),
            const SizedBox(height: 24),
            // Legend
            _buildLegend(),
          ],
        ),
      ),
    );
  }

  Widget _buildCountText(String label, int count, Color color) {
    return Row(
      children: [
        Text('$label: ', style: const TextStyle(fontSize: 16)),
        Text(
          '$count',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildCalendarGrid(Map<int, String> dayStatus) {
    // Get the number of days in the month and the first day's weekday
    final daysInMonth = DateTime(
      _currentDate.year,
      _currentDate.month + 1,
      0,
    ).day;
    final firstDayOfMonth = DateTime(
      _currentDate.year,
      _currentDate.month,
      1,
    ).weekday;

    // Create a list of all day widgets
    List<Widget> days = [];
    // Add empty placeholders for days before the 1st
    for (int i = 1; i < firstDayOfMonth; i++) {
      days.add(const SizedBox.shrink());
    }

    // Add day widgets for each day of the month
    for (int i = 1; i <= daysInMonth; i++) {
      String? status = dayStatus[i];
      Color dotColor = Colors.transparent;

      switch (status) {
        case 'Present':
          dotColor = Colors.green;
          break;
        case 'Leave':
          dotColor = Colors.red;
          break;
        case 'Upcoming Leave':
          dotColor = Colors.orange;
          break;
        case 'Week Off':
          dotColor = Colors.blue;
          break;
      }

      days.add(
        _buildDayContainer(
          day: i,
          dotColor: dotColor,
          isToday:
              i == DateTime.now().day &&
              _currentDate.month == DateTime.now().month,
          isWeekend:
              (i + firstDayOfMonth - 1) % 7 == 0 ||
              (i + firstDayOfMonth - 1) % 7 == 6,
        ),
      );
    }

    return Column(
      children: [
        // Month and year navigation
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${_getMonthName(_currentDate.month)} ${_currentDate.year}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_left),
                  onPressed: _goToPreviousMonth,
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_right),
                  onPressed: () {
                    // Logic to go to the next month
                    setState(() {
                      _currentDate = DateTime(
                        _currentDate.year,
                        _currentDate.month + 1,
                      );
                      _futureDayStatus = _fetchAttendanceData(_currentDate);
                    });
                  },
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Day of the week headers
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text('Sun', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('Mon', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('Tue', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('Wed', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('Thu', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('Fri', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('Sat', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 8),
        // Day grid
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 7,
          children: days,
        ),
      ],
    );
  }

  Widget _buildDayContainer({
    required int day,
    required Color dotColor,
    bool isToday = false,
    bool isWeekend = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isToday
            ? Colors.lightGreen.withAlpha(25) // Using withAlpha
            : Colors.white,
        border: Border.all(
          color: isToday ? Colors.green : Colors.transparent,
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Day number
          Positioned(
            child: Text(
              '$day',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isWeekend ? Colors.grey : Colors.black,
              ),
            ),
          ),
          // Status dot
          if (dotColor != Colors.transparent)
            Positioned(
              bottom: 8,
              child: Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Legend',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLegendItem('Present', Colors.green),
                _buildLegendItem('Upcoming Leave', Colors.orange),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLegendItem('Leave', Colors.red),
                _buildLegendItem('Weekoff', Colors.blue),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLegendItem(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(text),
        ],
      ),
    );
  }

  // Helper function to get the month name from its number
  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }
}
