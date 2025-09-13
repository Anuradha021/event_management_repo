import 'package:flutter/material.dart';
import 'package:event_management_app1/features/organizer/screens/events/widgets/assigned_events_list.dart';
import 'package:event_management_app1/features/organizer/screens/events/organizer_event_details_screen.dart';

class AssignedEventListScreen extends StatelessWidget {
  const AssignedEventListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AssignedEventsList(
      showAppBar: true,
      onEventTap: (event) {
        final eventId = event['id'] ?? event['eventId'] ?? event['_id'];
        if (eventId != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OrganizerEventDetailsScreen(
                eventId: eventId.toString(),
                eventData: event,
              ),
            ),
          );
        }
      },
    );
  }
}