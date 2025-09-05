import 'package:flutter/material.dart';
import '../../../../core/services/session_panel_service.dart';

class SessionFilterState extends ChangeNotifier {
  String? _selectedZoneId;
  String? _selectedTrackId;
  List<Map<String, dynamic>> _zones = [];
  List<Map<String, dynamic>> _tracks = [];
  bool _isLoading = false;
  String? _errorMessage;

  String? get selectedZoneId => _selectedZoneId;
  String? get selectedTrackId => _selectedTrackId;
  List<Map<String, dynamic>> get zones => _zones;
  List<Map<String, dynamic>> get tracks => _tracks;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get canCreateSession => _selectedZoneId != null && _selectedTrackId != null;
  bool get hasZones => _zones.isNotEmpty;
  bool get hasTracks => _tracks.isNotEmpty;

  Future<void> initialize(String eventId) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      _zones = await SessionPanelService.loadZones(eventId);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error loading data: $e';
      _zones = [];
      _tracks = [];
      _selectedZoneId = null;
      _selectedTrackId = null;
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> onZoneChanged(String eventId, String? zoneId) async {
    _selectedZoneId = zoneId;
    _selectedTrackId = null;
    _tracks = [];
    notifyListeners();

    if (zoneId != null) {
      try {
        _tracks = await SessionPanelService.loadTracks(eventId, zoneId);
        notifyListeners();
      } catch (e) {
        _errorMessage = 'Error loading tracks: $e';
        _tracks = [];
        _selectedTrackId = null;
        notifyListeners();
      }
    }
  }

  void onTrackChanged(String? trackId) {
    _selectedTrackId = trackId;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}