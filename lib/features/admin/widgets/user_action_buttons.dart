import 'package:flutter/material.dart';
import 'package:event_management_app1/core/services/admin_service.dart';

class UserActionButtons extends StatelessWidget {
  final String userId;
  final String userName;
  final bool isAdmin;
  final bool isOrganizer;
  final VoidCallback onUserUpdated;

  const UserActionButtons({
    super.key,
    required this.userId,
    required this.userName,
    required this.isAdmin,
    required this.isOrganizer,
    required this.onUserUpdated,
  });

  Future<void> _promoteToAdmin(BuildContext context) async {
    final result = await AdminService.updateUserRole(userId, role: 'admin');
    if (result['success']) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("User promoted to Admin")));
      onUserUpdated();
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: ${result['message']}")));
    }
  }

  Future<void> _demoteFromAdmin(BuildContext context) async {
    final result = await AdminService.updateUserRole(userId, role: 'user');
    if (result['success']) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Admin demoted to User")));
      onUserUpdated();
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: ${result['message']}")));
    }
  }

  Future<void> _promoteToOrganizer(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Assign as Organizer'),
          content: Text(
            'Are you sure you want to assign $userName as an Organizer?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text(
                'Confirm',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      final result = await AdminService.updateUserRole(
        userId,
        isOrganizer: true,
      );
      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$userName has been assigned as Organizer')),
        );
        onUserUpdated();
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${result['message']}')));
      }
    }
  }

  Future<void> _demoteFromOrganizer(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Remove Organizer Role'),
          content: Text(
            'Are you sure you want to remove $userName from Organizer role?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text(
                'Remove',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      final result = await AdminService.updateUserRole(
        userId,
        isOrganizer: false,
      );
      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$userName has been removed from Organizer role'),
          ),
        );
        onUserUpdated();
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${result['message']}')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      child: Wrap(
        spacing: 4,
        runSpacing: 4,
        alignment: WrapAlignment.end,
        children: [
          
          SizedBox(
            width: 78,
            child:
                isAdmin
                    ? ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 6,
                        ),
                        minimumSize: const Size(0, 28),
                      ),
                      onPressed: () => _demoteFromAdmin(context),
                      child: const Text(
                        "Remove Admin",
                        style: TextStyle(color: Colors.white, fontSize: 10),
                        textAlign: TextAlign.center,
                      ),
                    )
                    : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 6,
                        ),
                        minimumSize: const Size(0, 28),
                      ),
                      onPressed: () => _promoteToAdmin(context),
                      child: const Text(
                        "Make Admin",
                        style: TextStyle(fontSize: 10),
                        textAlign: TextAlign.center,
                      ),
                    ),
          ),

          SizedBox(
            width: 78,
            child:
                isOrganizer
                    ? ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 6,
                        ),
                        minimumSize: const Size(0, 28),
                      ),
                      onPressed: () => _demoteFromOrganizer(context),
                      child: const Text(
                        "Remove Org",
                        style: TextStyle(color: Colors.white, fontSize: 10),
                        textAlign: TextAlign.center,
                      ),
                    )
                    : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 6,
                        ),
                        minimumSize: const Size(0, 28),
                      ),
                      onPressed: () => _promoteToOrganizer(context),
                      child: const Text(
                        "Make Org",
                        style: TextStyle(color: Colors.white, fontSize: 10),
                        textAlign: TextAlign.center,
                      ),
                    ),
          ),
        ],
      ),
    );
  }
}
