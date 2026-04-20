import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum WardrobeLayoutMode { grid2Column, grid3Column, list }

class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'app_theme_seed_color';
  static const String _darkModeKey = 'app_dark_mode';
  static const String _fontKey = 'app_font_family';
  static const String _layoutModeKey = 'app_wardrobe_layout_mode';
  static const int _defaultSeedColor = 0xFF275AFF;
  static const bool _defaultDarkMode = false;
  static const String _defaultFontFamily = 'Roboto';
  static const WardrobeLayoutMode _defaultLayoutMode = WardrobeLayoutMode.grid2Column;

  late SharedPreferences _prefs;
  int _seedColor = _defaultSeedColor;
  bool _isDarkMode = _defaultDarkMode;
  String _fontFamily = _defaultFontFamily;
  WardrobeLayoutMode _wardrobeLayoutMode = _defaultLayoutMode;

  ThemeProvider() {
    _initializeTheme();
  }

  Future<void> _initializeTheme() async {
    _prefs = await SharedPreferences.getInstance();
    _seedColor = _prefs.getInt(_themeKey) ?? _defaultSeedColor;
    _isDarkMode = _prefs.getBool(_darkModeKey) ?? _defaultDarkMode;
    _fontFamily = _prefs.getString(_fontKey) ?? _defaultFontFamily;
    _wardrobeLayoutMode = WardrobeLayoutMode.values.firstWhere(
      (mode) => mode.name == _prefs.getString(_layoutModeKey),
      orElse: () => _defaultLayoutMode,
    );
    notifyListeners();
  }

  int get seedColor => _seedColor;
  bool get isDarkMode => _isDarkMode;
  String get fontFamily => _fontFamily;
  WardrobeLayoutMode get wardrobeLayoutMode => _wardrobeLayoutMode;

  Color get primaryColor => Color(_seedColor);

  ThemeData get theme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: _isDarkMode ? Brightness.dark : Brightness.light,
    );

    return ThemeData(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: _isDarkMode ? const Color(0xFF1F2937) : const Color(0xFFF3F4F6),
      textTheme: GoogleFonts.getTextTheme(_fontFamily),
      useMaterial3: true,
    );
  }

  Future<void> setSeedColor(int colorValue) async {
    _seedColor = colorValue;
    await _prefs.setInt(_themeKey, colorValue);
    notifyListeners();
  }

  Future<void> toggleDarkMode() async {
    _isDarkMode = !_isDarkMode;
    await _prefs.setBool(_darkModeKey, _isDarkMode);
    notifyListeners();
  }

  Future<void> setFontFamily(String fontFamily) async {
    _fontFamily = fontFamily;
    await _prefs.setString(_fontKey, fontFamily);
    notifyListeners();
  }

  Future<void> setWardrobeLayoutMode(WardrobeLayoutMode mode) async {
    _wardrobeLayoutMode = mode;
    await _prefs.setString(_layoutModeKey, mode.name);
    notifyListeners();
  }

  // Preset color schemes
  static const Map<String, int> colorSchemes = {
    'Blue': 0xFF275AFF,
    'Purple': 0xFF7C3AED,
    'Red': 0xFFDC2626,
    'Green': 0xFF059669,
    'Orange': 0xFFF97316,
    'Pink': 0xFFEC4899,
    'Indigo': 0xFF4F46E5,
    'Cyan': 0xFF0891B2,
  };

  // Preset font families
  static const Map<String, String> fontFamilies = {
    'Roboto': 'Roboto',
    'Open Sans': 'Open Sans',
    'Lato': 'Lato',
    'Montserrat': 'Montserrat',
    'Poppins': 'Poppins',
    'Nunito': 'Nunito',
    'Inter': 'Inter',
    'Work Sans': 'Work Sans',
  };

  static const Map<WardrobeLayoutMode, String> wardrobeLayoutLabels = {
    WardrobeLayoutMode.grid2Column: 'Grid (2 columns)',
    WardrobeLayoutMode.grid3Column: 'Grid (3 columns)',
    WardrobeLayoutMode.list: 'List',
  };
}
