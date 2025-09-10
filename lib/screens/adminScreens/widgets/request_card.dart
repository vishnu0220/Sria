import 'package:flow_sphere/screens/adminScreens/widgets/review_request_dialog.dart';
import 'package:flutter/material.dart';

class RequestCard extends StatelessWidget {
  final Request request;

  const RequestCard({super.key, required this.request});

  Color _getStatusColor(String status) {
    switch (status) {
      case 'PENDING':
        return Colors.amber.shade800;
      case 'APPROVED':
        return Colors.green.shade800;
      default:
        return Colors.grey.shade800;
    }
  }

  Color _getStatusBackgroundColor(String status) {
    switch (status) {
      case 'PENDING':
        return Colors.amber.shade100;
      case 'APPROVED':
        return Colors.green.shade100;
      default:
        return Colors.grey.shade100;
    }
  }

  void _showReviewDialog(BuildContext context, Request request) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ReviewRequestDialog(request: request);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isApproved = request.status == 'APPROVED';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Text(
                        request.type,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusBackgroundColor(request.status),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          request.status,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _getStatusColor(request.status),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    request.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  Text(
                    request.email,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Date:'),
                          SizedBox(height: 8),
                          Text('Type:'),
                          SizedBox(height: 8),
                          Text('Reason:'),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              request.date,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              request.leaveType,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              request.reason,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: OutlinedButton.icon(
                onPressed: isApproved
                    ? null
                    : () => _showReviewDialog(context, request),
                icon: const Icon(Icons.remove_red_eye_outlined),
                label: const Text('Review'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: isApproved
                      ? Colors.grey
                      : Colors.blue.shade700,
                  side: BorderSide(
                    color: isApproved ? Colors.grey : Colors.blue.shade700,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
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
