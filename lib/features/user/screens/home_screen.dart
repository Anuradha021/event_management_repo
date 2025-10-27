import 'package:event_management_app1/core/services/event_service.dart';
import 'package:event_management_app1/features/user/screens/home_screen_widgets/user_screen_widget.dart';
import 'package:event_management_app1/features/user/screens/home_screen_widgets/search_bar.dart';
import 'package:flutter/material.dart';
import '../../../core/config/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<dynamic> _events = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    loadEvents();
  }

  Future<void> loadEvents() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await EventService.getPublishedEvents(
      search: _searchQuery.isEmpty ? null : _searchQuery,
    );

    if (result['success'] == true) {
      List<dynamic> filteredEvents = (result['data']['events'] ?? []).where((event) {
        final title = (event['eventTitle'] ?? '').toString().toLowerCase();
        final description = (event['eventDescription'] ?? '').toString().toLowerCase();
        
        final isTestEvent = title.contains('test') ||
                           title.contains('dynamic ticketing') ||
                           description.contains('test') ||
                           description.contains('dynamic ticketing');

        return !isTestEvent;
      }).toList();
      
      setState(() {
        _events = filteredEvents;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = result['message'] ?? 'Failed to load events';
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Events'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          SearchBarWidget(
            controller: _searchController,
            onChanged: (value) {
              setState(() => _searchQuery = value.toLowerCase());
              loadEvents(); 
            },
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(child: Text('Error: $_errorMessage'))
                    : _events.isEmpty
                        ? const Center(child: Text('No events available'))
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _events.length,
                            itemBuilder: (context, index) {
                              final event = _events[index];
                              return EventCard(
                                eventId: event['id'],
                                eventData: event,
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}