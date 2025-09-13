import 'package:flutter/material.dart';

class UpdateSessionDialog extends StatefulWidget {
  final String currentTitle;
  final String currentDescription;
  final String currentSpeaker;
  final DateTime? currentStartTime;
  final DateTime? currentEndTime;
  final Future<void> Function(String title, String desc, String speaker, DateTime? startTime, DateTime? endTime) onUpdate;

  const UpdateSessionDialog({
    super.key,
    required this.currentTitle,
    required this.currentDescription,
    required this.currentSpeaker,
    required this.currentStartTime,
    required this.currentEndTime,
    required this.onUpdate,
  });

  @override
  State<UpdateSessionDialog> createState() => _UpdateSessionDialogState();
}

class _UpdateSessionDialogState extends State<UpdateSessionDialog> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _speakerController = TextEditingController();
  DateTime? _startTime;
  DateTime? _endTime;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.currentTitle;
    _descController.text = widget.currentDescription;
    _speakerController.text = widget.currentSpeaker;
    _startTime = widget.currentStartTime;
    _endTime = widget.currentEndTime;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _speakerController.dispose();
    super.dispose();
  }

  Future<void> _selectStartTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _startTime ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_startTime ?? DateTime.now()),
      );

      if (time != null && mounted) {
        setState(() {
          _startTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
         
          if (_endTime != null && _endTime!.isBefore(_startTime!)) {
            _endTime = null;
          }
        });
      }
    }
  }

  Future<void> _selectEndTime() async {
    if (_startTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select start time first')),
      );
      return;
    }

    final date = await showDatePicker(
      context: context,
      initialDate: _endTime ?? _startTime!,
      firstDate: _startTime!,
      lastDate: _startTime!.add(const Duration(days: 7)),
    );

    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_endTime ?? _startTime!.add(const Duration(hours: 1))),
      );

      if (time != null && mounted) {
        final endTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
        
        if (endTime.isAfter(_startTime!)) {
          setState(() {
            _endTime = endTime;
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('End time must be after start time')),
          );
        }
      }
    }
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return 'Not selected';
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
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
        _startTime,
        _endTime,
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
          : SingleChildScrollView(
            child: Column(
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
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: _selectStartTime,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.access_time),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Start Time *', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                Text(_formatDateTime(_startTime)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: _selectEndTime,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.access_time),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('End Time *', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                Text(_formatDateTime(_endTime)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
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