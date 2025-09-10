import 'package:event_management_app1/core/services/zone_service.dart';
import 'package:flutter/material.dart';
import 'zone_widgets/zone_detail_app_bar.dart';
import 'zone_widgets/zone_info_card.dart';
import 'zone_widgets/zone_update_button.dart';
import 'zone_widgets/zone_update_dialog.dart';

class ZoneDetailScreen extends StatefulWidget {
  final String eventId;
  final String zoneId;
  final Map<String, dynamic> zoneData;

  const ZoneDetailScreen({
    super.key,
    required this.eventId,
    required this.zoneId,
    required this.zoneData,
  });

  @override
  State<ZoneDetailScreen> createState() => _ZoneDetailScreenState();
}

class _ZoneDetailScreenState extends State<ZoneDetailScreen> {
  Map<String, dynamic> _currentZoneData = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _currentZoneData = Map<String, dynamic>.from(widget.zoneData);
  }

  Future<void> _refreshZoneData() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final zones = await ZoneService.getZones(widget.eventId);
      final zone = zones.firstWhere(
        (zone) => zone['id'] == widget.zoneId,
        orElse: () => {},
      );
      
      if (zone.isNotEmpty && mounted) {
        setState(() {
          _currentZoneData = zone;
        });
      }
    } catch (e) {
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final zoneName = _currentZoneData['title'] ?? _currentZoneData['name'] ?? 'Untitled Zone';
    final description = _currentZoneData['description'] ?? 'No description provided';

    return Scaffold(
      appBar: ZoneDetailAppBar(zoneName: zoneName),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ZoneInfoCard(
                    zoneName: zoneName,
                    description: description,
                  ),
                  const SizedBox(height: 24),
                  ZoneUpdateButton(
                    onPressed: () => _showUpdateDialog(zoneName, description),
                  ),
                ],
              ),
            ),
    );
  }

  void _showUpdateDialog(String currentName, String currentDescription) {
    showDialog(
      context: context,
      builder: (context) => ZoneUpdateDialog(
        currentName: currentName,
        currentDescription: currentDescription,
        onUpdate: _handleZoneUpdate,
      ),
    );
  }

  Future<void> _handleZoneUpdate(String name, String description) async {
    final result = await ZoneService.updateZone(
      widget.eventId,
      widget.zoneId,
      name,
      description,
    );
    
    if (result['success']) {
      await _refreshZoneData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Zone updated successfully')),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${result['message']}')),
        );
      }
    }
  }
}