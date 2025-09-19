import 'dart:io';
import 'package:flow_sphere/Services/Admin_services/login_api_services.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:open_filex/open_filex.dart';
import 'package:permission_handler/permission_handler.dart';

class ExportProgressDialog extends StatefulWidget {
  const ExportProgressDialog({super.key});

  @override
  State<ExportProgressDialog> createState() => _ExportProgressDialogState();
}

class _ExportProgressDialogState extends State<ExportProgressDialog> {
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2025, 8),
      lastDate: DateTime.now(),
      helpText: 'Select Date',
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: const Color(0xFF0d6efd),
            colorScheme: const ColorScheme.light(primary: Color(0xFF0d6efd)),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<bool> _requestStoragePermission() async {
    if (Platform.isAndroid) {
      // First try normal storage permission
      if (await Permission.storage.request().isGranted) {
        return true;
      }
      // If Android 11+ requires MANAGE_EXTERNAL_STORAGE
      if (await Permission.manageExternalStorage.request().isGranted) {
        return true;
      }
      return false;
    }
    return true;
  }

  Future<void> _exportToExcel() async {
    final AuthService authService = AuthService();
    final token = await authService.getToken();

    setState(() {
      _isLoading = true;
    });

    try {
      // ✅ Ask storage permission (important for Android)
      final hasPermission = await _requestStoragePermission();
      if (!hasPermission) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Storage permission denied ❌")),
        );
        return;
      }

      // Format date as yyyy-MM-dd
      final String formattedDate = DateFormat(
        'yyyy-MM-dd',
      ).format(_selectedDate);
      final String url =
          "https://leave-backend-vbw6.onrender.com/api/export?date=$formattedDate";

      final response = await http.get(
        Uri.parse(url),
        headers: {
          "Authorization": "Bearer $token",
          "Accept":
              "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
        },
      );

      if (response.statusCode == 200) {
        String filePath;

        if (Platform.isAndroid) {
          // ✅ Custom directory: /storage/emulated/0/Flow Sphere/Employee Progress
          final customDir = Directory(
            "/storage/emulated/0/Flow Sphere/Employee Progress",
          );

          if (!customDir.existsSync()) {
            customDir.createSync(recursive: true);
          }

          filePath = "${customDir.path}/progress_$formattedDate.xlsx";
        } else {
          // For other platforms (Desktop/Mac/iOS) fallback
          final dir = Directory.systemTemp;
          filePath = "${dir.path}/progress_$formattedDate.xlsx";
        }

        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("File saved to: $filePath"),
            action: SnackBarAction(
              label: "Open",
              onPressed: () {
                OpenFilex.open(filePath);
              },
            ),
          ),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed: ${response.statusCode}")),
        );
      }
    } catch (e) {
      // debugPrint("Error $e");
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("It seems your internet connection is slow")));
    } finally {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        Navigator.of(context).pop(); // close dialog after export
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.description, color: Colors.black54),
                    SizedBox(width: 8),
                    Text(
                      'Export Progress',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Select a date to export your progress data as an Excel spreadsheet.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            const Text(
              'Select Date',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => _selectDate(context),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFf3f4f6),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        DateFormat('MMM dd, yyyy').format(_selectedDate),
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    const Icon(Icons.keyboard_arrow_down, size: 24),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF0d6efd),
                      side: const BorderSide(color: Colors.transparent),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                    ),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    onPressed: _exportToExcel,
                    icon: const Icon(
                      Icons.download,
                      size: 20,
                      color: Colors.white,
                    ),
                    label: const Text(
                      'Export Excel',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF198754),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
