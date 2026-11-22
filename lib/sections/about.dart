import 'package:material_ui/material_ui.dart';

import '../content/site_content.dart';
import '../pages/home_page.dart';
import '../theme/app_theme.dart';
import '../widgets/reveal.dart';
import '../widgets/ui.dart';
import '../widgets/web_painters.dart';

class AboutSection extends StatelessWidget {
  const AboutSection({super.key});

  @override
  Widget build(BuildContext context) {
    final wide = context.w >= 980;
    final portrait = Reveal(style: RevealStyle.swingLeft, child: const _Portrait());
    final copy = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SectionHeader(number: '05', eyebrow: 'About Me', title: "Hi, I'm Nikhil."),
      const SizedBox(height: 8),
      Reveal(
        child: Text('A Video Editor & Creative Storyteller.', style: AppText.display(context.isMobile ? 24 : 30, color: AppColors.blueGlow)),
      ),
      const SizedBox(height: 22),
      for (final (i, p) in const [
        "I'm a passionate video editor with approximately one year of experience in creating engaging digital content. My journey includes working in a professional team environment and gaining hands-on freelance experience, where I've developed my skills in short-form content, talking-head videos, podcast editing, UGC ads and creative video production.",
        "I believe great video editing is more than just cutting clips. It's about understanding the story, capturing attention and creating an experience that keeps viewers engaged.",
        "Through Nikhil Cutz, I work with content creators, personal brands and businesses to bring their ideas to life through professional video editing. Currently based in Tamil Nadu, India, I'm available to collaborate with clients worldwide.",
      ].indexed)
        Reveal(
          delay: Duration(milliseconds: 80 * i),
          child: Padding(padding: const EdgeInsets.only(bottom: 16), child: Text(p, style: AppText.body(context.isMobile ? 15 : 16.5))),
        ),
      Reveal(
        child: Text("Let's create something impactful together.", style: AppText.body(18, color: Colors.white, weight: FontWeight.w800)),
      ),
      const SizedBox(height: 26),
      Reveal(
        delay: const Duration(milliseconds: 120),
        child: Wrap(spacing: 12, runSpacing: 12, children: const [
          _Fact(icon: Icons.timelapse_rounded, label: '~1 year editing'),
          _Fact(icon: Icons.groups_rounded, label: 'Team + freelance'),
          _Fact(icon: Icons.location_on_rounded, label: Contact.location),
          _Fact(icon: Icons.public_rounded, label: 'Worldwide remote'),
        ]),
      ),
      const SizedBox(height: 30),
      Reveal(
        delay: const Duration(milliseconds: 200),
        child: CtaButton(label: "Let's Work Together", icon: Icons.arrow_forward_rounded, onTap: () => Nav.to(context, Sec.contact)),
      ),
    ]);
    return SectionShell(
      child: wide
          ? Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
              Expanded(flex: 4, child: portrait),
              const SizedBox(width: 70),
              Expanded(flex: 6, child: copy),
            ])
          : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 380), child: portrait)),
              const SizedBox(height: 50),
              copy,
            ]),
    );
  }
}

/// Portrait placeholder. Swap the inner content for Image.asset('assets/images/nikhil.jpg').
class _Portrait extends StatelessWidget {
  const _Portrait();
  @override
  Widget build(BuildContext context) {
    return Stack(clipBehavior: Clip.none, children: [
      Positioned.fill(
        child: Transform.rotate(
          angle: .05,
          child: Container(decoration: BoxDecoration(color: AppColors.blue, borderRadius: BorderRadius.circular(22))),
        ),
      ),
      Positioned.fill(
        child: Transform.rotate(
          angle: -.035,
          child: Container(decoration: BoxDecoration(color: AppColors.red, borderRadius: BorderRadius.circular(22))),
        ),
      ),
      TiltCard(
        borderRadius: 22,
        child: AspectRatio(
          aspectRatio: 4 / 5,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: Colors.black, width: 3),
              gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF151A30), Color(0xFF0A0C16)]),
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(fit: StackFit.expand, children: [
              CustomPaint(painter: HalftonePainter(color: AppColors.red, opacity: .3)),
              const AnimatedWeb(anchor: Offset(1, 0), opacity: .18, spokes: 10, rings: 6, radiusFactor: .9),
              Center(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  ShaderMask(
                    shaderCallback: (r) => const LinearGradient(colors: [AppColors.red, AppColors.blueGlow]).createShader(r),
                    child: Text('NC', style: AppText.display(130)),
                  ),
                  Text('PHOTO COMING SOON', style: AppText.label(11, color: AppColors.textMute)),
                ]),
              ),
              Positioned(
                left: 16,
                bottom: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(color: Colors.black.withValues(alpha: .7), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white12)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.movie_creation_rounded, size: 18, color: AppColors.red),
                    const SizedBox(width: 8),
                    Text('Nikhil · Editor', style: AppText.body(13, color: Colors.white, weight: FontWeight.w700, height: 1.2)),
                  ]),
                ),
              ),
            ]),
          ),
        ),
      ),
    ]);
  }
}

class _Fact extends StatelessWidget {
  const _Fact({required this.icon, required this.label});
  final IconData icon;
  final String label;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 17, color: AppColors.red),
          const SizedBox(width: 8),
          Text(label, style: AppText.body(13.5, color: Colors.white, weight: FontWeight.w600, height: 1.2)),
        ]),
      );
}

// ───────────────────────── Why choose ─────────────────────────
class WhyChooseSection extends StatelessWidget {
  const WhyChooseSection({super.key});
  @override
  Widget build(BuildContext context) {
    return SectionShell(
      top: 40,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SectionHeader(number: '06', eyebrow: 'Why Choose Nikhil Cutz', title: 'An Editor Who Gets The Assignment'),
        const SizedBox(height: 46),
        ResponsiveGrid(
          minItemWidth: 330,
          spacing: 20,
          children: [
            for (var i = 0; i < whyChoose.length; i++)
              Reveal(
                style: RevealStyle.zoom,
                delay: Duration(milliseconds: 90 * (i % 3)),
                child: _WhyCard(f: whyChoose[i], i: i),
              ),
          ],
        ),
      ]),
    );
  }
}

class _WhyCard extends StatefulWidget {
  const _WhyCard({required this.f, required this.i});
  final Feature f;
  final int i;
  @override
  State<_WhyCard> createState() => _WhyCardState();
}

class _WhyCardState extends State<_WhyCard> {
  bool _h = false;
  @override
  Widget build(BuildContext context) {
    final c = widget.i.isEven ? AppColors.red : AppColors.blue;
    return MouseRegion(
      onEnter: (_) => setState(() => _h = true),
      onExit: (_) => setState(() => _h = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: AppColors.surface,
          gradient: _h ? LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [c.withValues(alpha: .22), AppColors.surface]) : null,
          border: Border.all(color: _h ? c : AppColors.border),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 46,
            height: 46,
            decoration: BoxDecoration(color: _h ? c : c.withValues(alpha: .14), borderRadius: BorderRadius.circular(12)),
            child: Icon(widget.f.icon, color: _h ? Colors.white : c, size: 23),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(widget.f.title, style: AppText.body(17.5, color: Colors.white, weight: FontWeight.w800, height: 1.3)),
              const SizedBox(height: 6),
              Text(widget.f.body, style: AppText.body(14.5)),
            ]),
          ),
        ]),
      ),
    );
  }
}

// ───────────────────────── Industries ─────────────────────────
class IndustriesSection extends StatelessWidget {
  const IndustriesSection({super.key});
  @override
  Widget build(BuildContext context) {
    return SectionShell(
      top: 40,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SectionHeader(number: '07', eyebrow: 'Industries Served', title: 'Built For Creators And Businesses'),
        const SizedBox(height: 46),
        ResponsiveGrid(
          minItemWidth: 260,
          spacing: 16,
          maxColumns: 3,
          children: [
            for (var i = 0; i < industries.length; i++)
              Reveal(
                style: i.isEven ? RevealStyle.swingLeft : RevealStyle.swingRight,
                delay: Duration(milliseconds: 70 * i),
                child: _IndustryTile(f: industries[i], i: i),
              ),
          ],
        ),
      ]),
    );
  }
}

class _IndustryTile extends StatefulWidget {
  const _IndustryTile({required this.f, required this.i});
  final Feature f;
  final int i;
  @override
  State<_IndustryTile> createState() => _IndustryTileState();
}

class _IndustryTileState extends State<_IndustryTile> {
  bool _h = false;
  @override
  Widget build(BuildContext context) {
    final c = widget.i.isEven ? AppColors.red : AppColors.blue;
    return MouseRegion(
      onEnter: (_) => setState(() => _h = true),
      onExit: (_) => setState(() => _h = false),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Container(
          decoration: BoxDecoration(color: AppColors.surface, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(14)),
          child: Stack(children: [
            // Fill wipes in from the left on hover
            Positioned.fill(
              child: AnimatedFractionallySizedBox(
                duration: const Duration(milliseconds: 380),
                curve: Curves.easeOutCubic,
                alignment: Alignment.centerLeft,
                widthFactor: _h ? 1 : 0,
                child: DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(colors: [c, c.withValues(alpha: .55)]))),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(22),
              child: Row(children: [
                Icon(widget.f.icon, color: _h ? Colors.white : c, size: 30),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(widget.f.title, style: AppText.display(21)),
                    const SizedBox(height: 4),
                    Text(widget.f.body, style: AppText.body(13.5, color: _h ? Colors.white : AppColors.textDim, height: 1.45)),
                  ]),
                ),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}
