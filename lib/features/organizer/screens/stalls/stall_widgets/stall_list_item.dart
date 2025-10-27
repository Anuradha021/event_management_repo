import 'package:event_management_app1/core/config/app_theme.dart';
import 'package:flutter/material.dart';


class StallListItem extends StatelessWidget {
  final Map<String, dynamic> stallData;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const StallListItem({
    super.key,
    required this.stallData,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.store),
        ),
        title: Text(
          stallData['name']?.toString() ?? 'Unnamed Stall',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          stallData['description']?.toString() ?? 'No description',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (onEdit != null)
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: onEdit,
                tooltip: 'Edit Stall',
                color: Colors.blue,
              ),
            if (onDelete != null)
              IconButton(
                icon: const Icon(Icons.delete,),
                onPressed: onDelete,
                tooltip: 'Delete Stall',
                color: Colors.red,
              ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
