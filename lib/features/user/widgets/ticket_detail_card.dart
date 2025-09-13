import 'package:event_management_app1/core/utils/date_utils.dart';
import 'package:event_management_app1/features/events/models/ticket_model.dart';
import 'package:event_management_app1/features/organizer/widgets/ticket_widgets/ticket_qr_section.dart';
import 'package:event_management_app1/features/user/widgets/ticket_widgets/download_button.dart';
import 'package:event_management_app1/features/user/widgets/ticket_widgets/ticket_detail_row.dart';
import 'package:flutter/material.dart';

class TicketCard extends StatelessWidget {
  final Ticket ticket;
  final Map<String, dynamic> eventData;

  const TicketCard({
    super.key,
    required this.ticket,
    required this.eventData,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
      
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  ticket.ticketTypeName,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppDateUtils.getStatusColor(ticket.status), 
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    ticket.status.toUpperCase(),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
            TicketDetailRow(label: "Event", value: ticket.eventTitle),
            TicketDetailRow(
                label: "Location", value: eventData['location'] ?? ''),
            TicketDetailRow(
                label: "Date", value: AppDateUtils.formatEventDate(eventData['eventDate'])),
            TicketDetailRow(
                label: "Price", value: "\$${ticket.price.toStringAsFixed(2)}"),
            TicketDetailRow(
                 label: "Purchase Date", value: AppDateUtils.formatPurchaseDate(ticket.purchaseDate)),

            const SizedBox(height: 20),
            TicketQrSection(ticket: ticket),
            const SizedBox(height: 20),
            DownloadButton(ticket: ticket),
          ],
        ),
      ),
    );
  }
}