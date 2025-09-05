import 'package:flutter/material.dart';

class TrackListWidget extends StatelessWidget {
  final List<Map<String, dynamic>> tracks;
  final Function(String, Map<String, dynamic>) onTrackTap;
  final Function(String, Map<String, dynamic>) onTrackEdit;
  final Function(String) onTrackDelete;

  const TrackListWidget({
    super.key,
    required this.tracks,
    required this.onTrackTap,
    required this.onTrackEdit,
    required this.onTrackDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (tracks.isEmpty) {
      return const Center(
        child: Text(
          'No tracks found. Create your first track!',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: tracks.length,
      itemBuilder: (context, index) {
        final track = tracks[index];
        final trackId = track['id'] ?? '';
        final trackName = track['title'] ?? track['name'] ?? 'Untitled Track';
        final description = track['description'] ?? '';

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
          elevation: 2,
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.deepPurple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.timeline, color: Colors.deepPurple),
            ),
            title: Text(
              trackName,
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
            onTap: () => onTrackTap(trackId, track),
            trailing: SizedBox(
              width: 80,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, size: 20),
                    onPressed: () => onTrackEdit(trackId, track),
                    tooltip: 'Edit Track',
                    color: Colors.blue,
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, size: 20),
                    onPressed: () => onTrackDelete(trackId),
                    tooltip: 'Delete Track',
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