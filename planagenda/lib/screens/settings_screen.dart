import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_data.dart';
import '../localization.dart';
import '../theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appData = context.watch<AppData>();

    return Scaffold(
      backgroundColor: AppColors.bgBottom,
      appBar: AppBar(
        backgroundColor: AppColors.bgBottom,
        elevation: 0,
        foregroundColor: AppColors.deepPurple,
        title: Text(appData.tr('settings_title'), style: headingFont(fontSize: 18)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(appData.tr('settings_language'), style: headingFont(fontSize: 18)),
          const SizedBox(height: 12),
          ...AppLanguage.values.map((lang) => _SelectableRow(
                leading: Text(lang.flagEmoji, style: const TextStyle(fontSize: 20)),
                label: lang.nativeName,
                selected: appData.language == lang,
                onTap: () => appData.setLanguage(lang),
              )),
          const SizedBox(height: 28),
          Text(appData.tr('settings_theme'), style: headingFont(fontSize: 18)),
          const SizedBox(height: 12),
          ...AppThemeOption.values.map((option) => _SelectableRow(
                leading: _ThemeSwatch(option: option),
                label: appData.tr(option.labelKey),
                selected: appData.themeOption == option,
                onTap: () => appData.setThemeOption(option),
              )),
        ],
      ),
    );
  }
}

class _SelectableRow extends StatelessWidget {
  final Widget leading;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SelectableRow({
    required this.leading,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: selected ? AppColors.midPurple.withValues(alpha: 0.15) : AppColors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: selected ? AppColors.midPurple : AppColors.iconBoxGrey,
                width: selected ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                leading,
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      color: AppColors.deepPurple,
                    ),
                  ),
                ),
                if (selected)
                  Icon(Icons.check_circle, color: AppColors.midPurple, size: 22)
                else
                  Icon(Icons.circle_outlined, color: AppColors.iconBoxGrey, size: 22),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Tema seçenekleri için küçük bir renk örneği (o temanın ana rengini
/// gösteren daire).
class _ThemeSwatch extends StatelessWidget {
  final AppThemeOption option;
  const _ThemeSwatch({required this.option});

  @override
  Widget build(BuildContext context) {
    final colors = _swatchColors(option);
    return SizedBox(
      width: 28,
      height: 28,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: colors.$1,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: colors.$2,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  (Color, Color) _swatchColors(AppThemeOption option) {
    switch (option) {
      case AppThemeOption.default_:
        return (const Color(0xFFB9A4E0), const Color(0xFF463A6E));
      case AppThemeOption.dark:
        return (const Color(0xFF2A2636), const Color(0xFFC9BCE8));
      case AppThemeOption.ocean:
        return (const Color(0xFF3E6E9E), const Color(0xFF7FAFD4));
      case AppThemeOption.slate:
        return (const Color(0xFF31363B), const Color(0xFF5B84A6));
    }
  }
}
