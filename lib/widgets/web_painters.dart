import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:material_ui/material_ui.dart';

import '../theme/app_theme.dart';

/// A radial web anchored at [anchor] (fractional position, can sit off-screen).
/// [progress] 0..1 draws the strands on; [sway] gently moves the rings.
class WebPainter extends CustomPainter {
  WebPainter({
    required this.progress,
    required this.sway,
    this.anchor = const Offset(1.02, -0.05),
    this.color = AppColors.text,
    this.opacity = .14,
    this.spokes = 14,
    this.rings = 9,
    this.radiusFactor = 1.15,
    this.parallax = Offset.zero,
  });

  final double progress;
  final double sway;
  final Offset anchor;
  final Color color;
  final double opacity;
  final int spokes;
  final int rings;
  final double radiusFactor;
  final Offset parallax;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * anchor.dx, size.height * anchor.dy) + parallax;
    final maxR = size.longestSide * radiusFactor;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    final spokeT = (progress / .45).clamp(0.0, 1.0);
    final ringT = ((progress - .25) / .75).clamp(0.0, 1.0);

    final angles = List.generate(spokes, (i) {
      final jitter = math.sin(i * 12.9898) * .08;
      return (i / spokes) * math.pi * 2 + jitter;
    });

    // Spokes
    for (var i = 0; i < spokes; i++) {
      final a = angles[i];
      final end = center + Offset(math.cos(a), math.sin(a)) * maxR * Curves.easeOutCubic.transform(spokeT);
      paint
        ..strokeWidth = 1.1
        ..shader = ui.Gradient.linear(center, end, [
          color.withValues(alpha: opacity * 1.6),
          color.withValues(alpha: 0),
        ]);
      canvas.drawLine(center, end, paint);
    }
    paint.shader = null;

    // Rings: sagging threads between neighbouring spokes.
    for (var r = 1; r <= rings; r++) {
      final local = ((ringT * rings) - (r - 1)).clamp(0.0, 1.0);
      if (local <= 0) continue;
      final radius = maxR * math.pow(r / rings, 1.35);
      final fade = (1 - r / (rings + 1)) * opacity * 1.4;
      paint
        ..strokeWidth = r < 3 ? 1.2 : .9
        ..color = color.withValues(alpha: fade);
      final segs = (spokes * local).ceil();
      final path = Path();
      for (var i = 0; i < segs; i++) {
        final a1 = angles[i];
        final a2 = angles[(i + 1) % spokes] + (i + 1 == spokes ? math.pi * 2 : 0);
        final wobble = math.sin(sway * math.pi * 2 + r * .7 + i) * radius * .012;
        final p1 = center + Offset(math.cos(a1), math.sin(a1)) * (radius + wobble);
        final p2 = center + Offset(math.cos(a2), math.sin(a2)) * (radius - wobble);
        final mid = (p1 + p2) / 2;
        final sag = center + (mid - center) * .9;
        path
          ..moveTo(p1.dx, p1.dy)
          ..quadraticBezierTo(sag.dx, sag.dy, p2.dx, p2.dy);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(WebPainter old) =>
      old.progress != progress || old.sway != sway || old.parallax != parallax || old.color != color;
}

/// Comic halftone dots that fade along a diagonal.
class HalftonePainter extends CustomPainter {
  HalftonePainter({this.color = AppColors.red, this.spacing = 14, this.maxDot = 2.6, this.fromTopLeft = true, this.opacity = .35});
  final Color color;
  final double spacing;
  final double maxDot;
  final bool fromTopLeft;
  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = color.withValues(alpha: opacity);
    final diag = size.width + size.height;
    for (double y = 0; y < size.height; y += spacing) {
      final shift = ((y / spacing).floor().isOdd) ? spacing / 2 : 0;
      for (double x = 0; x < size.width; x += spacing) {
        final px = x + shift;
        final d = fromTopLeft ? (px + y) / diag : ((size.width - px) + (size.height - y)) / diag;
        final r = maxDot * (1 - d * 1.6);
        if (r > .35) canvas.drawCircle(Offset(px, y), r, p);
      }
    }
  }

  @override
  bool shouldRepaint(HalftonePainter old) => false;
}

/// A single silk strand from [from] to [to] that sags and is drawn on by [t].
class StrandPainter extends CustomPainter {
  StrandPainter({required this.t, required this.from, required this.to, this.sag = 40, this.color = AppColors.text, this.width = 1.4});
  final double t;
  final Offset from, to;
  final double sag;
  final Color color;
  final double width;

  @override
  void paint(Canvas canvas, Size size) {
    if (t <= 0) return;
    final a = Offset(from.dx * size.width, from.dy * size.height);
    final b = Offset(to.dx * size.width, to.dy * size.height);
    final ctrl = (a + b) / 2 + Offset(0, sag);
    final path = Path()
      ..moveTo(a.dx, a.dy)
      ..quadraticBezierTo(ctrl.dx, ctrl.dy, b.dx, b.dy);
    final metric = path.computeMetrics().first;
    final drawn = metric.extractPath(0, metric.length * t.clamp(0, 1));
    canvas.drawPath(
        drawn,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = width
          ..strokeCap = StrokeCap.round
          ..color = color.withValues(alpha: .55));
    final tip = metric.getTangentForOffset(metric.length * t.clamp(0, 1))?.position;
    if (tip != null && t < 1) {
      canvas.drawCircle(tip, 3, Paint()..color = AppColors.red);
    }
  }

  @override
  bool shouldRepaint(StrandPainter old) => old.t != t;
}

/// Self-animating decorative web, used in section corners.
class AnimatedWeb extends StatefulWidget {
  const AnimatedWeb({
    super.key,
    this.anchor = const Offset(1.02, -.05),
    this.color = AppColors.text,
    this.opacity = .12,
    this.spokes = 12,
    this.rings = 7,
    this.radiusFactor = 1,
    this.duration = const Duration(milliseconds: 2200),
  });
  final Offset anchor;
  final Color color;
  final double opacity;
  final int spokes, rings;
  final double radiusFactor;
  final Duration duration;

  @override
  State<AnimatedWeb> createState() => _AnimatedWebState();
}

class _AnimatedWebState extends State<AnimatedWeb> with TickerProviderStateMixin {
  late final AnimationController _draw = AnimationController(vsync: this, duration: widget.duration)..forward();
  late final AnimationController _sway = AnimationController(vsync: this, duration: const Duration(seconds: 7))..repeat();

  @override
  void dispose() {
    _draw.dispose();
    _sway.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final still = MediaQuery.disableAnimationsOf(context);
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: Listenable.merge([_draw, _sway]),
        builder: (_, _) => CustomPaint(
          painter: WebPainter(
            progress: still ? 1 : Curves.easeInOutCubic.transform(_draw.value),
            sway: still ? 0 : _sway.value,
            anchor: widget.anchor,
            color: widget.color,
            opacity: widget.opacity,
            spokes: widget.spokes,
            rings: widget.rings,
            radiusFactor: widget.radiusFactor,
          ),
          size: Size.infinite,
        ),
      ),
    );
  }
}
