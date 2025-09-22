import 'package:flutter/material.dart';

class BuildProgressCard extends StatelessWidget {
  final int todayProgressPercent;
  const BuildProgressCard({
    super.key,
    required this.context,
    required this.todayProgressPercent,
  });

  final BuildContext context;

  // final int progressPercent;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.bar_chart, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  "Today's Progress",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Center(
              child: Text(
                '$todayProgressPercent%',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Center(
              child: const Text(
                'Tasks Completed',
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/progress');
                }, // Placeholder for button action
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.grey[400]!),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Update Progress',
                  style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
