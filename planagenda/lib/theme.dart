import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
enum AppThemeOption { default_, dark, ocean, slate }

extension AppThemeOptionLabel on AppThemeOption {
  String get labelKey {
    switch (this) {
      case AppThemeOption.default_:
        return 'theme_default';
      case AppThemeOption.dark:
        return 'theme_dark';
      case AppThemeOption.ocean:
        return 'theme_ocean';
      case AppThemeOption.slate:
        return 'theme_slate';
    }
  }

  bool get isDark => this == AppThemeOption.dark || this == AppThemeOption.slate;
}

class _Palette {
  final Color bgTop;
  final Color bgBottom;
  final Color headerCloud;
  final Color deepPurple;
  final Color midPurple;
  final Color softPurple;
  final Color accentPurple;
  final Color cardYesterday;
  final Color cardToday;
  final Color cardTomorrow;
  final Color rowLavender1;
  final Color rowLavender2;
  final Color rowLavender3;
  final Color rowLavender4;
  final Color rowLavender5;
  final Color rowLavender6;
  final Color rowLavender7;
  final Color badgeGreenBg;
  final Color badgeGreenText;
  final Color chipPink;
  final Color chipPinkText;
  final Color iconBoxGrey;
  final Color white;

  const _Palette({
    required this.bgTop,
    required this.bgBottom,
    required this.headerCloud,
    required this.deepPurple,
    required this.midPurple,
    required this.softPurple,
    required this.accentPurple,
    required this.cardYesterday,
    required this.cardToday,
    required this.cardTomorrow,
    required this.rowLavender1,
    required this.rowLavender2,
    required this.rowLavender3,
    required this.rowLavender4,
    required this.rowLavender5,
    required this.rowLavender6,
    required this.rowLavender7,
    required this.badgeGreenBg,
    required this.badgeGreenText,
    required this.chipPink,
    required this.chipPinkText,
    required this.iconBoxGrey,
    required this.white,
  });
}
const _defaultPalette = _Palette(
  bgTop: Color(0xFFE9DFF6),
  bgBottom: Color(0xFFF9F6FD),
  headerCloud: Color(0xFFDCCFF2),
  deepPurple: Color(0xFF463A6E),
  midPurple: Color(0xFF7A6BAE),
  softPurple: Color(0xFFB9A4E0),
  accentPurple: Color(0xFF8C7BC4),
  cardYesterday: Color(0xFFEAE7EF),
  cardToday: Color(0xFFDCD0F2),
  cardTomorrow: Color(0xFFF1E9F8),
  rowLavender1: Color(0xFFEFEAF8),
  rowLavender2: Color(0xFFE6DEF5),
  rowLavender3: Color(0xFFDCD1F1),
  rowLavender4: Color(0xFFD3C6ED),
  rowLavender5: Color(0xFFC9BAE9),
  rowLavender6: Color(0xFFBEACE4),
  rowLavender7: Color(0xFFB4A0E0),
  badgeGreenBg: Color(0xFFC9F0D9),
  badgeGreenText: Color(0xFF2E7D4F),
  chipPink: Color(0xFFF6E4EC),
  chipPinkText: Color(0xFFB05C7E),
  iconBoxGrey: Color(0xFFE8E5EE),
  white: Color(0xFFFFFFFF),
);

const _darkPalette = _Palette(
  bgTop: Color(0xFF242030),
  bgBottom: Color(0xFF17151E),
  headerCloud: Color(0xFF322C42),
  deepPurple: Color(0xFFEDE7F8),
  midPurple: Color(0xFFC9BCE8),
  softPurple: Color(0xFF8E7FC0),
  accentPurple: Color(0xFFA595D6),
  cardYesterday: Color(0xFF2A2636),
  cardToday: Color(0xFF3A3350),
  cardTomorrow: Color(0xFF2D2839),
  rowLavender1: Color(0xFF2A2636),
  rowLavender2: Color(0xFF302B40),
  rowLavender3: Color(0xFF362F49),
  rowLavender4: Color(0xFF3D3552),
  rowLavender5: Color(0xFF443A5C),
  rowLavender6: Color(0xFF4B4066),
  rowLavender7: Color(0xFF524570),
  badgeGreenBg: Color(0xFF244232),
  badgeGreenText: Color(0xFF7FDDA3),
  chipPink: Color(0xFF3A2530),
  chipPinkText: Color(0xFFE3A0B8),
  iconBoxGrey: Color(0xFF322D3E),
  white: Color(0xFF2A2636),
);


const _oceanPalette = _Palette(
  bgTop: Color(0xFFDDEBF7),
  bgBottom: Color(0xFFF4F8FB),
  headerCloud: Color(0xFFC7DEF0),
  deepPurple: Color(0xFF1F3A5F),
  midPurple: Color(0xFF3E6E9E),
  softPurple: Color(0xFF7FAFD4),
  accentPurple: Color(0xFF4A85B8),
  cardYesterday: Color(0xFFE6ECF1),
  cardToday: Color(0xFFCFE1EF),
  cardTomorrow: Color(0xFFE9F2F8),
  rowLavender1: Color(0xFFE9F1F8),
  rowLavender2: Color(0xFFDCEAF4),
  rowLavender3: Color(0xFFCFE2F0),
  rowLavender4: Color(0xFFC2D9EB),
  rowLavender5: Color(0xFFB5D0E6),
  rowLavender6: Color(0xFFA7C7E1),
  rowLavender7: Color(0xFF9ABEDC),
  badgeGreenBg: Color(0xFFCFF0DE),
  badgeGreenText: Color(0xFF276B48),
  chipPink: Color(0xFFE3ECF3),
  chipPinkText: Color(0xFF3E6E9E),
  iconBoxGrey: Color(0xFFE3EAF0),
  white: Color(0xFFFFFFFF),
);

const _slatePalette = _Palette(
  bgTop: Color(0xFF262A2E),
  bgBottom: Color(0xFF1B1E21),
  headerCloud: Color(0xFF31363B),
  deepPurple: Color(0xFFE8EAED),
  midPurple: Color(0xFFAEB6BF),
  softPurple: Color(0xFF5B84A6),
  accentPurple: Color(0xFF6C93B3),
  cardYesterday: Color(0xFF292D31),
  cardToday: Color(0xFF32424E),
  cardTomorrow: Color(0xFF2A2E32),
  rowLavender1: Color(0xFF292D31),
  rowLavender2: Color(0xFF2E3337),
  rowLavender3: Color(0xFF33393E),
  rowLavender4: Color(0xFF394045),
  rowLavender5: Color(0xFF3F474D),
  rowLavender6: Color(0xFF454E55),
  rowLavender7: Color(0xFF4C555D),
  badgeGreenBg: Color(0xFF223A2C),
  badgeGreenText: Color(0xFF7FDDA3),
  chipPink: Color(0xFF3A2C30),
  chipPinkText: Color(0xFFD79BAE),
  iconBoxGrey: Color(0xFF2E3337),
  white: Color(0xFF292D31),
);

_Palette _paletteFor(AppThemeOption option) {
  switch (option) {
    case AppThemeOption.default_:
      return _defaultPalette;
    case AppThemeOption.dark:
      return _darkPalette;
    case AppThemeOption.ocean:
      return _oceanPalette;
    case AppThemeOption.slate:
      return _slatePalette;
  }
}

class AppColors {
  static Color bgTop = _defaultPalette.bgTop;
  static Color bgBottom = _defaultPalette.bgBottom;
  static Color headerCloud = _defaultPalette.headerCloud;

  static Color deepPurple = _defaultPalette.deepPurple;
  static Color midPurple = _defaultPalette.midPurple;
  static Color softPurple = _defaultPalette.softPurple;
  static Color accentPurple = _defaultPalette.accentPurple;

  static Color cardYesterday = _defaultPalette.cardYesterday;
  static Color cardToday = _defaultPalette.cardToday;
  static Color cardTomorrow = _defaultPalette.cardTomorrow;

  static Color rowLavender1 = _defaultPalette.rowLavender1;
  static Color rowLavender2 = _defaultPalette.rowLavender2;
  static Color rowLavender3 = _defaultPalette.rowLavender3;
  static Color rowLavender4 = _defaultPalette.rowLavender4;
  static Color rowLavender5 = _defaultPalette.rowLavender5;
  static Color rowLavender6 = _defaultPalette.rowLavender6;
  static Color rowLavender7 = _defaultPalette.rowLavender7;

  static Color badgeGreenBg = _defaultPalette.badgeGreenBg;
  static Color badgeGreenText = _defaultPalette.badgeGreenText;

  static Color chipPink = _defaultPalette.chipPink;
  static Color chipPinkText = _defaultPalette.chipPinkText;

  static Color iconBoxGrey = _defaultPalette.iconBoxGrey;
  static Color white = _defaultPalette.white;

  static void apply(AppThemeOption option) {
    final p = _paletteFor(option);
    bgTop = p.bgTop;
    bgBottom = p.bgBottom;
    headerCloud = p.headerCloud;
    deepPurple = p.deepPurple;
    midPurple = p.midPurple;
    softPurple = p.softPurple;
    accentPurple = p.accentPurple;
    cardYesterday = p.cardYesterday;
    cardToday = p.cardToday;
    cardTomorrow = p.cardTomorrow;
    rowLavender1 = p.rowLavender1;
    rowLavender2 = p.rowLavender2;
    rowLavender3 = p.rowLavender3;
    rowLavender4 = p.rowLavender4;
    rowLavender5 = p.rowLavender5;
    rowLavender6 = p.rowLavender6;
    rowLavender7 = p.rowLavender7;
    badgeGreenBg = p.badgeGreenBg;
    badgeGreenText = p.badgeGreenText;
    chipPink = p.chipPink;
    chipPinkText = p.chipPinkText;
    iconBoxGrey = p.iconBoxGrey;
    white = p.white;
  }
}

ThemeData buildAppTheme(AppThemeOption option) {
  final brightness = option.isDark ? Brightness.dark : Brightness.light;
  final base = ThemeData(
    useMaterial3: true,
    brightness: brightness,
    scaffoldBackgroundColor: AppColors.bgBottom,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.midPurple,
      brightness: brightness,
    ),
  );
  return base.copyWith(
    textTheme: GoogleFonts.interTextTheme(base.textTheme).apply(
      bodyColor: AppColors.deepPurple,
      displayColor: AppColors.deepPurple,
    ),
  );
}

TextStyle headingFont({
  double fontSize = 24,
  Color? color,
  FontWeight weight = FontWeight.w600,
}) {
  return GoogleFonts.playfairDisplay(
    fontSize: fontSize,
    color: color ?? AppColors.deepPurple,
    fontWeight: weight,
  );
}
