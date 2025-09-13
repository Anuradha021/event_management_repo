import 'package:flutter/material.dart';
import 'package:event_management_app1/core/services/session_service.dart';


class CreateSessionDialog extends StatefulWidget {
  final String eventId;
  final String zoneId;
  final String trackId;
  final Future<void> Function() onSessionCreated;

  const CreateSessionDialog({
    super.key,
    required this.eventId,
    required this.zoneId,
    required this.trackId,
    required this.onSessionCreated,
  });

  @override
  State<CreateSessionDialog> createState() => _CreateSessionDialogState();
}

class _CreateSessionDialogState extends State<CreateSessionDialog> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _speakerController = TextEditingController();
  
  DateTime? _startTime;
  DateTime? _endTime;
  bool _isLoading = false;

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
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (time != null && mounted) {
        setState(() {
          _startTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
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
      initialDate: _startTime!,
      firstDate: _startTime!,
      lastDate: _startTime!.add(const Duration(days: 7)),
    );

    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_startTime!.add(const Duration(hours: 1))),
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

 Future<void> _handleCreate() async {
  if (_titleController.text.trim().isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Session title is required')),
    );
    return;
  }

  if (_startTime == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Start time is required')),
    );
    return;
  }

  if (_endTime == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('End time is required')),
    );
    return;
  }

  setState(() => _isLoading = true);

  try {
    final result = await SessionService.createSession(
      eventId: widget.eventId,
      zoneId: widget.zoneId,
      trackId: widget.trackId,
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      speaker: _speakerController.text.trim(),
      startTime: _startTime!,
      endTime: _endTime!,
    );

    if (result['success'] == true) {
      if (mounted) {
        Navigator.pop(context);
        widget.onSessionCreated();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Session created successfully')),
        );
      }
    } else {
      throw Exception(result['message'] ?? 'Failed to create session');
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating session: $e')),
      );
    }
  } finally {
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }
}

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return 'Not selected';
    return dateTime.toIso8601String();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create New Session'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Session Title *',
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
            TextField(
              controller: _speakerController,
              decoration: const InputDecoration(
                labelText: 'Speaker',
                border: OutlineInputBorder(),
              ),
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
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _handleCreate,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Create'),
        ),
      ],
    );
  }
}