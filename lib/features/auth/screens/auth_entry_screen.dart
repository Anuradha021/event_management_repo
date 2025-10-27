import 'package:event_management_app1/features/organizer/screens/events/Event_screen.dart';
import 'package:event_management_app1/features/user/screens/unified_dashboard.dart';
import 'package:event_management_app1/features/admin/screens/admin_dashboard.dart';
import 'package:event_management_app1/features/organizer/screens/events/widgets/event_request_form.dart';
import 'package:flutter/material.dart';
import 'package:event_management_app1/core/services/auth_service.dart';

class EntryPointScreen extends StatelessWidget {
  const EntryPointScreen({super.key});

  Future<String> _getUserRole() async {
  final me = await AuthService().me();
  if (me.isSuccess && me.user != null) {

    final role = me.user!.role.toUpperCase();
    return role == 'SYSTEM_ADMIN' ? 'admin' : role.toLowerCase();
  }
  return 'guest';
}

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _getUserRole(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        switch (snapshot.data) {
          case 'admin':
            return const AdminDashboard();
          case 'organizer':
            return const EventScreen();
          case 'user':
            return const UnifiedDashboard();
          default:
            return const ContactForm(isFromDashboard: false);
        }
      },
    );
  }
}
