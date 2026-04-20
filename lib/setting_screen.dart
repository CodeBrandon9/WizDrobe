import 'package:flutter/material.dart';
import 'theme_provider.dart';

class SettingScreen extends StatefulWidget {
  final ThemeProvider themeProvider;

  const SettingScreen({super.key, required this.themeProvider});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  late String _selectedColorScheme;
  late String _selectedFontFamily;
  late WardrobeLayoutMode _selectedLayoutMode;

  @override
  void initState() {
    super.initState();
    // Find the current color scheme name
    _selectedColorScheme = ThemeProvider.colorSchemes.entries
        .firstWhere(
          (entry) => entry.value == widget.themeProvider.seedColor,
          orElse: () => const MapEntry('Blue', 0xFF275AFF),
        )
        .key;
    
    // Find the current font family name
    _selectedFontFamily = ThemeProvider.fontFamilies.entries
        .firstWhere(
          (entry) => entry.value == widget.themeProvider.fontFamily,
          orElse: () => const MapEntry('Roboto', 'Roboto'),
        )
        .key;

    _selectedLayoutMode = widget.themeProvider.wardrobeLayoutMode;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 52,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF374151)
                    : const Color(0xFFF7F8FA),
                border: Border(
                  bottom: BorderSide(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? const Color(0xFF4B5563)
                        : const Color(0xFFDFE3E8),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.checkroom_outlined,
                    size: 18,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Wizdrobe',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w500,
                      letterSpacing: -0.5,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : const Color(0xFF101828),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Settings',
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -1.1,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : const Color(0xFF000000),
                        ),
                      ),
                      const SizedBox(height: 32),
                      Text(
                        'Color Scheme',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : const Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildColorSchemeSelector(),
                      const SizedBox(height: 32),
                      Text(
                        'Appearance',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : const Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildDarkModeToggle(),
                      const SizedBox(height: 32),
                      Text(
                        'Wardrobe Layout',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : const Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildWardrobeLayoutSelector(),
                      const SizedBox(height: 32),
                      Text(
                        'Typography',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : const Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildFontSelector(),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 40,
                        child: ElevatedButton(
                          onPressed: _applyColorScheme,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(widget.themeProvider.seedColor),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Apply Theme',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDarkModeToggle() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF374151)
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF4B5563)
              : const Color(0xFFE5E7EB),
        ),
      ),
      child: Row(
        children: [
          Icon(
            widget.themeProvider.isDarkMode
                ? Icons.dark_mode
                : Icons.light_mode,
            color: Theme.of(context).colorScheme.primary,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Dark Mode',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : const Color(0xFF111827),
              ),
            ),
          ),
          Switch(
            value: widget.themeProvider.isDarkMode,
            onChanged: (value) {
              widget.themeProvider.toggleDarkMode();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    value ? 'Switched to dark mode' : 'Switched to light mode',
                  ),
                  duration: const Duration(seconds: 2),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                ),
              );
            },
            activeTrackColor: Theme.of(context).colorScheme.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildFontSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF374151)
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF4B5563)
              : const Color(0xFFE5E7EB),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Font Family',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : const Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ThemeProvider.fontFamilies.keys.map((fontName) {
              final isSelected = _selectedFontFamily == fontName;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedFontFamily = fontName;
                  });
                  final fontFamily = ThemeProvider.fontFamilies[fontName]!;
                  widget.themeProvider.setFontFamily(fontFamily);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Font changed to $fontName'),
                      duration: const Duration(seconds: 2),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).brightness == Brightness.dark
                            ? const Color(0xFF4B5563)
                            : const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).brightness == Brightness.dark
                              ? const Color(0xFF6B7280)
                              : const Color(0xFFE5E7EB),
                    ),
                  ),
                  child: Text(
                    fontName,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isSelected
                          ? Colors.white
                          : Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : const Color(0xFF111827),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildWardrobeLayoutSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF374151)
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF4B5563)
              : const Color(0xFFE5E7EB),
        ),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: ThemeProvider.wardrobeLayoutLabels.entries.map((entry) {
          final isSelected = _selectedLayoutMode == entry.key;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedLayoutMode = entry.key;
              });
              widget.themeProvider.setWardrobeLayoutMode(entry.key);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Wardrobe layout set to ${entry.value}'),
                  duration: const Duration(seconds: 2),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).brightness == Brightness.dark
                        ? const Color(0xFF4B5563)
                        : const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFF6B7280)
                          : const Color(0xFFE5E7EB),
                ),
              ),
              child: Text(
                entry.value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : const Color(0xFF111827),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildColorSchemeSelector() {
    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      children: ThemeProvider.colorSchemes.entries.map((entry) {
        final colorName = entry.key;
        final colorValue = entry.value;
        final isSelected = _selectedColorScheme == colorName;

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedColorScheme = colorName;
            });
          },
          child: Container(
            decoration: BoxDecoration(
              color: Color(colorValue),
              borderRadius: BorderRadius.circular(12),
              border: isSelected
                  ? Border.all(
                      color: Colors.black,
                      width: 3,
                    )
                  : null,
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: Color(colorValue).withValues(alpha: 0.3),
                        blurRadius: 8,
                        spreadRadius: 2,
                      )
                    ]
                  : null,
            ),
            child: isSelected
                ? const Center(
                    child: Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 28,
                    ),
                  )
                : Center(
                    child: Text(
                      colorName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
          ),
        );
      }).toList(),
    );
  }

  void _applyColorScheme() {
    final selectedColor =
        ThemeProvider.colorSchemes[_selectedColorScheme] ?? 0xFF275AFF;
    widget.themeProvider.setSeedColor(selectedColor);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Theme changed to $_selectedColorScheme'),
        duration: const Duration(seconds: 2),
        backgroundColor: Color(selectedColor),
      ),
    );
  }
}



