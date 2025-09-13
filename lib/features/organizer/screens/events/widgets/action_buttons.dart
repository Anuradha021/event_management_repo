import 'package:event_management_app1/core/config/app_theme.dart';
import 'package:event_management_app1/features/organizer/screens/events/event_management_screen.dart';
import 'package:flutter/material.dart';

class ActionButtons extends StatelessWidget {
  final String eventId;
  final String eventTitle;
  const ActionButtons({
    super.key,
    required this.eventId,
    required this.eventTitle,
  });
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EventManagementScreen(eventId: eventId)),
              );
            },
            icon: const Icon(Icons.settings),
            label: const Text("Configure"),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        
      ],
    );
  }
}
