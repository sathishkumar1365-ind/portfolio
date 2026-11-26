import 'package:material_ui/material_ui.dart';

import '../content/site_content.dart';
import '../theme/app_theme.dart';
import '../widgets/reveal.dart';
import '../widgets/ui.dart';

class FaqSection extends StatefulWidget {
  const FaqSection({super.key});
  @override
  State<FaqSection> createState() => _FaqSectionState();
}

class _FaqSectionState extends State<FaqSection> {
  int _open = 0;

  @override
  Widget build(BuildContext context) {
    final wide = context.w >= 1000;
    final header = const SectionHeader(
      number: '12',
      eyebrow: 'FAQ',
      title: 'Questions, Answered',
      subtitle: "Can't find what you need? Message me on WhatsApp or email and I'll reply quickly.",
    );
    final list = Column(
      children: [
        for (var i = 0; i < faqs.length; i++)
          Reveal(
            delay: Duration(milliseconds: 60 * i),
            child: _FaqItem(q: faqs[i].$1, a: faqs[i].$2, open: _open == i, index: i, onTap: () => setState(() => _open = _open == i ? -1 : i)),
          ),
      ],
    );
    return SectionShell(
      top: 60,
      child: wide
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 4, child: header),
                const SizedBox(width: 60),
                Expanded(flex: 6, child: list),
              ],
            )
          : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [header, const SizedBox(height: 36), list]),
    );
  }
}

class _FaqItem extends StatefulWidget {
  const _FaqItem({required this.q, required this.a, required this.open, required this.index, required this.onTap});
  final String q, a;
  final bool open;
  final int index;
  final VoidCallback onTap;
  @override
  State<_FaqItem> createState() => _FaqItemState();
}

class _FaqItemState extends State<_FaqItem> {
  bool _h = false;
  @override
  Widget build(BuildContext context) {
    final c = widget.index.isEven ? AppColors.red : AppColors.blue;
    final on = widget.open || _h;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _h = true),
        onExit: (_) => setState(() => _h = false),
        child: Semantics(
          button: true,
          expanded: widget.open,
          child: GestureDetector(
            onTap: widget.onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              clipBehavior: Clip.antiAlias,
              // Rounded borders must be one colour; the coloured accent is drawn as a foreground bar.
              decoration: BoxDecoration(
                color: widget.open ? AppColors.surfaceHi : AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              foregroundDecoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: LinearGradient(colors: [on ? c : Colors.transparent, Colors.transparent], stops: const [.006, .006]),
              ),
              padding: const EdgeInsets.fromLTRB(22, 20, 18, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.q,
                          style: AppText.body(context.isMobile ? 16 : 17.5, color: Colors.white, weight: FontWeight.w800, height: 1.35),
                        ),
                      ),
                      const SizedBox(width: 12),
                      AnimatedRotation(
                        turns: widget.open ? .125 : 0,
                        duration: const Duration(milliseconds: 350),
                        curve: Curves.easeOutBack,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: widget.open ? c : Colors.transparent,
                            border: Border.all(color: c, width: 1.6),
                          ),
                          child: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
                        ),
                      ),
                    ],
                  ),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 380),
                    curve: Curves.easeOutCubic,
                    alignment: Alignment.topCenter,
                    child: widget.open
                        ? Padding(
                            padding: const EdgeInsets.only(top: 12, right: 40),
                            child: TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0, end: 1),
                              duration: const Duration(milliseconds: 420),
                              builder: (_, t, child) => Opacity(
                                opacity: t,
                                child: Transform.translate(offset: Offset(0, 8 * (1 - t)), child: child),
                              ),
                              child: Text(widget.a, style: AppText.body(15.5)),
                            ),
                          )
                        : const SizedBox(width: double.infinity),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
