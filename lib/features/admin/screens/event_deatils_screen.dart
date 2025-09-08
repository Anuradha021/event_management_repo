import 'package:event_management_app1/core/services/admin_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EventDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> eventData;
  final String docId;

  const EventDetailsScreen({
    Key? key,
    required this.eventData,
    required this.docId,
  }) : super(key: key);

  String _formatDate(dynamic dateValue) {
    if (dateValue == null) return 'N/A';

    try {
      if (dateValue is String) {
        final date = DateTime.tryParse(dateValue);
        if (date != null) {
          return DateFormat('dd-MMM-yy').format(date);
        }
      }
      if (dateValue is DateTime) {
        return DateFormat('dd-MMM-yy').format(dateValue);
      }
    } catch (_) {
      return 'N/A';
    }
    return 'N/A';
  }

  Future<void> _approveRequest(BuildContext context) async {
    try {
      final result = await AdminService.approveEventRequest(docId);

      if (result['success']) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Event approved and organizer assigned!'),
            ),
          );
          Navigator.of(context).pop();
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error approving: ${result['message']}')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error approving: $e')));
      }
    }
  }

  Future<void> _rejectRequest(BuildContext context) async {
    try {
      final result = await AdminService.updateRequestStatus(docId, 'rejected');

      if (result['success']) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Event rejected!')));
          Navigator.of(context).pop();
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error rejecting: ${result['message']}')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error rejecting: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = eventData;
    final status = data['status'] ?? 'pending';

    return Scaffold(
      appBar: AppBar(title: const Text('Event Details')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text(
              data['eventTitle'] ?? 'No Title',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text('Organizer Email: ${data['organizerEmail'] ?? 'N/A'}'),
            const SizedBox(height: 10),
            Text('Event Date: ${_formatDate(data['eventDate'])}'),
            const SizedBox(height: 10),
            Text('Location: ${data['location'] ?? 'N/A'}'),
            const SizedBox(height: 10),
            Text('Status: $status'),
            const SizedBox(height: 10),
            const Text('Description:'),
            Text(data['eventDescription'] ?? 'No Description'),
            const SizedBox(height: 20),

            if (status == 'pending' || status == 'rejected') ...[
              ElevatedButton(
                onPressed: () => _approveRequest(context),
                child: const Text('Approve & Assign Organizer'),
              ),
              const SizedBox(height: 10),
            ],
            if (status == 'pending' || status == 'approved') ...[
              ElevatedButton(
                onPressed: () => _rejectRequest(context),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Reject'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
