import 'package:event_management_app1/core/config/app_theme.dart';
import 'package:event_management_app1/core/services/organizer_event_service.dart';
import 'package:event_management_app1/features/organizer/screens/events/widgets/event_detail_card.dart';
import 'package:event_management_app1/features/organizer/screens/events/widgets/action_buttons.dart';
import 'package:flutter/material.dart';

class OrganizerEventDetailsScreen extends StatefulWidget {
  final String eventId;
  final Map<String, dynamic> eventData;

  const OrganizerEventDetailsScreen({
    super.key,
    required this.eventId,
    required this.eventData,
  });

  @override
  State<OrganizerEventDetailsScreen> createState() =>
      _OrganizerEventDetailsScreenState();
}

class _OrganizerEventDetailsScreenState
    extends State<OrganizerEventDetailsScreen> {
  Map<String, dynamic> _eventData = {};
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _eventData = widget.eventData;
    _loadEventDetails();
  }

  Future<void> _loadEventDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await OrganizerEventService.getEventDetails(widget.eventId);

    if (result['success']) {
     
      Map<String, dynamic> eventData;

      if (result['data'] != null && result['data']['success'] == true) {
       
        eventData = result['data']['data'] ?? {};
      } else {
        
        eventData = result['data'] ?? {};
      }

      setState(() {
        _eventData = eventData;
        _isLoading = false;
      });

    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = result['message'];
      });
    }
  }

  Future<void> _updateEventStatus(String status) async {
    final result = await OrganizerEventService.updateEventStatus(
      widget.eventId,
      status,
    );

    if (result['success']) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Event $status successfully')));
      _loadEventDetails();
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${result['message']}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_eventData['title'] ?? _eventData['eventTitle'] ?? 'Event'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          if (_eventData['status'] == 'draft')
            IconButton(
              icon: const Icon(Icons.publish),
              onPressed: () => _updateEventStatus('published'),
              tooltip: 'Publish Event',
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadEventDetails,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
              ? Center(child: Text('Error: $_errorMessage'))
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    EventDetailCard(
                      eventData: _eventData,
                    ),

                    const SizedBox(height: 16),
                    ActionButtons(
                      eventId: widget.eventId,
                      eventTitle:
                          _eventData['title'] ??
                          _eventData['eventTitle'] ??
                          'Event',
                    ),
                  ],
                ),
              ),
    );
  }
}