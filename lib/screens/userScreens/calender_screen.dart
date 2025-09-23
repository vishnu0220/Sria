import 'dart:convert';
import 'package:flow_sphere/Services/login_api_services.dart';
import 'package:flow_sphere/screens/userScreens/custom_appbar.dart';
import 'package:flow_sphere/screens/userScreens/navigation_drawer.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

// Class to hold combined attendance and leave data for a single day
class DailyStatus {
  String status;
  DateTime? checkIn;
  DateTime? checkOut;
  double? hoursWorked;

  DailyStatus({
    required this.status,
    this.checkIn,
    this.checkOut,
    this.hoursWorked,
  });
}

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  String userId = '';
  String token = '';
  // The first day to show on the calendar, based on the user's join date
  DateTime _firstDay = DateTime.utc(2023, 1, 1);
  // A map to hold all fetched attendance and leave data
  Map<DateTime, DailyStatus> _attendanceData = {};
  // A variable to keep track of the currently displayed date
  late DateTime _focusedDay;
  DateTime? _selectedDay;
  // A boolean to track the loading state
  bool _isLoading = true;

  // State variables for dynamic counts
  int _presentCount = 0;
  int _leaveCount = 0;
  int _upcomingLeaveCount = 0; // New state variable for upcoming leaves

  // Custom colors based on user's request
  static const Color presentColor = Color.fromRGBO(16, 185, 129, 1);
  static const Color leaveColor = Color.fromRGBO(239, 68, 68, 1);
  static const Color weekOffColor = Color.fromRGBO(96, 165, 250, 1);
  static const Color upcomingLeaveColor = Color.fromRGBO(250, 204, 21, 1);

  @override
  void initState() {
    super.initState();
    // Start the calendar at the first day of the current month
    final now = DateTime.now();
    _focusedDay = DateTime.utc(now.year, now.month, 1);
    _selectedDay = now;
    getUserInfo();
  }

  void getUserInfo() async {
    final authService = AuthService();
    final storedToken = await authService.getToken();
    token = storedToken ?? '';
    Map<String, dynamic>? user = await authService.getStoredUser();
    userId = user?['id'];
    if (userId.isNotEmpty) {
      _fetchCombinedData();
    }
  }

  // Function to fetch and combine data from both APIs
  Future<void> _fetchCombinedData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      // Fetch attendance data
      final attendanceResponse = await http.get(
        Uri.parse(
          'https://leave-backend-vbw6.onrender.com/api/attendance/employee/$userId',
        ),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      final leaveResponse = await http.get(
        Uri.parse('https://leave-backend-vbw6.onrender.com/api/requests/me'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (attendanceResponse.statusCode == 200 &&
          leaveResponse.statusCode == 200) {
        final attendanceList = json.decode(attendanceResponse.body) as List;
        final leaveList = json.decode(leaveResponse.body) as List;

        // Extract joining date from attendance data
        if (attendanceList.isNotEmpty && attendanceList.last['date'] != null) {
          final joiningDateString =
              attendanceList.last['date'] ?? DateTime.now().toIso8601String();
          final joiningDate = DateTime.parse(joiningDateString);
          _firstDay = DateTime.utc(
            joiningDate.year,
            joiningDate.month,
            joiningDate.day,
          );
        } else {
          // If no attendance, set firstDay to today
          _firstDay = DateTime.utc(
            DateTime.now().year,
            DateTime.now().month,
            DateTime.now().day,
          );
        }

        // Process attendance data
        final Map<DateTime, DailyStatus> attendanceMap = {};
        for (var attendance in attendanceList) {
          final date = DateTime.parse(attendance['date']);
          final checkIn = DateTime.parse(attendance['check_in_at']);
          final checkOut = attendance['check_out_at'] != null
              ? DateTime.parse(attendance['check_out_at'])
              : null;
          final hoursWorked = attendance['hours_worked'] != null
              ? attendance['hours_worked'] as double
              : null;

          attendanceMap[DateTime.utc(
            date.year,
            date.month,
            date.day,
          )] = DailyStatus(
            status: 'Present',
            checkIn: checkIn,
            checkOut: checkOut,
            hoursWorked: hoursWorked,
          );
        }

        // Process approved leave data and determine if it's past or future
        final now = DateTime.now();
        for (var leave in leaveList) {
          if (leave['type'] == 'LEAVE' && leave['status'] == 'APPROVED') {
            final fromDate = DateTime.parse(leave['start_date']);
            final toDate = DateTime.parse(leave['end_date']);

            for (
              DateTime d = fromDate;
              d.isBefore(toDate) || d.isAtSameMomentAs(toDate);
              d = d.add(const Duration(days: 1))
            ) {
              final utcDay = DateTime.utc(d.year, d.month, d.day);
              // Check if the day is already marked as 'Present' (e.g., a leave was approved for a day already attended)
              if (!attendanceMap.containsKey(utcDay)) {
                // If it's a weekend, skip marking it as leave
                if (utcDay.weekday == DateTime.saturday ||
                    utcDay.weekday == DateTime.sunday) {
                  continue;
                }
                if (utcDay.isBefore(
                  DateTime.utc(now.year, now.month, now.day),
                )) {
                  // If the leave date is in the past, mark it as 'Leave'
                  attendanceMap[utcDay] = DailyStatus(status: 'Leave');
                } else {
                  // Otherwise, mark it as 'Upcoming Leave'
                  attendanceMap[utcDay] = DailyStatus(status: 'Upcoming Leave');
                }
              }
            }
          }
        }
        if (mounted) {
          setState(() {
            _attendanceData = attendanceMap;
            _updateCountsForMonth(
              _focusedDay,
            ); // Update counts for the initial month
            _isLoading = false;
          });
        }
      } else {
        // Handle API errors
        print(
          'Failed to load data: ${attendanceResponse.statusCode}, ${leaveResponse.statusCode}',
        );
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('An error occurred: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Function to update the present and leave counts for the currently focused month
  void _updateCountsForMonth(DateTime month) {
    _presentCount = 0;
    _leaveCount = 0;
    _upcomingLeaveCount = 0; // Reset upcoming leaves count
    final now = DateTime.now();

    for (
      int day = 1;
      day <= DateUtils.getDaysInMonth(month.year, month.month);
      day++
    ) {
      final date = DateTime.utc(month.year, month.month, day);

      // Skip days before the joining date
      if (date.isBefore(
        DateTime.utc(_firstDay.year, _firstDay.month, _firstDay.day),
      )) {
        continue;
      }

      // Skip weekends from being counted as an absence
      final isWeekend =
          date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;
      if (isWeekend) {
        continue;
      }

      final dailyStatus = _attendanceData[date];

      if (dailyStatus != null) {
        // If there is data, increment the appropriate counter
        if (dailyStatus.status == 'Present') {
          _presentCount++;
        } else if (dailyStatus.status == 'Leave') {
          _leaveCount++;
        } else if (dailyStatus.status == 'Upcoming Leave') {
          _upcomingLeaveCount++;
        }
      } else {
        // If no data exists for a past weekday, count it as an absence
        if (date.isBefore(DateTime.utc(now.year, now.month, now.day))) {
          _leaveCount++;
        }
      }
    }
  }

  // Function to show the attendance dialog
  void _showAttendanceDialog(DateTime date) {
    final dailyStatus =
        _attendanceData[DateTime.utc(date.year, date.month, date.day)];
    // Convert to IST for display
    final formattedDate = DateFormat(
      'EEE, MMM d, yyyy',
    ).format(date.toLocal()); // Short day, short month

    String title;
    Widget content;

    final isWeekend =
        date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;

    if (isWeekend) {
      title = 'Weekoff';
      content = const Text(
        'This is a designated weekoff day.',
        style: TextStyle(fontSize: 16),
      );
    } else if (dailyStatus == null) {
      title = 'No Attendance Data';
      content = const Text(
        'No attendance data for this day.',
        style: TextStyle(fontSize: 16),
      );
    } else {
      title = 'Attendance Details';
      String status = dailyStatus.status;
      String checkInText = '';
      String checkOutText = '';
      String hoursWorkedText = '';

      if (dailyStatus.checkIn != null) {
        checkInText =
            'Check In: ${DateFormat('h:mm a').format(dailyStatus.checkIn!.toLocal())}';
      }

      if (dailyStatus.checkOut != null) {
        checkOutText =
            'Check Out: ${DateFormat('h:mm a').format(dailyStatus.checkOut!.toLocal())}';

        if (dailyStatus.hoursWorked != null) {
          hoursWorkedText =
              'Hours Worked: ${dailyStatus.hoursWorked!.toStringAsFixed(2)}';
        }
      }

      content = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(Icons.info, color: Colors.blue),
              const SizedBox(width: 8),
              Text(
                formattedDate,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Status: $status',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          if (checkInText.isNotEmpty) Text(checkInText),
          if (checkOutText.isNotEmpty) Text(checkOutText),
          if (hoursWorkedText.isNotEmpty) Text(hoursWorkedText),
        ],
      );
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: content,
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return Scaffold(
      appBar: CustomAppBar(),
      drawer: CustomNavigationDrawer(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _buildCountText('Present: ', _presentCount, presentColor),
                      SizedBox(width: 10),
                      _buildCountText('Leaves: ', _leaveCount, leaveColor),
                      SizedBox(width: 10),
                      _buildCountText(
                        'Upcoming Leaves: ',
                        _upcomingLeaveCount,
                        upcomingLeaveColor,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Calendar',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    'View your attendance history and schedule',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  // New row for "Today" button and "Upcoming Leaves" count
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _focusedDay = DateTime.utc(
                          now.year,
                          now.month,
                          now.day,
                        );
                        _selectedDay = now;
                        _updateCountsForMonth(_focusedDay);
                      });
                    },
                    icon: const Icon(Icons.today, size: 18),
                    label: const Text('Today'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: presentColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                  // Updated TableCalendar
                  TableCalendar(
                    firstDay: _firstDay,
                    // Allow navigating up to 3 months into the future
                    lastDay: DateTime.utc(now.year, now.month + 3, now.day),
                    focusedDay: _focusedDay.isBefore(_firstDay)
                        ? _firstDay
                        : _focusedDay,
                    selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      });
                      _showAttendanceDialog(selectedDay);
                    },
                    onPageChanged: (focusedDay) {
                      setState(() {
                        _focusedDay = focusedDay;
                      });
                      _updateCountsForMonth(focusedDay);
                    },
                    daysOfWeekHeight: 30,
                    headerStyle: HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                      titleTextFormatter: (date, locale) =>
                          DateFormat.yMMMM().format(date),
                      // Chevrons are already part of the header,
                      // so we can use their onPressed handlers
                      leftChevronIcon: IconButton(
                        icon: const Icon(Icons.arrow_left),
                        onPressed: () {
                          final prevMonth = DateTime.utc(
                            _focusedDay.year,
                            _focusedDay.month - 1,
                            1,
                          );
                          // Prevents navigating before the first joining month
                          if (!prevMonth.isBefore(
                            DateTime.utc(_firstDay.year, _firstDay.month, 1),
                          )) {
                            setState(() {
                              _focusedDay = prevMonth;
                            });
                            _updateCountsForMonth(prevMonth);
                          }
                        },
                      ),
                      rightChevronIcon: IconButton(
                        icon: const Icon(Icons.arrow_right),
                        onPressed: () {
                          final nextMonth = DateTime.utc(
                            _focusedDay.year,
                            _focusedDay.month + 1,
                            1,
                          );
                          // Prevents navigating more than 3 months ahead
                          if (!nextMonth.isAfter(
                            DateTime.utc(now.year, now.month + 3, 0),
                          )) {
                            setState(() {
                              _focusedDay = nextMonth;
                            });
                            _updateCountsForMonth(nextMonth);
                          }
                        },
                      ),
                    ),
                    calendarBuilders: CalendarBuilders(
                      defaultBuilder: (context, day, focusedDay) {
                        final dailyStatus =
                            _attendanceData[DateTime.utc(
                              day.year,
                              day.month,
                              day.day,
                            )];
                        Color statusColor = Colors.transparent;

                        final isWeekend =
                            day.weekday == DateTime.saturday ||
                            day.weekday == DateTime.sunday;
                        final isBeforeJoining = day.isBefore(_firstDay);
                        final isToday = isSameDay(day, DateTime.now());
                        final isPastDay = day.isBefore(
                          DateTime.utc(now.year, now.month, now.day),
                        );

                        // Prioritize weekends
                        if (isWeekend) {
                          statusColor = weekOffColor;
                        } else if (isBeforeJoining) {
                          statusColor = Colors.transparent;
                        } else if (dailyStatus != null) {
                          // Check for attendance/leave data
                          switch (dailyStatus.status) {
                            case 'Present':
                              statusColor = presentColor;
                              break;
                            case 'Upcoming Leave':
                              statusColor = upcomingLeaveColor;
                              break;
                            case 'Leave':
                              statusColor = leaveColor;
                              break;
                            default:
                              statusColor = Colors.transparent;
                              break;
                          }
                        } else {
                          // Default for past non-weekend days with no data
                          if (isPastDay) {
                            statusColor = leaveColor;
                          } else {
                            statusColor = Colors.transparent;
                          }
                        }

                        final bool isSelected = isSameDay(day, _selectedDay);

                        return Container(
                          margin: const EdgeInsets.all(4.0),
                          alignment: Alignment.center,
                          width: 48,
                          height: 48,
                          decoration: (isSelected || isToday)
                              ? BoxDecoration(
                                  border: Border.all(
                                    color: presentColor,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(8.0),
                                )
                              : null,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Positioned(
                                top: 8,
                                child: Text(
                                  '${day.day}',
                                  style: TextStyle(
                                    color: isWeekend
                                        ? Colors.grey
                                        : Colors.black,
                                    fontWeight: (isSelected || isToday)
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                              if (statusColor != Colors.transparent)
                                Positioned(
                                  bottom: 4,
                                  child: Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: statusColor,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildLegend(),
                ],
              ),
            ),
    );
  }

  // A helper function to check if two dates are in the same month and year.
  bool isSameMonth(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month;
  }

  Widget _buildCountText(String label, int count, Color color) {
    return Row(
      children: [
        Text(label, style: const TextStyle(fontSize: 16)),
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
                _buildLegendItem('Present', presentColor),
                _buildLegendItem('Upcoming Leave', upcomingLeaveColor),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLegendItem('Leave/Absent', leaveColor),
                _buildLegendItem('Weekoff', weekOffColor),
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
}
