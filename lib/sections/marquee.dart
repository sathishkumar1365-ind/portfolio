import 'package:flutter/scheduler.dart';
import 'package:material_ui/material_ui.dart';

import '../theme/app_theme.dart';

/// Two crossing comic tape bands scrolling in opposite directions.
class ServiceMarquee extends StatelessWidget {
  const ServiceMarquee({super.key});

  static const _a = ['REELS', 'SHORTS', 'PODCASTS', 'UGC ADS', 'YOUTUBE', 'BRAND VIDEOS', 'MOTION GRAPHICS'];
  static const _b = ['CUTS', 'CAPTIONS', 'B-ROLL', 'SOUND DESIGN', 'COLOR', 'TRANSITIONS', 'KINETIC TYPE'];

  @override
  Widget build(BuildContext context) {
    final h = context.isMobile ? 130.0 : 170.0;
    return SizedBox(
      height: h,
      child: ClipRect(
        child: Stack(alignment: Alignment.center, children: [
          Transform.rotate(angle: .035, child: OverflowBox(maxWidth: double.infinity, child: _Band(words: _b, color: AppColors.blue, speed: -40, textColor: Colors.white))),
          Transform.rotate(angle: -.03, child: OverflowBox(maxWidth: double.infinity, child: _Band(words: _a, color: AppColors.red, speed: 55, textColor: Colors.white))),
        ]),
      ),
    );
  }
}

class _Band extends StatefulWidget {
  const _Band({required this.words, required this.color, required this.speed, required this.textColor});
  final List<String> words;
  final Color color;
  final double speed; // px per second, sign = direction
  final Color textColor;
  @override
  State<_Band> createState() => _BandState();
}

class _BandState extends State<_Band> with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  final _offset = ValueNotifier<double>(0);
  Duration _last = Duration.zero;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((elapsed) {
      final dt = (elapsed - _last).inMicroseconds / 1e6;
      _last = elapsed;
      _offset.value += widget.speed * dt;
    })
      ..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fs = context.isMobile ? 26.0 : 34.0;
    final row = Row(mainAxisSize: MainAxisSize.min, children: [
      for (final w in widget.words) ...[
        Text(w, style: AppText.comic(fs, color: widget.textColor)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: Icon(Icons.blur_on_rounded, color: Colors.white.withValues(alpha: .7), size: fs * .8),
        ),
      ],
    ]);
    return Container(
      width: MediaQuery.sizeOf(context).width * 1.2,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: widget.color,
        border: const Border.symmetric(horizontal: BorderSide(color: Colors.black, width: 3)),
        boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 20)],
      ),
      child: ExcludeSemantics(
        child: RepaintBoundary(
          child: LayoutBuilder(builder: (context, c) {
            return _Looper(offset: _offset, child: row);
          }),
        ),
      ),
    );
  }
}

/// Repeats [child] horizontally and wraps the offset by its measured width.
class _Looper extends StatefulWidget {
  const _Looper({required this.offset, required this.child});
  final ValueNotifier<double> offset;
  final Widget child;
  @override
  State<_Looper> createState() => _LooperState();
}

class _LooperState extends State<_Looper> {
  final _key = GlobalKey();
  double _w = 0;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      final b = _key.currentContext?.findRenderObject() as RenderBox?;
      if (b != null && mounted) setState(() => _w = b.size.width);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
      valueListenable: widget.offset,
      builder: (_, o, _) {
        final x = _w == 0 ? 0.0 : -(o % _w);
        return OverflowBox(
          alignment: Alignment.centerLeft,
          maxWidth: double.infinity,
          child: Transform.translate(
            offset: Offset(x, 0),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              KeyedSubtree(key: _key, child: widget.child),
              widget.child,
              widget.child,
              widget.child,
            ]),
          ),
        );
      },
    );
  }
}
