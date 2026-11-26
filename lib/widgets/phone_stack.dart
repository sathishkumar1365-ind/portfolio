import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../content/site_content.dart';
import '../theme/app_theme.dart';
import 'embed.dart';
import 'video.dart';

/// A stack of vertical video cards. The card in the middle morphs into a phone
/// (bezel, rounded screen, camera island) and plays in place; the others fan out
/// behind it, smaller and dimmer. Drag, swipe, tap a side card, use the arrows
/// or the keyboard to move through it.
class PhoneStackCarousel extends StatefulWidget {
  const PhoneStackCarousel({super.key, required this.items, this.onChanged, this.autoAdvance = const Duration(seconds: 4)});
  final List<Project> items;
  final ValueChanged<int>? onChanged;
  final Duration autoAdvance;

  @override
  State<PhoneStackCarousel> createState() => _PhoneStackCarouselState();
}

class _PhoneStackCarouselState extends State<PhoneStackCarousel> with SingleTickerProviderStateMixin {
  late final AnimationController _pos = AnimationController.unbounded(vsync: this);
  final _focus = FocusNode(debugLabel: 'phone stack');
  Timer? _auto;
  int _index = 0;
  bool _playing = false;
  bool _touched = false; // stop auto-advance once the visitor takes over
  bool _hovering = false;
  double _spacing = 200;

  int get _n => widget.items.length;

  @override
  void initState() {
    super.initState();
    _pos.addListener(_onMove);
    _auto = Timer.periodic(widget.autoAdvance, (_) {
      if (_touched || _playing || _hovering || !mounted || _n < 2) return;
      _goTo(_index + 1 >= _n ? 0 : _index + 1);
    });
  }

  @override
  void didUpdateWidget(PhoneStackCarousel old) {
    super.didUpdateWidget(old);
    if (old.items != widget.items) {
      _pos.value = 0;
      _index = 0;
      _playing = false;
    }
  }

  @override
  void dispose() {
    _auto?.cancel();
    _pos.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _onMove() {
    final i = _pos.value.round().clamp(0, math.max(0, _n - 1)).toInt();
    if (i != _index) {
      _index = i;
      _playing = false;
      widget.onChanged?.call(i);
    }
    setState(() {});
  }

  void _goTo(int i) {
    if (_n == 0) return;
    final target = i.clamp(0, _n - 1).toDouble();
    _playing = false;
    _pos.animateTo(target, duration: const Duration(milliseconds: 700), curve: Curves.easeOutCubic);
  }

  void _step(int dir) {
    _touched = true;
    _goTo(_index + dir);
  }

  void _activate(int i) {
    _touched = true;
    _focus.requestFocus();
    if (i != _index || (_pos.value - i).abs() > .05) {
      _goTo(i);
      return;
    }
    final p = widget.items[i];
    if (youTubeId(p.videoUrl) != null) {
      setState(() => _playing = true);
    } else {
      openVideo(context, url: p.videoUrl, title: p.title);
    }
  }

  void _dragStart(DragStartDetails _) {
    _touched = true;
    _pos.stop();
    if (_playing) setState(() => _playing = false);
  }

  void _dragUpdate(DragUpdateDetails d) {
    var v = _pos.value - d.delta.dx / _spacing;
    // Rubber band past the ends.
    if (v < 0) v = _pos.value - d.delta.dx / _spacing * .35;
    if (v > _n - 1) v = _pos.value - d.delta.dx / _spacing * .35;
    _pos.value = v.clamp(-.4, _n - 1 + .4);
  }

  void _dragEnd(DragEndDetails d) {
    final fling = -(d.primaryVelocity ?? 0) / _spacing * .22;
    _goTo((_pos.value + fling).round());
  }

  KeyEventResult _key(FocusNode _, KeyEvent e) {
    if (e is! KeyDownEvent) return KeyEventResult.ignored;
    if (e.logicalKey == LogicalKeyboardKey.arrowRight) {
      _step(1);
      return KeyEventResult.handled;
    }
    if (e.logicalKey == LogicalKeyboardKey.arrowLeft) {
      _step(-1);
      return KeyEventResult.handled;
    }
    if (e.logicalKey == LogicalKeyboardKey.enter || e.logicalKey == LogicalKeyboardKey.space) {
      _activate(_index);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    if (_n == 0) return const SizedBox.shrink();
    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth;
        final phoneW = math.min(context.isMobile ? 230.0 : 290.0, w * .6);
        final phoneH = phoneW * 2.05;
        _spacing = phoneW * .68;
        final areaH = phoneH + 30;
        final cx = w / 2;
        final p = _pos.value;

        final order = List.generate(_n, (i) => i)..sort((a, b) => (b - p).abs().compareTo((a - p).abs()));
        final cards = <Widget>[];
        for (final i in order) {
          final d = i - p;
          final ad = d.abs();
          if (ad > 3.6) continue;
          final scale = math.pow(.82, math.min(ad, 3.6)).toDouble();
          final travel = ad <= 1 ? ad : 1 + (ad - 1) * .66;
          final x = cx + d.sign * travel * _spacing;
          final cw = phoneW * scale;
          final ch = phoneH * scale;
          final morph = Curves.easeOut.transform((1 - ad).clamp(0.0, 1.0));
          final opacity = (3.4 - ad).clamp(0.0, 1.0);
          final live = _playing && i == _index && ad < .02;
          cards.add(
            Positioned(
              left: x - cw / 2,
              top: (areaH - ch) / 2,
              width: cw,
              height: ch,
              child: Opacity(
                opacity: opacity,
                child: Transform(
                  alignment: Alignment.center,
                  transform: live
                      ? Matrix4.identity()
                      : (Matrix4.identity()
                          ..setEntry(3, 2, .0012)
                          ..rotateY(-d.clamp(-1.0, 1.0) * .22)),
                  child: _StackCard(project: widget.items[i], seed: i, morph: morph, dim: math.min(ad, 1.2) * .55, live: live, onTap: () => _activate(i)),
                ),
              ),
            ),
          );
        }

        return Focus(
          focusNode: _focus,
          onKeyEvent: _key,
          child: MouseRegion(
            onEnter: (_) => _hovering = true,
            onExit: (_) => _hovering = false,
            child: Column(
              children: [
                Semantics(
                  label: 'Video carousel. ${widget.items[_index].title}, ${_index + 1} of $_n. Use left and right arrow keys to browse.',
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onHorizontalDragStart: _dragStart,
                    onHorizontalDragUpdate: _dragUpdate,
                    onHorizontalDragEnd: _dragEnd,
                    child: SizedBox(
                      height: areaH,
                      width: w,
                      child: ClipRect(
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            // Glow under the phone
                            Positioned(
                              left: cx - phoneW,
                              width: phoneW * 2,
                              top: areaH * .15,
                              height: areaH * .7,
                              child: IgnorePointer(
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    gradient: RadialGradient(
                                      colors: [AppColors.red.withValues(alpha: .28), AppColors.blue.withValues(alpha: .12), Colors.transparent],
                                      stops: const [0, .5, 1],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            ...cards,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                _Controls(
                  index: _index,
                  count: _n,
                  onPrev: () => _step(-1),
                  onNext: () => _step(1),
                  onDot: (i) {
                    _touched = true;
                    _goTo(i);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StackCard extends StatefulWidget {
  const _StackCard({required this.project, required this.seed, required this.morph, required this.dim, required this.live, required this.onTap});
  final Project project;
  final int seed;
  final double morph; // 0 = flat card, 1 = full phone
  final double dim;
  final bool live;
  final VoidCallback onTap;

  @override
  State<_StackCard> createState() => _StackCardState();
}

class _StackCardState extends State<_StackCard> {
  bool _h = false;

  @override
  Widget build(BuildContext context) {
    final m = widget.morph;
    final p = widget.project;
    final bezel = lerpDouble(0, 9, m)!;
    final outerR = lerpDouble(18, 42, m)!;
    final innerR = math.max(8.0, outerR - bezel);
    final thumb = thumbnailFor(p.videoUrl);
    final id = youTubeId(p.videoUrl);
    final poster = Poster(icon: Icons.movie_rounded, seed: widget.seed);

    final screen = ClipRRect(
      borderRadius: BorderRadius.circular(innerR),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (widget.live && id != null)
            youTubePlayer(id)
          else ...[
            poster,
            if (thumb != null)
              Image.network(
                thumb,
                fit: BoxFit.cover,
                filterQuality: FilterQuality.medium,
                errorBuilder: (_, _, _) => poster,
                frameBuilder: (_, child, frame, sync) =>
                    AnimatedOpacity(opacity: frame == null && !sync ? 0 : 1, duration: const Duration(milliseconds: 400), child: child),
              ),
            // Legibility gradient
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x66000000), Colors.transparent, Color(0xE6000000)],
                  stops: [0, .35, 1],
                ),
              ),
            ),
            // Side cards are dimmed
            IgnorePointer(
              child: ColoredBox(color: Colors.black.withValues(alpha: widget.dim)),
            ),
            if (m > .6)
              Opacity(
                opacity: ((m - .6) / .4).clamp(0.0, 1.0),
                child: Stack(
                  children: [
                    Center(child: PlayBadge(size: 56, hot: _h)),
                    Positioned(
                      left: 16,
                      right: 16,
                      bottom: 18,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Transform.rotate(
                            angle: -.04,
                            child: Container(
                              padding: const EdgeInsets.fromLTRB(8, 4, 8, 2),
                              decoration: BoxDecoration(
                                color: AppColors.red,
                                border: Border.all(color: Colors.black, width: 2),
                                boxShadow: const [BoxShadow(color: AppColors.blue, offset: Offset(3, 3))],
                              ),
                              child: Text(p.category.toUpperCase(), style: AppText.comic(13)),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(p.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: AppText.display(20)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            if (p.sample && m > .6)
              Positioned(
                top: 34,
                right: 12,
                child: Tooltip(
                  message: 'Sample video for layout preview',
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Text('SAMPLE', style: AppText.label(9)),
                  ),
                ),
              ),
          ],
        ],
      ),
    );

    return Semantics(
      button: true,
      label: m > .6 ? 'Play ${p.title}' : 'Show ${p.title}',
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _h = true),
        onExit: (_) => setState(() => _h = false),
        child: GestureDetector(
          onTap: widget.live ? null : widget.onTap,
          child: Container(
            padding: EdgeInsets.all(bezel),
            decoration: BoxDecoration(
              color: Color.lerp(AppColors.surface, const Color(0xFF0B0C12), m),
              borderRadius: BorderRadius.circular(outerR),
              border: Border.all(color: Color.lerp(AppColors.border, const Color(0xFF3A3F55), m)!, width: lerpDouble(1, 2, m)!),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: .55), blurRadius: 30, offset: const Offset(0, 18)),
                if (m > 0)
                  BoxShadow(
                    color: AppColors.blue.withValues(alpha: m * .9),
                    offset: Offset(8 * m, 8 * m),
                  ),
                if (m > 0)
                  BoxShadow(
                    color: AppColors.red.withValues(alpha: m * .35),
                    blurRadius: 50 * m,
                  ),
              ],
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                screen,
                // Camera island fades in as the card becomes the phone
                if (m > .05)
                  Positioned(
                    top: 10,
                    left: 0,
                    right: 0,
                    child: IgnorePointer(
                      child: Center(
                        child: Opacity(
                          opacity: m,
                          child: Container(
                            width: lerpDouble(20, 76, m),
                            height: 20,
                            decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(12)),
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 8),
                            child: Container(
                              width: 7,
                              height: 7,
                              decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF1A2340)),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Controls extends StatelessWidget {
  const _Controls({required this.index, required this.count, required this.onPrev, required this.onNext, required this.onDot});
  final int index, count;
  final VoidCallback onPrev, onNext;
  final ValueChanged<int> onDot;

  @override
  Widget build(BuildContext context) {
    Widget arrow(IconData icon, String tip, VoidCallback? onTap) => Tooltip(
      message: tip,
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(side: BorderSide(color: AppColors.border, width: 1.4)),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          hoverColor: AppColors.red.withValues(alpha: .25),
          child: SizedBox(width: 46, height: 46, child: Icon(icon, color: onTap == null ? AppColors.textMute : Colors.white)),
        ),
      ),
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        arrow(Icons.arrow_back_rounded, 'Previous', index > 0 ? onPrev : null),
        const SizedBox(width: 18),
        Flexible(
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 6,
            runSpacing: 6,
            children: [
              for (var i = 0; i < count; i++)
                GestureDetector(
                  onTap: () => onDot(i),
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutCubic,
                      width: i == index ? 26 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        gradient: i == index ? const LinearGradient(colors: [AppColors.red, AppColors.blue]) : null,
                        color: i == index ? null : AppColors.border,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: 18),
        arrow(Icons.arrow_forward_rounded, 'Next', index < count - 1 ? onNext : null),
      ],
    );
  }
}
