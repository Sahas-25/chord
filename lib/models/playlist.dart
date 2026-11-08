import 'package:flutter/material.dart';

/// A playlist stores only song ids (not whole songs).
/// The list is mutable so that user playlists can be edited.
class Playlist {
  Playlist({
    required this.id,
    required this.name,
    required this.color,
    this.description = '',
    List<String>? songIds,
    this.isUserCreated = false,
  }) : songIds = songIds ?? <String>[];

  final String id;
  String name;
  String description;
  final Color color;
  final List<String> songIds;
  final bool isUserCreated;
}
