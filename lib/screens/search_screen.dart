import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/sample_data.dart';
import '../models/song.dart';
import '../providers/player_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/responsive.dart';
import '../widgets/section_title.dart';
import '../widgets/song_tile.dart';

/// Screen 2 - Search songs.
/// StatefulWidget: the text typed by the user is the "state" of this screen.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<Song> get _results {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return SampleData.songs;
    return SampleData.songs.where((s) {
      return s.title.toLowerCase().contains(q) ||
          s.genre.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final songs = _results;

    return PageContainer(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Search',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            onChanged: (value) => setState(() => _query = value),
            decoration: AppTheme.inputDecoration(
              hint: 'Search songs',
              icon: Icons.search,
              suffix: _query.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Clear',
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        _controller.clear();
                        setState(() => _query = '');
                      },
                    ),
            ),
          ),
          if (songs.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: Text(
                  'No songs found',
                  style: TextStyle(color: AppColors.textMuted),
                ),
              ),
            )
          else ...[
            SectionTitle(_query.trim().isEmpty ? 'Browse all songs' : 'Results'),
            for (final song in songs)
              SongTile(
                song: song,
                onTap: () =>
                    context.read<PlayerProvider>().play(song, queue: songs),
              ),
          ],
        ],
      ),
    );
  }
}
