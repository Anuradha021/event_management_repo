class SessionModel {
  final String id;
  final String title;
  final String description;
  final String speaker;
  final DateTime startTime;
  final DateTime endTime;

  SessionModel({
    required this.id,
    required this.title,
    required this.description,
    required this.speaker,
    required this.startTime,
    required this.endTime,
  });

  factory SessionModel.fromMap(Map<String, dynamic> data, String documentId) {
 DateTime parseDateTime(dynamic dateTime) {
      if (dateTime == null) return DateTime.now();
      
      if (dateTime is DateTime) {
        return dateTime;
      }
      
      if (dateTime is String) {
        return DateTime.parse(dateTime);
      }
  
      if (dateTime.runtimeType.toString().contains('Timestamp')) {
        return dateTime.toDate();
      }
      
      return DateTime.now();
    }

    return SessionModel(
      id: documentId,
      title: data['title'] ?? 'No Title',
      description: data['description'] ?? '',
      speaker: data['speaker'] ?? 'Not Specified',
      startTime: parseDateTime(data['startTime']),
      endTime: parseDateTime(data['endTime']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'speaker': speaker,
      'startTime': startTime,
      'endTime': endTime,
    };
  }

  SessionModel copyWith({
    String? id,
    String? title,
    String? description,
    String? speaker,
    DateTime? startTime,
    DateTime? endTime,
  }) {
    return SessionModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      speaker: speaker ?? this.speaker,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
    );
  }
}