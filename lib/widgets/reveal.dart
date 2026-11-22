import 'dart:math' as math;

import 'package:flutter/scheduler.dart';
import 'package:material_ui/material_ui.dart';

/// Provides the page's scroll position to every [Reveal] below it.
class ScrollScope extends InheritedWidget {
  const ScrollScope({super.key, required this.controller, required super.child});
  final ScrollController controller;

  static ScrollController? of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<ScrollScope>()?.controller;

  @override
  bool updateShouldNotify(ScrollScope oldWidget) => oldWidget.controller != controller;
}

enum RevealStyle { rise, swingLeft, swingRight, zoom, slideLeft, slideRight }

/// Animates its child in once it scrolls into view. Swing styles pivot from the
/// top edge, like something swinging in on a line.
class Reveal extends StatefulWidget {
  const Reveal({super.key, required this.child, this.style = RevealStyle.rise, this.delay = Duration.zero, this.duration = const Duration(milliseconds: 850)});
  final Widget child;
  final RevealStyle style;
  final Duration delay;
  final Duration duration;

  @override
  State<Reveal> createState() => _RevealState();
}

class _RevealState extends State<Reveal> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: widget.duration);
  ScrollController? _scroll;
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final s = ScrollScope.of(context);
    if (s != _scroll) {
      _scroll?.removeListener(_check);
      _scroll = s;
      _scroll?.addListener(_check);
    }
    SchedulerBinding.instance.addPostFrameCallback((_) => _check());
  }

  void _check() {
    if (_started || !mounted) return;
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize || !box.attached) return;
    final top = box.localToGlobal(Offset.zero).dy;
    final vh = MediaQuery.sizeOf(context).height;
    if (top < vh * .92 && top + box.size.height > 0) {
      _started = true;
      _scroll?.removeListener(_check);
      Future.delayed(widget.delay, () {
        if (mounted) _c.forward();
      });
    }
  }

  @override
  void dispose() {
    _scroll?.removeListener(_check);
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) return widget.child;
    return AnimatedBuilder(
      animation: _c,
      child: widget.child,
      builder: (context, child) {
        final t = Curves.easeOutCubic.transform(_c.value);
        final spring = Curves.easeOutBack.transform(_c.value);
        Matrix4 m = Matrix4.identity();
        Alignment origin = Alignment.center;
        switch (widget.style) {
          case RevealStyle.rise:
            m = Matrix4.translationValues(0, 48 * (1 - t), 0);
          case RevealStyle.zoom:
            final s = .86 + .14 * spring;
            m = Matrix4.diagonal3Values(s, s, 1);
          case RevealStyle.slideLeft:
            m = Matrix4.translationValues(-70 * (1 - t), 0, 0);
          case RevealStyle.slideRight:
            m = Matrix4.translationValues(70 * (1 - t), 0, 0);
          case RevealStyle.swingLeft:
          case RevealStyle.swingRight:
            final dir = widget.style == RevealStyle.swingLeft ? -1 : 1;
            origin = Alignment.topCenter;
            m = Matrix4.identity()
              ..setEntry(3, 2, .0012)
              ..translateByDouble(dir * 90 * (1 - t), -30 * (1 - t), 0, 1)
              ..rotateZ(dir * .22 * (1 - spring))
              ..rotateX(-.5 * (1 - t));
        }
        return Opacity(
          opacity: math.min(1, _c.value * 1.6),
          child: Transform(transform: m, alignment: origin, child: child),
        );
      },
    );
  }
}
