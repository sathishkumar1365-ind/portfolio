import 'package:material_ui/material_ui.dart';

/// Red & blue on a near-black base. Web-slinger energy, no franchise assets.
class AppColors {
  static const bg = Color(0xFF06070C);
  static const bgAlt = Color(0xFF0A0D18);
  static const surface = Color(0xFF10131F);
  static const surfaceHi = Color(0xFF161A2A);
  static const border = Color(0xFF232842);
  static const red = Color(0xFFE8202A);
  static const redDeep = Color(0xFF9E0E16);
  static const blue = Color(0xFF2563FF);
  static const blueDeep = Color(0xFF0B1E5B);
  static const blueGlow = Color(0xFF4F8BFF);
  static const text = Color(0xFFFFFFFF);
  static const textDim = Color(0xFFA1A1AA);
  static const textMute = Color(0xFF6B7080);

  static const heroGradient = LinearGradient(
    colors: [red, Color(0xFFB0127E), blue],
    stops: [0, .5, 1],
  );
}

class AppText {
  static TextStyle display(double size, {Color color = AppColors.text}) =>
      TextStyle(fontFamily: 'Anton', fontSize: size, color: color, height: 1.02, letterSpacing: .5);
  static TextStyle comic(double size, {Color color = AppColors.text}) =>
      TextStyle(fontFamily: 'Bangers', fontSize: size, color: color, letterSpacing: 1.4, height: 1);
  static TextStyle body(double size, {Color color = AppColors.textDim, FontWeight weight = FontWeight.w400, double height = 1.6}) =>
      TextStyle(fontFamily: 'Manrope', fontSize: size, color: color, fontWeight: weight, height: height);
  static TextStyle label(double size, {Color color = AppColors.text}) =>
      TextStyle(fontFamily: 'Manrope', fontSize: size, color: color, fontWeight: FontWeight.w800, letterSpacing: 2.2);
}

ThemeData buildTheme() {
  final base = ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,
    fontFamily: 'Manrope',
    scaffoldBackgroundColor: AppColors.bg,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.red,
      secondary: AppColors.blue,
      surface: AppColors.surface,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: AppColors.text,
      error: Color(0xFFFF5470),
    ),
  );
  return base.copyWith(
    textTheme: base.textTheme.apply(fontFamily: 'Manrope', bodyColor: AppColors.text, displayColor: AppColors.text),
    focusColor: AppColors.blueGlow.withValues(alpha: .35),
    textSelectionTheme: const TextSelectionThemeData(cursorColor: AppColors.red, selectionColor: Color(0x662563FF)),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.bg.withValues(alpha: .6),
      labelStyle: AppText.body(14),
      floatingLabelStyle: AppText.body(14, color: AppColors.blueGlow, weight: FontWeight.w700),
      hintStyle: AppText.body(14, color: AppColors.textMute),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.blue, width: 1.6)),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFFF5470))),
      focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.red, width: 1.6)),
    ),
    scrollbarTheme: ScrollbarThemeData(
      thumbColor: WidgetStatePropertyAll(AppColors.red.withValues(alpha: .7)),
      thickness: const WidgetStatePropertyAll(6),
      radius: const Radius.circular(6),
    ),
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(color: AppColors.surfaceHi, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.border)),
      textStyle: AppText.body(12, color: AppColors.text),
    ),
  );
}

/// Breakpoints
extension Responsive on BuildContext {
  double get w => MediaQuery.sizeOf(this).width;
  bool get isMobile => w < 720;
  bool get isTablet => w >= 720 && w < 1080;
  bool get isDesktop => w >= 1080;
  double get gutter => isMobile ? 20 : (isTablet ? 40 : 64);
}
