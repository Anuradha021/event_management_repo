import 'package:flutter/material.dart';
import 'package:event_management_app1/features/admin/widgets/user_action_buttons.dart';

class RegularUserCard extends StatelessWidget {
  final dynamic user;
  final VoidCallback onUserUpdated;

  const RegularUserCard({
    super.key,
    required this.user,
    required this.onUserUpdated,
  });

  @override
  Widget build(BuildContext context) {
    final userName = user['name'] ?? 'Unnamed';
    final userEmail = user['email'] ?? 'No Email';
    final role = user['role'] ?? 'USER';
    final isAdmin = role == 'ADMIN' || role == 'SYSTEM_ADMIN';
    final isOrganizer = user['isOrganizer'] == true;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor:
              isAdmin
                  ? Colors.red
                  : isOrganizer
                  ? Colors.green
                  : Colors.blue,
          child: Icon(
            isAdmin
                ? Icons.security
                : isOrganizer
                ? Icons.event
                : Icons.person,
            color: Colors.white,
          ),
        ),
        title: Text(userName),
        subtitle: Text(
          '$userEmail\n${isAdmin
              ? 'Admin'
              : isOrganizer
              ? 'Organizer'
              : 'User'}',
        ),
        trailing: UserActionButtons(
          userId: user['id'] ?? '',
          userName: userName,
          isAdmin: isAdmin,
          isOrganizer: isOrganizer,
          onUserUpdated: onUserUpdated,
        ),
      ),
    );
  }
}
