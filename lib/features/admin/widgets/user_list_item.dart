import 'package:flutter/material.dart';
import 'package:event_management_app1/core/services/auth_storage_service.dart';
import 'package:event_management_app1/features/admin/widgets/system_admin_user_card.dart';
import 'package:event_management_app1/features/admin/widgets/regular_user_card.dart';

class UserListItem extends StatelessWidget {
  final dynamic user;
  final VoidCallback onUserUpdated;

  const UserListItem({
    super.key,
    required this.user,
    required this.onUserUpdated,
  });

  @override
  Widget build(BuildContext context) {
    final currentUserId = AuthStorageService.getCurrentUserId();
    final userId = user['id'] ?? '';
    final userEmail = user['email'] ?? 'No Email';
    final isSystemAdmin =
        user['isSystemAdmin'] == true || userEmail == 'admin21@event.com';
    final isCurrentUser = currentUserId == userId;

    if (isSystemAdmin || isCurrentUser) {
      return SystemAdminUserCard(
        userName: user['name'] ?? 'Unnamed',
        userEmail: userEmail,
      );
    }

    return RegularUserCard(user: user, onUserUpdated: onUserUpdated);
  }
}
