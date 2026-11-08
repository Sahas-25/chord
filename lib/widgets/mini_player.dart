import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/player_provider.dart';
import '../screens/player_screen.dart';
import '../theme/app_theme.dart';
import 'cover_art.dart';

/// Small bar shown at the bottom while a song is loaded.
/// Tap it to open the full Music Player screen.
class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PlayerProvider>(
      builder: (context, player, _) {
        final song = player.currentSong;
        if (song == null) return const SizedBox.shrink();

        final total = player.duration.inMilliseconds;
        final progress = total == 0
            ? 0.0
            : (player.position.inMilliseconds / total).clamp(0.0, 1.0).toDouble();

        return Material(
          color: AppColors.card,
          child: SafeArea(
            top: false,
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PlayerScreen()),
                );
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  LinearProgressIndicator(
                    value: progress,
                    minHeight: 2,
                    color: AppColors.purple,
                    backgroundColor: AppColors.cardLight,
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      children: [
                        CoverArt(
                          size: 44,
                          radius: 8,
                          color: song.color,
                          heroTag: 'now-playing-cover',
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                song.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                song.genre,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          tooltip: 'Previous',
                          icon: const Icon(Icons.skip_previous),
                          onPressed: player.previous,
                        ),
                        IconButton(
                          tooltip: player.isPlaying ? 'Pause' : 'Play',
                          icon: Icon(
                            player.isPlaying ? Icons.pause : Icons.play_arrow,
                            color: AppColors.purple,
                            size: 30,
                          ),
                          onPressed: player.togglePlayPause,
                        ),
                        IconButton(
                          tooltip: 'Next',
                          icon: const Icon(Icons.skip_next),
                          onPressed: player.next,
                        ),
                      ],
                    ),
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
