import 'package:flutter/material.dart';

class SystemAdminUserCard extends StatelessWidget {
  final String userName;
  final String userEmail;

  const SystemAdminUserCard({
    super.key,
    required this.userName,
    required this.userEmail,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.purple,
          child: const Icon(Icons.admin_panel_settings, color: Colors.white),
        ),
        title: Text(userName),
        subtitle: Text('$userEmail\nSystem Admin'),
        trailing: const Chip(
          label: Text('System Admin'),
          backgroundColor: Colors.purple,
          labelStyle: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
