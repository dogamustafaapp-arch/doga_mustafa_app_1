import 'package:flutter/material.dart';

import 'app_theme.dart';

/// Maps stored bond score (0–5) to a single accent color — no digits in the UI.
abstract final class BondStrength {
  static const double maxScore = 5;

  static Color colorForScore(int score) {
    final t = (score / maxScore).clamp(0.0, 1.0);
    if (!t.isFinite || t <= 0.001) return AppPalette.ringTrack;
    if (t < 0.5) {
      return Color.lerp(
            const Color(0xFFFB923C),
            const Color(0xFFFBBF24),
            t * 2,
          ) ??
          const Color(0xFFFBBF24);
    }
    return Color.lerp(
          const Color(0xFFFBBF24),
          AppPalette.tealNav,
          (t - 0.5) * 2,
        ) ??
        AppPalette.tealNav;
  }
}
