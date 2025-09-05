import 'package:event_management_app1/core/config/app_theme.dart';
import 'package:event_management_app1/features/organizer/widgets/quick_actions_section.dart';
import 'package:event_management_app1/features/events/widgets/welcome_header.dart';
import 'package:event_management_app1/core/services/organizer_dashboard_service.dart';
import 'package:flutter/material.dart';

class OrganizerDashboardScreen extends StatefulWidget {
  const OrganizerDashboardScreen({super.key});

  @override
  State<OrganizerDashboardScreen> createState() => _OrganizerDashboardScreenState();
}

class _OrganizerDashboardScreenState extends State<OrganizerDashboardScreen> {
  @override
  void initState() {
    super.initState();
    _checkAndShowApprovalPopup();
  }

  Future<void> _checkAndShowApprovalPopup() async {
    final result = await OrganizerDashboardService.checkApprovalStatus();
    
    if (result['success'] == true) {
      final data = result['data'];
      final isOrganizer = data['isOrganizer'] ?? false;
      final popupShown = data['popupShown'] ?? false;

      if (isOrganizer && !popupShown) {
        if (!mounted) return;
        
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Approval Received"),
            content: const Text("Congratulations! You are now an approved organizer."),
            actions: [
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  
                  await OrganizerDashboardService.updatePopupStatus();
                },
                child: const Text("OK"),
              ),
            ],
          ),
        );
      }
    }
  }

  void _logout() async {
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text("Organizer Dashboard"),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_outlined),
            tooltip: 'Sign Out',
            onPressed: _logout,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            WelcomeHeader(),
            SizedBox(height: AppTheme.spacingXL),
            QuickActionsSection(),
          ],
        ),
      ),
    );
  }
}