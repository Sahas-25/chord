import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/playlist.dart';
import '../providers/library_provider.dart';
import '../providers/player_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/cover_art.dart';
import '../widgets/mini_player.dart';
import '../widgets/responsive.dart';
import '../widgets/song_tile.dart';

/// Screen 4 - Playlist details and its song list.
class PlaylistScreen extends StatefulWidget {
  const PlaylistScreen({
    super.key,
    required this.playlistId,
    required this.heroTag,
  });

  final String playlistId;
  final String heroTag; // same tag as the card we came from -> Hero animation

  @override
  State<PlaylistScreen> createState() => _PlaylistScreenState();
}

class _PlaylistScreenState extends State<PlaylistScreen> {
  // Remember the last playlist we saw, so the screen does not flash an
  // error while it is closing after the playlist has been deleted.
  Playlist? _lastPlaylist;

  Future<void> _confirmDelete(LibraryProvider library, Playlist playlist) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        title: const Text('Delete playlist?'),
        content: Text('"${playlist.name}" will be removed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok == true && mounted) {
      library.deletePlaylist(playlist.id);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final library = context.watch<LibraryProvider>();
    final found = library.findPlaylist(widget.playlistId);
    if (found != null) _lastPlaylist = found;
    final playlist = found ?? _lastPlaylist;

    if (playlist == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Playlist not found')),
      );
    }

    final songs = library.songsOf(playlist);
    final coverSize = Responsive.isMobile(context) ? 110.0 : 180.0;
    final totalMinutes =
        (songs.fold<int>(0, (sum, s) => sum + s.seconds) / 60).ceil();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Playlist'),
        actions: [
          if (playlist.isUserCreated)
            IconButton(
              tooltip: 'Delete playlist',
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _confirmDelete(library, playlist),
            ),
        ],
      ),
      body: PageContainer(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ----- header: cover + details -----
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: coverSize,
                  height: coverSize,
                  child: CoverArt(
                    color: playlist.color,
                    icon: Icons.queue_music,
                    heroTag: widget.heroTag,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        playlist.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        playlist.description,
                        style: const TextStyle(color: AppColors.textMuted),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${songs.length} songs • $totalMinutes min',
                        style: const TextStyle(color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ----- action buttons -----
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  onPressed: songs.isEmpty
                      ? null
                      : () => context
                          .read<PlayerProvider>()
                          .play(songs.first, queue: songs),
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Play'),
                ),
                if (!playlist.isUserCreated)
                  OutlinedButton.icon(
                    onPressed: () => library.toggleSave(playlist.id),
                    icon: Icon(library.isSaved(playlist.id)
                        ? Icons.bookmark
                        : Icons.bookmark_border),
                    label: Text(
                        library.isSaved(playlist.id) ? 'Saved' : 'Save to library'),
                  ),
              ],
            ),
            const SizedBox(height: 20),

            // ----- songs -----
            if (songs.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Text(
                  'This playlist is empty.\nOpen the ⋮ menu on any song and choose "Add to playlist".',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textMuted),
                ),
              ),
            for (final song in songs)
              SongTile(
                song: song,
                onTap: () =>
                    context.read<PlayerProvider>().play(song, queue: songs),
                onRemove: playlist.isUserCreated
                    ? () => library.removeSongFromPlaylist(playlist.id, song.id)
                    : null,
              ),
          ],
        ),
      ),
      bottomNavigationBar: const MiniPlayer(),
    );
  }
}
