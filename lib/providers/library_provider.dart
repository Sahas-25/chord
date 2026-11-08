import 'package:flutter/material.dart';

import '../data/sample_data.dart';
import '../models/playlist.dart';
import '../models/song.dart';

/// Stores liked songs, saved playlists and playlists created by the user.
class LibraryProvider extends ChangeNotifier {
  final List<Playlist> popularPlaylists = SampleData.buildPopularPlaylists();
  final List<Playlist> myPlaylists = [];

  final List<String> _likedIds = ['s1', 's3']; // two liked songs for the demo
  final Set<String> _savedIds = {'p1'}; // saved popular playlists

  static const List<Color> _colors = [
    Color(0xFF7E57C2),
    Color(0xFF26A69A),
    Color(0xFF42A5F5),
    Color(0xFFFF7043),
    Color(0xFFAB47BC),
  ];

  // ---------- liked songs ----------
  List<Song> get likedSongs => _likedIds.map(SampleData.byId).toList();

  bool isLiked(String songId) => _likedIds.contains(songId);

  void toggleLike(String songId) {
    if (!_likedIds.remove(songId)) {
      _likedIds.add(songId);
    }
    notifyListeners();
  }

  // ---------- saved playlists ----------
  bool isSaved(String playlistId) => _savedIds.contains(playlistId);

  void toggleSave(String playlistId) {
    if (!_savedIds.remove(playlistId)) {
      _savedIds.add(playlistId);
    }
    notifyListeners();
  }

  /// Playlists shown in the Library: my own + saved popular ones.
  List<Playlist> get savedPlaylists => [
        ...myPlaylists,
        ...popularPlaylists.where((p) => _savedIds.contains(p.id)),
      ];

  Playlist? findPlaylist(String id) {
    for (final p in [...popularPlaylists, ...myPlaylists]) {
      if (p.id == id) return p;
    }
    return null;
  }

  List<Song> songsOf(Playlist playlist) =>
      playlist.songIds.map(SampleData.byId).toList();

  // ---------- playlist creation / editing ----------
  Playlist createPlaylist(String name) {
    final playlist = Playlist(
      id: 'u${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      description: 'Created by you',
      color: _colors[myPlaylists.length % _colors.length],
      isUserCreated: true,
    );
    myPlaylists.insert(0, playlist);
    notifyListeners();
    return playlist;
  }

  void deletePlaylist(String id) {
    myPlaylists.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  /// Returns false when the song is already in the playlist.
  bool addSongToPlaylist(String playlistId, String songId) {
    final playlist = findPlaylist(playlistId);
    if (playlist == null || playlist.songIds.contains(songId)) return false;
    playlist.songIds.add(songId);
    notifyListeners();
    return true;
  }

  void removeSongFromPlaylist(String playlistId, String songId) {
    findPlaylist(playlistId)?.songIds.remove(songId);
    notifyListeners();
  }
}
