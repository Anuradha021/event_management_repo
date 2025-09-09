import 'package:event_management_app1/core/services/zone_service.dart';
import 'package:event_management_app1/features/events/widgets/zone_list_widget.dart';
import 'package:event_management_app1/features/organizer/screens/zones/zone_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:event_management_app1/features/organizer/widgets/create_zone_dialog.dart';
import '../../widgets/panel_header.dart';
import '../../widgets/delete_confirmation_dialog.dart';

class ZonePanel extends StatefulWidget {
  final String eventId;

  const ZonePanel({
    super.key,
    required this.eventId,
  });

  @override
  State<ZonePanel> createState() => _ZonePanelState();
}

class _ZonePanelState extends State<ZonePanel> {
  late Future<List<Map<String, dynamic>>> _zonesFuture;

  @override
  void initState() {
    super.initState();
    _loadZones();
  }

  void _loadZones() {
    setState(() {
      _zonesFuture = ZoneService.getZones(widget.eventId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: PanelHeader(
            title: 'Event Zones',
            onCreatePressed: () => _showCreateZoneDialog(context),
            createTooltip: 'Create Zone',
          ),
        ),
  
        Expanded(
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: _zonesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No zones found'));
              }
              
              return ZoneListWidget( 
                zones: snapshot.data!,
                onZoneTap: (zoneId, data) => _showZoneDetails(context, zoneId, data),
                onZoneEdit: (zoneId, data) => _showZoneDetails(context, zoneId, data),
                onZoneDelete: (zoneId) => _handleDeleteZone(context, zoneId),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showZoneDetails(BuildContext context, String zoneId, Map<String, dynamic> zoneData) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ZoneDetailScreen(
          eventId: widget.eventId,
          zoneId: zoneId,
          zoneData: zoneData,
        ),
      ),
    );
  }

  void _showCreateZoneDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => CreateZoneDialog(
        onCreate: (title, description) => _createZone(context, title, description),
      ),
    );
  }

  Future<void> _createZone(BuildContext context, String title, String description) async {
    if (title.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Zone name is required')),
      );
      return;
    }

    try {
      final result = await ZoneService.createZone(
        widget.eventId,
        title.trim(),
        description.trim(),
      );

      if (result['success']) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Zone created successfully')),
        );
        _loadZones();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${result['message']}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating zone: ${e.toString()}')),
      );
    }
  }

  void _handleDeleteZone(BuildContext context, String zoneId) {
    DeleteConfirmationDialog.show(
      context,
      itemType: 'Zone',
      itemName: 'Zone',
      onConfirm: () => _deleteZone(zoneId),
    );
  }

  Future<void> _deleteZone(String zoneId) async {
    try {
      final result = await ZoneService.deleteZone(widget.eventId, zoneId);
      
      if (result['success']) {
        _loadZones();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Zone deleted successfully')),
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
          SnackBar(content: Text('Error deleting zone: ${e.toString()}')),
        );
      }
    }
  }
}