import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flow_sphere/Services/Admin_services/login_api_services.dart';

class Request {
  final String id;
  final String type;
  final String status;
  final String name;
  final String email;
  final String date;
  final String leaveType;
  final String reason;
  final String? endDate;
  final String? actionDate;
  final String? expectedLogoffTime;

  Request({
    required this.id,
    required this.type,
    required this.status,
    required this.name,
    required this.email,
    required this.date,
    required this.leaveType,
    required this.reason,
    this.endDate,
    this.actionDate,
    this.expectedLogoffTime,
  });

  // copyWith to update request locally
  Request copyWith({String? status}) {
    return Request(
      id: id,
      type: type,
      status: status ?? this.status,
      name: name,
      email: email,
      date: date,
      leaveType: leaveType,
      reason: reason,
      endDate: endDate,
      actionDate: actionDate,
      expectedLogoffTime: expectedLogoffTime,
    );
  }
}

class ReviewRequestDialog extends StatefulWidget {
  final Request request;

  const ReviewRequestDialog({super.key, required this.request});

  @override
  State<ReviewRequestDialog> createState() => _ReviewRequestDialogState();
}

class _ReviewRequestDialogState extends State<ReviewRequestDialog> {
  String? _selectedDecision;
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmitting = false;

  Future<void> _submitDecision() async {
    if (_selectedDecision == null) return;

    setState(() => _isSubmitting = true);

    final AuthService authService = AuthService();
    final token = await authService.getToken();

    if (token == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Authentication failed. Please login.")),
      );
      setState(() => _isSubmitting = false);
      return;
    }

    String status = _selectedDecision == "Approve" ? "APPROVED" : "REJECTED";

    final payload = {
      "status": status,
      "comment": _commentController.text.trim(),
    };

    final url =
        "https://leave-backend-vbw6.onrender.com/api/admin/requests/${widget.request.id}/decision";

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        if (!mounted) return;
        Navigator.of(context).pop(status); // return updated status
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Decision submitted successfully!")),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to submit: ${response.statusCode}")),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDecisionMade = _selectedDecision != null;

    return AlertDialog(
      titlePadding: const EdgeInsets.all(24),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(widget.request.type),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Employee'),
            Text(
              '${widget.request.name} (${widget.request.email})',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text('Date Range'),
            Text(
              (() {
                if (widget.request.leaveType == "LEAVE" &&
                    widget.request.endDate != null &&
                    widget.request.endDate != widget.request.date) {
                  return "${widget.request.date} to ${widget.request.endDate}";
                } else {
                  return widget.request.date;
                }
              })(),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text('Leave Type'),
            Text(
              widget.request.expectedLogoffTime != null
                  ? "${widget.request.leaveType} at ${widget.request.expectedLogoffTime}"
                  : widget.request.leaveType,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text('Reason'),
            Text(
              widget.request.reason,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            const Text('Decision'),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              hint: const Text('Select decision'),
              initialValue: _selectedDecision,
              items: ['Approve', 'Decline']
                  .map(
                    (decision) => DropdownMenuItem<String>(
                      value: decision,
                      child: Text(decision),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedDecision = value;
                });
              },
            ),
            const SizedBox(height: 16),
            const Text('Comment (Optional)'),
            const SizedBox(height: 8),
            TextField(
              controller: _commentController,
              maxLines: 2,
              decoration: const InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
                hintText: 'Add any comments...',
              ),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Cancel', style: TextStyle(color: Colors.black)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        TextButton(
          style: TextButton.styleFrom(
            backgroundColor: isDecisionMade
                ? const Color(0xFF00a896)
                : Colors.grey.shade400,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: isDecisionMade && !_isSubmitting ? _submitDecision : null,
          child: _isSubmitting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Submit Decision'),
        ),
      ],
    );
  }
}
