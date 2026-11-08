import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/song.dart';
import '../providers/library_provider.dart';
import '../providers/player_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/playlist_card.dart';
import '../widgets/responsive.dart';
import '../widgets/section_title.dart';
import '../widgets/song_tile.dart';

/// Screen 1 - Popular playlists + recently played songs.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final library = context.watch<LibraryProvider>();
    final recent =
        context.select<PlayerProvider, List<Song>>((p) => p.recentlyPlayed);

    return PageContainer(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Hello 👋',
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text(
            'What would you like to listen to today?',
            style: TextStyle(color: AppColors.textMuted),
          ),
          const SectionTitle('Popular playlists'),
          PlaylistGrid(
            playlists: library.popularPlaylists,
            heroPrefix: 'home',
          ),
          const SectionTitle('Recently played'),
          for (final song in recent)
            SongTile(
              song: song,
              onTap: () =>
                  context.read<PlayerProvider>().play(song, queue: recent),
            ),
        ],
      ),
    );
  }
}
