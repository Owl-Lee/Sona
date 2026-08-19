import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/track.dart';

class TrackArtwork extends StatelessWidget {
  const TrackArtwork({
    super.key,
    required this.track,
    this.size = 48,
    this.borderRadius = 13,
  });

  final Track? track;
  final double size;
  final double borderRadius;

  static const _palettes = <List<Color>>[
    [Color(0xFF375A4B), AppColors.mint],
    [Color(0xFF40366B), AppColors.lavender],
    [Color(0xFF693D3A), AppColors.coral],
    [Color(0xFF234D66), Color(0xFF82D8FF)],
    [Color(0xFF664F24), Color(0xFFFFD778)],
  ];

  @override
  Widget build(BuildContext context) {
    final seed =
        track?.contentHash.codeUnits.fold<int>(0, (a, b) => a + b) ?? 0;
    final palette = _palettes[seed % _palettes.length];
    final initial = _artworkInitial(track?.title);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: palette,
        ),
        boxShadow: [
          BoxShadow(
            color: palette.last.withValues(alpha: 0.13),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.94),
          fontSize: size * 0.38,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  String _artworkInitial(String? title) {
    if (title == null || title.trim().isEmpty) return '♫';
    // Skip filename punctuation such as 《》, brackets and quotes. Those were
    // becoming accidental "logos" on imported song artwork.
    for (final character in title.trim().characters) {
      if (RegExp(r'[A-Za-z0-9\u3400-\u9FFF]').hasMatch(character)) {
        return character.toUpperCase();
      }
    }
    return '♫';
  }
}
