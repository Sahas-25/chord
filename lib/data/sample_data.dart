import 'package:flutter/material.dart';

import '../models/playlist.dart';
import '../models/song.dart';

/// Hard-coded sample data. The audio files in assets/audio are
/// synthesised by tools/generate_audio.py, so they are royalty free.
class SampleData {
  static const List<Song> songs = [
    Song(
      id: 's1',
      title: 'Telugu',
      genre: 'Electronic',
      assetPath: 'audio/track1.wav',
      seconds: 30,
      color: Color(0xFF7E57C2),
    ),
    Song(
      id: 's2',
      title: 'Hindi',
      genre: 'Lofi',
      assetPath: 'audio/track2.wav',
      seconds: 30,
      color: Color(0xFF5C6BC0),
    ),
    Song(
      id: 's3',
      title: 'Tamil',
      genre: 'Acoustic',
      assetPath: 'audio/track3.wav',
      seconds: 30,
      color: Color(0xFF26A69A),
    ),
    Song(
      id: 's4',
      title: 'Kannada',
      genre: 'Electronic',
      assetPath: 'audio/track4.wav',
      seconds: 30,
      color: Color(0xFFAB47BC),
    ),
    Song(
      id: 's5',
      title: 'Malayalam',
      genre: 'Acoustic',
      assetPath: 'audio/track5.wav',
      seconds: 30,
      color: Color(0xFFFF7043),
    ),
    Song(
      id: 's6',
      title: 'English',
      genre: 'Chill',
      assetPath: 'audio/track6.wav',
      seconds: 30,
      color: Color(0xFF42A5F5),
    ),
  ];

  static Song byId(String id) => songs.firstWhere((s) => s.id == id);

  /// Returns fresh playlist objects (a function, not a const list,
  /// because Playlist is mutable).
  static List<Playlist> buildPopularPlaylists() {
    return [
      Playlist(
        id: 'p1',
        name: 'Telugu',
        description: 'Calm tracks to help you concentrate.',
        color: const Color(0xFF5C6BC0),
        songIds: ['s2', 's4', 's1'],
      ),
      Playlist(
        id: 'p2',
        name: 'Hindi',
        description: 'Relax after a long day of lectures.',
        color: const Color(0xFF26A69A),
        songIds: ['s3', 's5', 's6', 's2'],
      ),
      Playlist(
        id: 'p3',
        name: 'Tamil',
        description: 'The most played songs on CHORD.',
        color: const Color(0xFF7E57C2),
        songIds: ['s1', 's6', 's4', 's3'],
      ),
      Playlist(
        id: 'p4',
        name: 'Kannada',
        description: 'Start your day with a good mood.',
        color: const Color(0xFFFF7043),
        songIds: ['s5', 's1', 's6'],
      ),
    ];
  }
}
