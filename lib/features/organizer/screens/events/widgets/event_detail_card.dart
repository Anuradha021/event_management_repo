import 'package:event_management_app1/features/organizer/screens/events/widgets/event_detail_row.dart';
import 'package:flutter/material.dart';

class EventDetailCard extends StatelessWidget {
  final Map<String, dynamic> eventData;

  const EventDetailCard({super.key, required this.eventData});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    eventData['eventTitle'] ?? 'Event Title',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(eventData['status']),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    (eventData['status'] ?? 'draft').toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            DetailRow(
              icon: Icons.description,
              label: "Description",
              value:
                  eventData['eventDescription'] ?? 'No description available',
            ),
            const SizedBox(height: 12),
            DetailRow(
              icon: Icons.location_on,
              label: "Location",
              value: eventData['location'] ?? 'Location TBD',
            ),

          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'published':
        return Colors.green;
      case 'draft':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
