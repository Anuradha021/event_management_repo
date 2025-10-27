import 'package:event_management_app1/core/services/session_service.dart';
import 'package:event_management_app1/features/models/session_model.dart';
import 'package:event_management_app1/features/organizer/screens/sessions/session_widgets/session_info_card.dart';
import 'package:event_management_app1/features/organizer/screens/sessions/session_widgets/update_session_dialog.dart';
import 'package:event_management_app1/features/organizer/screens/sessions/session_widgets/session_update_button.dart'; // Add this import
import 'package:flutter/material.dart';
import '../../../../core/config/app_theme.dart';

class SessionDetailScreen extends StatefulWidget {
  final String eventId;
  final String zoneId;
  final String trackId;
  final String sessionId;
  final SessionModel session;

  const SessionDetailScreen({
    super.key,
    required this.eventId,
    required this.zoneId,
    required this.trackId,
    required this.sessionId,
    required this.session,
  });

  @override
  State<SessionDetailScreen> createState() => _SessionDetailScreenState();
}

class _SessionDetailScreenState extends State<SessionDetailScreen> {
  late SessionModel _currentSession;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _currentSession = widget.session;
  }

  Future<void> _refreshSessionData() async {
    setState(() => _isLoading = true);
    try {
      final sessionsData = await SessionService.getSessions(
        widget.eventId,
        widget.zoneId,
        widget.trackId,
      );

      final sessionMap = sessionsData.firstWhere(
        (s) => s['id'] == widget.sessionId,
        orElse: () => {},
      );

      if (sessionMap.isNotEmpty && mounted) {
        setState(() {
          _currentSession = SessionModel.fromMap(sessionMap, widget.sessionId);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error refreshing session: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _updateSession(String title, String desc, String speaker, DateTime? startTime, DateTime? endTime) async {
    setState(() => _isLoading = true);
    try {
      final result = await SessionService.updateSession(
        eventId: widget.eventId,
        zoneId: widget.zoneId,
        trackId: widget.trackId,
        sessionId: widget.sessionId,
        title: title,
        description: desc,
        speaker: speaker,
        startTime: startTime,
        endTime: endTime,
      );

      if (result['success']) {
        await _refreshSessionData();
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Session updated successfully')),
          );
        }
      } else {
        throw Exception(result['message']);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating session: $e')),
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        centerTitle: true,
        title: const Text('Session Details',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  SessionInfoCard(
                    title: _currentSession.title,
                    description: _currentSession.description,
                    speaker: _currentSession.speaker,
                    startTime: _currentSession.startTime,
                    endTime: _currentSession.endTime,
                  ),
                  const SizedBox(height: 24),
                  SessionUpdateButton( 
                    onPressed: () => showDialog(
                      context: context,
                      builder: (ctx) => UpdateSessionDialog(
                        currentTitle: _currentSession.title,
                        currentDescription: _currentSession.description,
                        currentSpeaker: _currentSession.speaker,
                        currentStartTime: _currentSession.startTime,
                        currentEndTime: _currentSession.endTime,
                        onUpdate: _updateSession,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}