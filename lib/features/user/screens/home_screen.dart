import 'package:event_management_app1/core/services/event_service.dart';
import 'package:event_management_app1/features/user/widgets/user_widgets/user_screen_widget.dart';
import 'package:event_management_app1/features/user/screens/home_screen_widgets/category_filter.dart';
import 'package:event_management_app1/features/user/screens/home_screen_widgets/search_bar.dart';
import 'package:flutter/material.dart';
import '../../../core/config/app_theme.dart';

class UnifiedHomeScreen extends StatefulWidget {
  const UnifiedHomeScreen({super.key});

  @override
  State<UnifiedHomeScreen> createState() => _UnifiedHomeScreenState();
}

class _UnifiedHomeScreenState extends State<UnifiedHomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'All';
  List<dynamic> _events = [];
  bool _isLoading = true;
  String? _errorMessage;

  final List<String> _categories = [
    'All', 'Technology', 'Business', 'Arts', 'Sports',
    'Education', 'Health', 'Music', 'Food', 'Other'
  ];

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
  setState(() {
    _isLoading = true;
    _errorMessage = null;
  });

  final result = await EventService.getPublishedEvents(
    search: _searchQuery.isEmpty ? null : _searchQuery,
    category: _selectedCategory == 'All' ? null : _selectedCategory,
  );

  if (result['success'] == true) {
  
    setState(() {
      _events = result['data']['events'] ?? [];
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

  List<dynamic> _filterEvents(List<dynamic> events) {
    return events.where((event) {
      final title = (event['eventTitle'] ?? '').toString().toLowerCase();
      final description = (event['eventDescription'] ?? '').toString().toLowerCase();
      
      final isTestEvent = title.contains('test') ||
                         title.contains('dynamic ticketing') ||
                         description.contains('test') ||
                         description.contains('dynamic ticketing');

      return !isTestEvent;
    }).toList();
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
              _loadEvents(); 
            },
          ),
          CategoryFilter(
            categories: _categories, 
            selectedCategory: _selectedCategory,
            onCategorySelected: (category) {
              setState(() => _selectedCategory = category);
              _loadEvents(); 
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