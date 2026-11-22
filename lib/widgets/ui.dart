import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../theme/app_theme.dart';
import 'reveal.dart';
import 'web_painters.dart';

/// Primary (red) or secondary (blue outline) call-to-action with hover lift,
/// comic offset shadow and keyboard focus ring.
class CtaButton extends StatefulWidget {
  const CtaButton({super.key, required this.label, required this.onTap, this.primary = true, this.icon, this.compact = false});
  final String label;
  final VoidCallback? onTap;
  final bool primary;
  final IconData? icon;
  final bool compact;

  @override
  State<CtaButton> createState() => _CtaButtonState();
}

class _CtaButtonState extends State<CtaButton> {
  bool _hover = false;
  bool _focus = false;
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final active = _hover || _focus;
    final fg = Colors.white;
    final pad = widget.compact ? const EdgeInsets.symmetric(horizontal: 18, vertical: 12) : const EdgeInsets.symmetric(horizontal: 26, vertical: 17);
    return FocusableActionDetector(
      mouseCursor: SystemMouseCursors.click,
      onShowHoverHighlight: (v) => setState(() => _hover = v),
      onShowFocusHighlight: (v) => setState(() => _focus = v),
      actions: {ActivateIntent: CallbackAction<ActivateIntent>(onInvoke: (_) => widget.onTap?.call())},
      shortcuts: const {SingleActivator(LogicalKeyboardKey.enter): ActivateIntent()},
      child: Semantics(
        button: true,
        label: widget.label,
        child: GestureDetector(
          onTapDown: (_) => setState(() => _down = true),
          onTapCancel: () => setState(() => _down = false),
          onTapUp: (_) => setState(() => _down = false),
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            transform: Matrix4.translationValues(active ? -3 : 0, _down ? 2 : (active ? -3 : 0), 0),
            padding: pad,
            decoration: BoxDecoration(
              gradient: widget.primary
                  ? LinearGradient(colors: active ? const [Color(0xFFFF3B44), AppColors.red] : const [AppColors.red, AppColors.redDeep])
                  : null,
              color: widget.primary ? null : (active ? AppColors.blue.withValues(alpha: .18) : Colors.transparent),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: widget.primary ? Colors.white.withValues(alpha: .18) : AppColors.blue, width: 1.6),
              boxShadow: [
                BoxShadow(
                  color: (widget.primary ? AppColors.blue : AppColors.red).withValues(alpha: active ? 1 : .0),
                  offset: active ? const Offset(6, 6) : Offset.zero,
                ),
                if (widget.primary) BoxShadow(color: AppColors.red.withValues(alpha: active ? .55 : .3), blurRadius: active ? 34 : 20),
                if (_focus) const BoxShadow(color: Colors.white, spreadRadius: 2),
              ],
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Text(widget.label.toUpperCase(), style: AppText.label(widget.compact ? 12 : 13.5, color: fg)),
              if (widget.icon != null) ...[
                const SizedBox(width: 10),
                AnimatedSlide(
                  duration: const Duration(milliseconds: 220),
                  offset: Offset(active ? .25 : 0, 0),
                  child: Icon(widget.icon, size: 18, color: fg),
                ),
              ],
            ]),
          ),
        ),
      ),
    );
  }
}

/// Section heading: comic-style number badge, eyebrow, big title, web swoosh underline.
class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.number, required this.eyebrow, required this.title, this.subtitle, this.center = false});
  final String number;
  final String eyebrow;
  final String title;
  final String? subtitle;
  final bool center;

  @override
  Widget build(BuildContext context) {
    final size = context.isMobile ? 40.0 : (context.isTablet ? 54.0 : 66.0);
    final align = center ? CrossAxisAlignment.center : CrossAxisAlignment.start;
    return Reveal(
      style: RevealStyle.swingLeft,
      child: Column(crossAxisAlignment: align, children: [
        Row(mainAxisSize: MainAxisSize.min, children: [
          Transform.rotate(
            angle: -.06,
            child: Container(
              padding: const EdgeInsets.fromLTRB(10, 6, 10, 4),
              decoration: BoxDecoration(
                color: AppColors.red,
                border: Border.all(color: Colors.black, width: 2),
                boxShadow: const [BoxShadow(color: AppColors.blue, offset: Offset(3, 3))],
              ),
              child: Text(number, style: AppText.comic(18)),
            ),
          ),
          const SizedBox(width: 14),
          Text(eyebrow.toUpperCase(), style: AppText.label(12, color: AppColors.blueGlow)),
        ]),
        const SizedBox(height: 18),
        ShaderMask(
          shaderCallback: (r) => const LinearGradient(colors: [Colors.white, Color(0xFFDCE4FF)]).createShader(r),
          child: Text(title, textAlign: center ? TextAlign.center : TextAlign.start, style: AppText.display(size)),
        ),
        const SizedBox(height: 14),
        const _Swoosh(),
        if (subtitle != null) ...[
          const SizedBox(height: 18),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Text(subtitle!, textAlign: center ? TextAlign.center : TextAlign.start, style: AppText.body(context.isMobile ? 15 : 17)),
          ),
        ],
      ]),
    );
  }
}

class _Swoosh extends StatefulWidget {
  const _Swoosh();
  @override
  State<_Swoosh> createState() => _SwooshState();
}

class _SwooshState extends State<_Swoosh> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100));

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 350), () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      height: 14,
      child: AnimatedBuilder(
        animation: _c,
        builder: (_, _) => CustomPaint(painter: _SwooshPainter(Curves.easeOutCubic.transform(_c.value))),
      ),
    );
  }
}

class _SwooshPainter extends CustomPainter {
  _SwooshPainter(this.t);
  final double t;
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width * t;
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(0, 2, w * .62, 5), const Radius.circular(3)), Paint()..color = AppColors.red);
    if (t > .3) {
      canvas.drawRRect(
          RRect.fromRectAndRadius(Rect.fromLTWH(size.width * .66, 2, (w - size.width * .66).clamp(0, size.width * .34), 5), const Radius.circular(3)),
          Paint()..color = AppColors.blue);
    }
    // web thread under it
    canvas.drawLine(Offset(0, 11), Offset(w, 11), Paint()
      ..color = Colors.white.withValues(alpha: .18)
      ..strokeWidth = 1);
  }

  @override
  bool shouldRepaint(_SwooshPainter old) => old.t != t;
}

/// Constrains content width and applies side gutters.
class SectionShell extends StatelessWidget {
  const SectionShell({super.key, required this.child, this.top = 120, this.bottom = 120, this.background, this.decor = const []});
  final Widget child;
  final double top, bottom;
  final Color? background;
  final List<Widget> decor;

  @override
  Widget build(BuildContext context) {
    final scale = context.isMobile ? .6 : 1.0;
    return Container(
      color: background,
      child: Stack(children: [
        ...decor,
        Padding(
          padding: EdgeInsets.fromLTRB(context.gutter, top * scale, context.gutter, bottom * scale),
          child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 1240), child: child)),
        ),
      ]),
    );
  }
}

/// Dark comic panel: clipped corner, thick border, offset colored shadow on hover.
class ComicPanel extends StatefulWidget {
  const ComicPanel({super.key, required this.child, this.padding = const EdgeInsets.all(28), this.accent = AppColors.red, this.halftone = true});
  final Widget child;
  final EdgeInsets padding;
  final Color accent;
  final bool halftone;

  @override
  State<ComicPanel> createState() => _ComicPanelState();
}

class _ComicPanelState extends State<ComicPanel> {
  bool _hover = false;
  @override
  Widget build(BuildContext context) {
    final other = widget.accent == AppColors.red ? AppColors.blue : AppColors.red;
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        transform: Matrix4.translationValues(_hover ? -4 : 0, _hover ? -4 : 0, 0),
        decoration: ShapeDecoration(
          shape: BeveledRectangleBorder(
            borderRadius: const BorderRadius.only(topRight: Radius.circular(22), bottomLeft: Radius.circular(22)),
            side: BorderSide(color: _hover ? widget.accent : AppColors.border, width: 1.4),
          ),
          color: AppColors.surface,
          shadows: [BoxShadow(color: other.withValues(alpha: _hover ? .9 : 0), offset: Offset(_hover ? 8 : 0, _hover ? 8 : 0))],
        ),
        child: ClipPath(
          clipper: const ShapeBorderClipper(
              shape: BeveledRectangleBorder(borderRadius: BorderRadius.only(topRight: Radius.circular(22), bottomLeft: Radius.circular(22)))),
          child: Stack(children: [
            if (widget.halftone)
              Positioned(
                right: 0,
                top: 0,
                width: 160,
                height: 120,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: _hover ? 1 : .35,
                  child: CustomPaint(painter: HalftonePainter(color: widget.accent, fromTopLeft: false, opacity: .3, spacing: 11, maxDot: 2.2)),
                ),
              ),
            Padding(padding: widget.padding, child: widget.child),
          ]),
        ),
      ),
    );
  }
}

/// 3D tilt toward the pointer with a moving glare. Static on touch devices.
class TiltCard extends StatefulWidget {
  const TiltCard({super.key, required this.child, this.maxTilt = .16, this.borderRadius = 18});
  final Widget child;
  final double maxTilt;
  final double borderRadius;

  @override
  State<TiltCard> createState() => _TiltCardState();
}

class _TiltCardState extends State<TiltCard> with SingleTickerProviderStateMixin {
  Offset _target = Offset.zero; // -1..1
  late final AnimationController _hover = AnimationController(vsync: this, duration: const Duration(milliseconds: 380));
  Offset _current = Offset.zero;

  @override
  void dispose() {
    _hover.dispose();
    super.dispose();
  }

  void _move(PointerEvent e, Size size) {
    setState(() {
      _target = Offset((e.localPosition.dx / size.width) * 2 - 1, (e.localPosition.dy / size.height) * 2 - 1);
      _current = _target;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final size = Size(c.maxWidth, c.maxHeight.isFinite ? c.maxHeight : 300);
      return MouseRegion(
        onEnter: (_) => _hover.forward(),
        onExit: (_) {
          _hover.reverse();
          setState(() => _target = Offset.zero);
        },
        onHover: (e) => _move(e, context.size ?? size),
        child: AnimatedBuilder(
          animation: _hover,
          builder: (context, child) {
            final h = Curves.easeOut.transform(_hover.value);
            final o = Offset.lerp(Offset.zero, _current, h)!;
            final m = Matrix4.identity()
              ..setEntry(3, 2, .0011)
              ..rotateX(-o.dy * widget.maxTilt)
              ..rotateY(o.dx * widget.maxTilt)
              ..scaleByDouble(1 + .03 * h, 1 + .03 * h, 1, 1);
            return Transform(
              alignment: Alignment.center,
              transform: m,
              child: Stack(children: [
                child!,
                Positioned.fill(
                  child: IgnorePointer(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(widget.borderRadius),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            center: Alignment(o.dx, o.dy),
                            radius: 1.1,
                            colors: [Colors.white.withValues(alpha: .16 * h), Colors.transparent],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ]),
            );
          },
          child: widget.child,
        ),
      );
    });
  }
}

/// Diagonal comic-cut divider with red and blue slashes and a strand across.
class SlashDivider extends StatelessWidget {
  const SlashDivider({super.key, this.flip = false, this.from = AppColors.bg, this.to = AppColors.bgAlt});
  final bool flip;
  final Color from, to;

  @override
  Widget build(BuildContext context) {
    final h = context.isMobile ? 48.0 : 84.0;
    return SizedBox(
      height: h,
      width: double.infinity,
      child: Reveal(
        style: flip ? RevealStyle.slideRight : RevealStyle.slideLeft,
        duration: const Duration(milliseconds: 1000),
        child: CustomPaint(painter: _SlashPainter(flip, from, to)),
      ),
    );
  }
}

class _SlashPainter extends CustomPainter {
  _SlashPainter(this.flip, this.from, this.to);
  final bool flip;
  final Color from, to;

  @override
  void paint(Canvas canvas, Size s) {
    canvas.drawRect(Offset.zero & s, Paint()..color = from);
    Path band(double y0, double y1) {
      final p = Path();
      if (!flip) {
        p
          ..moveTo(0, s.height * y0)
          ..lineTo(s.width, s.height * (y0 - .55))
          ..lineTo(s.width, s.height * (y1 - .55))
          ..lineTo(0, s.height * y1)
          ..close();
      } else {
        p
          ..moveTo(0, s.height * (y0 - .55))
          ..lineTo(s.width, s.height * y0)
          ..lineTo(s.width, s.height * y1)
          ..lineTo(0, s.height * (y1 - .55))
          ..close();
      }
      return p;
    }

    canvas.drawPath(band(.72, 1.6), Paint()..color = to);
    canvas.drawPath(band(.6, .68), Paint()..color = AppColors.red);
    canvas.drawPath(band(.7, .735), Paint()..color = AppColors.blue);
    final thread = Paint()
      ..color = Colors.white.withValues(alpha: .25)
      ..strokeWidth = 1;
    final y = s.height * .5;
    final path = Path()
      ..moveTo(0, y - 10)
      ..quadraticBezierTo(s.width / 2, y + 24, s.width, y - 30);
    canvas.drawPath(path, thread..style = PaintingStyle.stroke);
  }

  @override
  bool shouldRepaint(_SlashPainter old) => false;
}

/// Small pill/tag.
class Tag extends StatelessWidget {
  const Tag(this.text, {super.key, this.color = AppColors.blueGlow});
  final String text;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: color.withValues(alpha: .1),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: color.withValues(alpha: .35)),
        ),
        child: Text(text, style: AppText.body(12, color: color, weight: FontWeight.w700, height: 1.2)),
      );
}

/// Gradient icon badge
class IconBadge extends StatelessWidget {
  const IconBadge(this.icon, {super.key, this.size = 52, this.redFirst = true});
  final IconData icon;
  final double size;
  final bool redFirst;
  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(size * .28),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: redFirst ? const [AppColors.red, AppColors.blue] : const [AppColors.blue, AppColors.red],
          ),
          boxShadow: [BoxShadow(color: (redFirst ? AppColors.red : AppColors.blue).withValues(alpha: .35), blurRadius: 18, offset: const Offset(0, 6))],
        ),
        child: Icon(icon, color: Colors.white, size: size * .5),
      );
}

/// Responsive grid that wraps children into equal-width columns.
class ResponsiveGrid extends StatelessWidget {
  const ResponsiveGrid({super.key, required this.children, this.minItemWidth = 300, this.spacing = 24, this.maxColumns = 3});
  final List<Widget> children;
  final double minItemWidth;
  final double spacing;
  final int maxColumns;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final cols = math.max(1, math.min(maxColumns, ((c.maxWidth + spacing) / (minItemWidth + spacing)).floor()));
      final w = (c.maxWidth - spacing * (cols - 1)) / cols;
      return Wrap(
        spacing: spacing,
        runSpacing: spacing,
        children: [for (final ch in children) SizedBox(width: w, child: ch)],
      );
    });
  }
}
