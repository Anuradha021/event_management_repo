import 'package:flutter/material.dart';
import '../../../../core/config/app_theme.dart';
import '../../../models/ticket_model.dart';
import '../../../../core/services/ticket_service.dart';
import '../../widgets/ticket_widgets/ticket_detail_card.dart';

class CustomerTicketDetailsScreen extends StatefulWidget {
  final String eventId;
  final String eventTitle;
  final Map<String, dynamic> eventData;

  const CustomerTicketDetailsScreen({
    super.key,
    required this.eventId,
    required this.eventTitle,
    required this.eventData,
  });

  @override
  State<CustomerTicketDetailsScreen> createState() =>
      _CustomerTicketDetailsScreenState();
}

class _CustomerTicketDetailsScreenState
    extends State<CustomerTicketDetailsScreen> {
  late Future<List<Ticket>> _ticketsFuture;

  @override
  void initState() {
    super.initState();
    _loadTickets();
  }

  void _loadTickets() {
    setState(() {
      _ticketsFuture = _getUserTicketsForEventFuture(widget.eventId);
    });
  }

  void _refreshTickets() {
    _loadTickets();
  }

  Future<List<Ticket>> _getUserTicketsForEventFuture(String eventId) async {
    try {
      
      final result = await TicketService.getUserTicketsForEvent(eventId).first;
      
      return result;
    } catch (e) {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Tickets - ${widget.eventTitle}'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshTickets,
          ),
        ],
      ),
      body: FutureBuilder<List<Ticket>>(
        future: _ticketsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
           
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text("Error: ${snapshot.error}"),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _refreshTickets,
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            );
          }

          final tickets = snapshot.data ?? [];
         

          if (tickets.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.receipt_long, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'No tickets found for this event',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'All purchased tickets will appear here.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _refreshTickets,
                    child: const Text('Refresh'),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);  
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Buy Tickets'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              _refreshTickets();
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: tickets.length,
              itemBuilder: (context, index) {
                final ticket = tickets[index];
               
                return TicketCard(
                  ticket: ticket,
                  eventData: widget.eventData,
                );
              },
            ),
          );
        },
      ),
    );
  }
}