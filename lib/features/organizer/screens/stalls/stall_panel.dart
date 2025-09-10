import 'package:event_management_app1/features/organizer/screens/stalls/stall_detail_screen.dart';
import 'package:flutter/material.dart';
import '../../../../core/services/stall_panel_service.dart';
import '../../widgets/panel_header.dart';
import '../zones/zone_widgets/zone_track_filter.dart';
import 'stall_widgets/stall_list_view.dart';
import '../../widgets/delete_confirmation_dialog.dart';

class StallPanel extends StatefulWidget {
  final String eventId;
  
  const StallPanel({
    super.key,
    required this.eventId,
  });

  @override
  State<StallPanel> createState() => _StallPanelState();
}

class _StallPanelState extends State<StallPanel> {
  String? _selectedZoneId;
  String? _selectedTrackId;
  List<Map<String, dynamic>> _zones = [];
  List<Map<String, dynamic>> _tracks = [];
  final GlobalKey<StallListViewState> _stallListViewKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _loadZones();
  }

  Future<void> _loadZones() async {
    try {
      final zones = await StallPanelService.loadZones(widget.eventId);
      if (!mounted) return;
      
      setState(() {
        _zones = zones;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading zones: $e')),
      );
    }
  }

  Future<void> _loadTracks(String zoneId) async {
    try {
      final tracks = await StallPanelService.loadTracks(widget.eventId, zoneId);
      if (!mounted) return;
      
      setState(() {
        _tracks = tracks;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading tracks: $e')),
      );
    }
  }

  void _refreshStalls() {
    if (_stallListViewKey.currentState != null && mounted) {
      _stallListViewKey.currentState!.refreshStalls();
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
                title: 'Event Stalls',
                onCreatePressed: _selectedZoneId != null && _selectedTrackId != null
                    ? () => _showCreateStallDialog()
                    : null,
                createTooltip: 'Create Stall',
                canCreate: _selectedZoneId != null && _selectedTrackId != null,
              ),
              const SizedBox(height: 16),
              ZoneTrackFilter(
                selectedZoneId: _selectedZoneId,
                selectedTrackId: _selectedTrackId,
                zones: _zones,
                tracks: _tracks,
                onZoneChanged: (zoneId) {
                  setState(() {
                    _selectedZoneId = zoneId;
                    _selectedTrackId = null;
                    _tracks.clear();
                  });
                  if (zoneId != null) {
                    _loadTracks(zoneId);
                  }
                },
                onTrackChanged: (trackId) {
                  setState(() {
                    _selectedTrackId = trackId;
                  });
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: _selectedZoneId != null && _selectedTrackId != null
              ? StallListView(
                  key: _stallListViewKey,
                  eventId: widget.eventId,
                  zoneId: _selectedZoneId!,
                  trackId: _selectedTrackId!,
                  onStallTap: _navigateToStallDetail,
                  onStallEdit: _navigateToStallDetail,
                  onStallDelete: _handleDeleteStall,
                )
              : const Center(
                  child: Text('Please select a zone and track to view stalls'),
                ),
        ),
      ],
    );
  }

  void _navigateToStallDetail(String stallId, Map<String, dynamic> stallData) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StallDetailScreen(
          eventId: widget.eventId,
          zoneId: _selectedZoneId!,
          trackId: _selectedTrackId!,
          stallId: stallId,
          stallData: stallData,
        ),
      ),
    );
  }

  void _handleDeleteStall(String stallId) {
    DeleteConfirmationDialog.show(
      context,
      itemType: 'Stall',
      itemName: 'Stall',
      onConfirm: () => _deleteStall(stallId),
    );
  }

  Future<void> _deleteStall(String stallId) async {
    try {
      await StallPanelService.deleteStall(
        widget.eventId,
        _selectedZoneId!,
        _selectedTrackId!,
        stallId,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Stall deleted successfully')),
        );
        _refreshStalls();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting stall: $e')),
        );
      }
    }
  }

  void _showCreateStallDialog() {
    showDialog(
      context: context,
      builder: (context) => _CreateStallDialog(
        eventId: widget.eventId,
        zoneId: _selectedZoneId!,
        trackId: _selectedTrackId!,
        onStallCreated: _refreshStalls,
      ),
    );
  }
}

class _CreateStallDialog extends StatefulWidget {
  final String eventId;
  final String zoneId;
  final String trackId;
  final VoidCallback onStallCreated;

  const _CreateStallDialog({
    required this.eventId,
    required this.zoneId,
    required this.trackId,
    required this.onStallCreated,
  });

  @override
  State<_CreateStallDialog> createState() => _CreateStallDialogState();
}

class _CreateStallDialogState extends State<_CreateStallDialog> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _handleCreate() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Stall name is required')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await StallPanelService.createStall(
        widget.eventId,
        widget.zoneId,
        widget.trackId,
        _nameController.text.trim(),
        _descController.text.trim(),
      );

      if (mounted) {
        widget.onStallCreated();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Stall created successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating stall: $e')),
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
      title: const Text('Create New Stall'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Stall Name *',
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