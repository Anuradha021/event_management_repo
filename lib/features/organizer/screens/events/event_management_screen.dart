import 'package:event_management_app1/features/organizer/screens/zones/zone_panel.dart';
import 'package:event_management_app1/features/organizer/screens/sessions/session_panel_screen.dart';
import 'package:event_management_app1/features/organizer/screens/stalls/stall_panel.dart';
import 'package:event_management_app1/core/config/app_theme.dart';
import 'package:event_management_app1/features/organizer/screens/tickets/organizer_tickets_screen.dart';
import 'package:event_management_app1/core/services/event_management_service.dart';
import 'package:flutter/material.dart';
import 'package:event_management_app1/features/organizer/screens/tracks/track_panel.dart';

class EventManagementScreen extends StatefulWidget {
  final String eventId;
  final VoidCallback? onEventPublished;

  EventManagementScreen({
    super.key,
    required this.eventId,
    this.onEventPublished,
  }) : assert(eventId.isNotEmpty);

  @override
  State<EventManagementScreen> createState() => _EventManagementScreenState();
}

class _EventManagementScreenState extends State<EventManagementScreen> {
  int _activeTabIndex = 0;
  final PageController _pageController = PageController();
  Key _refreshKey = UniqueKey();
  bool _isPublishing = false;

  void _refreshAllData() {
    setState(() {
      _refreshKey = UniqueKey();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Refreshing all data...'),
        duration: Duration(seconds: 1),
      ),
    );
  }
  Future<void> _publishEvent() async {
    if (widget.eventId.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error: No event ID available'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Publish Event'),
        content: const Text(
          'Are you sure you want to publish this event? Once published, it will be visible to all users.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.successColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Publish'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isPublishing = true);

    try {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 16),
                Text('Publishing event...'),
              ],
            ),
            duration: Duration(seconds: 30),
          ),
        );
      }

      final result = await EventManagementService.publishEvent(widget.eventId);

      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        
        if (result['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Event published successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          _refreshAllData();
          if (widget.onEventPublished != null) {
            widget.onEventPublished!();
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${result['message']}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error publishing event: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isPublishing = false);
      }
    }
  }

  Widget _buildTabNavigation() {
    return Container(
      margin: const EdgeInsets.all(AppTheme.spacingM),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Row(
        children: [
          _buildTabButton(0, Icons.map_outlined, 'Zones'),
          _buildTabButton(1, Icons.timeline_outlined, 'Tracks'),
          _buildTabButton(2, Icons.schedule_outlined, 'Session'),
          _buildTabButton(3, Icons.store_outlined, 'Stalls'),
          _buildTabButton(4, Icons.confirmation_number_outlined, 'Tickets'),
        ],
      ),
    );
  }

  Widget _buildTabButton(int index, IconData icon, String label) {
    final isActive = _activeTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => _activeTabIndex = index);
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.all(2),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            gradient: isActive ? AppTheme.primaryGradient : null,
            color: isActive ? null : Colors.transparent,
            borderRadius: BorderRadius.circular(AppTheme.radiusM),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: AppTheme.primaryColor.withAlpha(80),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isActive ? Colors.white : AppTheme.textSecondary,
                size: 22,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  color: isActive ? Colors.white : AppTheme.textSecondary,
                  fontSize: 12,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Event Management'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_outlined),
            onPressed: _refreshAllData,
            tooltip: 'Refresh All Data',
          ),
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: IconButton(
              icon: _isPublishing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.publish_outlined),
              onPressed: _isPublishing ? null : _publishEvent,
              tooltip: 'Publish Event',
              style: IconButton.styleFrom(
                backgroundColor: AppTheme.successColor.withAlpha(25),
                foregroundColor: AppTheme.successColor,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildTabNavigation(),
          Expanded(
            child: PageView(
              key: _refreshKey,
              controller: _pageController,
              onPageChanged: (index) => setState(() => _activeTabIndex = index),
              children: [
                ZonePanel(eventId: widget.eventId),
                TrackPanel(eventId: widget.eventId),
                SessionPanelScreen(eventId: widget.eventId),
                StallPanel(eventId: widget.eventId),
                OrganizerTicketsScreen(
                  eventId: widget.eventId,
                  eventTitle: 'Event Tickets',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}