import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:video_player/video_player.dart';

import '../theme/app_theme.dart';
import 'web_painters.dart';

/// Opens a full-screen lightbox that streams [url]. Nothing loads until opened.
Future<void> openVideo(BuildContext context, {required String url, required String title}) {
  return showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Close video',
    barrierColor: Colors.black.withValues(alpha: .88),
    transitionDuration: const Duration(milliseconds: 420),
    pageBuilder: (_, _, _) => _VideoLightbox(url: url, title: title),
    transitionBuilder: (_, a, _, child) {
      final t = Curves.easeOutBack.transform(a.value);
      return Opacity(
        opacity: a.value,
        child: Transform.scale(scale: .85 + .15 * t, child: child),
      );
    },
  );
}

class _VideoLightbox extends StatefulWidget {
  const _VideoLightbox({required this.url, required this.title});
  final String url, title;
  @override
  State<_VideoLightbox> createState() => _VideoLightboxState();
}

class _VideoLightboxState extends State<_VideoLightbox> {
  late final VideoPlayerController _c = VideoPlayerController.networkUrl(Uri.parse(widget.url));
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _c.initialize().then((_) {
      if (!mounted) return;
      setState(() {});
      _c.play();
    }).catchError((_) {
      if (mounted) setState(() => _error = true);
    });
    _c.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final ready = _c.value.isInitialized;
    final ar = ready ? _c.value.aspectRatio : 16 / 9;
    double w = size.width * (context.isMobile ? .94 : .78);
    double h = w / ar;
    final maxH = size.height * .78;
    if (h > maxH) {
      h = maxH;
      w = h * ar;
    }
    return Center(
      child: Material(
        type: MaterialType.transparency,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          SizedBox(
            width: w,
            child: Row(children: [
              Expanded(child: Text(widget.title, style: AppText.display(context.isMobile ? 20 : 26), overflow: TextOverflow.ellipsis)),
              IconButton(
                tooltip: 'Close',
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded, color: Colors.white, size: 30),
              ),
            ]),
          ),
          const SizedBox(height: 10),
          Container(
            width: w,
            height: h,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.red, width: 2),
              boxShadow: const [BoxShadow(color: AppColors.blue, offset: Offset(8, 8)), BoxShadow(color: Color(0x88E8202A), blurRadius: 60)],
            ),
            clipBehavior: Clip.antiAlias,
            child: _error
                ? Center(child: Text('This video could not be loaded.', style: AppText.body(15)))
                : !ready
                    ? const Center(child: _WebSpinner())
                    : GestureDetector(
                        onTap: () => _c.value.isPlaying ? _c.pause() : _c.play(),
                        child: Stack(fit: StackFit.expand, children: [
                          VideoPlayer(_c),
                          AnimatedOpacity(
                            duration: const Duration(milliseconds: 200),
                            opacity: _c.value.isPlaying ? 0 : 1,
                            child: Container(
                              color: Colors.black38,
                              child: const Center(child: Icon(Icons.play_arrow_rounded, size: 80, color: Colors.white)),
                            ),
                          ),
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: VideoProgressIndicator(
                              _c,
                              allowScrubbing: true,
                              padding: const EdgeInsets.all(0),
                              colors: const VideoProgressColors(playedColor: AppColors.red, bufferedColor: Color(0x552563FF), backgroundColor: Colors.white12),
                            ),
                          ),
                        ]),
                      ),
          ),
          if (ready)
            SizedBox(
              width: w,
              child: Row(children: [
                IconButton(
                  tooltip: _c.value.isPlaying ? 'Pause' : 'Play',
                  onPressed: () => _c.value.isPlaying ? _c.pause() : _c.play(),
                  icon: Icon(_c.value.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded, color: Colors.white),
                ),
                IconButton(
                  tooltip: _c.value.volume == 0 ? 'Unmute' : 'Mute',
                  onPressed: () => _c.setVolume(_c.value.volume == 0 ? 1 : 0),
                  icon: Icon(_c.value.volume == 0 ? Icons.volume_off_rounded : Icons.volume_up_rounded, color: Colors.white),
                ),
                const Spacer(),
                Text('${_fmt(_c.value.position)} / ${_fmt(_c.value.duration)}', style: AppText.body(13)),
              ]),
            ),
        ]),
      ),
    );
  }

  String _fmt(Duration d) => '${d.inMinutes.remainder(60).toString().padLeft(2, '0')}:${d.inSeconds.remainder(60).toString().padLeft(2, '0')}';
}

class _WebSpinner extends StatefulWidget {
  const _WebSpinner();
  @override
  State<_WebSpinner> createState() => _WebSpinnerState();
}

class _WebSpinnerState extends State<_WebSpinner> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..repeat();
  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 90,
        height: 90,
        child: AnimatedBuilder(
          animation: _c,
          builder: (_, _) => Transform.rotate(
            angle: _c.value * 6.283,
            child: CustomPaint(painter: WebPainter(progress: (_c.value * 2).clamp(0, 1), sway: _c.value, anchor: const Offset(.5, .5), opacity: .6, spokes: 8, rings: 4, radiusFactor: .5)),
          ),
        ),
      );
}

/// Muted inline preview that only loads while [active] is true (hover on desktop).
class HoverPreview extends StatefulWidget {
  const HoverPreview({super.key, required this.url, required this.active});
  final String url;
  final bool active;
  @override
  State<HoverPreview> createState() => _HoverPreviewState();
}

class _HoverPreviewState extends State<HoverPreview> {
  VideoPlayerController? _c;
  Timer? _debounce;

  @override
  void didUpdateWidget(HoverPreview old) {
    super.didUpdateWidget(old);
    if (widget.active != old.active) {
      _debounce?.cancel();
      if (widget.active) {
        _debounce = Timer(const Duration(milliseconds: 350), _start);
      } else {
        _stop();
      }
    }
  }

  Future<void> _start() async {
    final c = VideoPlayerController.networkUrl(Uri.parse(widget.url), videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true));
    _c = c;
    try {
      await c.setVolume(0);
      await c.initialize();
      await c.setLooping(true);
      if (!mounted || _c != c) {
        c.dispose();
        return;
      }
      await c.play();
      setState(() {});
    } catch (_) {
      // Poster stays visible on failure.
    }
  }

  void _stop() {
    final c = _c;
    _c = null;
    c?.dispose();
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _c?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = _c;
    final ready = c != null && c.value.isInitialized;
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 400),
      opacity: ready ? 1 : 0,
      child: ready
          ? FittedBox(
              fit: BoxFit.cover,
              clipBehavior: Clip.hardEdge,
              child: SizedBox(width: c.value.size.width, height: c.value.size.height, child: VideoPlayer(c)),
            )
          : const SizedBox.shrink(),
    );
  }
}

/// Generated poster art (no image downloads): gradient, halftone, web corner, icon.
class Poster extends StatelessWidget {
  const Poster({super.key, required this.icon, this.seed = 0, this.label});
  final IconData icon;
  final int seed;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final redFirst = seed.isEven;
    return Stack(fit: StackFit.expand, children: [
      DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment(-1 + (seed % 3) * .3, -1),
            end: const Alignment(1, 1),
            colors: redFirst
                ? const [Color(0xFF3A0A12), Color(0xFF0D0F1E), Color(0xFF0A1A4A)]
                : const [Color(0xFF0A1A4A), Color(0xFF0D0F1E), Color(0xFF3A0A12)],
          ),
        ),
      ),
      CustomPaint(painter: HalftonePainter(color: redFirst ? AppColors.red : AppColors.blue, spacing: 12, maxDot: 2.4, opacity: .4)),
      CustomPaint(
          painter: WebPainter(
              progress: 1,
              sway: seed * .13,
              anchor: Offset(seed.isEven ? 1 : 0, 0),
              opacity: .16,
              spokes: 10,
              rings: 6,
              radiusFactor: .8)),
      Center(child: Icon(icon, size: 64, color: Colors.white.withValues(alpha: .12))),
    ]);
  }
}

/// Pulsing play button.
class PlayBadge extends StatefulWidget {
  const PlayBadge({super.key, this.size = 64, this.hot = false});
  final double size;
  final bool hot;
  @override
  State<PlayBadge> createState() => _PlayBadgeState();
}

class _PlayBadgeState extends State<PlayBadge> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800))..repeat();
  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.size;
    return SizedBox(
      width: s * 1.8,
      height: s * 1.8,
      child: AnimatedBuilder(
        animation: _c,
        builder: (_, child) => Stack(alignment: Alignment.center, children: [
          for (final off in [0.0, .5])
            Builder(builder: (_) {
              final v = (_c.value + off) % 1;
              return Container(
                width: s * (1 + v * .8),
                height: s * (1 + v * .8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: (off == 0 ? AppColors.red : AppColors.blue).withValues(alpha: (1 - v) * .7), width: 2),
                ),
              );
            }),
          child!,
        ]),
        child: AnimatedScale(
          duration: const Duration(milliseconds: 250),
          scale: widget.hot ? 1.12 : 1,
          child: Container(
            width: s,
            height: s,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.red,
              border: Border.all(color: Colors.white, width: 2.5),
              boxShadow: const [BoxShadow(color: AppColors.blue, offset: Offset(4, 4)), BoxShadow(color: Color(0x99E8202A), blurRadius: 30)],
            ),
            child: Icon(Icons.play_arrow_rounded, color: Colors.white, size: s * .6),
          ),
        ),
      ),
    );
  }
}
