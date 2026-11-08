import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/song.dart';
import '../providers/library_provider.dart';
import '../theme/app_theme.dart';
import 'create_playlist_dialog.dart';

/// Bottom sheet that lets the user add [song] to one of their playlists.
Future<void> showAddToPlaylistSheet(BuildContext context, Song song) {
  final messenger = ScaffoldMessenger.of(context);

  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.card,
    builder: (sheetContext) {
      return SafeArea(
        child: Consumer<LibraryProvider>(
          builder: (_, library, __) {
            return ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(vertical: 12),
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    'Add to playlist',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.add, color: AppColors.purple),
                  title: const Text('New playlist'),
                  onTap: () async {
                    final name = await showCreatePlaylistDialog(sheetContext);
                    if (name == null) return;
                    final playlist = library.createPlaylist(name);
                    library.addSongToPlaylist(playlist.id, song.id);
                    if (sheetContext.mounted) Navigator.pop(sheetContext);
                    messenger.showSnackBar(
                      SnackBar(content: Text('Added to "$name"')),
                    );
                  },
                ),
                for (final playlist in library.myPlaylists)
                  ListTile(
                    leading: const Icon(Icons.queue_music),
                    title: Text(playlist.name),
                    subtitle: Text('${playlist.songIds.length} songs'),
                    trailing: playlist.songIds.contains(song.id)
                        ? const Icon(Icons.check, color: AppColors.purple)
                        : null,
                    onTap: () {
                      final added =
                          library.addSongToPlaylist(playlist.id, song.id);
                      Navigator.pop(sheetContext);
                      messenger.showSnackBar(SnackBar(
                        content: Text(added
                            ? 'Added to "${playlist.name}"'
                            : 'Already in "${playlist.name}"'),
                      ));
                    },
                  ),
              ],
            );
          },
        ),
      );
    },
  );
}
