import 'package:event_management_app1/core/config/app_theme.dart';
import 'package:event_management_app1/core/services/organizer_event_service.dart';
import 'package:event_management_app1/features/user/widgets/user_widgets/action_buttons.dart';
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
  State<OrganizerEventDetailsScreen> createState() => _OrganizerEventDetailsScreenState();
}

class _OrganizerEventDetailsScreenState extends State<OrganizerEventDetailsScreen> {
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
      setState(() {
        _eventData = result['data']?['event'] ?? 
                    result['data'] ?? 
                    result['event'] ?? 
                    {};
        
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
    final result = await OrganizerEventService.updateEventStatus(widget.eventId, status);
    
    if (result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Event ${status} successfully')),
      );
      _loadEventDetails(); 
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${result['message']}')),
      );
    }
  }

  String _getEventTitle() {
    return _eventData['title'] ?? 
           _eventData['eventTitle'] ?? 
           _eventData['name'] ?? 
           'Event';
  }

  String _getEventDescription() {
    return _eventData['description'] ?? 
           _eventData['eventDescription'] ?? 
           _eventData['desc'] ?? 
           '';
  }

  String _getEventLocation() {
    return _eventData['location'] ?? 
           _eventData['venue'] ?? 
           _eventData['address'] ?? 
           'Location TBD';
  }

  dynamic _getEventDate() {
    return _eventData['date'] ?? 
           _eventData['eventDate'] ?? 
           _eventData['startDate'] ?? 
           _eventData['datetime'] ?? 
           null;
  }

  String _getEventTime() {
    return _eventData['time'] ?? 
           _eventData['eventTime'] ?? 
           _eventData['startTime'] ?? 
           'Time TBD';
  }

  String _formatEventDate(dynamic eventDate) {
    if (eventDate == null) return 'Date TBD';
    try {
      if (eventDate is String) {
        final date = DateTime.tryParse(eventDate);
        if (date != null) {
          final weekdays = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
          final months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
          
          return '${weekdays[date.weekday]}, ${months[date.month - 1]} ${date.day}, ${date.year}';
        }
        return eventDate;
      }
      return eventDate.toString();
    } catch (_) {
      return 'Date TBD';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getEventTitle()),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          if (_eventData['status'] == 'draft')
            IconButton(
              icon: const Icon(Icons.publish),
              onPressed: () => _updateEventStatus('published'),
              tooltip: 'Publish Event',
            ),
          if (_eventData['status'] == 'published')
            IconButton(
              icon: const Icon(Icons.unpublished),
              onPressed: () => _updateEventStatus('draft'),
              tooltip: 'Unpublish Event',
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadEventDetails,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text('Error: $_errorMessage'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getEventTitle(),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      if (_getEventDescription().isNotEmpty) ...[
                        const Text(
                          'Description',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _getEventDescription(),
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                      ],
                      
                      const Text(
                        'Location',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _getEventLocation(),
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      
                      const Text(
                        'Date',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _formatEventDate(_getEventDate()),
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      
                      const Text(
                        'Time',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _getEventTime(),
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      
                      const Divider(height: 32),
                      
                      ActionButtons(
                        eventId: widget.eventId, 
                        eventTitle: _getEventTitle(),
                      ),
                    ],
                  ),
                ),
    );
  }
}