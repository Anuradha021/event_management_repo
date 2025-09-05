import 'package:flutter/material.dart';
import 'package:event_management_app1/core/config/app_theme.dart';
import 'package:event_management_app1/features/organizer/widgets/modern_card.dart';
import 'package:event_management_app1/features/organizer/screens/events/event_request_form.dart';
import 'package:event_management_app1/features/organizer/screens/events/assigned_event_list_screen.dart';

class QuickActionsSection extends StatelessWidget {
  const QuickActionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Quick Actions", style: AppTheme.headingSmall),
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
                builder: (_) => const AssignedEventListScreen(),
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
          decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(AppTheme.radiusM)),
          child: Icon(icon, color: iconColor, size: 24),
        ),
        const SizedBox(width: AppTheme.spacingM),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTheme.labelLarge),
              const SizedBox(height: 4),
              Text(subtitle, style: AppTheme.bodyMedium),
            ],
          ),
        ),
        const Icon(Icons.arrow_forward_ios, color: AppTheme.textTertiary, size: 16),
      ],
    );
  }
}