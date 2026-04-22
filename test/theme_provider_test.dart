import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wizdrobe/theme_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    GoogleFonts.config.allowRuntimeFetching = false;
    SharedPreferences.setMockInitialValues({});
  });

  group('ThemeProvider', () {
    test('loads defaults from empty prefs', () async {
      final p = ThemeProvider();
      await p.prefsReady;
      expect(p.seedColor, 0xFF275AFF);
      expect(p.isDarkMode, isFalse);
      expect(p.fontFamily, 'Roboto');
      expect(p.wardrobeLayoutMode, WardrobeLayoutMode.grid2Column);
    });

    test('loads persisted values', () async {
      SharedPreferences.setMockInitialValues({
        'app_theme_seed_color': 0xFFDC2626,
        'app_dark_mode': true,
        'app_font_family': 'Lato',
        'app_wardrobe_layout_mode': WardrobeLayoutMode.list.name,
      });

      final p = ThemeProvider();
      await p.prefsReady;
      expect(p.seedColor, 0xFFDC2626);
      expect(p.isDarkMode, isTrue);
      expect(p.fontFamily, 'Lato');
      expect(p.wardrobeLayoutMode, WardrobeLayoutMode.list);
    });

    test('setSeedColor updates state and prefs', () async {
      SharedPreferences.setMockInitialValues({});
      final p = ThemeProvider();
      await p.prefsReady;

      await p.setSeedColor(0xFF059669);
      expect(p.seedColor, 0xFF059669);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt('app_theme_seed_color'), 0xFF059669);
    });

    test('toggleDarkMode flips flag and persists', () async {
      SharedPreferences.setMockInitialValues({'app_dark_mode': false});
      final p = ThemeProvider();
      await p.prefsReady;

      await p.toggleDarkMode();
      expect(p.isDarkMode, isTrue);
      expect((await SharedPreferences.getInstance()).getBool('app_dark_mode'), isTrue);

      await p.toggleDarkMode();
      expect(p.isDarkMode, isFalse);
    });

    test('setFontFamily persists', () async {
      SharedPreferences.setMockInitialValues({});
      final p = ThemeProvider();
      await p.prefsReady;

      await p.setFontFamily('Inter');
      expect(p.fontFamily, 'Inter');
      expect(
        (await SharedPreferences.getInstance()).getString('app_font_family'),
        'Inter',
      );
    });

    test('setWardrobeLayoutMode persists', () async {
      SharedPreferences.setMockInitialValues({});
      final p = ThemeProvider();
      await p.prefsReady;

      await p.setWardrobeLayoutMode(WardrobeLayoutMode.grid3Column);
      expect(p.wardrobeLayoutMode, WardrobeLayoutMode.grid3Column);
      expect(
        (await SharedPreferences.getInstance()).getString('app_wardrobe_layout_mode'),
        WardrobeLayoutMode.grid3Column.name,
      );
    });

    test('primaryColor reflects seedColor', () async {
      SharedPreferences.setMockInitialValues({'app_theme_seed_color': 0xFFEC4899});
      final p = ThemeProvider();
      await p.prefsReady;

      expect(p.primaryColor, const Color(0xFFEC4899));
    });

    test('invalid layout string in prefs falls back to default grid', () async {
      SharedPreferences.setMockInitialValues({
        'app_wardrobe_layout_mode': 'not_a_real_mode',
      });
      final p = ThemeProvider();
      await p.prefsReady;

      expect(p.wardrobeLayoutMode, WardrobeLayoutMode.grid2Column);
    });

    test('theme builds without throwing', () async {
      SharedPreferences.setMockInitialValues({});
      final p = ThemeProvider();
      await p.prefsReady;

      expect(() => p.theme, returnsNormally);
      expect(p.theme.useMaterial3, isTrue);
    });
  });
}
