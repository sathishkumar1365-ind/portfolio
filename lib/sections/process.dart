import 'package:material_ui/material_ui.dart';

import '../content/site_content.dart';
import '../theme/app_theme.dart';
import '../widgets/reveal.dart';
import '../widgets/ui.dart';

/// Reports how far (0..1) its child has travelled through the viewport.
class ScrollProgress extends StatefulWidget {
  const ScrollProgress({super.key, required this.builder});
  final Widget Function(BuildContext, double) builder;
  @override
  State<ScrollProgress> createState() => _ScrollProgressState();
}

class _ScrollProgressState extends State<ScrollProgress> {
  ScrollController? _s;
  double _p = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final s = ScrollScope.of(context);
    if (s != _s) {
      _s?.removeListener(_update);
      _s = s;
      _s?.addListener(_update);
    }
  }

  void _update() {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.attached) return;
    final vh = MediaQuery.sizeOf(context).height;
    final top = box.localToGlobal(Offset.zero).dy;
    final p = ((vh * .7 - top) / box.size.height).clamp(0.0, 1.0);
    if ((p - _p).abs() > .01 || (p != _p && (p == 0 || p == 1))) setState(() => _p = p);
  }

  @override
  void dispose() {
    _s?.removeListener(_update);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, _p);
}

// ───────────────────────── Workflow ─────────────────────────
class WorkflowSection extends StatelessWidget {
  const WorkflowSection({super.key});

  @override
  Widget build(BuildContext context) {
    final wide = context.w >= 900;
    return SectionShell(
      background: AppColors.bgAlt,
      top: 90,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            number: '08',
            eyebrow: 'Editing Workflow',
            title: 'Five Steps, Zero Guesswork',
            subtitle: 'From the first chat to the final file, you always know where your project is.',
          ),
          const SizedBox(height: 60),
          ScrollProgress(
            builder: (context, p) => Stack(
              children: [
                // The web strand spine, filling as you scroll.
                if (!wide) Positioned(top: 0, bottom: 0, left: 23, width: 4, child: _Spine(p: p)),
                if (wide)
                  Positioned.fill(
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: SizedBox(
                        width: 4,
                        height: double.infinity,
                        child: _Spine(p: p),
                      ),
                    ),
                  ),
                Column(
                  children: [for (var i = 0; i < workflow.length; i++) _Step(i: i, f: workflow[i], wide: wide, lit: p * workflow.length > i + .2)],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Spine extends StatelessWidget {
  const _Spine({required this.p});
  final double p;
  @override
  Widget build(BuildContext context) => Stack(
    children: [
      Positioned.fill(
        child: Container(
          decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
        ),
      ),
      Positioned.fill(
        child: FractionallySizedBox(
          alignment: Alignment.topCenter,
          heightFactor: p,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [AppColors.red, AppColors.blue]),
              boxShadow: [BoxShadow(color: AppColors.red.withValues(alpha: .6), blurRadius: 12)],
            ),
          ),
        ),
      ),
    ],
  );
}

class _Step extends StatelessWidget {
  const _Step({required this.i, required this.f, required this.wide, required this.lit});
  final int i;
  final Feature f;
  final bool wide;
  final bool lit;

  @override
  Widget build(BuildContext context) {
    final c = i.isEven ? AppColors.red : AppColors.blue;
    final node = AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic, // no overshoot: colours and shadows can't go past their end values
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: lit ? c : AppColors.surface,
        border: Border.all(color: lit ? Colors.white : AppColors.border, width: 2.5),
        boxShadow: lit ? [BoxShadow(color: c.withValues(alpha: .7), blurRadius: 22)] : null,
      ),
      alignment: Alignment.center,
      child: Text('0${i + 1}', style: AppText.comic(20)),
    );
    final card = Reveal(
      style: wide ? (i.isEven ? RevealStyle.swingLeft : RevealStyle.swingRight) : RevealStyle.slideRight,
      child: ComicPanel(
        accent: c,
        padding: const EdgeInsets.all(24),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconBadge(f.icon, size: 46, redFirst: i.isEven),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(f.title, style: AppText.display(23)),
                  const SizedBox(height: 6),
                  Text(f.body, style: AppText.body(14.5)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
    if (!wide) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 26),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            node,
            const SizedBox(width: 18),
            Expanded(child: card),
          ],
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 30),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(child: i.isEven ? card : const SizedBox()),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 30), child: node),
          Expanded(child: i.isOdd ? card : const SizedBox()),
        ],
      ),
    );
  }
}

// ───────────────────────── Software & Skills ─────────────────────────
class SoftwareSection extends StatelessWidget {
  const SoftwareSection({super.key});
  @override
  Widget build(BuildContext context) {
    return SectionShell(
      background: AppColors.bgAlt,
      top: 40,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(number: '09', eyebrow: 'Software & Skills', title: 'The Toolkit'),
          const SizedBox(height: 44),
          ResponsiveGrid(
            minItemWidth: 250,
            maxColumns: 4,
            spacing: 18,
            children: [
              for (var i = 0; i < software.length; i++)
                Reveal(
                  style: RevealStyle.zoom,
                  delay: Duration(milliseconds: 90 * i),
                  child: _ToolCard(s: software[i], i: i),
                ),
            ],
          ),
          const SizedBox(height: 30),
          Reveal(
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (var i = 0; i < skills.length; i++)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(40),
                      border: Border.all(color: i.isEven ? AppColors.red.withValues(alpha: .5) : AppColors.blue.withValues(alpha: .6)),
                    ),
                    child: Text(
                      skills[i],
                      style: AppText.body(14, color: Colors.white, weight: FontWeight.w600, height: 1.2),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ToolCard extends StatelessWidget {
  const _ToolCard({required this.s, required this.i});
  final Software s;
  final int i;
  @override
  Widget build(BuildContext context) {
    return TiltCard(
      borderRadius: 16,
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: i.isEven ? AppColors.redDeep : AppColors.blueDeep,
                border: Border.all(color: i.isEven ? AppColors.red : AppColors.blue, width: 2),
              ),
              alignment: Alignment.center,
              child: Text(s.short, style: AppText.display(22)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s.name,
                    style: AppText.body(16, color: Colors.white, weight: FontWeight.w800, height: 1.25),
                  ),
                  const SizedBox(height: 3),
                  Text(s.area, style: AppText.body(13, height: 1.35)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ───────────────────────── What You Can Expect ─────────────────────────
class ExpectSection extends StatelessWidget {
  const ExpectSection({super.key});
  @override
  Widget build(BuildContext context) {
    return SectionShell(
      background: AppColors.bgAlt,
      top: 40,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(number: '10', eyebrow: 'What You Can Expect', title: 'Working With Me'),
          const SizedBox(height: 44),
          ResponsiveGrid(
            minItemWidth: 250,
            maxColumns: 4,
            spacing: 18,
            children: [
              for (var i = 0; i < expectations.length; i++)
                Reveal(
                  style: RevealStyle.swingLeft,
                  delay: Duration(milliseconds: 100 * i),
                  child: ComicPanel(
                    accent: i.isEven ? AppColors.red : AppColors.blue,
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(expectations[i].icon, color: i.isEven ? AppColors.red : AppColors.blueGlow, size: 32),
                        const SizedBox(height: 16),
                        Text(
                          expectations[i].title,
                          style: AppText.body(17, color: Colors.white, weight: FontWeight.w800, height: 1.3),
                        ),
                        const SizedBox(height: 8),
                        Text(expectations[i].body, style: AppText.body(14)),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
