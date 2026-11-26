import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../content/site_content.dart';
import '../pages/home_page.dart';
import '../theme/app_theme.dart';
import '../widgets/ui.dart';
import '../widgets/video.dart';
import '../widgets/web_painters.dart';

class HeroSection extends StatefulWidget {
  const HeroSection({super.key, required this.start});
  final bool start;
  @override
  State<HeroSection> createState() => _HeroSectionState();
}

class _HeroSectionState extends State<HeroSection> with TickerProviderStateMixin {
  late final AnimationController _enter = AnimationController(vsync: this, duration: const Duration(milliseconds: 2600));
  late final AnimationController _loop = AnimationController(vsync: this, duration: const Duration(seconds: 8))..repeat();
  final _pointer = ValueNotifier<Offset>(Offset.zero);

  @override
  void initState() {
    super.initState();
    if (widget.start) _enter.forward();
  }

  @override
  void didUpdateWidget(HeroSection old) {
    super.didUpdateWidget(old);
    if (widget.start && !old.start) _enter.forward();
  }

  @override
  void dispose() {
    _enter.dispose();
    _loop.dispose();
    super.dispose();
  }

  /// 0..1 progress of a staggered slice of the entrance.
  double _seg(double from, double to, [Curve curve = Curves.easeOutCubic]) => curve.transform(((_enter.value - from) / (to - from)).clamp(0.0, 1.0));

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final mobile = context.isMobile;
    final wide = context.w >= 1080;
    final h = math.max(size.height, mobile ? 720.0 : 760.0);

    return MouseRegion(
      onHover: (e) => _pointer.value = Offset(e.position.dx / size.width - .5, e.position.dy / size.height - .5),
      child: SizedBox(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: wide ? h : 0),
          child: Stack(
            children: [
              // Background glows
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: const Alignment(-.8, -.4),
                      radius: 1.2,
                      colors: [AppColors.red.withValues(alpha: .22), AppColors.bg.withValues(alpha: 0)],
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: const Alignment(.9, .5),
                      radius: 1.1,
                      colors: [AppColors.blue.withValues(alpha: .25), AppColors.bg.withValues(alpha: 0)],
                    ),
                  ),
                ),
              ),
              // Animated web with pointer parallax
              Positioned.fill(
                child: RepaintBoundary(
                  child: AnimatedBuilder(
                    animation: Listenable.merge([_enter, _loop, _pointer]),
                    builder: (_, _) => CustomPaint(
                      painter: WebPainter(
                        progress: _seg(0, .75, Curves.easeInOutCubic),
                        sway: _loop.value,
                        anchor: const Offset(1.0, -.08),
                        parallax: _pointer.value * -30,
                        opacity: .16,
                        spokes: 16,
                        rings: 10,
                        radiusFactor: mobile ? 1.3 : 1.0,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                bottom: 0,
                width: 380,
                height: 300,
                child: CustomPaint(painter: HalftonePainter(color: AppColors.blue, fromTopLeft: false, opacity: .28)),
              ),
              // Skyline silhouette
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: mobile ? 120 : 190,
                child: AnimatedBuilder(
                  animation: Listenable.merge([_enter, _pointer]),
                  builder: (_, _) => Transform.translate(
                    offset: Offset(_pointer.value.dx * 18, 40 * (1 - _seg(.1, .7))),
                    child: RepaintBoundary(child: CustomPaint(painter: _SkylinePainter())),
                  ),
                ),
              ),
              // Content
              Padding(
                padding: EdgeInsets.fromLTRB(context.gutter, mobile ? 110 : 140, context.gutter, mobile ? 120 : 90),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1240),
                    child: AnimatedBuilder(
                      animation: _enter,
                      builder: (context, _) => wide
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(flex: 6, child: _copy(context)),
                                const SizedBox(width: 40),
                                Expanded(
                                  flex: 4,
                                  child: Center(
                                    // Scale the hanging phone down to fit short, wide screens.
                                    child: SizedBox(
                                      height: h - 260,
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: SizedBox(width: 300, child: _hangingReel(context)),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _copy(context),
                                const SizedBox(height: 50),
                                Center(
                                  child: SizedBox(width: mobile ? 260 : 300, child: _hangingReel(context)),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fade(double from, double to, Widget child, {double dy = 30, double dx = 0}) {
    final t = _seg(from, to);
    return Opacity(
      opacity: t,
      child: Transform.translate(offset: Offset(dx * (1 - t), dy * (1 - t)), child: child),
    );
  }

  Widget _copy(BuildContext context) {
    final mobile = context.isMobile;
    final nameSize = mobile ? 72.0 : (context.isTablet ? 110.0 : 136.0);
    final split = 14 * (1 - _seg(.15, .55, Curves.easeOutExpo));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fade(
          .05,
          .3,
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 28, height: 2, color: AppColors.red),
              const SizedBox(width: 10),
              Flexible(
                child: Text(HeroCopy.eyebrow.toUpperCase(), style: AppText.label(mobile ? 11 : 13, color: AppColors.blueGlow)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        // Name: red + blue offset layers converge into white (comic print misregistration).
        Semantics(
          header: true,
          label: 'Nikhil Cutz',
          child: ExcludeSemantics(
            child: Opacity(
              opacity: _seg(.1, .35),
              child: Transform.scale(
                scale: 1.25 - .25 * _seg(.1, .5, Curves.easeOutExpo),
                alignment: Alignment.centerLeft,
                child: Stack(
                  children: [
                    Transform.translate(
                      offset: Offset(-split - 4, 2),
                      child: Text('NIKHIL CUTZ', style: AppText.display(nameSize, color: AppColors.red.withValues(alpha: .9))),
                    ),
                    Transform.translate(
                      offset: Offset(split + 4, -2),
                      child: Text('NIKHIL CUTZ', style: AppText.display(nameSize, color: AppColors.blue.withValues(alpha: .9))),
                    ),
                    Text('NIKHIL CUTZ', style: AppText.display(nameSize)),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        _TaglineWords(t: _seg(.35, .75, Curves.linear), size: mobile ? 26 : 36),
        const SizedBox(height: 20),
        _fade(
          .5,
          .8,
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 580),
            child: Text(HeroCopy.body, style: AppText.body(mobile ? 15.5 : 18)),
          ),
        ),
        const SizedBox(height: 24),
        _fade(
          .58,
          .88,
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (var i = 0; i < HeroCopy.services.length; i++) Tag(HeroCopy.services[i], color: i.isEven ? const Color(0xFFFF6B72) : AppColors.blueGlow),
            ],
          ),
        ),
        const SizedBox(height: 34),
        _fade(
          .65,
          .95,
          Wrap(
            spacing: 16,
            runSpacing: 14,
            children: [
              CtaButton(label: 'View My Work', icon: Icons.play_arrow_rounded, primary: false, onTap: () => Nav.to(context, Sec.work)),
              CtaButton(label: "Let's Work Together", icon: Icons.arrow_forward_rounded, onTap: () => Nav.to(context, Sec.contact)),
            ],
          ),
          dy: 20,
        ),
        const SizedBox(height: 26),
        _fade(
          .75,
          1,
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const _LiveDot(),
              const SizedBox(width: 10),
              Text(
                HeroCopy.supporting,
                style: AppText.body(14, color: Colors.white, weight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// A phone-shaped reel card hanging on a web strand. It drops in and swings to rest.
  Widget _hangingReel(BuildContext context) {
    final drop = _seg(.25, .55, Curves.easeOutCubic);
    final tSwing = ((_enter.value - .4) * 2600 / 1000).clamp(0.0, 10.0);
    final swing = _enter.value < .4 ? .35 : .35 * math.exp(-1.6 * tSwing) * math.cos(5.2 * tSwing);
    final idle = math.sin(_loop.value * math.pi * 2) * .015;
    final strand = context.isMobile ? 60.0 : 130.0;
    return Opacity(
      opacity: math.min(1, drop * 2),
      child: Transform.translate(
        offset: Offset(0, -260 * (1 - drop)),
        child: Transform.rotate(
          angle: swing + idle,
          alignment: Alignment.topCenter,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 1.6,
                height: strand,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.white.withValues(alpha: 0), Colors.white.withValues(alpha: .7)],
                  ),
                ),
              ),
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(color: AppColors.red, shape: BoxShape.circle),
              ),
              const SizedBox(height: 2),
              const _ReelPhone(),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReelPhone extends StatefulWidget {
  const _ReelPhone();
  @override
  State<_ReelPhone> createState() => _ReelPhoneState();
}

class _ReelPhoneState extends State<_ReelPhone> {
  bool _hover = false;
  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Play showreel',
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: GestureDetector(
          onTap: () => openVideo(context, url: showreelUrl, title: 'Nikhil Cutz Showreel'),
          child: TiltCard(
            borderRadius: 34,
            child: AspectRatio(
              aspectRatio: 9 / 17,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(34),
                  border: Border.all(color: Colors.white.withValues(alpha: .85), width: 3),
                  boxShadow: [
                    const BoxShadow(color: AppColors.blue, offset: Offset(10, 10)),
                    BoxShadow(color: AppColors.red.withValues(alpha: .45), blurRadius: 60, spreadRadius: 4),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    const Poster(icon: Icons.movie_filter_rounded, seed: 0),
                    HoverPreview(url: showreelUrl, active: _hover),
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Color(0xCC000000)],
                          stops: [.5, 1],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 14,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          width: 70,
                          height: 6,
                          decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(4)),
                        ),
                      ),
                    ),
                    Center(child: PlayBadge(size: 58, hot: _hover)),
                    Positioned(
                      left: 18,
                      right: 18,
                      bottom: 20,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('SHOWREEL', style: AppText.comic(28)),
                          const SizedBox(height: 2),
                          Text('30–45 sec of the best cuts', style: AppText.body(12.5, color: Colors.white70, height: 1.3)),
                          const SizedBox(height: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(3),
                            child: const LinearProgressIndicator(value: .38, minHeight: 3, color: AppColors.red, backgroundColor: Colors.white24),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TaglineWords extends StatelessWidget {
  const _TaglineWords({required this.t, required this.size});
  final double t;
  final double size;
  @override
  Widget build(BuildContext context) {
    final words = HeroCopy.title.split(' ');
    return Semantics(
      label: HeroCopy.title,
      child: ExcludeSemantics(
        child: Wrap(
          spacing: size * .28,
          runSpacing: 4,
          children: [
            for (var i = 0; i < words.length; i++)
              Builder(
                builder: (_) {
                  final local = ((t * words.length * 1.4) - i).clamp(0.0, 1.0);
                  final e = Curves.easeOutBack.transform(local);
                  final accent = words[i].startsWith('Capture') || words[i].startsWith('Attention');
                  return Opacity(
                    opacity: local,
                    child: Transform.translate(
                      offset: Offset(0, 22 * (1 - e)),
                      child: Transform.rotate(
                        angle: .12 * (1 - e),
                        child: accent
                            ? ShaderMask(
                                shaderCallback: (r) => const LinearGradient(colors: [Color(0xFFFF4D55), Color(0xFF5B8CFF)]).createShader(r),
                                child: Text(words[i], style: AppText.display(size)),
                              )
                            : Text(words[i], style: AppText.display(size, color: Colors.white.withValues(alpha: .92))),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _LiveDot extends StatefulWidget {
  const _LiveDot();
  @override
  State<_LiveDot> createState() => _LiveDotState();
}

class _LiveDotState extends State<_LiveDot> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..repeat();
  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 14,
    height: 14,
    child: AnimatedBuilder(
      animation: _c,
      builder: (_, _) => Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 6 + 8 * _c.value,
            height: 6 + 8 * _c.value,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF3DDC84).withValues(alpha: 1 - _c.value),
            ),
          ),
          Container(
            width: 7,
            height: 7,
            decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF3DDC84)),
          ),
        ],
      ),
    ),
  );
}

/// Generic procedural city skyline (no real landmarks).
class _SkylinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rnd = math.Random(7);
    void layer(Color c, double minH, double maxH, double minW, double maxW, {bool windows = false}) {
      final p = Paint()..color = c;
      double x = -10;
      while (x < size.width) {
        final w = minW + rnd.nextDouble() * (maxW - minW);
        final h = size.height * (minH + rnd.nextDouble() * (maxH - minH));
        final r = Rect.fromLTWH(x, size.height - h, w - 3, h);
        canvas.drawRect(r, p);
        if (rnd.nextDouble() > .7) canvas.drawRect(Rect.fromLTWH(x + w * .4, size.height - h - 14, 2, 14), p);
        if (windows) {
          final wp = Paint();
          for (double wy = r.top + 10; wy < size.height - 8; wy += 12) {
            for (double wx = r.left + 6; wx < r.right - 6; wx += 10) {
              final v = rnd.nextDouble();
              if (v > .9) {
                wp.color = (v > .97 ? AppColors.red : const Color(0xFF8FB0FF)).withValues(alpha: .45);
                canvas.drawRect(Rect.fromLTWH(wx, wy, 3, 4), wp);
              }
            }
          }
        }
        x += w;
      }
    }

    layer(const Color(0xFF0C1433), .35, .8, 40, 90);
    layer(const Color(0xFF080B1A), .2, .6, 30, 80, windows: true);
    final fade = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0x0006070C), AppColors.bg],
        stops: [.4, 1],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, fade);
  }

  @override
  bool shouldRepaint(_SkylinePainter old) => false;
}
