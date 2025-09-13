import 'package:flutter/material.dart';
import 'package:event_management_app1/core/config/app_theme.dart';
import 'package:event_management_app1/features/organizer/widgets/modern_card.dart';
import 'package:event_management_app1/features/organizer/screens/events/widgets/event_request_form.dart';
import 'package:event_management_app1/features/organizer/screens/events/widgets/assigned_event_list_screen.dart';

class EventScreen extends StatelessWidget {
  final VoidCallback? onEventPublished;
  const EventScreen({super.key, this.onEventPublished});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Events',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 90),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Quick Actions",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Manage your events and requests",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: AppTheme.spacingM),
            ModernCard(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ContactForm(isFromDashboard: true),
                  ),
                );
              },
              child: _buildActionItem(
                icon: Icons.add_circle_outline,
                iconColor: AppTheme.secondaryColor,
                bgColor: AppTheme.secondaryColor.withAlpha(25),
                title: "Create New Event Request",
                subtitle: "Submit a new event proposal for approval",
              ),
            ),

            const SizedBox(height: AppTheme.spacingM),

            ModernCard(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AssignedEventListScreen(onEventPublished: onEventPublished),
                  ),
                );
              },
              child: _buildActionItem(
                icon: Icons.event_note_outlined,
                iconColor: AppTheme.primaryColor,
                bgColor: AppTheme.primaryColor.withAlpha(25),
                title: "View My Assigned Events",
                subtitle: "Manage and organize your approved events",
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionItem({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: bgColor, 
            borderRadius: BorderRadius.circular(AppTheme.radiusM)
          ),
          child: Icon(icon, color: iconColor, size: 24),
        ),
        const SizedBox(width: AppTheme.spacingM),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title, 
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle, 
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 16),
      ],
    );
  }
}