import 'package:event_management_app1/core/config/app_theme.dart';
import 'package:event_management_app1/features/user/widgets/user_widgets/assigned_events_section.dart';
import 'package:event_management_app1/features/user/widgets/user_widgets/create_event_request_card.dart';
import 'package:flutter/material.dart';
import 'package:event_management_app1/core/services/organizer_dashboard_service.dart';
import 'package:event_management_app1/core/services/auth_storage_service.dart';

class UserEventsTabScreen extends StatefulWidget {
  const UserEventsTabScreen({super.key});

  @override
  State<UserEventsTabScreen> createState() => _UserEventsTabScreenState();
}

class _UserEventsTabScreenState extends State<UserEventsTabScreen> {
  bool _isOrganizer = false;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkOrganizerStatus();
  }

  Future<void> _checkOrganizerStatus() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final token = await AuthStorageService.getToken();
      if (token == null) {
        setState(() {
          _isOrganizer = false;
          _isLoading = false;
          _errorMessage = 'Not authenticated';
        });
        return;
      }

      final result = await OrganizerDashboardService.getAssignedEvents();
      
      if (result['success'] == true && result['data'] != null) {
        setState(() {
          _isOrganizer = true;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isOrganizer = false;
          _isLoading = false;
          _errorMessage = result['message'] ?? 'Not an organizer';
        });
      }
    } catch (e) {
      setState(() {
        _isOrganizer = false;
        _isLoading = false;
        _errorMessage = 'Error checking status: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Events'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _checkOrganizerStatus,
            tooltip: 'Refresh status',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Error: $_errorMessage',
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _checkOrganizerStatus,
                        child: const Text('Try Again'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const CreateEventRequestCard(),
                      if (_isOrganizer) ...[
                        const SizedBox(height: 24),
                        const Text(
                          'My Assigned Events',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const AssignedEventsSection(),
                      ] else ...[
                        const SizedBox(height: 24),
                        const Text(
                          'Organizer Access',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.event_available,
                                  size: 40,
                                  color: Colors.blue,
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'Become an Event Organizer',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Submit an event request to get approved as an organizer and manage your events.',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
    );
  }
}