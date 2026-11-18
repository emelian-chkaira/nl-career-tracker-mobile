import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// system -> light -> dark -> system. Remembered on the device.
class ThemeController extends ValueNotifier<ThemeMode> {
  ThemeController._() : super(ThemeMode.system);
  static final ThemeController instance = ThemeController._();
  static const _k = 'theme_mode';
  final _s = const FlutterSecureStorage();

  Future<void> load() async {
    try {
      final v = await _s.read(key: _k);
      value = ThemeMode.values.firstWhere((m) => m.name == v, orElse: () => ThemeMode.system);
    } catch (_) {/* keep system */}
  }

  void next() {
    value = switch (value) { ThemeMode.system => ThemeMode.light, ThemeMode.light => ThemeMode.dark, _ => ThemeMode.system };
    _s.write(key: _k, value: value.name).catchError((_) {});
  }

  IconData get icon => switch (value) { ThemeMode.light => Icons.light_mode, ThemeMode.dark => Icons.dark_mode, _ => Icons.brightness_auto };
}
