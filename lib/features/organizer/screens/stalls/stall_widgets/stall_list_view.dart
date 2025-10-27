import 'package:event_management_app1/core/services/stall_service.dart';
import 'package:flutter/material.dart';

import 'empty_state.dart';
import 'stall_list_item.dart';

class StallListView extends StatefulWidget {
  final String eventId;
  final String zoneId;
  final String trackId;
  final Function(String stallId, Map<String, dynamic> stallData) onStallTap;
  final Function(String stallId, Map<String, dynamic> stallData) onStallEdit;
  final Function(String stallId) onStallDelete;

  const StallListView({
    super.key,
    required this.eventId,
    required this.zoneId,
    required this.trackId,
    required this.onStallTap,
    required this.onStallEdit,
    required this.onStallDelete,
  });

  @override
  StallListViewState createState() => StallListViewState();
}

class StallListViewState extends State<StallListView> {
  late Future<List<Map<String, dynamic>>> _stallsFuture;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStalls();
  }

  @override
  void didUpdateWidget(StallListView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.zoneId != widget.zoneId || oldWidget.trackId != widget.trackId) {
      _loadStalls();
    }
  }

  void refreshStalls() {
    _loadStalls();
  }

  void _loadStalls() {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    _stallsFuture = StallApiService.getStalls(
      widget.eventId,
      widget.zoneId,
      widget.trackId,
    );

    _stallsFuture.then((_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }).catchError((_) {
      if (!mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _stallsFuture,
      builder: (context, snapshot) {
        if (_isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error: ${snapshot.error}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadStalls,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const CompactEmptyState(
            icon: Icons.store_outlined,
            title: 'No stalls yet',
            subtitle: 'Tap + to create your first stall',
          );
        }

        final stalls = snapshot.data!;

        return RefreshIndicator(
          onRefresh: () async {
            _loadStalls();
            await _stallsFuture;
          },
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: stalls.length,
            itemBuilder: (context, index) {
              final stall = stalls[index];
              final stallId = stall['id']?.toString() ?? stall['_id']?.toString() ?? index.toString();

              return StallListItem(
                stallData: stall,
                onTap: () => widget.onStallTap(stallId, stall),
                onEdit: () => widget.onStallEdit(stallId, stall),
                onDelete: () => widget.onStallDelete(stallId),
              );
            },
          ),
        );
      },
    );
  }
}
