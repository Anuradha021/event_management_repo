import 'package:flutter/material.dart';
import '../../../../core/config/app_theme.dart';
import '../../../models/ticket_model.dart';
import '../../../../core/services/ticket_service.dart';
import '../../widgets/ticket_widgets/ticket_detail_card.dart';

class UserTicketsOverviewScreen extends StatelessWidget {
  const UserTicketsOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tickets'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<List<Ticket>>(
        stream: TicketService.getUserTickets(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return _buildError(snapshot.error.toString());
          }

          final tickets = snapshot.data ?? [];
          if (tickets.isEmpty) return _buildEmptyState();

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: tickets.length,
            itemBuilder: (context, index) {
              final ticket = tickets[index];
              
              final defaultEventData = {
                'title': ticket.eventTitle,
                'location': 'Venue details not available',
                'eventDate': _formatPurchaseDate(ticket.purchaseDate),
                'description': 'Event details could not be loaded'
              };
              
              return FutureBuilder<Map<String, dynamic>>(
                future: TicketService.getEventData(ticket.eventId),
                builder: (context, eventSnapshot) {
                  final eventData = (eventSnapshot.data?.isNotEmpty ?? false) 
                      ? eventSnapshot.data! 
                      : defaultEventData;
                  
                  return TicketCard(
                    ticket: ticket,
                    eventData: eventData,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  String _formatPurchaseDate(DateTime purchaseDate) {
    return '${purchaseDate.day}/${purchaseDate.month}/${purchaseDate.year} - Purchased';
  }

  Widget _buildError(String error) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error: $error'),
          ],
        ),
      );

  Widget _buildEmptyState() => const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No tickets purchased',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Your purchased tickets will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
}