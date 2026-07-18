import 'package:flutter/foundation.dart';

/// Simple global language state for the whole app.
/// 'en' = English (LTR), 'ar' = Arabic (RTL)
class AppLocale {
  AppLocale._();

  static final ValueNotifier<String> languageCode = ValueNotifier<String>('en');

  static bool get isArabic => languageCode.value == 'ar';

  static void setLanguage(String code) {
    languageCode.value = code;
  }

  static void toggle() {
    languageCode.value = isArabic ? 'en' : 'ar';
  }
}
