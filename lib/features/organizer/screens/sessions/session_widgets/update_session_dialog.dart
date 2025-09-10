import 'package:flutter/material.dart';

class UpdateSessionDialog extends StatefulWidget {
  final String currentTitle;
  final String currentDescription;
  final String currentSpeaker;
  final Future<void> Function(String title, String desc, String speaker) onUpdate;

  const UpdateSessionDialog({
    super.key,
    required this.currentTitle,
    required this.currentDescription,
    required this.currentSpeaker,
    required this.onUpdate,
  });

  @override
  State<UpdateSessionDialog> createState() => _UpdateSessionDialogState();
}

class _UpdateSessionDialogState extends State<UpdateSessionDialog> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _speakerController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.currentTitle;
    _descController.text = widget.currentDescription;
    _speakerController.text = widget.currentSpeaker;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _speakerController.dispose();
    super.dispose();
  }

  Future<void> _handleUpdate() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Session title cannot be empty')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await widget.onUpdate(
        _titleController.text.trim(),
        _descController.text.trim(),
        _speakerController.text.trim(),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
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
      title: const Text('Update Session'),
      content: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Session Title',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _speakerController,
                  decoration: const InputDecoration(
                    labelText: 'Speaker Name',
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
      actions: _isLoading
          ? []
          : [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: _handleUpdate,
                child: const Text('Update'),
              ),
            ],
    );
  }
}