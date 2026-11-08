import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/song.dart';
import '../providers/library_provider.dart';
import '../providers/player_provider.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import 'add_to_playlist_sheet.dart';
import 'cover_art.dart';

/// One row in any song list (Home, Search, Library, Playlist).
class SongTile extends StatelessWidget {
  const SongTile({
    super.key,
    required this.song,
    required this.onTap,
    this.onRemove,
  });

  final Song song;
  final VoidCallback onTap;
  final VoidCallback? onRemove; // only given inside user playlists

  @override
  Widget build(BuildContext context) {
    // context.select rebuilds this tile only when the selected value changes.
    final isCurrent = context
        .select<PlayerProvider, bool>((p) => p.currentSong?.id == song.id);
    final isLiked =
        context.select<LibraryProvider, bool>((l) => l.isLiked(song.id));

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250), // simple animation
        decoration: BoxDecoration(
          color: isCurrent ? AppColors.cardLight : AppColors.card,
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          onTap: onTap,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          leading: CoverArt(size: 48, color: song.color, radius: 8),
          title: Text(
            song.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isCurrent ? AppColors.purple : AppColors.textPrimary,
            ),
          ),
          subtitle: Text(
            '${song.genre} • ${formatDuration(song.duration)}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AppColors.textMuted),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                tooltip: isLiked ? 'Remove from liked songs' : 'Like',
                icon: Icon(
                  isLiked ? Icons.favorite : Icons.favorite_border,
                  color: isLiked ? AppColors.purple : AppColors.textMuted,
                ),
                onPressed: () =>
                    context.read<LibraryProvider>().toggleLike(song.id),
              ),
              PopupMenuButton<String>(
                color: AppColors.cardLight,
                icon: const Icon(Icons.more_vert, color: AppColors.textMuted),
                onSelected: (value) {
                  if (value == 'add') {
                    showAddToPlaylistSheet(context, song);
                  } else if (value == 'remove') {
                    onRemove?.call();
                  }
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(
                    value: 'add',
                    child: Text('Add to playlist'),
                  ),
                  if (onRemove != null)
                    const PopupMenuItem(
                      value: 'remove',
                      child: Text('Remove from playlist'),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
