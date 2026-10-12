
enum AppLanguage { tr, en, fr, de, it }

extension AppLanguageInfo on AppLanguage {

  String get nativeName {
    switch (this) {
      case AppLanguage.tr:
        return 'Türkçe';
      case AppLanguage.en:
        return 'English';
      case AppLanguage.fr:
        return 'Français';
      case AppLanguage.de:
        return 'Deutsch';
      case AppLanguage.it:
        return 'Italiano';
    }
  }

  String get flagEmoji {
    switch (this) {
      case AppLanguage.tr:
        return '🇹🇷';
      case AppLanguage.en:
        return '🇬🇧';
      case AppLanguage.fr:
        return '🇫🇷';
      case AppLanguage.de:
        return '🇩🇪';
      case AppLanguage.it:
        return '🇮🇹';
    }
  }


  String get code {
    switch (this) {
      case AppLanguage.tr:
        return 'tr';
      case AppLanguage.en:
        return 'en';
      case AppLanguage.fr:
        return 'fr';
      case AppLanguage.de:
        return 'de';
      case AppLanguage.it:
        return 'it';
    }
  }

  String get localeTag {
    switch (this) {
      case AppLanguage.tr:
        return 'tr_TR';
      case AppLanguage.en:
        return 'en_US';
      case AppLanguage.fr:
        return 'fr_FR';
      case AppLanguage.de:
        return 'de_DE';
      case AppLanguage.it:
        return 'it_IT';
    }
  }
}

AppLanguage languageFromCode(String? code) {
  return AppLanguage.values.firstWhere(
    (l) => l.code == code,
    orElse: () => AppLanguage.tr,
  );
}
