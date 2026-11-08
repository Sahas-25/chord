import 'package:flutter/material.dart';

/// A coloured rounded square with a music icon (we use no image files).
/// If [size] is null the widget fills the space its parent gives it,
/// so the parent must give it a fixed size (SizedBox, Expanded ...).
/// If [heroTag] is given, the cover takes part in a Hero animation.
class CoverArt extends StatelessWidget {
  const CoverArt({
    super.key,
    required this.color,
    this.size,
    this.radius = 12,
    this.icon = Icons.music_note,
    this.heroTag,
  });

  final Color color;
  final double? size;
  final double radius;
  final IconData icon;
  final String? heroTag;

  @override
  Widget build(BuildContext context) {
    final box = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final side = constraints.biggest.shortestSide;
          return Center(
            child: Icon(
              icon,
              color: Colors.white70,
              size: side.isFinite ? side * 0.45 : 24,
            ),
          );
        },
      ),
    );

    if (heroTag == null) return box;
    return Hero(tag: heroTag!, child: box);
  }
}
