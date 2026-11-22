import 'package:material_ui/material_ui.dart';

import '../content/site_content.dart';
import '../theme/app_theme.dart';
import '../widgets/reveal.dart';
import '../widgets/ui.dart';
import '../widgets/video.dart';
import '../widgets/web_painters.dart';

IconData _iconFor(String category) => switch (category) {
      'Talking-Head' => Icons.record_voice_over_rounded,
      'Podcast' || 'Podcast Editing' => Icons.mic_rounded,
      'UGC / Product Ads' || 'UGC & Video Ads' => Icons.shopping_bag_rounded,
      'Business Reels' => Icons.business_center_rounded,
      'YouTube / Long-Form' => Icons.smart_display_rounded,
      'Motion Graphics' => Icons.auto_awesome_rounded,
      _ => Icons.movie_rounded,
    };

// ───────────────────────── Showreel ─────────────────────────
class ShowreelSection extends StatelessWidget {
  const ShowreelSection({super.key});

  static const _includes = ['Talking-head edits', 'Podcast clips', 'Animated captions', 'B-roll', 'Color grading', 'Sound design', 'Brand promos'];

  @override
  Widget build(BuildContext context) {
    final wide = context.w >= 1000;
    final text = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SectionHeader(number: '01', eyebrow: 'Showreel', title: 'The Cut Before The Cut', subtitle: 'A 30–45 second montage of my strongest work, with the best moments in the first five seconds.'),
      const SizedBox(height: 26),
      Reveal(
        delay: const Duration(milliseconds: 200),
        child: Wrap(spacing: 8, runSpacing: 8, children: [for (var i = 0; i < _includes.length; i++) Tag(_includes[i], color: i.isEven ? AppColors.blueGlow : const Color(0xFFFF6B72))]),
      ),
    ]);
    final reel = Reveal(style: RevealStyle.swingRight, child: const _ShowreelPlayer());
    return SectionShell(
      top: 130,
      bottom: 60,
      child: wide
          ? Row(crossAxisAlignment: CrossAxisAlignment.center, children: [Expanded(flex: 4, child: text), const SizedBox(width: 60), Expanded(flex: 6, child: reel)])
          : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [text, const SizedBox(height: 40), reel]),
    );
  }
}

class _ShowreelPlayer extends StatefulWidget {
  const _ShowreelPlayer();
  @override
  State<_ShowreelPlayer> createState() => _ShowreelPlayerState();
}

class _ShowreelPlayerState extends State<_ShowreelPlayer> {
  bool _h = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _h = true),
      onExit: (_) => setState(() => _h = false),
      child: GestureDetector(
        onTap: () => openVideo(context, url: showreelUrl, title: 'Nikhil Cutz Showreel'),
        child: Semantics(
          button: true,
          label: 'Play the Nikhil Cutz showreel',
          child: TiltCard(
            maxTilt: .08,
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: _h ? AppColors.red : AppColors.border, width: 2),
                  boxShadow: [BoxShadow(color: AppColors.blue.withValues(alpha: _h ? 1 : .6), offset: const Offset(12, 12))],
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(fit: StackFit.expand, children: [
                  const Poster(icon: Icons.movie_filter_rounded, seed: 1),
                  HoverPreview(url: showreelUrl, active: _h),
                  const DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Color(0xD9000000)], stops: [.45, 1]))),
                  // Film-strip edges
                  const Positioned(left: 0, right: 0, top: 0, height: 16, child: _Sprockets()),
                  const Positioned(left: 0, right: 0, bottom: 0, height: 16, child: _Sprockets()),
                  Center(child: PlayBadge(size: 76, hot: _h)),
                  Positioned(
                    left: 24,
                    bottom: 30,
                    right: 24,
                    child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                          Text('SHOWREEL 2026', style: AppText.comic(context.isMobile ? 26 : 40)),
                          Text('Nikhil Cutz · Video Editor & Creative Storyteller', style: AppText.body(13, color: Colors.white70)),
                        ]),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: AppColors.red, borderRadius: BorderRadius.circular(4)),
                        child: Text('0:45', style: AppText.label(12)),
                      ),
                    ]),
                  ),
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Sprockets extends StatelessWidget {
  const _Sprockets();
  @override
  Widget build(BuildContext context) => CustomPaint(painter: _SprocketPainter());
}

class _SprocketPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size s) {
    canvas.drawRect(Offset.zero & s, Paint()..color = Colors.black.withValues(alpha: .75));
    final p = Paint()..color = Colors.white.withValues(alpha: .25);
    for (double x = 8; x < s.width; x += 22) {
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(x, 4, 10, s.height - 8), const Radius.circular(2)), p);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

// ───────────────────────── Portfolio ─────────────────────────
class PortfolioSection extends StatefulWidget {
  const PortfolioSection({super.key});
  @override
  State<PortfolioSection> createState() => _PortfolioSectionState();
}

class _PortfolioSectionState extends State<PortfolioSection> {
  String _cat = 'All';

  @override
  Widget build(BuildContext context) {
    final list = _cat == 'All' ? projects : projects.where((p) => p.category == _cat).toList();
    return SectionShell(
      top: 80,
      decor: const [Positioned(left: 0, top: 0, width: 520, height: 520, child: AnimatedWeb(anchor: Offset(-.05, -.05), opacity: .07, radiusFactor: 1))],
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SectionHeader(number: '02', eyebrow: 'Selected Portfolio', title: 'Work, Sorted By What You Need', subtitle: 'Pick a category to see edits in that style. Hover to preview, tap to watch.'),
        const SizedBox(height: 34),
        Reveal(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            child: Row(children: [
              for (final c in portfolioCategories)
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: _FilterChip(label: c, selected: c == _cat, onTap: () => setState(() => _cat = c)),
                ),
            ]),
          ),
        ),
        const SizedBox(height: 34),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 450),
          switchInCurve: Curves.easeOutCubic,
          transitionBuilder: (child, a) => FadeTransition(
            opacity: a,
            child: SlideTransition(position: Tween(begin: const Offset(0, .04), end: Offset.zero).animate(a), child: child),
          ),
          child: ResponsiveGrid(
            key: ValueKey(_cat),
            minItemWidth: 330,
            children: [
              for (var i = 0; i < list.length; i++)
                Reveal(
                  style: i.isEven ? RevealStyle.swingLeft : RevealStyle.swingRight,
                  delay: Duration(milliseconds: 90 * (i % 3)),
                  child: ProjectCard(project: list[i], seed: i),
                ),
            ],
          ),
        ),
      ]),
    );
  }
}

class _FilterChip extends StatefulWidget {
  const _FilterChip({required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;
  @override
  State<_FilterChip> createState() => _FilterChipState();
}

class _FilterChipState extends State<_FilterChip> {
  bool _h = false;
  @override
  Widget build(BuildContext context) {
    final sel = widget.selected;
    return Semantics(
      button: true,
      selected: sel,
      label: 'Show ${widget.label}',
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _h = true),
        onExit: (_) => setState(() => _h = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
            decoration: BoxDecoration(
              gradient: sel ? const LinearGradient(colors: [AppColors.red, AppColors.blue]) : null,
              color: sel ? null : (_h ? AppColors.surfaceHi : AppColors.surface),
              borderRadius: BorderRadius.circular(40),
              border: Border.all(color: sel ? Colors.transparent : (_h ? AppColors.blue : AppColors.border)),
              boxShadow: sel ? [BoxShadow(color: AppColors.red.withValues(alpha: .35), blurRadius: 18)] : null,
            ),
            child: Text(widget.label, style: AppText.body(14, color: sel || _h ? Colors.white : AppColors.textDim, weight: FontWeight.w700, height: 1.2)),
          ),
        ),
      ),
    );
  }
}

class ProjectCard extends StatefulWidget {
  const ProjectCard({super.key, required this.project, required this.seed});
  final Project project;
  final int seed;
  @override
  State<ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends State<ProjectCard> {
  bool _h = false;
  @override
  Widget build(BuildContext context) {
    final p = widget.project;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _h = true),
      onExit: (_) => setState(() => _h = false),
      child: GestureDetector(
        onTap: () => openVideo(context, url: p.videoUrl, title: p.title),
        child: Semantics(
          button: true,
          label: 'Play ${p.title}, ${p.category} edit',
          child: TiltCard(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 260),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: _h ? AppColors.red : AppColors.border, width: 1.4),
                boxShadow: [BoxShadow(color: AppColors.blue.withValues(alpha: _h ? 1 : 0), offset: Offset(_h ? 8 : 0, _h ? 8 : 0))],
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                AspectRatio(
                  aspectRatio: 16 / 11,
                  child: Stack(fit: StackFit.expand, children: [
                    Poster(icon: _iconFor(p.category), seed: widget.seed),
                    HoverPreview(url: p.videoUrl, active: _h),
                    Center(child: PlayBadge(size: 50, hot: _h)),
                    Positioned(top: 14, left: 14, child: _CategoryStamp(p.category)),
                    if (p.vertical)
                      Positioned(
                        top: 14,
                        right: 14,
                        child: Tooltip(
                          message: 'Vertical 9:16 edit',
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(8)),
                            child: const Icon(Icons.stay_current_portrait_rounded, size: 16, color: Colors.white),
                          ),
                        ),
                      ),
                  ]),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(22, 20, 22, 22),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(p.title, style: AppText.display(24)),
                    const SizedBox(height: 8),
                    Text(p.description, style: AppText.body(14.5)),
                    const SizedBox(height: 16),
                    Row(children: [
                      const Icon(Icons.tune_rounded, size: 15, color: AppColors.blueGlow),
                      const SizedBox(width: 6),
                      Expanded(child: Text(p.style, style: AppText.body(13, color: Colors.white, weight: FontWeight.w600))),
                    ]),
                    const SizedBox(height: 6),
                    Row(children: [
                      const Icon(Icons.layers_rounded, size: 15, color: Color(0xFFFF6B72)),
                      const SizedBox(width: 6),
                      Expanded(child: Text(p.software, style: AppText.body(13, color: AppColors.textDim, weight: FontWeight.w600))),
                    ]),
                  ]),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryStamp extends StatelessWidget {
  const _CategoryStamp(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Transform.rotate(
        angle: -.04,
        child: Container(
          padding: const EdgeInsets.fromLTRB(10, 5, 10, 3),
          decoration: BoxDecoration(
            color: AppColors.red,
            border: Border.all(color: Colors.black, width: 2),
            boxShadow: const [BoxShadow(color: AppColors.blue, offset: Offset(3, 3))],
          ),
          child: Text(text.toUpperCase(), style: AppText.comic(15)),
        ),
      );
}

// ───────────────────────── Case Studies ─────────────────────────
class CaseStudiesSection extends StatelessWidget {
  const CaseStudiesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SectionShell(
      top: 60,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SectionHeader(number: '03', eyebrow: 'Project Case Studies', title: 'From Raw Footage To Final Cut', subtitle: 'What the project needed, how I approached the edit, and what was delivered.'),
        const SizedBox(height: 50),
        for (var i = 0; i < caseStudies.length; i++) ...[
          _CaseRow(cs: caseStudies[i], flip: i.isOdd, seed: i + 3),
          if (i < caseStudies.length - 1) const SizedBox(height: 70),
        ],
      ]),
    );
  }
}

class _CaseRow extends StatelessWidget {
  const _CaseRow({required this.cs, required this.flip, required this.seed});
  final CaseStudy cs;
  final bool flip;
  final int seed;

  @override
  Widget build(BuildContext context) {
    final wide = context.w >= 960;
    final media = Reveal(
      style: flip ? RevealStyle.swingRight : RevealStyle.swingLeft,
      child: _CaseMedia(cs: cs, seed: seed),
    );
    final text = Reveal(
      style: flip ? RevealStyle.slideLeft : RevealStyle.slideRight,
      delay: const Duration(milliseconds: 150),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Tag(cs.category, color: flip ? AppColors.blueGlow : const Color(0xFFFF6B72)),
        const SizedBox(height: 14),
        Text(cs.title, style: AppText.display(context.isMobile ? 30 : 40)),
        const SizedBox(height: 22),
        _step('THE BRIEF', cs.brief, AppColors.red),
        _step('THE APPROACH', cs.approach, AppColors.blue),
        _step('THE OUTPUT', cs.output, Colors.white),
      ]),
    );
    if (!wide) return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [media, const SizedBox(height: 30), text]);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: flip
          ? [Expanded(child: text), const SizedBox(width: 60), Expanded(child: media)]
          : [Expanded(child: media), const SizedBox(width: 60), Expanded(child: text)],
    );
  }

  Widget _step(String label, String body, Color c) => Padding(
        padding: const EdgeInsets.only(bottom: 18),
        child: IntrinsicHeight(
          child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Container(width: 3, decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(2))),
            const SizedBox(width: 16),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(label, style: AppText.label(11.5, color: c == Colors.white ? AppColors.textDim : c)),
                const SizedBox(height: 6),
                Text(body, style: AppText.body(15.5, color: const Color(0xFFD4D4DC))),
              ]),
            ),
          ]),
        ),
      );
}

class _CaseMedia extends StatefulWidget {
  const _CaseMedia({required this.cs, required this.seed});
  final CaseStudy cs;
  final int seed;
  @override
  State<_CaseMedia> createState() => _CaseMediaState();
}

class _CaseMediaState extends State<_CaseMedia> {
  bool _h = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _h = true),
      onExit: (_) => setState(() => _h = false),
      child: GestureDetector(
        onTap: () => openVideo(context, url: widget.cs.videoUrl, title: widget.cs.title),
        child: Semantics(
          button: true,
          label: 'Play ${widget.cs.title}',
          child: Stack(clipBehavior: Clip.none, children: [
            // Comic panel stack behind
            Positioned.fill(
              child: Transform.rotate(
                angle: -.04,
                child: Container(decoration: BoxDecoration(color: widget.seed.isOdd ? AppColors.red : AppColors.blue, borderRadius: BorderRadius.circular(18))),
              ),
            ),
            TiltCard(
              maxTilt: .1,
              child: AspectRatio(
                aspectRatio: 16 / 10,
                child: Container(
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.black, width: 3)),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(fit: StackFit.expand, children: [
                    Poster(icon: _iconFor(widget.cs.category), seed: widget.seed),
                    HoverPreview(url: widget.cs.videoUrl, active: _h),
                    Center(child: PlayBadge(size: 60, hot: _h)),
                  ]),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
