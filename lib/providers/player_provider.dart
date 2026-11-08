import 'dart:async';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

import '../data/sample_data.dart';
import '../models/song.dart';

/// Controls music playback. Screens listen to this class with Provider,
/// so when something changes here (song, position, play/pause) the
/// widgets that depend on it rebuild automatically.
class PlayerProvider extends ChangeNotifier {
  PlayerProvider() {
    _listenToPlayer();
  }

  final AudioPlayer _player = AudioPlayer();
  final List<StreamSubscription<dynamic>> _subscriptions = [];
  final Random _random = Random();

  List<Song> _queue = [];
  int _index = 0;
  Song? _currentSong;
  bool _isPlaying = false;
  bool _shuffle = false;
  bool _repeatOne = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  // Starts with 4 songs so the Home screen is not empty.
  // We always create a NEW list when it changes (see play()).
  List<Song> _recentlyPlayed = SampleData.songs.take(4).toList();

  Song? get currentSong => _currentSong;
  bool get isPlaying => _isPlaying;
  bool get shuffle => _shuffle;
  bool get repeatOne => _repeatOne;
  Duration get position => _position;
  Duration get duration => _duration;
  List<Song> get recentlyPlayed => _recentlyPlayed;

  // ---------- listening to the audio player ----------
  void _listenToPlayer() {
    _subscriptions.add(_player.onPositionChanged.listen((p) {
      _position = p;
      notifyListeners();
    }));
    _subscriptions.add(_player.onDurationChanged.listen((d) {
      if (d > Duration.zero) {
        _duration = d;
        notifyListeners();
      }
    }));
    _subscriptions.add(_player.onPlayerStateChanged.listen((state) {
      _isPlaying = state == PlayerState.playing;
      notifyListeners();
    }));
    _subscriptions.add(_player.onPlayerComplete.listen((_) {
      _onSongFinished();
    }));
  }

  void _onSongFinished() {
    if (_repeatOne && _currentSong != null) {
      play(_currentSong!, queue: _queue);
    } else {
      next(); // go to the next song automatically
    }
  }

  // ---------- public actions ----------
  /// Plays [song]. [queue] is the list the song belongs to (a playlist,
  /// search results ...) so that next/previous know what to play.
  Future<void> play(Song song, {List<Song>? queue}) async {
    if (queue != null) {
      _queue = List<Song>.of(queue);
    } else if (!_queue.any((s) => s.id == song.id)) {
      _queue = List<Song>.of(SampleData.songs);
    }
    _index = _queue.indexWhere((s) => s.id == song.id);
    if (_index < 0) {
      _queue = [song];
      _index = 0;
    }

    _currentSong = song;
    _position = Duration.zero;
    _duration = song.duration;
    _recentlyPlayed = [
      song,
      ..._recentlyPlayed.where((s) => s.id != song.id),
    ].take(8).toList();
    notifyListeners();

    try {
      await _player.play(AssetSource(song.assetPath));
    } catch (e) {
      debugPrint('Could not play ${song.title}: $e');
    }
  }

  Future<void> togglePlayPause() async {
    final song = _currentSong;
    if (song == null) return;
    if (_player.state == PlayerState.playing) {
      await _player.pause();
    } else if (_player.state == PlayerState.paused) {
      await _player.resume();
    } else {
      await play(song, queue: _queue); // stopped or finished
    }
  }

  Future<void> next() async {
    if (_queue.isEmpty) return;
    int nextIndex;
    if (_shuffle && _queue.length > 1) {
      do {
        nextIndex = _random.nextInt(_queue.length);
      } while (nextIndex == _index);
    } else {
      nextIndex = (_index + 1) % _queue.length;
    }
    await play(_queue[nextIndex], queue: _queue);
  }

  Future<void> previous() async {
    if (_queue.isEmpty) return;
    // Like most players: after 3 seconds, "previous" restarts the song.
    if (_position.inSeconds > 3) {
      await seek(Duration.zero);
      return;
    }
    final prevIndex = (_index - 1 + _queue.length) % _queue.length;
    await play(_queue[prevIndex], queue: _queue);
  }

  Future<void> seek(Duration newPosition) async {
    await _player.seek(newPosition);
    _position = newPosition;
    notifyListeners();
  }

  void toggleShuffle() {
    _shuffle = !_shuffle;
    notifyListeners();
  }

  void toggleRepeat() {
    _repeatOne = !_repeatOne;
    notifyListeners();
  }

  @override
  void dispose() {
    for (final s in _subscriptions) {
      s.cancel();
    }
    _player.dispose();
    super.dispose();
  }
}
