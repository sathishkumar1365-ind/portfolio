import 'dart:ui';

import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import '../content/site_content.dart';
import '../sections/about.dart';
import '../sections/contact.dart';
import '../sections/faq.dart';
import '../sections/hero.dart';
import '../sections/marquee.dart';
import '../sections/portfolio.dart';
import '../sections/pricing.dart';
import '../sections/process.dart';
import '../sections/services.dart';
import '../theme/app_theme.dart';
import '../widgets/reveal.dart';
import '../widgets/ui.dart';

enum Sec { home, work, services, about, process, pricing, faq, contact }

const _navItems = [
  (Sec.work, 'Work'),
  (Sec.services, 'Services'),
  (Sec.about, 'About'),
  (Sec.process, 'Process'),
  (Sec.pricing, 'Pricing'),
  (Sec.faq, 'FAQ'),
  (Sec.contact, 'Contact'),
];

Future<void> openLink(String url) => launchUrl(Uri.parse(url), webOnlyWindowName: '_blank');

/// Lets any section jump to another (e.g. hero CTAs → work / contact).
class Nav extends InheritedWidget {
  const Nav({super.key, required this.go, required super.child});
  final void Function(Sec) go;
  static void to(BuildContext context, Sec s) => context.dependOnInheritedWidgetOfExactType<Nav>()!.go(s);
  @override
  bool updateShouldNotify(Nav old) => false;
}

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.introDone});
  final bool introDone;
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _scroll = ScrollController();
  final _keys = {for (final s in Sec.values) s: GlobalKey()};
  final _progress = ValueNotifier<double>(0);
  final _scrolled = ValueNotifier<bool>(false);
  final _active = ValueNotifier<Sec>(Sec.home);

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  void _onScroll() {
    final p = _scroll.position;
    _progress.value = p.maxScrollExtent <= 0 ? 0 : (p.pixels / p.maxScrollExtent).clamp(0, 1);
    _scrolled.value = p.pixels > 40;
    final probe = MediaQuery.sizeOf(context).height * .35;
    var current = Sec.home;
    for (final s in Sec.values) {
      final box = _keys[s]!.currentContext?.findRenderObject() as RenderBox?;
      if (box == null || !box.attached) continue;
      if (box.localToGlobal(Offset.zero).dy <= probe) current = s;
    }
    _active.value = current;
  }

  void _go(Sec s) {
    final ctx = _keys[s]!.currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(ctx, duration: const Duration(milliseconds: 1100), curve: Curves.easeInOutCubic);
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  Widget _anchor(Sec s, Widget child) => KeyedSubtree(key: _keys[s], child: child);

  @override
  Widget build(BuildContext context) {
    return Nav(
      go: _go,
      child: Scaffold(
        backgroundColor: AppColors.bg,
        body: ScrollScope(
          controller: _scroll,
          child: Stack(children: [
            Scrollbar(
              controller: _scroll,
              child: SingleChildScrollView(
                controller: _scroll,
                child: Column(children: [
                  _anchor(Sec.home, HeroSection(start: widget.introDone)),
                  const ServiceMarquee(),
                  _anchor(Sec.work, const Column(children: [ShowreelSection(), PortfolioSection(), CaseStudiesSection()])),
                  const SlashDivider(from: AppColors.bg, to: AppColors.bgAlt),
                  _anchor(Sec.services, const ServicesSection()),
                  const SlashDivider(flip: true, from: AppColors.bgAlt, to: AppColors.bg),
                  _anchor(Sec.about, const Column(children: [AboutSection(), WhyChooseSection(), IndustriesSection()])),
                  const SlashDivider(from: AppColors.bg, to: AppColors.bgAlt),
                  _anchor(Sec.process, const Column(children: [WorkflowSection(), SoftwareSection(), ExpectSection()])),
                  const SlashDivider(flip: true, from: AppColors.bgAlt, to: AppColors.bg),
                  _anchor(Sec.pricing, const PricingSection()),
                  _anchor(Sec.faq, const FaqSection()),
                  _anchor(Sec.contact, const ContactSection()),
                  const FooterSection(),
                ]),
              ),
            ),
            _NavBar(scrolled: _scrolled, active: _active, progress: _progress, onGo: _go),
            const Positioned(right: 20, bottom: 20, child: _WhatsAppFab()),
          ]),
        ),
      ),
    );
  }
}

class _NavBar extends StatelessWidget {
  const _NavBar({required this.scrolled, required this.active, required this.progress, required this.onGo});
  final ValueNotifier<bool> scrolled;
  final ValueNotifier<Sec> active;
  final ValueNotifier<double> progress;
  final void Function(Sec) onGo;

  @override
  Widget build(BuildContext context) {
    final desktop = context.w >= 1000;
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: ValueListenableBuilder<bool>(
        valueListenable: scrolled,
        builder: (context, isScrolled, _) => ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: isScrolled ? 14 : 0, sigmaY: isScrolled ? 14 : 0),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              color: isScrolled ? AppColors.bg.withValues(alpha: .78) : Colors.transparent,
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                AnimatedPadding(
                  duration: const Duration(milliseconds: 300),
                  padding: EdgeInsets.symmetric(horizontal: context.gutter, vertical: isScrolled ? 12 : 22),
                  child: Row(children: [
                    _Logo(onTap: () => onGo(Sec.home)),
                    const Spacer(),
                    if (desktop) ...[
                      ValueListenableBuilder<Sec>(
                        valueListenable: active,
                        builder: (_, a, _) => Row(children: [
                          for (final (s, label) in _navItems) _NavLink(label: label, active: a == s, onTap: () => onGo(s)),
                        ]),
                      ),
                      const SizedBox(width: 18),
                      CtaButton(label: "Let's Work Together", compact: true, onTap: () => onGo(Sec.contact)),
                    ] else
                      IconButton(
                        tooltip: 'Menu',
                        onPressed: () => _openMenu(context),
                        icon: const Icon(Icons.menu_rounded, color: Colors.white, size: 30),
                      ),
                  ]),
                ),
                ValueListenableBuilder<double>(
                  valueListenable: progress,
                  builder: (_, p, _) => Align(
                    alignment: Alignment.centerLeft,
                    child: FractionallySizedBox(
                      widthFactor: p,
                      child: Container(height: 2.5, decoration: const BoxDecoration(gradient: AppColors.heroGradient)),
                    ),
                  ),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }

  void _openMenu(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierLabel: 'Close menu',
      barrierDismissible: true,
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 500),
      pageBuilder: (ctx, a, _) => _MobileMenu(anim: a, onGo: (s) {
        Navigator.of(ctx).pop();
        Future.delayed(const Duration(milliseconds: 250), () => onGo(s));
      }),
    );
  }
}

class _MobileMenu extends StatelessWidget {
  const _MobileMenu({required this.anim, required this.onGo});
  final Animation<double> anim;
  final void Function(Sec) onGo;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: anim,
      builder: (context, _) {
        final t = Curves.easeOutCubic.transform(anim.value);
        return Material(
          color: Colors.transparent,
          child: ClipPath(
            clipper: _CircleReveal(t),
            child: Container(
              color: AppColors.bg,
              child: Stack(children: [
                Positioned.fill(child: CustomPaint(painter: _MenuBg())),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        _Logo(onTap: () => onGo(Sec.home)),
                        const Spacer(),
                        IconButton(
                          tooltip: 'Close menu',
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close_rounded, color: Colors.white, size: 32),
                        ),
                      ]),
                      const SizedBox(height: 30),
                      for (var i = 0; i < _navItems.length; i++)
                        Builder(builder: (_) {
                          final local = ((anim.value - i * .06) / .6).clamp(0.0, 1.0);
                          final e = Curves.easeOutBack.transform(local);
                          return Opacity(
                            opacity: local,
                            child: Transform.translate(
                              offset: Offset(-60 * (1 - e), 0),
                              child: Transform.rotate(
                                angle: -.08 * (1 - e),
                                alignment: Alignment.topLeft,
                                child: InkWell(
                                  onTap: () => onGo(_navItems[i].$1),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    child: Row(children: [
                                      Text('0${i + 1}', style: AppText.comic(18, color: i.isEven ? AppColors.red : AppColors.blueGlow)),
                                      const SizedBox(width: 16),
                                      Text(_navItems[i].$2.toUpperCase(), style: AppText.display(40)),
                                    ]),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      const Spacer(),
                      CtaButton(label: "Let's Work Together", icon: Icons.arrow_forward_rounded, onTap: () => onGo(Sec.contact)),
                    ]),
                  ),
                ),
              ]),
            ),
          ),
        );
      },
    );
  }
}

class _CircleReveal extends CustomClipper<Path> {
  _CircleReveal(this.t);
  final double t;
  @override
  Path getClip(Size s) => Path()..addOval(Rect.fromCircle(center: Offset(s.width - 40, 40), radius: s.longestSide * 1.3 * t));
  @override
  bool shouldReclip(_CircleReveal old) => old.t != t;
}

class _MenuBg extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..shader = RadialGradient(colors: [AppColors.red.withValues(alpha: .25), Colors.transparent])
          .createShader(Rect.fromCircle(center: Offset(size.width, 0), radius: size.width));
    canvas.drawRect(Offset.zero & size, p);
    final b = Paint()
      ..shader = RadialGradient(colors: [AppColors.blue.withValues(alpha: .25), Colors.transparent])
          .createShader(Rect.fromCircle(center: Offset(0, size.height), radius: size.width));
    canvas.drawRect(Offset.zero & size, b);
  }

  @override
  bool shouldRepaint(_) => false;
}

class _Logo extends StatefulWidget {
  const _Logo({required this.onTap});
  final VoidCallback onTap;
  @override
  State<_Logo> createState() => _LogoState();
}

class _LogoState extends State<_Logo> {
  bool _h = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _h = true),
      onExit: (_) => setState(() => _h = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Semantics(
          label: 'Nikhil Cutz home',
          button: true,
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            AnimatedRotation(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOutBack,
              turns: _h ? .125 : 0,
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [AppColors.red, AppColors.blue], begin: Alignment.topLeft, end: Alignment.bottomRight),
                  borderRadius: BorderRadius.circular(9),
                  border: Border.all(color: Colors.white24),
                ),
                alignment: Alignment.center,
                child: Transform.rotate(angle: _h ? -.785 : 0, child: Text('NC', style: AppText.display(15))),
              ),
            ),
            const SizedBox(width: 10),
            Text('NIKHIL', style: AppText.display(22)),
            Text(' CUTZ', style: AppText.display(22, color: AppColors.red)),
          ]),
        ),
      ),
    );
  }
}

class _NavLink extends StatefulWidget {
  const _NavLink({required this.label, required this.active, required this.onTap});
  final String label;
  final bool active;
  final VoidCallback onTap;
  @override
  State<_NavLink> createState() => _NavLinkState();
}

class _NavLinkState extends State<_NavLink> {
  bool _h = false;
  @override
  Widget build(BuildContext context) {
    final on = _h || widget.active;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _h = true),
      onExit: (_) => setState(() => _h = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Semantics(
          link: true,
          label: widget.label,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: AppText.body(14.5, color: on ? Colors.white : AppColors.textDim, weight: FontWeight.w700, height: 1.2),
                child: Text(widget.label),
              ),
              const SizedBox(height: 5),
              AnimatedContainer(
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeOutCubic,
                height: 2.5,
                width: on ? 22 : 0,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [AppColors.red, AppColors.blue]),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

class _WhatsAppFab extends StatefulWidget {
  const _WhatsAppFab();
  @override
  State<_WhatsAppFab> createState() => _WhatsAppFabState();
}

class _WhatsAppFabState extends State<_WhatsAppFab> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
  bool _h = false;
  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Reveal(
      style: RevealStyle.zoom,
      delay: const Duration(milliseconds: 1600),
      child: Tooltip(
        message: 'Chat on WhatsApp',
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) => setState(() => _h = true),
          onExit: (_) => setState(() => _h = false),
          child: GestureDetector(
            onTap: () => openLink(Contact.whatsappUrl("Hi Nikhil, I'd like to discuss a video editing project.")),
            child: Semantics(
              button: true,
              label: 'Chat on WhatsApp',
              child: AnimatedBuilder(
                animation: _c,
                builder: (_, child) => Stack(alignment: Alignment.center, children: [
                  Container(
                    width: 58 + 26 * _c.value,
                    height: 58 + 26 * _c.value,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFF25D366).withValues(alpha: .35 * (1 - _c.value))),
                  ),
                  child!,
                ]),
                child: AnimatedScale(
                  scale: _h ? 1.1 : 1,
                  duration: const Duration(milliseconds: 200),
                  child: Container(
                    width: 58,
                    height: 58,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF1FAF55),
                      boxShadow: [BoxShadow(color: AppColors.blue, offset: Offset(3, 3)), BoxShadow(color: Colors.black54, blurRadius: 16)],
                    ),
                    child: const Icon(Icons.chat_rounded, color: Colors.white, size: 28),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
