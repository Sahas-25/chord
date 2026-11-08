import 'package:flutter/material.dart';

/// A single song. All fields are final, so a Song never changes.
class Song {
  const Song({
    required this.id,
    required this.title,
    required this.genre,
    required this.assetPath,
    required this.seconds,
    required this.color,
  });

  final String id;
  final String title;
  final String genre;
  final String assetPath; // path inside the assets folder, e.g. audio/track1.wav
  final int seconds;
  final Color color; // colour of the cover art

  Duration get duration => Duration(seconds: seconds);
}
