import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppDateUtils {

  static String formatEventDate(dynamic eventDate, {bool fullFormat = false}) {
    if (eventDate == null) return 'Date TBD';

    try {
      DateTime date;
      if (eventDate is String) {
        try {
          date = DateTime.parse(eventDate);
        } catch (_) {
          return eventDate; 
        }
      } else if (eventDate is Timestamp) {
        date = eventDate.toDate();
      } else if (eventDate is DateTime) {
        date = eventDate;
      } else {
        return 'Date TBD';
      }

      if (fullFormat) {
        return DateFormat('EEEE, MMMM dd, yyyy').format(date);
      } else {
        return DateFormat('dd/MM/yyyy').format(date);
      }
    } catch (_) {
      return 'Date TBD';
    }
  }

  static String formatDateTime(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
  }

  static String formatPurchaseDate(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  static String formatTime(dynamic timeData) {
    if (timeData == null) return 'Time TBD';

    try {
      DateTime time;
      if (timeData is String) {
        time = DateTime.parse(timeData);
      } else if (timeData is Timestamp) {
        time = timeData.toDate();
      } else if (timeData is DateTime) {
        time = timeData;
      } else {
        return 'Time TBD';
      }

      return DateFormat('h:mm a').format(time);
    } catch (_) {
      return 'Time TBD';
    }
  }

  static Color getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'published':
      case 'active':
      case 'approved':
        return Colors.green;
      case 'draft':
      case 'pending':
        return Colors.orange;
      case 'cancelled':
      case 'rejected':
      case 'used':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  static DateTime? parseDate(dynamic dateData) {
    if (dateData == null) return null;

    try {
      if (dateData is String) {
        return DateTime.tryParse(dateData);
      } else if (dateData is Timestamp) {
        return dateData.toDate();
      } else if (dateData is DateTime) {
        return dateData;
      }
    } catch (_) {
      return null;
    }
    return null;
  }
}
