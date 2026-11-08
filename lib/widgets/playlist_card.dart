import 'package:flutter/material.dart';

import '../models/playlist.dart';
import '../screens/playlist_screen.dart';
import '../theme/app_theme.dart';
import 'cover_art.dart';

/// A rounded card showing a playlist cover and name. Tap to open it.
class PlaylistCard extends StatelessWidget {
  const PlaylistCard({
    super.key,
    required this.playlist,
    required this.heroPrefix,
  });

  final Playlist playlist;
  final String heroPrefix; // makes the Hero tag unique for each screen

  @override
  Widget build(BuildContext context) {
    final heroTag = '$heroPrefix-playlist-${playlist.id}';

    return Material(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PlaylistScreen(
                playlistId: playlist.id,
                heroTag: heroTag,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: CoverArt(
                  color: playlist.color,
                  icon: Icons.queue_music,
                  radius: 10,
                  heroTag: heroTag,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                playlist.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                '${playlist.songIds.length} songs',
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Responsive grid: the number of columns changes with the screen width
/// because each card may be at most 200 pixels wide.
class PlaylistGrid extends StatelessWidget {
  const PlaylistGrid({
    super.key,
    required this.playlists,
    required this.heroPrefix,
  });

  final List<Playlist> playlists;
  final String heroPrefix;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: playlists.length,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 200,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemBuilder: (_, i) =>
          PlaylistCard(playlist: playlists[i], heroPrefix: heroPrefix),
    );
  }
}
