// import 'package:event_management_app1/core/config/app_theme.dart';
// import 'package:event_management_app1/core/utils/date_utils.dart';
// import 'package:event_management_app1/features/organizer/screens/events/organizer_event_details_screen.dart';
// import 'package:flutter/material.dart';

// class EventCard extends StatelessWidget {
//   final String eventId;
//   final Map<String, dynamic> eventData;

//   const EventCard({
//     super.key,
//     required this.eventId,
//     required this.eventData,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       margin: const EdgeInsets.only(bottom: 12),
//       elevation: 2,
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Expanded(
//                   child: Text(
                  
//                     eventData['title'] ?? eventData['eventTitle'] ?? 'Event',
//                     style: const TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//                 Container(
//                   padding: const EdgeInsets.symmetric(
//                       horizontal: 8, vertical: 4),
//                   decoration: BoxDecoration(
//                     color: _getStatusColor(eventData['status']),
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Text(
//                     (eventData['status'] ?? 'draft').toString().toUpperCase(),
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 10,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ],
//             ),

//             const SizedBox(height: 8),

  
//             if (eventData['description'] != null || eventData['eventDescription'] != null) ...[
//               Text(
//                 eventData['description'] ?? eventData['eventDescription'] ?? '',
//                 maxLines: 2,
//                 overflow: TextOverflow.ellipsis,
//                 style: TextStyle(color: Colors.grey[600], fontSize: 14),
//               ),
//               const SizedBox(height: 8),
//             ],

//             Row(
//               children: [
//                 Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
//                 const SizedBox(width: 4),
//                 Expanded(
//                   child: Text(
//                     eventData['location'] ?? 'Location TBD',
//                     style: TextStyle(color: Colors.grey[600], fontSize: 12),
//                   ),
//                 ),
//               ],
//             ),

//             const SizedBox(height: 4),

//             Row(
//               children: [
//                 Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
//                 const SizedBox(width: 4),
//                 Text(
//                    AppDateUtils.formatEventDate(eventData['date'] ?? eventData['eventDate']),
//                   style: TextStyle(color: Colors.grey[600], fontSize: 12),
//                 ),
//               ],
//             ),

//             const SizedBox(height: 12),

//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => OrganizerEventDetailsScreen(
//                         eventId: eventId,
//                         eventData: eventData,
//                       ),
//                     ),
//                   );
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: AppTheme.primaryColor,
//                   foregroundColor: Colors.white,
//                   padding: const EdgeInsets.symmetric(vertical: 8),
//                 ),
//                 child: const Text('Manage Event'),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Color _getStatusColor(String? status) {
//     switch (status?.toLowerCase()) {
//       case 'published':
//         return Colors.green;
//       case 'pending':
//         return Colors.orange;
//       case 'rejected':
//         return Colors.red;
//       default:
//         return Colors.grey;
//     }
//   }
// }