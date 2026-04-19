import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Radar-style bond map: you at the center, higher scores sit closer.
///
/// **Hardcoded samples** for UI preview only — replace with real data later.
class BondsMapPreview extends StatelessWidget {
  const BondsMapPreview({super.key});

  static final List<_MapSample> _samples = _buildDemoSamples();

  /// 30 placeholder avatars for layout preview (replace with real bonds later).
  static List<_MapSample> _buildDemoSamples() {
    return List.generate(30, (i) {
      final hue = (i * 137.508) % 360.0;
      final start = HSVColor.fromAHSV(1, hue, 0.48, 0.76).toColor();
      final end = HSVColor.fromAHSV(1, (hue + 26) % 360, 0.52, 0.9).toColor();
      final letter = String.fromCharCode(65 + (i % 26));
      final suffix = 1 + i ~/ 26;
      return _MapSample(
        name: '$letter$suffix',
        score: (i % 5) + 1,
        avatarGradStart: start,
        avatarGradEnd: end,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final mq = MediaQuery.sizeOf(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        var maxW = constraints.maxWidth;
        var maxH = constraints.maxHeight;
        // Parent should be a fixed-height SizedBox (see HomePage map sliver).
        if (!maxW.isFinite || maxW <= 0) {
          maxW = mq.width - 32;
        }
        if (!maxH.isFinite || maxH <= 0) {
          maxH = mq.height * 0.52;
        }
        final h = math.max(240.0, maxH);
        final side = math.max(200.0, math.min(maxW, h));
        final cx = side / 2;
        final cy = side / 2;
        const userR = 6.0;
        final maxR = math.max(8.0, side / 2 - 8);
        final rInner = maxR * 0.24;
        final rOuter = maxR * 0.90;

        double radiusForScore(int score) {
          final s = score.clamp(1, 5);
          final t = (s - 1) / 4.0;
          return rOuter + t * (rInner - rOuter);
        }

        final n = _samples.length;
        final layoutScale = n > 10 ? math.min(1.0, 10 / n) : 1.0;
        final layouts = <_PlacedNode>[];
        for (var i = 0; i < n; i++) {
          final theta = -math.pi / 2 + (2 * math.pi * i) / n + 0.12;
          final r = radiusForScore(_samples[i].score);
          layouts.add(
            _PlacedNode(
              sample: _samples[i],
              theta: theta,
              r: r,
              cx: cx + r * math.cos(theta),
              cy: cy + r * math.sin(theta),
            ),
          );
        }

        return Center(
          child: SizedBox(
            width: side,
            height: side,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: _RadarMapPainter(
                      linesTo: layouts.map((e) => Offset(e.cx, e.cy)).toList(),
                      center: Offset(cx, cy),
                      userRadius: userR,
                    ),
                  ),
                ),
                ...layouts.map(
                  (e) => _MapPersonNode(
                    key: ValueKey(e.sample.name),
                    name: e.sample.name,
                    avatarGradStart: e.sample.avatarGradStart,
                    avatarGradEnd: e.sample.avatarGradEnd,
                    centerX: e.cx,
                    centerY: e.cy,
                    textTheme: tt,
                    layoutScale: layoutScale,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _MapSample {
  const _MapSample({
    required this.name,
    required this.score,
    this.avatarGradStart,
    this.avatarGradEnd,
  });

  final String name;
  final int score;
  final Color? avatarGradStart;
  final Color? avatarGradEnd;
}

class _PlacedNode {
  _PlacedNode({
    required this.sample,
    required this.theta,
    required this.r,
    required this.cx,
    required this.cy,
  });

  final _MapSample sample;
  final double theta;
  final double r;
  final double cx;
  final double cy;
}

class _RadarMapPainter extends CustomPainter {
  _RadarMapPainter({
    required this.linesTo,
    required this.center,
    required this.userRadius,
  });

  final List<Offset> linesTo;
  final Offset center;
  final double userRadius;

  static const _ringOuter = Color(0xFF3D3D46);
  static const _ringMid = Color(0xFF323238);
  static const _ringInner = Color(0xFF28282E);

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final maxR = size.shortestSide / 2 - 2;

    canvas.drawCircle(c, maxR, Paint()..color = _ringOuter);
    canvas.drawCircle(c, maxR * 0.62, Paint()..color = _ringMid);
    canvas.drawCircle(c, maxR * 0.32, Paint()..color = _ringInner);

    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.35)
      ..strokeWidth = 1.1
      ..style = PaintingStyle.stroke;

    for (final end in linesTo) {
      canvas.drawLine(center, end, linePaint);
    }

    canvas.drawCircle(
      center,
      userRadius,
      Paint()..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(covariant _RadarMapPainter oldDelegate) {
    return oldDelegate.linesTo != linesTo ||
        oldDelegate.center != center ||
        oldDelegate.userRadius != userRadius;
  }
}

class _MapPersonNode extends StatelessWidget {
  const _MapPersonNode({
    super.key,
    required this.name,
    this.avatarGradStart,
    this.avatarGradEnd,
    required this.centerX,
    required this.centerY,
    required this.textTheme,
    this.layoutScale = 1.0,
  });

  final String name;
  final Color? avatarGradStart;
  final Color? avatarGradEnd;
  final double centerX;
  final double centerY;
  final TextTheme textTheme;
  final double layoutScale;

  static const double _avatarR = 22;

  @override
  Widget build(BuildContext context) {
    final avatarR = _avatarR * layoutScale;
    final labelHeight = 18.0 * layoutScale;
    final gap = 6.0 * layoutScale;
    final top = centerY - labelHeight - gap - avatarR;
    final colW = 104 * layoutScale;
    final nameFont = 12 * layoutScale;
    final initialFont = 20 * layoutScale;

    final gradStart = avatarGradStart ?? const Color(0xFF6366F1);
    final gradEnd = avatarGradEnd ?? const Color(0xFFC084FC);

    return Positioned(
      left: centerX - colW / 2,
      top: top,
      width: colW,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: (textTheme.labelLarge ?? const TextStyle()).copyWith(
              color: Colors.white.withValues(alpha: 0.95),
              fontWeight: FontWeight.w600,
              fontSize: nameFont,
              letterSpacing: 0.2,
            ),
          ),
          SizedBox(height: gap),
          Center(
            child: Container(
              width: avatarR * 2,
              height: avatarR * 2,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [gradStart, gradEnd],
                ),
              ),
              child: Center(
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : '?',
                  style: (textTheme.titleMedium ?? const TextStyle()).copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: initialFont,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
