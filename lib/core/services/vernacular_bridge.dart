// Design Bible Reference: docs/DESIGN_BIBLE.md - Phase 5 (Gemini 3 Reasoning)
// Implements vernacular bridge for local language ingredient names

import 'package:flutter/foundation.dart';

/// VernacularBridge - Translates ingredient names to local languages
/// 
/// Specification from Design Bible:
/// - Supports multiple Indian languages (Hindi, Telugu, Tamil, etc.)
/// - Offline fallback dictionary for common ingredients
/// - Gemini 3 API integration for rare ingredients (optional)
/// - Geo-context aware (Hyderabad heritage focus)
class VernacularBridge {
  /// Offline dictionary of common Ayurvedic ingredients
  /// Format: {english_name: {language_code: vernacular_name}}
  static const Map<String, Map<String, String>> _offlineDictionary = {
    // Spices
    'turmeric': {
      'hi': 'हल्दी',
      'te': 'పసుపు',
      'ta': 'மஞ்சள்',
      'kn': 'ಅರಿಶಿನ',
      'ml': 'മഞ്ഞൾ',
    },
    'ginger': {
      'hi': 'अदरक',
      'te': 'అల్లం',
      'ta': 'இஞ்சி',
      'kn': 'ಶುಂಠಿ',
      'ml': 'ഇഞ്ചി',
    },
    'cumin': {
      'hi': 'जीरा',
      'te': 'జీలకర్ర',
      'ta': 'சீரகம்',
      'kn': 'ಜೀರಿಗೆ',
      'ml': 'ജീരകം',
    },
    'coriander': {
      'hi': 'धनिया',
      'te': 'ధనియాలు',
      'ta': 'கொத்தமல்லி',
      'kn': 'ಕೊತ್ತಂಬರಿ',
      'ml': 'മല്ലി',
    },
    'black pepper': {
      'hi': 'काली मिर्च',
      'te': 'నల్ల మిరియాలు',
      'ta': 'கருப்பு மிளகு',
      'kn': 'ಕರಿಮೆಣಸು',
      'ml': 'കുരുമുളക്',
    },
    'cardamom': {
      'hi': 'इलायची',
      'te': 'ఏలకులు',
      'ta': 'ஏலக்காய்',
      'kn': 'ಏಲಕ್ಕಿ',
      'ml': 'ഏലം',
    },
    'cinnamon': {
      'hi': 'दालचीनी',
      'te': 'దాల్చిన చెక్క',
      'ta': 'பட்டை',
      'kn': 'ದಾಲ್ಚಿನ್ನಿ',
      'ml': 'കറുവപ്പട്ട',
    },
    'clove': {
      'hi': 'लौंग',
      'te': 'లవంగాలు',
      'ta': 'கிராம்பு',
      'kn': 'ಲವಂಗ',
      'ml': 'ഗ്രാമ്പു',
    },
    
    // Herbs
    'tulsi': {
      'hi': 'तुलसी',
      'te': 'తులసి',
      'ta': 'துளசி',
      'kn': 'ತುಳಸಿ',
      'ml': 'തുളസി',
    },
    'neem': {
      'hi': 'नीम',
      'te': 'వేప',
      'ta': 'வேப்பம்',
      'kn': 'ಬೇವು',
      'ml': 'വേപ്പ്',
    },
    'ashwagandha': {
      'hi': 'अश्वगंधा',
      'te': 'అశ్వగంధ',
      'ta': 'அஸ்வகந்தா',
      'kn': 'ಅಶ್ವಗಂಧ',
      'ml': 'അശ്വഗന്ധ',
    },
    
    // Common ingredients
    'honey': {
      'hi': 'शहद',
      'te': 'తేనె',
      'ta': 'தேன்',
      'kn': 'ಜೇನು',
      'ml': 'തേൻ',
    },
    'ghee': {
      'hi': 'घी',
      'te': 'నెయ్యి',
      'ta': 'நெய்',
      'kn': 'ತುಪ್ಪ',
      'ml': 'നെയ്യ്',
    },
    'milk': {
      'hi': 'दूध',
      'te': 'పాలు',
      'ta': 'பால்',
      'kn': 'ಹಾಲು',
      'ml': 'പാൽ',
    },
    'water': {
      'hi': 'पानी',
      'te': 'నీరు',
      'ta': 'தண்ணீர்',
      'kn': 'ನೀರು',
      'ml': 'വെള്ളം',
    },
    'salt': {
      'hi': 'नमक',
      'te': 'ఉప్పు',
      'ta': 'உப்பு',
      'kn': 'ಉಪ್ಪು',
      'ml': 'ഉപ്പ്',
    },
    'sugar': {
      'hi': 'चीनी',
      'te': 'చక్కెర',
      'ta': 'சர்க்கரை',
      'kn': 'ಸಕ್ಕರೆ',
      'ml': 'പഞ്ചസാര',
    },
  };

  /// Supported language codes
  static const List<String> supportedLanguages = [
    'hi', // Hindi
    'te', // Telugu
    'ta', // Tamil
    'kn', // Kannada
    'ml', // Malayalam
  ];

  /// Language names for UI display
  static const Map<String, String> languageNames = {
    'hi': 'हिन्दी (Hindi)',
    'te': 'తెలుగు (Telugu)',
    'ta': 'தமிழ் (Tamil)',
    'kn': 'ಕನ್ನಡ (Kannada)',
    'ml': 'മലയാളം (Malayalam)',
  };

  /// Translate ingredient name to vernacular language
  /// 
  /// Returns the vernacular name if found in offline dictionary,
  /// otherwise returns the original English name
  /// 
  /// Future enhancement: Integrate Gemini 3 API for rare ingredients
  static String translate({
    required String ingredientName,
    required String languageCode,
  }) {
    // Normalize input
    final normalizedName = ingredientName.toLowerCase().trim();
    
    // Check offline dictionary
    if (_offlineDictionary.containsKey(normalizedName)) {
      final translations = _offlineDictionary[normalizedName]!;
      if (translations.containsKey(languageCode)) {
        return translations[languageCode]!;
      }
    }
    
    // Fallback: return original name
    return ingredientName;
  }

  /// Translate multiple ingredients
  static Map<String, String> translateBatch({
    required List<String> ingredientNames,
    required String languageCode,
  }) {
    return {
      for (var name in ingredientNames)
        name: translate(ingredientName: name, languageCode: languageCode),
    };
  }

  /// Check if ingredient has vernacular translation
  static bool hasTranslation({
    required String ingredientName,
    required String languageCode,
  }) {
    final normalizedName = ingredientName.toLowerCase().trim();
    return _offlineDictionary.containsKey(normalizedName) &&
        _offlineDictionary[normalizedName]!.containsKey(languageCode);
  }

  /// Get all available translations for an ingredient
  static Map<String, String> getAllTranslations(String ingredientName) {
    final normalizedName = ingredientName.toLowerCase().trim();
    return _offlineDictionary[normalizedName] ?? {};
  }

  /// Get geo-context aware language suggestion
  /// 
  /// Based on Hyderabad heritage focus, suggests Telugu as primary
  static String getSuggestedLanguage({String? userLocation}) {
    // Default to Telugu for Hyderabad heritage
    // Future: Use userLocation for geo-aware suggestions
    return 'te'; // Telugu
  }

  /// Format ingredient with vernacular name
  /// 
  /// Returns: "English Name (వెర్నాక్యులర్ నేమ్)"
  static String formatWithVernacular({
    required String ingredientName,
    required String languageCode,
  }) {
    final vernacularName = translate(
      ingredientName: ingredientName,
      languageCode: languageCode,
    );
    
    if (vernacularName != ingredientName) {
      return '$ingredientName ($vernacularName)';
    }
    
    return ingredientName;
  }

  /// Get offline dictionary size
  static int getDictionarySize() {
    return _offlineDictionary.length;
  }

  /// Check if language is supported
  static bool isLanguageSupported(String languageCode) {
    return supportedLanguages.contains(languageCode);
  }
}

/// Example usage:
/// 
/// ```dart
/// // Single translation
/// final hindiName = VernacularBridge.translate(
///   ingredientName: 'turmeric',
///   languageCode: 'hi',
/// );
/// print(hindiName); // Output: हल्दी
/// 
/// // Batch translation
/// final ingredients = ['turmeric', 'ginger', 'honey'];
/// final teluguNames = VernacularBridge.translateBatch(
///   ingredientNames: ingredients,
///   languageCode: 'te',
/// );
/// 
/// // Formatted display
/// final formatted = VernacularBridge.formatWithVernacular(
///   ingredientName: 'Turmeric',
///   languageCode: 'hi',
/// );
/// print(formatted); // Output: Turmeric (हल्दी)
/// ```
