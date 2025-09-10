import 'package:event_management_app1/core/services/session_panel_service.dart';
import 'package:event_management_app1/features/organizer/screens/sessions/models/session_model.dart';
import 'package:event_management_app1/features/organizer/screens/sessions/session_detail_screen.dart';
import 'package:event_management_app1/features/organizer/screens/sessions/session_widgets/create_session_dialog.dart';
import 'package:event_management_app1/features/organizer/screens/sessions/session_widgets/session_list_item.dart';
import 'package:event_management_app1/features/organizer/widgets/delete_confirmation_dialog.dart';
import 'package:flutter/material.dart';

import '../../widgets/panel_header.dart';
import '../zones/zone_widgets/zone_track_filter.dart';

class SessionPanelScreen extends StatefulWidget {
  final String eventId;
  
  const SessionPanelScreen({
    super.key,
    required this.eventId,
  });

  @override
  State<SessionPanelScreen> createState() => _SessionPanelScreenState();
}

class _SessionPanelScreenState extends State<SessionPanelScreen> {
  String? _selectedZoneId;
  String? _selectedTrackId;
  List<Map<String, dynamic>> _zones = [];
  List<Map<String, dynamic>> _tracks = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadZones();
  }

  Future<void> _loadZones() async {
    setState(() => _isLoading = true);
    try {
      final zones = await SessionPanelService.loadZones(widget.eventId);
      setState(() {
        _zones = zones;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading zones: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadTracks(String zoneId) async {
    setState(() {
      _selectedZoneId = zoneId;
      _selectedTrackId = null;
      _tracks = [];
    });

    try {
      final tracks = await SessionPanelService.loadTracks(widget.eventId, zoneId);
      setState(() {
        _tracks = tracks;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading tracks: $e')),
        );
      }
    }
  }

  Future<List<SessionModel>> _getSessionsFuture() async {
    if (_selectedZoneId == null || _selectedTrackId == null) {
      return [];
    }

    final sessionsData = await SessionPanelService.getSessions(
      widget.eventId,
      _selectedZoneId!,
      _selectedTrackId!,
    );
    
    
    return sessionsData.map((sessionMap) {
      return SessionModel.fromMap(sessionMap, sessionMap['id'] ?? '');
    }).toList();
  }

  Future<void> _refreshSessions() async {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                PanelHeader(
                  title: 'Event Sessions',
                  onCreatePressed: _selectedZoneId != null && _selectedTrackId != null
                      ? () => _showCreateSessionDialog()
                      : null,
                  createTooltip: 'Create Session',
                  canCreate: _selectedZoneId != null && _selectedTrackId != null,
                ),
                const SizedBox(height: 4),
                ZoneTrackFilter(
                  selectedZoneId: _selectedZoneId,
                  selectedTrackId: _selectedTrackId,
                  zones: _zones,
                  tracks: _tracks,
                  onZoneChanged: (zoneId) {
                    if (zoneId != null) {
                      _loadTracks(zoneId);
                    } else {
                      setState(() {
                        _selectedZoneId = null;
                        _selectedTrackId = null;
                        _tracks = [];
                      });
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
          const SizedBox(height: 8),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_selectedZoneId == null) {
      return const Center(
        child: Text(
          'Please select a zone to view tracks',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    if (_selectedTrackId == null) {
      return const Center(
        child: Text(
          'Please select a track to view sessions',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return FutureBuilder<List<SessionModel>>(
      future: _getSessionsFuture(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        
        final sessions = snapshot.data ?? [];
        
        if (sessions.isEmpty) {
          return const Center(
            child: Text(
              'No sessions found\nCreate a session to get started',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          );
        }
        
        return ListView.builder(
          itemCount: sessions.length,
          itemBuilder: (context, index) {
            final session = sessions[index];
            return SessionListItem(
              session: session,
              onTap: () => _navigateToSessionDetail(session),
              onEdit: () => _navigateToSessionDetail(session),
              onDelete: () => _handleDeleteSession(session.id),
            );
          },
        );
      },
    );
  }

  void _navigateToSessionDetail(SessionModel session) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SessionDetailScreen(
          eventId: widget.eventId,
          zoneId: _selectedZoneId!,
          trackId: _selectedTrackId!,
          sessionId: session.id,
          session: session, 
        ),
      ),
    );
  }

  void _handleDeleteSession(String sessionId) {
    DeleteConfirmationDialog.show(
      context,
      itemType: 'Session',
      itemName: 'Session',
      onConfirm: () => _deleteSession(sessionId),
    );
  }

  Future<void> _deleteSession(String sessionId) async {
    try {
      await SessionPanelService.deleteSession(
        widget.eventId,
        _selectedZoneId!,
        _selectedTrackId!,
        sessionId,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Session deleted successfully')),
        );
        await _refreshSessions();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting session: $e')),
        );
      }
    }
  }

  void _showCreateSessionDialog() {
    showDialog(
      context: context,
      builder: (context) => CreateSessionDialog(
        eventId: widget.eventId,
        zoneId: _selectedZoneId!,
        trackId: _selectedTrackId!,
        onSessionCreated: _refreshSessions,
      ),
    );
  }
}