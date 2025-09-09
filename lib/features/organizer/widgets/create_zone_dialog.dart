import 'package:flutter/material.dart';

class CreateZoneDialog extends StatefulWidget {
  final Function(String, String) onCreate;

  const CreateZoneDialog({super.key, required this.onCreate});

  @override
  State<CreateZoneDialog> createState() => _CreateZoneDialogState();
}

class _CreateZoneDialogState extends State<CreateZoneDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _descController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create New Zone'),
      contentPadding: const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 24.0),
      content: SizedBox(
        width: 300,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Zone Name *',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => widget.onCreate(_titleController.text, _descController.text),
          child: const Text('Create'),
        ),
      ],
    );
  }
}
