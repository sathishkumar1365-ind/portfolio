import 'package:material_ui/material_ui.dart';

import '../content/site_content.dart';
import '../pages/home_page.dart';
import '../theme/app_theme.dart';
import '../widgets/reveal.dart';
import '../widgets/ui.dart';
import '../widgets/web_painters.dart';

class PricingSection extends StatefulWidget {
  const PricingSection({super.key});
  @override
  State<PricingSection> createState() => _PricingSectionState();
}

class _PricingSectionState extends State<PricingSection> {
  bool _monthly = false;

  @override
  Widget build(BuildContext context) {
    final tiers = _monthly ? monthlyPricing : singleReelPricing;
    return SectionShell(
      top: 90,
      decor: const [Positioned(left: 0, bottom: 0, width: 560, height: 560, child: AnimatedWeb(anchor: Offset(-.05, 1.05), opacity: .07))],
      child: Column(
        children: [
          const SectionHeader(
            number: '11',
            eyebrow: 'Pricing',
            title: 'Simple Pricing For India',
            subtitle: 'Transparent starting prices for reels. Every project is confirmed with a clear scope before work begins.',
            center: true,
          ),
          const SizedBox(height: 36),
          Reveal(
            child: _Toggle(monthly: _monthly, onChanged: (v) => setState(() => _monthly = v)),
          ),
          const SizedBox(height: 40),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 450),
            transitionBuilder: (child, a) => FadeTransition(
              opacity: a,
              child: ScaleTransition(
                scale: Tween(begin: .96, end: 1.0).animate(CurvedAnimation(parent: a, curve: Curves.easeOutBack)),
                child: child,
              ),
            ),
            child: ResponsiveGrid(
              key: ValueKey(_monthly),
              minItemWidth: 300,
              children: [
                for (var i = 0; i < tiers.length; i++)
                  Reveal(
                    style: RevealStyle.swingLeft,
                    delay: Duration(milliseconds: 110 * i),
                    child: _PriceCard(t: tiers[i], monthly: _monthly),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Reveal(
            child: Text('Prices in Indian Rupees (INR). Single reels are up to 60 seconds.', style: AppText.body(13, color: AppColors.textMute)),
          ),
          const SizedBox(height: 44),
          const Reveal(style: RevealStyle.zoom, child: _IntlQuote()),
        ],
      ),
    );
  }
}

class _Toggle extends StatelessWidget {
  const _Toggle({required this.monthly, required this.onChanged});
  final bool monthly;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final w = context.isMobile ? 150.0 : 190.0;
    Widget opt(String label, bool value) => Semantics(
      button: true,
      selected: monthly == value,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => onChanged(value),
          child: SizedBox(
            width: w,
            height: 48,
            child: Center(
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 250),
                style: AppText.body(14, color: monthly == value ? Colors.white : AppColors.textDim, weight: FontWeight.w800, height: 1.2),
                child: Text(label),
              ),
            ),
          ),
        ),
      ),
    );
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: AppColors.border),
      ),
      child: Stack(
        children: [
          AnimatedPositioned(
            duration: const Duration(milliseconds: 380),
            curve: Curves.easeOutBack,
            left: monthly ? w : 0,
            top: 0,
            bottom: 0,
            width: w,
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [AppColors.red, AppColors.blue]),
                borderRadius: BorderRadius.circular(40),
                boxShadow: [BoxShadow(color: AppColors.red.withValues(alpha: .4), blurRadius: 16)],
              ),
            ),
          ),
          Row(mainAxisSize: MainAxisSize.min, children: [opt('Single Reel', false), opt('Monthly · 20 Reels', true)]),
        ],
      ),
    );
  }
}

class _PriceCard extends StatefulWidget {
  const _PriceCard({required this.t, required this.monthly});
  final PriceTier t;
  final bool monthly;
  @override
  State<_PriceCard> createState() => _PriceCardState();
}

class _PriceCardState extends State<_PriceCard> {
  bool _h = false;
  @override
  Widget build(BuildContext context) {
    final t = widget.t;
    final hi = t.highlight;
    return MouseRegion(
      onEnter: (_) => setState(() => _h = true),
      onExit: (_) => setState(() => _h = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        transform: Matrix4.translationValues(0, _h ? -10 : 0, 0),
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: hi || _h ? const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [AppColors.red, AppColors.blue]) : null,
          color: hi || _h ? null : AppColors.border,
          boxShadow: [if (hi || _h) BoxShadow(color: AppColors.red.withValues(alpha: .25), blurRadius: 40, offset: const Offset(0, 20))],
        ),
        child: Container(
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(color: hi ? const Color(0xFF12152A) : AppColors.surface, borderRadius: BorderRadius.circular(20)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(t.name.toUpperCase(), style: AppText.comic(28, color: hi ? AppColors.red : Colors.white)),
                  const Spacer(),
                  if (hi)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: AppColors.blue, borderRadius: BorderRadius.circular(20)),
                      child: Text('BALANCED', style: AppText.label(10)),
                    ),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(t.price, style: AppText.display(54)),
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(widget.monthly ? '/ month' : '/ reel', style: AppText.body(14)),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Container(height: 1, color: AppColors.border),
              const SizedBox(height: 18),
              for (final f in t.features)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Icon(Icons.check_circle_rounded, size: 18, color: hi ? AppColors.red : AppColors.blueGlow),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(f, style: AppText.body(14.5, color: const Color(0xFFD4D4DC), height: 1.45)),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: CtaButton(label: 'Choose ${t.name}', primary: hi, icon: Icons.arrow_forward_rounded, onTap: () => Nav.to(context, Sec.contact)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IntlQuote extends StatelessWidget {
  const _IntlQuote();
  @override
  Widget build(BuildContext context) {
    final mobile = context.isMobile;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF1A0A12), Color(0xFF0A1238)]),
        border: Border.all(color: AppColors.blue.withValues(alpha: .6), width: 1.4),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(painter: HalftonePainter(color: AppColors.blue, fromTopLeft: false, opacity: .25)),
          ),
          Padding(
            padding: EdgeInsets.all(mobile ? 26 : 44),
            child: Flex(
              direction: mobile ? Axis.vertical : Axis.horizontal,
              crossAxisAlignment: mobile ? CrossAxisAlignment.start : CrossAxisAlignment.center,
              children: [
                const IconBadge(Icons.public_rounded, size: 64, redFirst: false),
                SizedBox(width: mobile ? 0 : 28, height: mobile ? 20 : 0),
                Flexible(
                  fit: mobile ? FlexFit.loose : FlexFit.tight,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('OUTSIDE INDIA?', style: AppText.label(12, color: AppColors.blueGlow)),
                      const SizedBox(height: 8),
                      Text('Need a custom editing package?', style: AppText.display(mobile ? 28 : 36)),
                      const SizedBox(height: 8),
                      Text(
                        "Let's discuss your project. International quotes are tailored to complexity, duration, revisions, turnaround and volume: single edits, monthly retainers, podcast packages, UGC ad packages and bulk editing.",
                        style: AppText.body(15),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: mobile ? 0 : 28, height: mobile ? 22 : 0),
                CtaButton(label: 'Get a Custom Quote', icon: Icons.arrow_forward_rounded, onTap: () => Nav.to(context, Sec.contact)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
