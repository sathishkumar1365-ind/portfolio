import 'package:material_ui/material_ui.dart';

import '../content/site_content.dart';
import '../theme/app_theme.dart';
import '../widgets/reveal.dart';
import '../widgets/ui.dart';
import '../widgets/web_painters.dart';

class ServicesSection extends StatelessWidget {
  const ServicesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SectionShell(
      background: AppColors.bgAlt,
      top: 90,
      decor: const [
        Positioned(right: 0, top: 0, width: 600, height: 600, child: AnimatedWeb(anchor: Offset(1.05, -.05), opacity: .08)),
      ],
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SectionHeader(
          number: '04',
          eyebrow: 'Services',
          title: 'Six Ways I Make Your Footage Hit',
          subtitle: 'Focused services I deliver to a professional standard, from scroll-stopping reels to full podcast episodes.',
        ),
        const SizedBox(height: 50),
        ResponsiveGrid(
          minItemWidth: 320,
          children: [
            for (var i = 0; i < services.length; i++)
              Reveal(
                style: RevealStyle.swingLeft,
                delay: Duration(milliseconds: 100 * (i % 3)),
                child: _ServiceCard(s: services[i], index: i),
              ),
          ],
        ),
        const SizedBox(height: 40),
        Reveal(
          child: ComicPanel(
            accent: AppColors.blue,
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 18,
              runSpacing: 14,
              children: [
                Text('ADD-ONS', style: AppText.comic(26, color: AppColors.blueGlow)),
                for (final a in addOnServices) Tag(a, color: Colors.white),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 620),
                  child: Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Padding(padding: EdgeInsets.only(top: 3), child: Icon(Icons.location_on_rounded, size: 18, color: AppColors.red)),
                    const SizedBox(width: 8),
                    Flexible(child: Text(localShootNote, style: AppText.body(14))),
                  ]),
                ),
              ],
            ),
          ),
        ),
      ]),
    );
  }
}

class _ServiceCard extends StatefulWidget {
  const _ServiceCard({required this.s, required this.index});
  final Service s;
  final int index;
  @override
  State<_ServiceCard> createState() => _ServiceCardState();
}

class _ServiceCardState extends State<_ServiceCard> {
  bool _h = false;
  @override
  Widget build(BuildContext context) {
    final red = widget.index.isEven;
    return MouseRegion(
      onEnter: (_) => setState(() => _h = true),
      onExit: (_) => setState(() => _h = false),
      child: ComicPanel(
        accent: red ? AppColors.red : AppColors.blue,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            AnimatedRotation(
              turns: _h ? -.04 : 0,
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutBack,
              child: AnimatedScale(scale: _h ? 1.12 : 1, duration: const Duration(milliseconds: 400), curve: Curves.easeOutBack, child: IconBadge(widget.s.icon, redFirst: red)),
            ),
            const Spacer(),
            Text('0${widget.index + 1}', style: AppText.display(42, color: Colors.white.withValues(alpha: _h ? .22 : .08))),
          ]),
          const SizedBox(height: 22),
          Text(widget.s.title, style: AppText.display(26)),
          const SizedBox(height: 10),
          Text(widget.s.summary, style: AppText.body(14.5)),
          const SizedBox(height: 18),
          Wrap(spacing: 6, runSpacing: 6, children: [
            for (final d in widget.s.deliverables) Tag(d, color: red ? const Color(0xFFFF8A90) : AppColors.blueGlow),
          ]),
          const SizedBox(height: 6),
          // Strand that draws across on hover
          SizedBox(
            height: 22,
            width: double.infinity,
            child: TweenAnimationBuilder<double>(
              tween: Tween(end: _h ? 1 : 0),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutCubic,
              builder: (_, t, _) => CustomPaint(painter: StrandPainter(t: t, from: const Offset(0, .3), to: const Offset(1, .3), sag: 14, color: red ? AppColors.red : AppColors.blueGlow)),
            ),
          ),
        ]),
      ),
    );
  }
}
