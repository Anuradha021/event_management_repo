import 'package:event_management_app1/core/config/app_theme.dart';
import 'package:event_management_app1/features/user/screens/home_screen_widgets/user_screen_widget.dart';
import 'package:flutter/material.dart';
import 'package:event_management_app1/core/services/organizer_dashboard_service.dart';
import 'package:event_management_app1/core/utils/date_utils.dart'; 

class AssignedEventsList extends StatefulWidget {
  final bool showAsSection; 
  final VoidCallback? onRefresh;
  final Function(Map<String, dynamic> event)? onEventTap;
  final bool showAppBar;

  const AssignedEventsList({
    super.key,
    this.showAsSection = false,
    this.onRefresh,
    this.onEventTap,
    this.showAppBar = false,
  });

  @override
  State<AssignedEventsList> createState() => _AssignedEventsListState();
}

class _AssignedEventsListState extends State<AssignedEventsList> {
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
          if (result['data'] is List) {
            events = List<Map<String, dynamic>>.from(result['data']);
          } else if (result['data'] is Map<String, dynamic>) {
            events = [result['data']];
          }
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

  Future<void> _handleRefresh() async {
    await _loadAssignedEvents();
    widget.onRefresh?.call();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.showAppBar) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: AppTheme.primaryColor,
          iconTheme: const IconThemeData(color: Colors.white),
          elevation: 0,
          centerTitle: true,
          title: const Text(
            'My Assigned Events',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
        ),
        body: _buildContent(),
      );
    }
    
    return _buildContent();
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadAssignedEvents,
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    if (_events.isEmpty) {
      return Center(
        child: Text(
          widget.showAsSection ? 'No events assigned to you' : 'No events assigned yet.',
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    final content = widget.showAsSection
        ? Column(
            children: _events.map((event) {
              final eventId = event['id'] ?? event['eventId'] ?? 'unknown';
              return EventCard(
                eventId: eventId.toString(),
                eventData: event,
              );
            }).toList(),
          )
        : RefreshIndicator(
            onRefresh: _handleRefresh,
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: _events.length,
              itemBuilder: (context, index) {
                final event = _events[index];
                return _buildEventListItem(event, context);
              },
            ),
          );

    return widget.showAsSection ? content : Expanded(child: content);
  }

  Widget _buildEventListItem(Map<String, dynamic> event, BuildContext context) {
    final status = event['status']?.toString()?.toLowerCase() ?? 'unknown';
    final eventId = event['id'] ?? event['eventId'] ?? event['_id'];

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.event,
            color: Theme.of(context).primaryColor,
          ),
        ),
        title: Text(
          event['eventTitle']?.toString() ??
              event['title']?.toString() ??
              'Untitled Event',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: _buildEventSubtitle(event, status),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          if (eventId != null) {
            widget.onEventTap?.call(event);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Error: Event ID is missing')),
            );
          }
        },
      ),
    );
  }

  Widget _buildEventSubtitle(Map<String, dynamic> event, String status) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 4),
        if (event['eventDate'] != null || event['startDate'] != null)
          Text(
            "Date: ${AppDateUtils.formatEventDate(event['eventDate'] ?? event['startDate'])}", 
            style: const TextStyle(fontSize: 12),
          ),
        if (event['location'] != null)
          Text(
            "Location: ${event['location']}",
            style: const TextStyle(fontSize: 12),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        const SizedBox(height: 4),
        Chip(
          label: Text(
            status.toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: AppDateUtils.getStatusColor(status), 
          padding: const EdgeInsets.symmetric(horizontal: 8),
        ),
      ],
    );
  }
}