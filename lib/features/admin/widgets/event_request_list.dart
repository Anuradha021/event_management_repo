import 'package:event_management_app1/core/services/admin_service.dart';
import 'package:event_management_app1/features/admin/screens/event_deatils_screen.dart';
import 'package:flutter/material.dart';

class EventRequestList extends StatefulWidget {
  final String selectedFilter;
  final String searchQuery;

  const EventRequestList({
    super.key,
    required this.selectedFilter,
    required this.searchQuery,
  });

  @override
  State<EventRequestList> createState() => _EventRequestListState();
}

class _EventRequestListState extends State<EventRequestList> {
  List<dynamic> _requests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEventRequests();
  }

  Future<void> _loadEventRequests() async {
    setState(() => _isLoading = true);

    final result = await AdminService.getEventRequests(
      status: widget.selectedFilter == 'all' ? null : widget.selectedFilter,
      search: widget.searchQuery.isEmpty ? null : widget.searchQuery,
    );


    if (result['success']) {
      final requests = result['data']['requests'] ?? [];
      setState(() {
        _requests = requests;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: ${result['message']}")));
    }
  }
  @override
  void didUpdateWidget(EventRequestList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedFilter != widget.selectedFilter ||
        oldWidget.searchQuery != widget.searchQuery) {
      _loadEventRequests();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_requests.isEmpty)
      return const Center(child: Text('No event requests found.'));

    return ListView.builder(
      itemCount: _requests.length,
      itemBuilder: (context, index) {
        final request = _requests[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            title: Text(request['eventTitle'] ?? 'No title'),
            subtitle: Text('Organizer: ${request['organizerEmail'] ?? 'N/A'}'),
            trailing: Icon(Icons.chevron_right, color: Colors.grey[600]),
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => EventDetailsScreen(
                        eventData: request,
                        docId: request['id'],
                      ),
                ),
              );
              _loadEventRequests();
            },
          ),
        );
      },
    );
  }
}
