class StallModel {
  final String id;
  final String name;
  final String description;

  StallModel({
    required this.id,
    required this.name,
    required this.description,
  });

  factory StallModel.fromMap(Map<String, dynamic> data, String documentId) {
    return StallModel(
      id: documentId,
      name: data['name'] ?? 'Unnamed Stall',
      description: data['description'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
    };
  }

  StallModel copyWith({
    String? id,
    String? name,
    String? description,
  }) {
    return StallModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
    );
  }
}