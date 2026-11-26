import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nikhil_cutz_portfolio/pages/home_page.dart';
import 'package:nikhil_cutz_portfolio/theme/app_theme.dart';

import 'dart:io';

import 'package:flutter/services.dart';

Future<void> _load(String family, List<String> files) async {
  final l = FontLoader(family);
  for (final f in files) {
    l.addFont(Future.value(ByteData.sublistView(File(f).readAsBytesSync())));
  }
  await l.load();
}

void main() {
  setUpAll(() async {
    await _load('Anton', ['assets/fonts/Anton-Regular.ttf']);
    await _load('Bangers', ['assets/fonts/Bangers-Regular.ttf']);
    await _load('Manrope', [
      'assets/fonts/Manrope-Regular.ttf',
      'assets/fonts/Manrope-SemiBold.ttf',
      'assets/fonts/Manrope-Bold.ttf',
      'assets/fonts/Manrope-ExtraBold.ttf',
    ]);
  });
  for (final size in const [
    Size(320, 640),
    Size(1280, 665),
    Size(1366, 600),
    Size(360, 740),
    Size(390, 844),
    Size(430, 932),
    Size(600, 900),
    Size(768, 1024),
    Size(900, 800),
    Size(1024, 768),
    Size(1280, 720),
    Size(1440, 900),
    Size(1920, 1080),
  ]) {
    testWidgets('no overflow at ${size.width.toInt()}x${size.height.toInt()}', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final errors = <String>[];
      final old = FlutterError.onError;
      FlutterError.onError = (d) {
        final m = d.exceptionAsString();
        if (m.contains('overflowed')) {
          errors.add('${m.split('\n').first} :: ${d.toString().split('\n').where((l) => l.contains('file:///') || l.contains('creator')).take(3).join(' | ')}');
        }
      };
      await tester.pumpWidget(MaterialApp(theme: buildTheme(), home: const HomePage(introDone: true)));
      await tester.pump(const Duration(seconds: 3));
      FlutterError.onError = old;
      // dispose
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 1));
      expect(errors, isEmpty, reason: errors.toSet().join('\n'));
    });
  }
}
