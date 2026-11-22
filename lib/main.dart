import 'package:material_ui/material_ui.dart';

import 'intro/intro_slot.dart';
import 'pages/home_page.dart';
import 'theme/app_theme.dart';

/// Plug Nikhil's intro in here when it is ready (see lib/intro/intro_slot.dart).
const IntroBuilder? kIntroBuilder = null;

void main() => runApp(const NikhilCutzApp());

class NikhilCutzApp extends StatelessWidget {
  const NikhilCutzApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nikhil Cutz | Professional Video Editor for Creators & Businesses',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      home: IntroSlot(
        intro: kIntroBuilder,
        builder: (context, introDone) => HomePage(introDone: introDone),
      ),
    );
  }
}
