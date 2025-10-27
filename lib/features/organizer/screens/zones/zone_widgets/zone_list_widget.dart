import 'package:flutter/material.dart';

class ZoneListWidget extends StatelessWidget {
  final List<Map<String, dynamic>> zones;
  final Function(String, Map<String, dynamic>) onZoneTap;
  final Function(String, Map<String, dynamic>) onZoneEdit;
  final Function(String) onZoneDelete;

  const ZoneListWidget({
    super.key,
    required this.zones,
    required this.onZoneTap,
    required this.onZoneEdit,
    required this.onZoneDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (zones.isEmpty) {
      return const Center(
        child: Text(
          'No zones found. Create your first zone!',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: zones.length,
      itemBuilder: (context, index) {
        final zone = zones[index];
        final zoneId = zone['id'] ?? '';
        final zoneName = zone['title'] ?? zone['name'] ?? 'Untitled Zone';
        final description = zone['description'] ?? '';

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
          elevation: 2,
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            title: Text(
              zoneName,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            subtitle: description.isNotEmpty
                ? Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  )
                : null,
            onTap: () => onZoneTap(zoneId, zone),
            trailing: SizedBox(
              width: 100,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, size: 20),
                    onPressed: () => onZoneEdit(zoneId, zone),
                    tooltip: 'Edit Zone',
                    color: Colors.blue,
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, size: 20),
                    onPressed: () => onZoneDelete(zoneId),
                    tooltip: 'Delete Zone',
                    color: Colors.red,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}