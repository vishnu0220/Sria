import 'package:flutter/material.dart';

class TimeTrackingCard extends StatelessWidget {
  final bool isCheckedIn;
  final bool isLoading;
  final VoidCallback onToggleCheckInOut;

  const TimeTrackingCard({
    super.key,
    required this.isCheckedIn,
    required this.isLoading,
    required this.onToggleCheckInOut,
  });

  @override
  Widget build(BuildContext context) {
    final statusText = isCheckedIn ? 'Checked In' : 'Ready to Check In';
    final statusColor = Colors.teal;
    final buttonText = isCheckedIn ? 'Clock Out' : 'Clock In';
    final icon = isCheckedIn ? Icons.exit_to_app : Icons.login;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: const [
                Icon(Icons.access_time_outlined, size: 20, color: Colors.teal),
                SizedBox(width: 8),
                Text(
                  'Time Tracking',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Column(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: statusColor.withAlpha(25),
                  child: Icon(icon, color: statusColor),
                ),
                const SizedBox(height: 8),
                Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : onToggleCheckInOut,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  backgroundColor: statusColor,
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(buttonText),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
