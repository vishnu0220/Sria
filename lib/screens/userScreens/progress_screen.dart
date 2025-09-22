import 'package:flow_sphere/Services/User_services/progress_service.dart';
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
  final TextEditingController _notesController = TextEditingController();
  bool _isTaskNotEmpty = false;
  bool _isLoading = false;
  bool _isSaving = false;

  // Progress data
  List<TaskItem> _tasks = [];
  String _dailyNotes = '';
  int _overallProgress = 0;
  String _selectedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  String _userId = ''; // Will be fetched from auth service

  @override
  void initState() {
    super.initState();
    _taskController.addListener(() {
      setState(() {
        _isTaskNotEmpty = _taskController.text.trim().isNotEmpty;
      });
    });
    _initializeUserAndFetchProgress();
  }

  @override
  void dispose() {
    _taskController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _initializeUserAndFetchProgress() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get user ID from progress service
      _userId = await ProgressService.getUserId();

      // Fetch progress data for the selected date
      await _fetchProgressForDate();
    } catch (e) {
      _showErrorMessage('Failed to initialize: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchProgressForDate() async {
    if (_userId.isEmpty) {
      _showErrorMessage('User not authenticated');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final progressData = await ProgressService.fetchTodayProgress(
        date: _selectedDate,
        userId: _userId,
      );

      setState(() {
        _tasks = List.from(progressData.tasks);
        _dailyNotes = progressData.dailyNotes;
        _notesController.text = _dailyNotes;
        _overallProgress = progressData.overallProgress;
      });

      print('Loaded ${_tasks.length} tasks for $_selectedDate');
    } catch (e) {
      // If no data exists for the selected date, start with empty data
      setState(() {
        _tasks = [];
        _dailyNotes = '';
        _notesController.text = '';
        _overallProgress = 0;
      });
      print('No progress data found for $_selectedDate: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _addTask() async {
    final taskDescription = _taskController.text.trim();
    if (taskDescription.isEmpty) return;

    final newTask = TaskItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      description: taskDescription,
      progress: 0,
      status: 'pending',
    );

    setState(() {
      _tasks.add(newTask);
      _calculateOverallProgress();
    });

    _taskController.clear();
    _showSuccessMessage('Task added successfully!');
  }

  void _updateTaskProgress(int index, int progress) {
    setState(() {
      _tasks[index].progress = progress;
      _tasks[index].status = progress == 100
          ? 'completed'
          : progress > 0
          ? 'in-progress'
          : 'pending';
      _calculateOverallProgress();
    });
  }

  void _deleteTask(int index) {
    setState(() {
      _tasks.removeAt(index);
      _calculateOverallProgress();
    });
  }

  void _calculateOverallProgress() {
    if (_tasks.isEmpty) {
      _overallProgress = 0;
      return;
    }

    final totalProgress = _tasks.fold<int>(
      0,
      (sum, task) => sum + task.progress,
    );
    _overallProgress = (totalProgress / _tasks.length).round();
  }

  Future<void> _saveProgress() async {
    setState(() {
      _isSaving = true;
    });

    try {
      await ProgressService.submitProgress(
        date: _selectedDate,
        userId: _userId,
        tasks: _tasks,
        dailyNotes: _notesController.text.trim(),
        // progress: progress,
      );

      setState(() {
        _dailyNotes = _notesController.text.trim();
      });

      _showSuccessMessage('Progress saved successfully!');
    } catch (e) {
      _showErrorMessage('Failed to save progress: $e');
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime today = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateFormat('yyyy-MM-dd').parse(_selectedDate),
      firstDate: DateTime(2020),
      lastDate: today,
    );

    if (picked != null) {
      final newDate = DateFormat('yyyy-MM-dd').format(picked);
      if (newDate != _selectedDate) {
        setState(() {
          _selectedDate = newDate;
        });

        // Fetch data for the new selected date
        await _fetchProgressForDate();

        final displayDate = DateFormat('MMMM d, yyyy').format(picked);
        _showSuccessMessage('Loaded data for $displayDate');
      }
    }
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  int get _completedTasks =>
      _tasks.where((task) => task.status == 'completed').length;
  int get _inProgressTasks => _tasks
      .where(
        (task) => task.status == 'in-progress' || task.status == 'in-progress',
      )
      .length;
  int get _pendingTasks =>
      _tasks.where((task) => task.status == 'pending').length;

  @override
  Widget build(BuildContext context) {
    const Color bootstrapPrimaryBlue = Color(0xFF0D6EFD);
    DateTime selectedDateTime = DateFormat('yyyy-MM-dd').parse(_selectedDate);
    String displayDate = DateFormat(
      'EEEE, MMMM d, yyyy',
    ).format(selectedDateTime);

    if (_isLoading) {
      return Scaffold(
        appBar: CustomAppBar(),
        drawer: CustomNavigationDrawer(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: CustomAppBar(),
      drawer: CustomNavigationDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(11),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress Tracker Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    Text.rich(
                      (TextSpan(
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                        children: [
                          WidgetSpan(
                            child: Icon(
                              Icons.bar_chart_rounded,
                              color: bootstrapPrimaryBlue,
                            ),
                          ),
                          TextSpan(text: "Progress Tracker"),
                        ],
                      )),
                    ),

                    const Text("Track your daily tasks \nand productivity"),
                  ],
                ),

                const SizedBox(width: 20),
                TextButton.icon(
                  style: TextButton.styleFrom(
                    backgroundColor: bootstrapPrimaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: _isSaving ? null : _saveProgress,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 40,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(
                          Icons.save_alt,
                          size: 18,
                          color: Colors.white,
                        ),
                  label: Text(_isSaving ? "Saving..." : "Save Progress"),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  style: TextButton.styleFrom(
                    backgroundColor: bootstrapPrimaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () => _selectDate(context),
                  icon: const Icon(
                    Icons.calendar_today,
                    size: 18,
                    color: Colors.white,
                  ),
                  label: Text(
                    DateFormat('MMM dd').format(selectedDateTime),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

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
                    Text(displayDate),
                    const SizedBox(height: 12),
                    Text(
                      "$_overallProgress%   $_completedTasks of ${_tasks.length} tasks completed",
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: _overallProgress / 100,
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
                              : Colors.grey,
                          child: IconButton(
                            icon: const Icon(Icons.add, color: Colors.white),
                            onPressed: _isTaskNotEmpty ? _addTask : null,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Today's Tasks Card
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
                      "Today's Tasks",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text("Track your progress throughout the day"),
                    const SizedBox(height: 16),
                    if (_tasks.isEmpty)
                      const Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 40,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 8),
                            Text(
                              "No tasks for today. Add your first task above!",
                            ),
                          ],
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _tasks.length,
                        separatorBuilder: (context, index) =>
                            const Divider(height: 20),
                        itemBuilder: (context, index) {
                          final task = _tasks[index];
                          return Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        task.description,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                        size: 20,
                                      ),
                                      onPressed: () => _deleteTask(index),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: LinearProgressIndicator(
                                        value: task.progress / 100,
                                        backgroundColor: Colors.grey[300],
                                        color: bootstrapPrimaryBlue,
                                        minHeight: 6,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      '${task.progress}%',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            minimumSize: const Size(40, 32),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                            ),
                                          ),
                                          onPressed: task.progress > 0
                                              ? () => _updateTaskProgress(
                                                  index,
                                                  (task.progress - 10).clamp(
                                                    0,
                                                    100,
                                                  ),
                                                )
                                              : null,
                                          child: const Icon(
                                            Icons.remove,
                                            size: 16,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            minimumSize: const Size(40, 32),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                            ),
                                            backgroundColor:
                                                bootstrapPrimaryBlue,
                                            foregroundColor: Colors.white,
                                          ),
                                          onPressed: task.progress < 100
                                              ? () => _updateTaskProgress(
                                                  index,
                                                  (task.progress + 10).clamp(
                                                    0,
                                                    100,
                                                  ),
                                                )
                                              : null,
                                          child: const Icon(
                                            Icons.add,
                                            size: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: task.status == 'completed'
                                            ? Colors.green
                                            : (task.status == 'in-progress' ||
                                                  task.status == 'in-progress')
                                            ? Colors.orange
                                            : Colors.grey,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        task.status == 'in-progress'
                                            ? 'IN PROGRESS'
                                            : task.status.toUpperCase(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Daily Notes Card
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
                    const Text("Note down thoughts, bloggers, or achievements"),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _notesController,
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
                  children: [
                    const Text(
                      "Quick Stats",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Total Tasks"),
                        Text("${_tasks.length}"),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Completed"),
                        Text(
                          "$_completedTasks",
                          style: const TextStyle(color: Colors.green),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("In Progress"),
                        Text(
                          "$_inProgressTasks",
                          style: const TextStyle(color: Colors.orange),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Pending"),
                        Text(
                          "$_pendingTasks",
                          style: const TextStyle(color: Colors.grey),
                        ),
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
