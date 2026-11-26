import 'package:material_ui/material_ui.dart';

/// Signature for a custom intro. Call [onFinished] when the intro ends (or is
/// skipped) and the portfolio fades in underneath.
typedef IntroBuilder = Widget Function(BuildContext context, VoidCallback onFinished);

/// THE INTRO HOOK.
///
/// Nikhil's own intro design plugs in here. Build it as a widget in
/// lib/intro/ and set [kIntroBuilder] in lib/main.dart, for example:
///
///   const IntroBuilder? kIntroBuilder = myIntro;
///   Widget myIntro(BuildContext c, VoidCallback done) => MyIntro(onFinished: done);
///
/// While [kIntroBuilder] is null the site opens straight onto the portfolio.
class IntroSlot extends StatefulWidget {
  const IntroSlot({super.key, required this.intro, required this.builder});

  final IntroBuilder? intro;

  /// Builds the site. [introDone] flips to true when the intro has finished,
  /// so the hero can start its entrance animation at the right moment.
  final Widget Function(BuildContext context, bool introDone) builder;

  @override
  State<IntroSlot> createState() => _IntroSlotState();
}

class _IntroSlotState extends State<IntroSlot> {
  late bool _done = widget.intro == null;
  bool _removeIntro = false;

  void _finish() {
    if (_done) return;
    setState(() => _done = true);
    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) setState(() => _removeIntro = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final site = widget.builder(context, _done);
    if (widget.intro == null || _removeIntro) return site;
    return Stack(
      children: [
        site,
        Positioned.fill(
          child: IgnorePointer(
            ignoring: _done,
            child: AnimatedOpacity(opacity: _done ? 0 : 1, duration: const Duration(milliseconds: 650), child: widget.intro!(context, _finish)),
          ),
        ),
      ],
    );
  }
}
