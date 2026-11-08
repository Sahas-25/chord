import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/library_provider.dart';
import '../providers/player_provider.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import '../widgets/cover_art.dart';
import '../widgets/responsive.dart';

/// Screen 5 - Music player with controls and a progress slider.
class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  // While the user drags the slider we show the dragged value.
  // It is null when the user is not dragging.
  double? _dragValue;

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerProvider>();
    final song = player.currentSong;

    final appBar = AppBar(
      leading: IconButton(
        tooltip: 'Close',
        icon: const Icon(Icons.keyboard_arrow_down, size: 32),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text('Now playing'),
    );

    if (song == null) {
      return Scaffold(
        appBar: appBar,
        body: const Center(child: Text('No song selected')),
      );
    }

    final width = Responsive.width(context);
    final isWide = width >= 800;
    final maxCover = isWide ? 340.0 : min(width - 64, 300.0);
    // The cover grows when playing and shrinks when paused (AnimatedContainer).
    final coverSize = player.isPlaying ? maxCover : maxCover * 0.85;

    final cover = Center(
      child: SizedBox(
        width: maxCover,
        height: maxCover,
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            width: coverSize,
            height: coverSize,
            child: CoverArt(
              color: song.color,
              radius: 16,
              heroTag: 'now-playing-cover',
            ),
          ),
        ),
      ),
    );

    // ----- slider values -----
    final totalSeconds = max(player.duration.inMilliseconds, 1) / 1000;
    final currentSeconds = (_dragValue ?? player.position.inMilliseconds / 1000)
        .clamp(0.0, totalSeconds)
        .toDouble();

    final isLiked = context
        .select<LibraryProvider, bool>((l) => l.isLiked(song.id));

    final controls = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    song.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    song.genre,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: isLiked ? 'Remove from liked songs' : 'Like',
              iconSize: 28,
              icon: Icon(
                isLiked ? Icons.favorite : Icons.favorite_border,
                color: isLiked ? AppColors.purple : AppColors.textMuted,
              ),
              onPressed: () =>
                  context.read<LibraryProvider>().toggleLike(song.id),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // ----- progress slider -----
        Slider(
          value: currentSeconds,
          min: 0,
          max: totalSeconds,
          onChanged: (value) => setState(() => _dragValue = value),
          onChangeEnd: (value) {
            player.seek(Duration(milliseconds: (value * 1000).round()));
            setState(() => _dragValue = null);
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                formatDuration(
                    Duration(milliseconds: (currentSeconds * 1000).round())),
                style: const TextStyle(color: AppColors.textMuted),
              ),
              Text(
                formatDuration(player.duration),
                style: const TextStyle(color: AppColors.textMuted),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // ----- buttons -----
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              tooltip: 'Shuffle',
              icon: Icon(
                Icons.shuffle,
                color: player.shuffle ? AppColors.purple : AppColors.textMuted,
              ),
              onPressed: player.toggleShuffle,
            ),
            IconButton(
              tooltip: 'Previous',
              iconSize: 36,
              icon: const Icon(Icons.skip_previous),
              onPressed: player.previous,
            ),
            const SizedBox(width: 8),
            Container(
              decoration: const BoxDecoration(
                color: AppColors.purple,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                tooltip: player.isPlaying ? 'Pause' : 'Play',
                iconSize: 40,
                padding: const EdgeInsets.all(12),
                color: Colors.white,
                icon: Icon(player.isPlaying ? Icons.pause : Icons.play_arrow),
                onPressed: player.togglePlayPause,
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              tooltip: 'Next',
              iconSize: 36,
              icon: const Icon(Icons.skip_next),
              onPressed: player.next,
            ),
            IconButton(
              tooltip: 'Repeat this song',
              icon: Icon(
                player.repeatOne ? Icons.repeat_one : Icons.repeat,
                color:
                    player.repeatOne ? AppColors.purple : AppColors.textMuted,
              ),
              onPressed: player.toggleRepeat,
            ),
          ],
        ),
      ],
    );

    return Scaffold(
      appBar: appBar,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: PageContainer(
            maxWidth: 1000,
            child: isWide
                // tablet / desktop: cover on the left, controls on the right
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(child: cover),
                      const SizedBox(width: 32),
                      Expanded(child: controls),
                    ],
                  )
                // phone: everything in one column
                : Column(
                    children: [
                      cover,
                      const SizedBox(height: 24),
                      controls,
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
