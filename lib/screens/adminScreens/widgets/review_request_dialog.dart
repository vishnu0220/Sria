import 'package:flutter/material.dart';

// Represents a single user request.
class Request {
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
}

class ReviewRequestDialog extends StatefulWidget {
  final Request request;

  const ReviewRequestDialog({super.key, required this.request});

  @override
  State<ReviewRequestDialog> createState() => _ReviewRequestDialogState();
}

class _ReviewRequestDialogState extends State<ReviewRequestDialog> {
  String? _selectedDecision;

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
            // Text(
            //   widget.request.endDate != widget.request.date
            //       ? "${widget.request.date} to ${widget.request.endDate}"
            //       : widget.request.date,
            //   style: TextStyle(fontWeight: FontWeight.bold),
            // ),
            Text(
              (() {
                if (widget.request.leaveType == "LEAVE" &&
                    widget.request.endDate != null &&
                    widget.request.endDate != widget.request.date) {
                  return "${widget.request.date} to ${widget.request.endDate}";
                } else if (widget.request.leaveType == "EARLY_LOGOFF") {
                  return widget.request.date;
                } else if (widget.request.leaveType == "CHECKOUT") {
                  return widget.request.date;
                } else {
                  // fallback (in case a new type comes later)
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
              style: TextStyle(fontWeight: FontWeight.bold),
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
            const TextField(
              maxLines: 2,
              decoration: InputDecoration(
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
          onPressed: () {
            Navigator.of(context).pop();
          },
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
          onPressed: isDecisionMade
              ? () {
                  // Implement submission logic here
                  debugPrint('Decision: $_selectedDecision');
                  Navigator.of(context).pop();
                }
              : null,
          child: const Text('Submit Decision'),
        ),
      ],
    );
  }
}
