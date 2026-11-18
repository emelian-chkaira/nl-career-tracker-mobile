import 'package:flutter/material.dart';

import 'theme_controller.dart';

/// Same visual language as the web app: indigo→violet gradient hero, soft cards, pill chips.
const kBrand = Color(0xFF2557F6);
const kViolet = Color(0xFF7C3AED);
const kHero = LinearGradient(colors: [Color(0xFF1E3A8A), kBrand, kViolet], begin: Alignment.topLeft, end: Alignment.bottomRight);

ThemeData appTheme([Brightness b = Brightness.light]) {
  final dark = b == Brightness.dark;
  final scheme = ColorScheme.fromSeed(seedColor: kBrand, brightness: b, surface: dark ? const Color(0xFF141922) : Colors.white).copyWith(primary: dark ? const Color(0xFF6F93FF) : kBrand);
  final bg = dark ? const Color(0xFF0B0E14) : const Color(0xFFF3F5F9);
  final line = dark ? const Color(0xFF252D3A) : const Color(0xFFE3E7EE);
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: bg,
    cardTheme: CardThemeData(elevation: 0, color: scheme.surface, margin: EdgeInsets.zero, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: line))),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: scheme.surface,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: line)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: line)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: scheme.primary, width: 1.6)),
    ),
    appBarTheme: AppBarTheme(centerTitle: false, backgroundColor: bg, surfaceTintColor: Colors.transparent, elevation: 0, titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: scheme.onSurface, letterSpacing: -.3)),
    navigationBarTheme: NavigationBarThemeData(backgroundColor: scheme.surface, indicatorColor: scheme.primary.withValues(alpha: .14), height: 66, labelTextStyle: const WidgetStatePropertyAll(TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600))),
    filledButtonTheme: FilledButtonThemeData(style: FilledButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13), textStyle: const TextStyle(fontWeight: FontWeight.w700))),
    outlinedButtonTheme: OutlinedButtonThemeData(style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), side: BorderSide(color: line), padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13))),
    chipTheme: ChipThemeData(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(99)), side: BorderSide(color: line)),
    dividerTheme: DividerThemeData(color: line),
  );
}

/// Gradient banner used at the top of the main screens.
class HeroBanner extends StatelessWidget {
  const HeroBanner({super.key, required this.title, this.subtitle, this.child, this.padding = const EdgeInsets.fromLTRB(18, 16, 18, 16)});
  final String title;
  final String? subtitle;
  final Widget? child;
  final EdgeInsets padding;
  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.fromLTRB(12, 4, 12, 8),
        padding: padding,
        decoration: BoxDecoration(gradient: kHero, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: kBrand.withValues(alpha: .25), blurRadius: 18, offset: const Offset(0, 8))]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.w800, height: 1.2, letterSpacing: -.3))),
            ValueListenableBuilder<ThemeMode>(valueListenable: ThemeController.instance, builder: (_, _, _) => IconButton(visualDensity: VisualDensity.compact, tooltip: 'Theme: light / dark / auto', icon: Icon(ThemeController.instance.icon, color: Colors.white, size: 22), onPressed: ThemeController.instance.next)),
          ]),
          if (subtitle != null) Padding(padding: const EdgeInsets.only(top: 6), child: Text(subtitle!, style: TextStyle(color: Colors.white.withValues(alpha: .85), fontSize: 13, height: 1.35))),
          if (child != null) Padding(padding: const EdgeInsets.only(top: 12), child: child),
        ]),
      );
}
