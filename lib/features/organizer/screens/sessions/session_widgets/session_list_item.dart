import 'package:flutter/material.dart';
import '../../../../models/session_model.dart';

class SessionListItem extends StatelessWidget {
  final SessionModel session;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const SessionListItem({
    super.key,
    required this.session,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(session.title),
      subtitle: Text('Speaker: ${session.speaker}'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: onEdit,
            color: Colors.blue,
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: onDelete,
            color: Colors.red,
          ),
        ],
      ),
      onTap: onTap,
    );
  }
}