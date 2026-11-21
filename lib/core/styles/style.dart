import 'package:flutter/material.dart';

import 'theme_controller.dart';

/// Same plain, warm look as the web app: cream paper, one teal accent, serif headings, thin lines, no gradients or shadows.
const kBrand = Color(0xFF1F7A6D);
const kAmber = Color(0xFFE0A030);
const kSerif = 'Georgia';
const kSerifFallback = ['Iowan Old Style', 'Charter', 'serif'];

ThemeData appTheme([Brightness b = Brightness.light]) {
  final dark = b == Brightness.dark;
  final scheme = ColorScheme.fromSeed(seedColor: kBrand, brightness: b, surface: dark ? const Color(0xFF1D1915) : const Color(0xFFFFFDF9)).copyWith(primary: dark ? const Color(0xFF5CCAB8) : kBrand, secondary: kAmber);
  final bg = dark ? const Color(0xFF14110E) : const Color(0xFFFAF6EF);
  final line = dark ? const Color(0xFF2F2922) : const Color(0xFFE8DFD0);
  return ThemeData(
    useMaterial3: true,
    textTheme: ThemeData(brightness: b).textTheme.copyWith(headlineSmall: const TextStyle(fontFamily: kSerif, fontFamilyFallback: kSerifFallback, fontWeight: FontWeight.w700), titleLarge: const TextStyle(fontFamily: kSerif, fontFamilyFallback: kSerifFallback, fontWeight: FontWeight.w700)),
    colorScheme: scheme,
    scaffoldBackgroundColor: bg,
    cardTheme: CardThemeData(elevation: 0, color: scheme.surface, margin: EdgeInsets.zero, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: BorderSide(color: line))),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: scheme.surface,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: line)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: line)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: scheme.primary, width: 1.6)),
    ),
    appBarTheme: AppBarTheme(centerTitle: false, backgroundColor: bg, surfaceTintColor: Colors.transparent, elevation: 0, titleTextStyle: TextStyle(fontFamily: kSerif, fontFamilyFallback: kSerifFallback, fontSize: 21, fontWeight: FontWeight.w700, color: scheme.onSurface, letterSpacing: -.3)),
    navigationBarTheme: NavigationBarThemeData(backgroundColor: scheme.surface, indicatorColor: scheme.primary.withValues(alpha: .14), height: 66, labelTextStyle: const WidgetStatePropertyAll(TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600))),
    filledButtonTheme: FilledButtonThemeData(style: FilledButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13), textStyle: const TextStyle(fontWeight: FontWeight.w700))),
    outlinedButtonTheme: OutlinedButtonThemeData(style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), side: BorderSide(color: line), padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13))),
    chipTheme: ChipThemeData(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(99)), side: BorderSide(color: line)),
    dividerTheme: DividerThemeData(color: line),
  );
}

/// Plain page heading used at the top of the main screens (no banner, no gradient).
class HeroBanner extends StatelessWidget {
  const HeroBanner({super.key, required this.title, this.subtitle, this.child, this.padding = const EdgeInsets.fromLTRB(16, 8, 16, 8)});
  final String title;
  final String? subtitle;
  final Widget? child;
  final EdgeInsets padding;
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: padding,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: Text(title, style: TextStyle(fontFamily: kSerif, fontFamilyFallback: kSerifFallback, color: cs.onSurface, fontSize: 25, fontWeight: FontWeight.w700, height: 1.2))),
          ValueListenableBuilder<ThemeMode>(valueListenable: ThemeController.instance, builder: (_, _, _) => IconButton(visualDensity: VisualDensity.compact, tooltip: 'Theme: light / dark / auto', icon: Icon(ThemeController.instance.icon, color: cs.onSurfaceVariant), onPressed: ThemeController.instance.next)),
        ]),
        if (subtitle != null) Padding(padding: const EdgeInsets.only(top: 4), child: Text(subtitle!, style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13.5, height: 1.4))),
        if (child != null) Padding(padding: const EdgeInsets.only(top: 12), child: child),
      ]),
    );
  }
}
