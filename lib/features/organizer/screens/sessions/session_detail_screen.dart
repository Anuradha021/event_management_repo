import 'package:event_management_app1/features/organizer/screens/sessions/session_info_card.dart';
import 'package:event_management_app1/features/organizer/screens/sessions/update_session_dialog.dart';
import 'package:flutter/material.dart';
import 'package:event_management_app1/core/config/app_theme.dart';
import 'package:event_management_app1/core/services/session_service.dart';

class SessionDetailScreen extends StatefulWidget {
  final String eventId;
  final String zoneId;
  final String trackId;
  final String sessionId;
  final Map<String, dynamic> sessionData;
  final DateTime startTime;
  final DateTime endTime;

  const SessionDetailScreen({
    super.key,
    required this.eventId,
    required this.zoneId,
    required this.trackId,
    required this.sessionId,
    required this.sessionData,
    required this.startTime,
    required this.endTime,
  });

  @override
  State<SessionDetailScreen> createState() => _SessionDetailScreenState();
}

class _SessionDetailScreenState extends State<SessionDetailScreen> {
  Map<String, dynamic> _currentSessionData = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _currentSessionData = Map<String, dynamic>.from(widget.sessionData);
  }

  Future<void> _refreshSessionData() async {
    setState(() => _isLoading = true);
    try {
      final sessions = await SessionService.getSessions(
        widget.eventId,
        widget.zoneId,
        widget.trackId,
      );
      
      final session = sessions.firstWhere(
        (s) => s['id'] == widget.sessionId,
        orElse: () => {},
      );

      if (session.isNotEmpty && mounted) {
        setState(() => _currentSessionData = session);
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

  Future<void> _updateSession(String title, String desc, String speaker) async {
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
    final title = _currentSessionData['title'] ?? 'No Title';
    final description = _currentSessionData['description'] ?? 'No Description';
    final speaker = _currentSessionData['speaker'] ?? 'Not specified';

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
                    title: title,
                    description: description,
                    speaker: speaker,
                    startTime: widget.startTime,
                    endTime: widget.endTime,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => showDialog(
                        context: context,
                        builder: (ctx) => UpdateSessionDialog(
                          currentTitle: title,
                          currentDescription: description,
                          currentSpeaker: speaker,
                          onUpdate: _updateSession,
                        ),
                      ),
                      icon: const Icon(Icons.edit),
                      label: const Text('Update Session'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}