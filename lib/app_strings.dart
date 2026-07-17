import 'app_locale.dart';

class AppStrings {
  AppStrings._();

  static const Map<String, Map<String, String>> _strings = {
    'appTitle': {'en': 'Tar el Char', 'ar': 'طار الشار'},
    'onboardingNext': {'en': 'Next', 'ar': 'التالي'},
    'onboardingGetStarted': {'en': 'Get Started', 'ar': 'ابدأ الآن'},
    'signIn': {'en': 'Sign In', 'ar': 'تسجيل الدخول'},
    'signUp': {'en': 'Sign Up', 'ar': 'إنشاء حساب'},
    'speakYourAffliction': {
      'en': 'Speak Your Affliction',
      'ar': 'تحدث عن دائك',
    },
    'theGrimoireAwaits': {
      'en': 'The Grimoire Awaits',
      'ar': 'الكتاب السحري بانتظارك',
    },
    'consultTheOracle': {'en': 'Consult the Oracle', 'ar': 'استشر العرّاف'},
    'theOracleSpeaks': {'en': 'The Oracle Speaks', 'ar': 'العرّاف يتحدث'},
    'yourAfflictions': {'en': 'Your afflictions', 'ar': 'أعراضك'},
    'yourInquiry': {'en': 'Your inquiry', 'ar': 'استفسارك'},
    'theGrimoireStirs': {
      'en': 'The grimoire stirs...',
      'ar': 'الكتاب السحري يتحرك...',
    },
    'oracleGuidance': {
      'en': "⚗ The Oracle's Guidance",
      'ar': '⚗ إرشاد العرّاف',
    },
    'ancientRemedy': {'en': '☽ Ancient Remedy', 'ar': '☽ علاج قديم'},
    'aboutThisHerb': {'en': '🌿 About This Herb', 'ar': '🌿 عن هذه العشبة'},
    'seekHealerIf': {'en': '⚠ Seek a Healer If', 'ar': '⚠ استشر طبيباً إذا'},
    'wasOracleWise': {
      'en': '✦ Was the Oracle Wise?',
      'ar': '✦ هل كان العرّاف حكيماً؟',
    },
    'yourReflection': {'en': '📝 Your Reflection', 'ar': '📝 تأملك'},
    'sealReflection': {'en': 'Seal Reflection', 'ar': 'احفظ التأمل'},
    'sealedInGrimoire': {
      'en': '✦ Sealed in the Grimoire',
      'ar': '✦ تم الحفظ في الكتاب',
    },
    'reflectionHint': {
      'en': 'How did this consultation serve you? What did you learn...',
      'ar': 'كيف أفادتك هذه الاستشارة؟ ماذا تعلمت...',
    },
    'nearbyHerbalists': {
      'en': '📍 Nearby Herbalists',
      'ar': '📍 عطارون قريبون',
    },
    'orderOnline': {'en': '🛒 Order Online', 'ar': '🛒 اطلب عبر الإنترنت'},
    'findIt': {'en': 'Find it →', 'ar': 'ابحث عنه ←'},
    'map': {'en': 'Map →', 'ar': 'الخريطة ←'},
    'notMedicalAdvice': {
      'en':
          '✦ This is not medical advice. Always consult a qualified healer for serious concerns.',
      'ar':
          '✦ هذا ليس استشارة طبية. استشر دائماً طبيباً مختصاً في الحالات الجدية.',
    },
    'grimoireRemembers': {
      'en': 'The Grimoire Remembers',
      'ar': 'الكتاب السحري يتذكر',
    },
    'signInToView': {
      'en': 'Sign in to view your consultations.',
      'ar': 'سجل الدخول لعرض استشاراتك.',
    },
    'grimoireSilent': {
      'en': 'The grimoire is silent',
      'ar': 'الكتاب السحري صامت',
    },
    'noConsultationsYet': {
      'en': 'No consultations yet.\nYour past inquiries will appear here.',
      'ar': 'لا توجد استشارات بعد.\nستظهر استفساراتك السابقة هنا.',
    },
    'yourRating': {'en': '✦ Your Rating', 'ar': '✦ تقييمك'},
  };

  static String t(String key) {
    final code = AppLocale.languageCode.value;
    return _strings[key]?[code] ?? _strings[key]?['en'] ?? key;
  }
}
