import 'package:event_management_app1/core/config/app_theme.dart';
import 'package:event_management_app1/core/utils/date_utils.dart';
import 'package:event_management_app1/features/organizer/screens/events/organizer_event_details_screen.dart';
import 'package:event_management_app1/features/organizer/screens/events/user_event_details_screen.dart';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EventCard extends StatelessWidget {
  final String eventId;
  final Map<String, dynamic> eventData;

  const EventCard({
    super.key,
    required this.eventId,
    required this.eventData,
  });

  void _navigateToEventDetails(BuildContext context, bool isMyEvent) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => isMyEvent
            ? OrganizerEventDetailsScreen(eventId: eventId, eventData: eventData)
            : UserEventDetailsScreen(eventId: eventId, eventData: eventData),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final isMyEvent = user != null && eventData['organizerUid'] == user.uid;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    eventData['eventTitle'] ?? 'Event',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (isMyEvent)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              eventData['eventDescription'] ?? '',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    eventData['location'] ?? '',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                   AppDateUtils.formatEventDate(eventData['eventDate']),
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _navigateToEventDetails(context, isMyEvent),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: Text(isMyEvent ? 'Manage Event' : 'View Event'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
