import 'package:event_management_app1/core/services/track_service.dart';
import 'package:event_management_app1/core/services/zone_service.dart';
import 'package:event_management_app1/features/organizer/screens/tracks/track_widgets/track_list_widget.dart';
import 'package:event_management_app1/features/organizer/screens/tracks/track_detail_screen.dart';
import 'package:flutter/material.dart';
import '../../widgets/panel_header.dart';
import '../zones/zone_widgets/zone_dropdown.dart';

import '../../../../core/widgets/delete_confirmation_dialog.dart';

class TrackPanel extends StatefulWidget {
  final String eventId;

  const TrackPanel({
    super.key,
    required this.eventId,
  });

  @override
  State<TrackPanel> createState() => _TrackPanelState();
}

class _TrackPanelState extends State<TrackPanel> {
  String? _selectedZoneId;
  List<Map<String, dynamic>> _zones = [];
  late Future<List<Map<String, dynamic>>> _tracksFuture;

  @override
  void initState() {
    super.initState();
    
     _tracksFuture = Future.value([]); 
    _loadZones();
  }

  Future<void> _loadZones() async {
    try {
      final zones = await ZoneService.getZones(widget.eventId);
      if (mounted) {
        setState(() {
          _zones = zones;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading zones: $e')),
        );
      }
    }
  }

  void _loadTracks() {
    if (_selectedZoneId != null && _selectedZoneId!.isNotEmpty) {
      setState(() {
        _tracksFuture = TrackService.getTracks(widget.eventId, _selectedZoneId!)
            .then((tracks) {
          return tracks;
        }).catchError((error) {
          throw error;
        });
      });
    } else {
      setState(() {
        _tracksFuture = Future.value([]);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              PanelHeader(
                title: 'Event Tracks',
                onCreatePressed: _selectedZoneId != null
                    ? () => _showCreateTrackDialog()
                    : null,
                createTooltip: 'Create Track',
                canCreate: _selectedZoneId != null,
              ),
              const SizedBox(height: 12),
              if (_zones.isNotEmpty)
                ZoneDropdown(
                  selectedZoneId: _selectedZoneId,
                  zones: _zones,
                  onChanged: (zoneId) {
                    setState(() {
                      _selectedZoneId = zoneId;
                    });
                    _loadTracks();
                  },
                ),
            ],
          ),
        ),
        Expanded(
          child: _selectedZoneId != null
              ? _buildTracksList()
              : const Center(
                  child: Text('Please select a zone to view tracks'),
                ),
        ),
      ],
    );
  }

  Widget _buildTracksList() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _tracksFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error: ${snapshot.error}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadTracks,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }
        
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.timeline, size: 48, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No tracks found',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                Text(
                  'Create your first track for this zone!',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          );
        }
        
        return TrackListWidget(
          tracks: snapshot.data!,
          onTrackTap: (trackId, data) => _navigateToTrackDetail(trackId, data),
          onTrackEdit: (trackId, data) => _navigateToTrackDetail(trackId, data),
          onTrackDelete: (trackId) => _handleDeleteTrack(trackId),
        );
      },
    );
  }

  void _navigateToTrackDetail(String trackId, Map<String, dynamic> trackData) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TrackDetailScreen(
          eventId: widget.eventId,
          zoneId: _selectedZoneId!,
          trackId: trackId,
          trackData: trackData,
        ),
      ),
    );
    _loadTracks();
  }

  void _handleDeleteTrack(String trackId) {
    DeleteConfirmationDialog.show(
      context,
      itemType: 'Track',
      itemName: 'Track',
      onConfirm: () => _deleteTrack(trackId),
    );
  }

  Future<void> _deleteTrack(String trackId) async {
  try {
    final result = await TrackService.deleteTrack(
      widget.eventId,
      _selectedZoneId!,
      trackId,
    );
    
    if (result['success']) {
      _loadTracks();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Track deleted successfully')),
        );
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${result['message']}')),
        );
      }
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting track: ${e.toString()}')),
      );
    }
  }
}

  void _showCreateTrackDialog() {
    final zone = _zones.firstWhere(
      (z) => z['id'] == _selectedZoneId,
      orElse: () => {'title': 'Unnamed Zone', 'name': 'Unnamed Zone'},
    );

    showDialog(
      context: context,
      builder: (context) => _CreateTrackDialog(
        eventId: widget.eventId,
        zoneId: _selectedZoneId!,
        zoneName: zone['title'] ?? zone['name'] ?? 'Unnamed Zone',
        onTrackCreated: _loadTracks,
      ),
    );
  }
}

class _CreateTrackDialog extends StatefulWidget {
  final String eventId;
  final String zoneId;
  final String zoneName;
  final VoidCallback onTrackCreated;

  const _CreateTrackDialog({
    required this.eventId,
    required this.zoneId,
    required this.zoneName,
    required this.onTrackCreated,
  });

  @override
  State<_CreateTrackDialog> createState() => _CreateTrackDialogState();
}

class _CreateTrackDialogState extends State<_CreateTrackDialog> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _handleCreate() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Track title is required')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await TrackService.createTrack(
        widget.eventId,
        widget.zoneId,
        _titleController.text.trim(),
        _descController.text.trim(),
      );

      if (result['success']) {
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Track created successfully')),
          );
          widget.onTrackCreated();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${result['message']}')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating track: ${e.toString()}')),
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
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Create New Track'),
          const SizedBox(height: 4),
          Text(
            'For Zone: ${widget.zoneName}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Track Title *',
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