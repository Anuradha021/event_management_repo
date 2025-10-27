import 'package:flutter/material.dart';

class TrackUpdateDialog extends StatefulWidget {
  final String currentName;
  final String currentDescription;
  final Future<void> Function(String name, String description) onUpdate;

  const TrackUpdateDialog({
    super.key,
    required this.currentName,
    required this.currentDescription,
    required this.onUpdate,
  });

  @override
  State<TrackUpdateDialog> createState() => _TrackUpdateDialogState();
}

class _TrackUpdateDialogState extends State<TrackUpdateDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _descController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentName);
    _descController = TextEditingController(text: widget.currentDescription);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _handleUpdate() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Track name cannot be empty')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await widget.onUpdate(
        _nameController.text.trim(),
        _descController.text.trim(),
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Track updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating track: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Update Track'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Track Name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _descController,
            decoration: const InputDecoration(
              labelText: 'Description ',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _handleUpdate,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Update'),
        ),
      ],
    );
  }
}
