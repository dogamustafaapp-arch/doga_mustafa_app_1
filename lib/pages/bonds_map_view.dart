import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Radar-style bond map: you at the center, higher scores sit closer.
///
/// **Hardcoded samples** for UI preview only — replace with real data later.
class BondsMapPreview extends StatelessWidget {
  const BondsMapPreview({super.key});

  // TODO: Remove — temporary preview nodes (wire to Firestore scores later).
  static const List<_MapSample> _samples = [
    _MapSample(
      name: 'Lil Bro',
      score: 3,
      variant: _NodeVariant.avatar,
    ),
    _MapSample(
      name: 'Alex',
      score: 5,
      variant: _NodeVariant.dot,
      dotColor: Color(0xFFE53935),
    ),
    _MapSample(
      name: 'Casey',
      score: 4,
      variant: _NodeVariant.avatar,
    ),
    _MapSample(
      name: 'Riley',
      score: 2,
      variant: _NodeVariant.dot,
      dotColor: Color(0xFF7C4DFF),
    ),
    _MapSample(
      name: 'Quinn',
      score: 1,
      variant: _NodeVariant.avatar,
    ),
  ];

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
                    variant: e.sample.variant,
                    dotColor: e.sample.dotColor,
                    centerX: e.cx,
                    centerY: e.cy,
                    textTheme: tt,
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

enum _NodeVariant { avatar, dot }

class _MapSample {
  const _MapSample({
    required this.name,
    required this.score,
    required this.variant,
    this.dotColor,
  });

  final String name;
  final int score;
  final _NodeVariant variant;
  final Color? dotColor;
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
    required this.variant,
    required this.dotColor,
    required this.centerX,
    required this.centerY,
    required this.textTheme,
  });

  final String name;
  final _NodeVariant variant;
  final Color? dotColor;
  final double centerX;
  final double centerY;
  final TextTheme textTheme;

  static const double _avatarR = 22;
  static const double _dotR = 9;

  @override
  Widget build(BuildContext context) {
    final nodeR = variant == _NodeVariant.avatar ? _avatarR : _dotR;
    const labelHeight = 18.0;
    const gap = 6.0;
    final top = centerY - labelHeight - gap - nodeR;

    return Positioned(
      left: centerX - 52,
      top: top,
      width: 104,
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
              fontSize: 12,
              letterSpacing: 0.2,
            ),
          ),
          SizedBox(height: gap),
          Center(
            child: variant == _NodeVariant.avatar
                ? Container(
                    width: _avatarR * 2,
                    height: _avatarR * 2,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF6366F1),
                          Color(0xFFC084FC),
                        ],
                      ),
                    ),
                    child: Center(
                      child: Text(
                        name.isNotEmpty ? name[0].toUpperCase() : '?',
                        style: (textTheme.titleMedium ?? const TextStyle())
                            .copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  )
                : Container(
                    width: _dotR * 2,
                    height: _dotR * 2,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: dotColor ?? Colors.redAccent,
                      boxShadow: [
                        BoxShadow(
                          color: (dotColor ?? Colors.red)
                              .withValues(alpha: 0.45),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
