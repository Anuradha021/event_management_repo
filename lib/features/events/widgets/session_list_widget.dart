import 'package:flutter/material.dart';

class SessionListWidget extends StatelessWidget {
  final List<Map<String, dynamic>> sessions;
  final Function(String, Map<String, dynamic>, DateTime, DateTime) onSessionTap;
  final Function(String, Map<String, dynamic>, DateTime, DateTime) onSessionEdit;
  final Function(String) onSessionDelete;

  const SessionListWidget({
    super.key,
    required this.sessions,
    required this.onSessionTap,
    required this.onSessionEdit,
    required this.onSessionDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (sessions.isEmpty) {
      return const Center(
        child: Text(
          'No sessions found\nCreate a session to get started',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey),
        ),
      );
    }
    
    return ListView.builder(
      itemCount: sessions.length,
      itemBuilder: (context, index) {
        final session = sessions[index];
        
        DateTime startTime;
        DateTime endTime;
        
        try {
          startTime = session['startTime'] is String 
              ? DateTime.parse(session['startTime'])
              : DateTime.now();
          endTime = session['endTime'] is String
              ? DateTime.parse(session['endTime'])
              : DateTime.now();
        } catch (e) {
          startTime = DateTime.now();
          endTime = DateTime.now().add(const Duration(hours: 1));
        }
        
        return ListTile(
          title: Text(session['title'] ?? 'No Title'),
          subtitle: Text('Speaker: ${session['speaker'] ?? 'Not specified'}'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => onSessionEdit(session['id'], session, startTime, endTime),
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => onSessionDelete(session['id']),
              ),
            ],
          ),
          onTap: () => onSessionTap(session['id'], session, startTime, endTime),
        );
      },
    );
  }
}