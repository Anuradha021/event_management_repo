
import 'package:event_management_app1/features/user/widgets/user_widgets/event_card.dart';
import 'package:flutter/material.dart';
import 'package:event_management_app1/core/services/organizer_dashboard_service.dart';


class AssignedEventsSection extends StatefulWidget {
  const AssignedEventsSection({super.key});

  @override
  State<AssignedEventsSection> createState() => _AssignedEventsSectionState();
}

class _AssignedEventsSectionState extends State<AssignedEventsSection> {
  List<Map<String, dynamic>> _events = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadAssignedEvents();
  }

  Future<void> _loadAssignedEvents() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await OrganizerDashboardService.getAssignedEvents();
      
      if (result['success'] == true) {
        
        List<Map<String, dynamic>> events = [];
        
        if (result['data'] != null) {
          events = List<Map<String, dynamic>>.from(result['data'] ?? []);
        }
        
        setState(() {
          _events = events;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = result['message'] ?? 'Failed to load assigned events';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error loading assigned events: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(child: Text(_errorMessage!));
    }

    if (_events.isEmpty) {
      return const Center(child: Text('No events assigned to you'));
    }

    return Column(
      children: _events.map((event) {
        final eventId = event['id'] ?? event['eventId'] ?? 'unknown';
        return EventCard(
          eventId: eventId.toString(),
          eventData: event,
        );
      }).toList(),
    );
  }
}