import 'package:event_management_app1/core/services/track_service.dart';
import 'package:event_management_app1/features/organizer/screens/tracks/track_widgets/track_update_button.dart';
import 'package:event_management_app1/features/organizer/screens/tracks/track_widgets/track_update_dialog.dart';
import 'package:flutter/material.dart';
import '../zones/zone_widgets/zone_detail_app_bar.dart';
import '../zones/zone_widgets/zone_info_card.dart';


class TrackDetailScreen extends StatefulWidget {
  final String eventId;
  final String zoneId;
  final String trackId;
  final Map<String, dynamic> trackData;

  const TrackDetailScreen({
    super.key,
    required this.eventId,
    required this.zoneId,
    required this.trackId,
    required this.trackData,
  });

  @override
  State<TrackDetailScreen> createState() => _TrackDetailScreenState();
}

class _TrackDetailScreenState extends State<TrackDetailScreen> {
  Map<String, dynamic> _currentTrackData = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _currentTrackData = Map<String, dynamic>.from(widget.trackData);
  }

  Future<void> _refreshTrackData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final tracks = await TrackService.getTracks(widget.eventId, widget.zoneId);
      final track = tracks.firstWhere(
        (track) => track['id'] == widget.trackId,
        orElse: () => {},
      );

      if (track.isNotEmpty && mounted) {
        setState(() {
          _currentTrackData = track;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error refreshing track: $e')),
        );
      }
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
    final trackName = _currentTrackData['title'] ?? _currentTrackData['name'] ?? 'Untitled Track';
    final description = _currentTrackData['description'] ?? 'No description provided';

    return Scaffold(
      appBar: ZoneDetailAppBar(zoneName: trackName),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ZoneInfoCard(
                    zoneName: trackName,
                    description: description,
                  ),
                  const SizedBox(height: 24),
                  TrackUpdateButton( 
                    onPressed: () => _showUpdateDialog(trackName, description),
                  ),
                ],
              ),
            ),
    );
  }

  void _showUpdateDialog(String currentName, String currentDescription) {
    showDialog(
      context: context,
      builder: (context) => TrackUpdateDialog( // Use TrackUpdateDialog instead of ZoneUpdateDialog
        currentName: currentName,
        currentDescription: currentDescription,
        onUpdate: _handleTrackUpdate,
      ),
    );
  }

  Future<void> _handleTrackUpdate(String name, String description) async {
    setState(() => _isLoading = true);
    
    try {
      final result = await TrackService.updateTrack(
        widget.eventId,
        widget.zoneId,
        widget.trackId,
        name,
        description,
      );

      if (result['success']) {
        await _refreshTrackData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Track updated successfully')),
          );
        }
      } else {
        throw Exception(result['message'] ?? 'Failed to update track');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}