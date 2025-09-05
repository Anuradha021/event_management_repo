import 'package:event_management_app1/core/config/app_theme.dart';
import 'package:event_management_app1/features/organizer/screens/events/organizer_event_details_screen.dart';
import 'package:event_management_app1/core/services/organizer_dashboard_service.dart';
import 'package:flutter/material.dart';

class AssignedEventListScreen extends StatefulWidget {
  const AssignedEventListScreen({super.key});

  @override
  State<AssignedEventListScreen> createState() =>
      _AssignedEventListScreenState();
}

class _AssignedEventListScreenState extends State<AssignedEventListScreen> {
  List<Map<String, dynamic>> _events = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchAssignedEvents();
  }

  Future<void> _fetchAssignedEvents() async {
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
          _errorMessage = result['message'] ?? 'Failed to load events';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error loading events: $e';
      });
    }
  }

  String _formatDate(dynamic dateString) {
    if (dateString is String) {
      try {
        final date = DateTime.parse(dateString);
        return '${date.day}/${date.month}/${date.year}';
      } catch (_) {
        return 'Invalid date';
      }
    }
    return 'N/A';
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'rejected':
        return Colors.red;
      case 'draft':
        return Colors.grey;
      default:
        return Colors.blue;
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
        title: const Text(
          'My Assigned Events',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchAssignedEvents,
            color: Colors.white,
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
              ? Center(
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
                      onPressed: _fetchAssignedEvents,
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              )
              : _events.isEmpty
              ? const Center(
                child: Text(
                  "No events assigned yet.",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              )
              : RefreshIndicator(
                onRefresh: _fetchAssignedEvents,
                child: ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: _events.length,
                  itemBuilder: (context, index) {
                    final event = _events[index];
                    final status =
                        event['status']?.toString()?.toLowerCase() ?? 'unknown';

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 16,
                      ),
                      elevation: 2,
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.event,
                            color: AppTheme.primaryColor,
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
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            if (event['eventDate'] != null ||
                                event['startDate'] != null)
                              Text(
                                "Date: ${_formatDate(event['eventDate'] ?? event['startDate'])}",
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
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              backgroundColor: _getStatusColor(status),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                            ),
                          ],
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          final eventId =
                              event['id'] ?? event['eventId'] ?? event['_id'];
                          if (eventId != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) => OrganizerEventDetailsScreen(
                                      eventId: eventId.toString(),
                                      eventData: event,
                                    ),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Error: Event ID is missing'),
                              ),
                            );
                          }
                        },
                      ),
                    );
                  },
                ),
              ),
    );
  }
}
