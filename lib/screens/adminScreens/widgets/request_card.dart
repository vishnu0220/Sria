import 'package:flutter/material.dart';
import 'review_request_dialog.dart';

class RequestCard extends StatelessWidget {
  final Request request;
  final Function(String) onUpdateStatus; // callback to update status

  const RequestCard({
    super.key,
    required this.request,
    required this.onUpdateStatus,
  });

  Color _getStatusColor(String status) {
    switch (status) {
      case 'PENDING':
        return Colors.amber.shade800;
      case 'APPROVED':
        return Colors.green.shade800;
      case 'REJECTED':
        return Colors.red.shade800;
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
      case 'REJECTED':
        return Colors.red.shade100;
      default:
        return Colors.grey.shade100;
    }
  }

  void _showReviewDialog(BuildContext context) async {
    final updatedStatus = await showDialog<String>(
      context: context,
      builder: (BuildContext context) => ReviewRequestDialog(request: request),
    );

    if (updatedStatus != null) {
      onUpdateStatus(updatedStatus);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isReviewed =
        request.status == 'APPROVED' || request.status == 'REJECTED';

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
                  const SizedBox(height: 8),
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
                onPressed: isReviewed ? null : () => _showReviewDialog(context),
                icon: const Icon(Icons.remove_red_eye_outlined),
                label: const Text('Review'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: isReviewed
                      ? Colors.grey
                      : Colors.blue.shade700,
                  side: BorderSide(
                    color: isReviewed ? Colors.grey : Colors.blue.shade700,
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
