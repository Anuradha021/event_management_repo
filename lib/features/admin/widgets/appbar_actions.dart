import 'package:flutter/material.dart';
import 'package:event_management_app1/features/admin/screens/user_list_screen.dart';

class AdminAppBarActions extends StatelessWidget {
  final bool isSystemAdmin;
  final VoidCallback onLogout; 

  const AdminAppBarActions({
    super.key,
    required this.isSystemAdmin,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (isSystemAdmin)
          IconButton(
            icon: const Icon(Icons.manage_accounts),
            tooltip: 'Manage Users',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const UserListScreen()),
              );
            },
          ),
        const SizedBox(width: 10),
        IconButton( 
          icon: const Icon(Icons.logout),
          tooltip: 'Logout',
          onPressed: onLogout,
        ),
      ],
    );
  }
}
