import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:event_management_app1/features/admin/screens/event_deatils_screen.dart';

class PublishedEventsList extends StatelessWidget {
  final List<dynamic> events;
  const PublishedEventsList({super.key, required this.events});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index] as Map<String, dynamic>;
        final eventId = event['id'] ?? event['_id'] ?? 'unknown_id_$index';
        return _buildEventCard(context, eventId, event);
      },
    );
  }

  Widget _buildEventCard(BuildContext context, String eventId, Map<String, dynamic> event) {
    final title = event['eventTitle'] ?? event['title'] ?? 'Untitled Event';
    final description = event['eventDescription'] ?? event['description'] ?? '';
    final date = event['eventDate'] ?? event['date'];
    final location = event['location'] ?? event['venue'] ?? '';
    final organizer = event['organizerName'] ?? event['organizer'] ?? 'Unknown';
    final status = event['status'] ?? 'published';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EventDetailsScreen(
                docId: eventId,
                eventData: event,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              if (date != null) _buildDateRow(date),
              const SizedBox(height: 8),
              if (location.isNotEmpty) _buildLocationRow(location),
              const SizedBox(height: 8),
              _buildOrganizerRow(organizer),
              if (description.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  description,
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 12),
              _buildStatusChip(status),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateRow(dynamic date) {
    return Row(
      children: [
        const Icon(Icons.calendar_today, size: 16, color: Colors.deepPurple),
        const SizedBox(width: 8),
        Text(
          _formatDate(date),
          style: const TextStyle(fontSize: 14, color: Colors.black87),
        ),
      ],
    );
  }

  Widget _buildLocationRow(String location) {
    return Row(
      children: [
        const Icon(Icons.location_on, size: 16, color: Colors.deepPurple),
        const SizedBox(width: 8),
        Expanded(
          child: Text(location, style: const TextStyle(fontSize: 14, color: Colors.black87)),
        ),
      ],
    );
  }

  Widget _buildOrganizerRow(String name) {
    return Row(
      children: [
        const Icon(Icons.person, size: 16, color: Colors.deepPurple),
        const SizedBox(width: 8),
        Text('By $name', style: const TextStyle(fontSize: 14, color: Colors.black54)),
      ],
    );
  }

  Widget _buildStatusChip(String status) {
    final color = status == 'published' ? Colors.green : Colors.orange;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  String _formatDate(dynamic date) {
    try {
      DateTime dateTime;
      if (date is String) {
        dateTime = DateTime.parse(date);
      } else if (date is DateTime) {
        dateTime = date;
      } else {
        return 'Date TBD';
      }
      return DateFormat('EEEE, MMMM dd, yyyy • h:mm a').format(dateTime);
    } catch (_) {
      return 'Date TBD';
    }
  }
}