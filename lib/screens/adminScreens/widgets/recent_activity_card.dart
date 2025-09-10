import 'package:flutter/material.dart';

class RecentActivityCard extends StatelessWidget {
  final List<ActivityItem> activities;

  const RecentActivityCard({super.key, required this.activities});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              children: [
                Icon(Icons.trending_up, color: Colors.teal),
                const SizedBox(width: 8),
                Text(
                  'Recent Activity',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Latest system activities and updates',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 12),
            Divider(),
            // Activity List
            ListView.builder(
              itemCount: activities.length,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final act = activities[index];
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Material(
                    // ignore: deprecated_member_use
                    // color: Colors.grey.withOpacity(0),
                    elevation: 1, // Shadow depth for each item
                    borderRadius: BorderRadius.circular(10),
                    child: ListTile(
                      leading: Icon(
                        Icons.circle,
                        color: Colors.orange,
                        size: 12,
                      ),
                      title: Text(
                        '${act.name} – ${act.action}',
                        style: TextStyle(fontSize: 15),
                      ),
                      trailing: Text(
                        act.time,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Model class to encapsulate activity details
class ActivityItem {
  final String name;
  final String action;
  final String time;

  ActivityItem({required this.name, required this.action, required this.time});
}
