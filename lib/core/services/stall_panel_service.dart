import 'package:event_management_app1/core/services/stall_service.dart';
import 'package:event_management_app1/core/services/track_service.dart';
import 'package:event_management_app1/core/services/zone_service.dart';

class StallPanelService {
  static Future<List<Map<String, dynamic>>> loadZones(String eventId) async {
    try {
      return await ZoneService.getZones(eventId);
    } catch (e) {
      throw Exception('Failed to load zones: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> loadTracks(String eventId, String zoneId) async {
    try {
      return await TrackService.getTracks(eventId, zoneId);
    } catch (e) {
      throw Exception('Failed to load tracks: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> getStalls(String eventId, String zoneId, String trackId) async {
    try {
      return await StallApiService.getStalls(eventId, zoneId, trackId);
    } catch (e) {
      throw Exception('Failed to load stalls: $e');
    }
  }

  static Future<void> createStall(String eventId, String zoneId, String trackId, String name, String description) async {
    try {
      await StallApiService.createStall(eventId, zoneId, trackId, name, description);
    } catch (e) {
      throw Exception('Failed to create stall: $e');
    }
  }

  static Future<void> deleteStall(String eventId, String zoneId, String trackId, String stallId) async {
  try {
    await StallApiService.deleteStall(eventId, zoneId, trackId, stallId);
  } catch (e) {
    if (e.toString().contains('HTML response')) {
      throw Exception('Server error: Please check if the stall exists and you have proper permissions');
    }
    throw Exception('Failed to delete stall: $e');
  }
}
}