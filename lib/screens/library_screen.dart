import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/library_provider.dart';
import '../providers/player_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/create_playlist_dialog.dart';
import '../widgets/playlist_card.dart';
import '../widgets/responsive.dart';
import '../widgets/song_tile.dart';

/// Screen 3 - Liked songs and saved playlists (two tabs).
/// It is a StatefulWidget because a TabController needs a State object.
class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _createPlaylist() async {
    final name = await showCreatePlaylistDialog(context);
    if (name == null || !mounted) return;
    context.read<LibraryProvider>().createPlaylist(name);
    _tabController.animateTo(1); // jump to the Playlists tab
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Playlist "$name" created')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final library = context.watch<LibraryProvider>();
    final liked = library.likedSongs;
    final playlists = library.savedPlaylists;

    return PageContainer(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Your Library',
                    style:
                        TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                ),
                FilledButton.icon(
                  onPressed: _createPlaylist,
                  icon: const Icon(Icons.add),
                  label: const Text('New playlist'),
                ),
              ],
            ),
          ),
          TabBar(
            controller: _tabController,
            tabs: const [Tab(text: 'Liked songs'), Tab(text: 'Playlists')],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // ----- Tab 1: liked songs -----
                liked.isEmpty
                    ? const _EmptyMessage('No liked songs yet.\nTap the heart on any song.')
                    : ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: FilledButton.icon(
                              onPressed: () => context
                                  .read<PlayerProvider>()
                                  .play(liked.first, queue: liked),
                              icon: const Icon(Icons.play_arrow),
                              label: const Text('Play all'),
                            ),
                          ),
                          const SizedBox(height: 12),
                          for (final song in liked)
                            SongTile(
                              song: song,
                              onTap: () => context
                                  .read<PlayerProvider>()
                                  .play(song, queue: liked),
                            ),
                        ],
                      ),
                // ----- Tab 2: saved playlists -----
                playlists.isEmpty
                    ? const _EmptyMessage('No saved playlists yet.')
                    : ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          PlaylistGrid(
                            playlists: playlists,
                            heroPrefix: 'library',
                          ),
                        ],
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyMessage extends StatelessWidget {
  const _EmptyMessage(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(color: AppColors.textMuted),
      ),
    );
  }
}
