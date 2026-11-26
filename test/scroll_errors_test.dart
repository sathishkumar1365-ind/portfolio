import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nikhil_cutz_portfolio/pages/home_page.dart';
import 'package:nikhil_cutz_portfolio/theme/app_theme.dart';

Future<void> _load(String family, List<String> files) async {
  final l = FontLoader(family);
  for (final f in files) {
    l.addFont(Future.value(ByteData.sublistView(File(f).readAsBytesSync())));
  }
  await l.load();
}

/// Scrolls the whole page down and back up (in steps, with animations running)
/// and fails on any framework error, e.g. paint assertions mid-animation.
void main() {
  setUpAll(() async {
    await _load('Anton', ['assets/fonts/Anton-Regular.ttf']);
    await _load('Bangers', ['assets/fonts/Bangers-Regular.ttf']);
    await _load('Manrope', ['assets/fonts/Manrope-Regular.ttf', 'assets/fonts/Manrope-Bold.ttf', 'assets/fonts/Manrope-ExtraBold.ttf']);
  });

  for (final size in const [Size(1280, 631), Size(390, 844)]) {
    testWidgets('no errors scrolling down and up at ${size.width.toInt()}', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final errors = <String>{};
      final old = FlutterError.onError;
      FlutterError.onError = (d) => errors.add(d.exceptionAsString().split('\n').take(2).join(' '));
      await tester.pumpWidget(MaterialApp(theme: buildTheme(), home: const HomePage(introDone: true)));
      await tester.pump(const Duration(seconds: 3));
      final scroll = find.byType(SingleChildScrollView).first;
      for (final dir in [-1.0, 1.0]) {
        for (var i = 0; i < 45; i++) {
          await tester.drag(scroll, Offset(0, dir * size.height * .45), warnIfMissed: false);
          for (var f = 0; f < 6; f++) {
            await tester.pump(const Duration(milliseconds: 50));
          }
        }
      }
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 1));
      FlutterError.onError = old;
      expect(errors, isEmpty, reason: errors.join('\n'));
    });
  }
}
