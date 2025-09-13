class Ticket {
  final String id;
  final String eventId;
  final String eventTitle;
  final String ticketTypeId;
  final String ticketTypeName;
  final String userId;
  final String userName;
  final String userEmail;
  final String userPhone;
  final double price;
  final DateTime purchaseDate;
  final String qrCode;
  final bool isUsed;
  final String status;
  final DateTime? usedAt;

  Ticket({
    required this.id,
    required this.eventId,
    required this.eventTitle,
    required this.ticketTypeId,
    required this.ticketTypeName,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.userPhone,
    required this.price,
    required this.purchaseDate,
    required this.qrCode,
    required this.isUsed,
    required this.status,
    this.usedAt,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    
    DateTime _parseDate(dynamic dateValue) {
      if (dateValue == null) return DateTime.now();
      
      if (dateValue is String) {
        return DateTime.parse(dateValue);
      }
      
      if (dateValue is Map<String, dynamic>) {
       
        if (dateValue.containsKey('_seconds')) {
          final seconds = dateValue['_seconds'] as int;
          final nanoseconds = dateValue['_nanoseconds'] as int;
          return DateTime.fromMillisecondsSinceEpoch(seconds * 1000 + (nanoseconds ~/ 1000000));
        }
      }
      
      return DateTime.now();
    }

  
    String _parseString(dynamic value, [String defaultValue = '']) {
      if (value == null) return defaultValue;
      if (value is String) return value.isEmpty ? defaultValue : value;
      return value.toString();
    }

    double _parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    return Ticket(
      id: _parseString(json['id'] ?? json['_id'], ''),
      eventId: _parseString(json['eventId'], ''),
      eventTitle: _parseString(json['eventTitle'], ''),
      ticketTypeId: _parseString(json['ticketTypeId'], ''),
      ticketTypeName: _parseString(json['ticketTypeName'], ''),
      userId: _parseString(json['userId'], ''),
      userName: _parseString(json['userName'], 'User'),
      userEmail: _parseString(json['userEmail'], ''),
      userPhone: _parseString(json['userPhone'], ''),
      price: _parseDouble(json['price']),
      purchaseDate: _parseDate(json['purchaseDate']),
      qrCode: _parseString(json['qrCode'], ''),
      isUsed: json['isUsed'] ?? json['status'] == 'used' ?? false,
      status: _parseString(json['status'], 'active'),
      usedAt: json['usedAt'] != null ? _parseDate(json['usedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'eventId': eventId,
      'eventTitle': eventTitle,
      'ticketTypeId': ticketTypeId,
      'ticketTypeName': ticketTypeName,
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'userPhone': userPhone,
      'price': price,
      'purchaseDate': purchaseDate.toIso8601String(),
      'qrCode': qrCode,
      'isUsed': isUsed,
      'status': status,
      'usedAt': usedAt?.toIso8601String(),
    };
  }
}

class TicketType {
  final String id;
  final String eventId;
  final String name;
  final String description;
  final double price;
  final int totalQuantity;
  final int soldQuantity;
  final int availableQuantity;
  final bool isSoldOut;
  final bool isActive;

  TicketType({
    required this.id,
    required this.eventId,
    required this.name,
    required this.description,
    required this.price,
    required this.totalQuantity,
    required this.soldQuantity,
    required this.availableQuantity,
    required this.isSoldOut,
     required this.isActive,
  });

  int get remainingQuantity => availableQuantity;

  factory TicketType.fromJson(Map<String, dynamic> json) {
    String _parseString(dynamic value, [String defaultValue = '']) {
      if (value == null) return defaultValue;
      if (value is String) return value.isEmpty ? defaultValue : value;
      return value.toString();
    }

    double _parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    int _parseInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is double) return value.toInt();
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    bool _parseBool(dynamic value) {
      if (value == null) return false;
      if (value is bool) return value;
      if (value is String) return value.toLowerCase() == 'true';
      if (value is int) return value != 0;
      return false;
    }

    return TicketType(
      id: _parseString(json['id'], ''),
      eventId: _parseString(json['eventId'], ''),
      name: _parseString(json['name'], ''),
      description: _parseString(json['description'], ''),
      price: _parseDouble(json['price']),
      totalQuantity: _parseInt(json['totalQuantity']),
      soldQuantity: _parseInt(json['soldQuantity']),
      availableQuantity: _parseInt(json['availableQuantity']),
      isSoldOut: _parseBool(json['isSoldOut']),
       isActive: _parseBool(json['isActive']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'eventId': eventId,
      'name': name,
      'description': description,
      'price': price,
      'totalQuantity': totalQuantity,
      'soldQuantity': soldQuantity,
      'availableQuantity': availableQuantity,
      'isSoldOut': isSoldOut,
      'isActive': isActive,
    };
  }
}