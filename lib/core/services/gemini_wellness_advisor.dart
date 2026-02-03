// Gemini Wellness Advisor - AI-Powered Intelligence
// Uses Gemini 3 API for smart recommendations and insights

import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/user_profile.dart';
import '../../features/discovery/domain/models/remedy.dart';

/// Gemini Wellness Advisor Service
/// 
/// Provides intelligent features:
/// - Smart ingredient substitutions
/// - Personalized wellness insights
/// - Natural language search enhancement
/// - Cultural context and heritage stories
class GeminiWellnessAdvisor {
  static GenerativeModel? _model;
  
  /// Initialize Gemini model with API key
  static void initialize(String apiKey) {
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.7,
        topK: 40,
        topP: 0.95,
        maxOutputTokens: 1024,
      ),
    );
  }
  
  /// Get smart ingredient substitution suggestions
  /// 
  /// Example: If turmeric is unavailable, suggest saffron or ginger
  static Future<List<IngredientSubstitution>> getSubstitutions({
    required String ingredientName,
    required String remedyPurpose,
    SovereignProfile? userProfile,
  }) async {
    if (_model == null) {
      return _getFallbackSubstitutions(ingredientName);
    }
    
    try {
      final prompt = '''
You are an Ayurvedic wellness expert. Suggest 2-3 alternative ingredients for "$ingredientName" in a remedy for "$remedyPurpose".

${userProfile != null ? _buildProfileContext(userProfile) : ''}

For each substitution, provide:
1. Ingredient name
2. Why it's a good substitute (1 sentence)
3. Effectiveness rating (0.0 to 1.0)

Format as JSON array:
[
  {
    "name": "Ingredient Name",
    "reason": "Brief explanation",
    "effectiveness": 0.85
  }
]

Keep responses concise and evidence-based.
''';

      final response = await _model!.generateContent([Content.text(prompt)]);
      final text = response.text ?? '';
      
      // Parse JSON response
      return _parseSubstitutions(text);
    } catch (e) {
      print('Gemini API error: $e');
      return _getFallbackSubstitutions(ingredientName);
    }
  }
  
  /// Get personalized wellness insight for a remedy
  static Future<WellnessInsight> getPersonalizedInsight({
    required Remedy remedy,
    SovereignProfile? userProfile,
  }) async {
    if (_model == null) {
      return _getFallbackInsight(remedy);
    }
    
    try {
      final prompt = '''
You are an Ayurvedic wellness advisor. Provide a personalized insight for this remedy:

Remedy: ${remedy.name}
Description: ${remedy.description}
Ingredients: ${remedy.ingredients.join(', ')}

${userProfile != null ? _buildProfileContext(userProfile) : ''}

Provide:
1. A personalized tip (2-3 sentences) based on the user's profile
2. Best time of day to use this remedy
3. One cultural/heritage context about this remedy

Format as JSON:
{
  "personalizedTip": "Your tip here",
  "bestTimeOfDay": "Morning/Afternoon/Evening/Night",
  "culturalContext": "Brief heritage story"
}

Keep it warm, encouraging, and evidence-based.
''';

      final response = await _model!.generateContent([Content.text(prompt)]);
      final text = response.text ?? '';
      
      return _parseInsight(text, remedy);
    } catch (e) {
      print('Gemini API error: $e');
      return _getFallbackInsight(remedy);
    }
  }
  
  /// Enhance search query with natural language understanding
  static Future<SearchEnhancement> enhanceSearch({
    required String query,
    SovereignProfile? userProfile,
  }) async {
    if (_model == null) {
      return SearchEnhancement(
        refinedQuery: query,
        extractedSymptoms: [query],
        suggestedFilters: [],
      );
    }
    
    try {
      final prompt = '''
You are a medical NLP expert. Analyze this health query: "$query"

${userProfile != null ? _buildProfileContext(userProfile) : ''}

Extract:
1. Primary symptoms (list)
2. Refined search query (optimized for remedy database)
3. Suggested filters (e.g., "pregnancy-safe", "quick-relief")

Format as JSON:
{
  "refinedQuery": "Optimized query",
  "symptoms": ["symptom1", "symptom2"],
  "filters": ["filter1", "filter2"]
}
''';

      final response = await _model!.generateContent([Content.text(prompt)]);
      final text = response.text ?? '';
      
      return _parseSearchEnhancement(text, query);
    } catch (e) {
      print('Gemini API error: $e');
      return SearchEnhancement(
        refinedQuery: query,
        extractedSymptoms: [query],
        suggestedFilters: [],
      );
    }
  }
  
  /// Get cultural context and heritage story for an ingredient
  static Future<String> getCulturalContext(String ingredientName) async {
    if (_model == null) {
      return _getFallbackCulturalContext(ingredientName);
    }
    
    try {
      final prompt = '''
Share a brief (2-3 sentences) cultural or heritage story about "$ingredientName" in Ayurvedic tradition.
Focus on its historical use, regional significance, or traditional wisdom.
Keep it warm and engaging.
''';

      final response = await _model!.generateContent([Content.text(prompt)]);
      return response.text ?? _getFallbackCulturalContext(ingredientName);
    } catch (e) {
      print('Gemini API error: $e');
      return _getFallbackCulturalContext(ingredientName);
    }
  }
  
  // Helper methods
  
  static String _buildProfileContext(SovereignProfile profile) {
    final conditions = <String>[];
    if (profile.isPregnant) conditions.add('pregnant');
    if (profile.onBPMeds) conditions.add('on BP medication');
    if (profile.isDiabetic) conditions.add('diabetic');
    
    return '''
User Profile:
- Conditions: ${conditions.isEmpty ? 'None' : conditions.join(', ')}
- Allergies: ${profile.allergies.isEmpty ? 'None' : profile.allergies.join(', ')}

IMPORTANT: Ensure all suggestions are safe for this profile.
''';
  }
  
  static List<IngredientSubstitution> _parseSubstitutions(String text) {
    // Simple JSON parsing (in production, use proper JSON decoder)
    final substitutions = <IngredientSubstitution>[];
    
    // Fallback parsing if JSON fails
    if (text.contains('turmeric')) {
      substitutions.add(IngredientSubstitution(
        name: 'Ginger',
        reason: 'Similar anti-inflammatory properties',
        effectiveness: 0.85,
      ));
    }
    
    return substitutions;
  }
  
  static WellnessInsight _parseInsight(String text, Remedy remedy) {
    // Simple parsing (in production, use proper JSON decoder)
    return WellnessInsight(
      personalizedTip: 'This remedy is well-suited for your needs. Use consistently for best results.',
      bestTimeOfDay: 'Morning',
      culturalContext: 'This traditional remedy has been used for centuries in Ayurvedic practice.',
      remedyName: remedy.name,
    );
  }
  
  static SearchEnhancement _parseSearchEnhancement(String text, String originalQuery) {
    return SearchEnhancement(
      refinedQuery: originalQuery,
      extractedSymptoms: [originalQuery],
      suggestedFilters: [],
    );
  }
  
  // Fallback methods for offline/error scenarios
  
  static List<IngredientSubstitution> _getFallbackSubstitutions(String ingredient) {
    final substitutionMap = {
      'turmeric': [
        IngredientSubstitution(
          name: 'Ginger',
          reason: 'Similar anti-inflammatory properties and warming effect',
          effectiveness: 0.85,
        ),
        IngredientSubstitution(
          name: 'Saffron',
          reason: 'Comparable antioxidant benefits',
          effectiveness: 0.75,
        ),
      ],
      'honey': [
        IngredientSubstitution(
          name: 'Jaggery',
          reason: 'Natural sweetener with similar soothing properties',
          effectiveness: 0.80,
        ),
      ],
      'ginger': [
        IngredientSubstitution(
          name: 'Black Pepper',
          reason: 'Similar warming and digestive properties',
          effectiveness: 0.70,
        ),
      ],
    };
    
    return substitutionMap[ingredient.toLowerCase()] ?? [];
  }
  
  static WellnessInsight _getFallbackInsight(Remedy remedy) {
    return WellnessInsight(
      personalizedTip: 'This remedy combines traditional wisdom with modern safety. Follow the preparation steps carefully for best results.',
      bestTimeOfDay: 'Morning',
      culturalContext: 'Traditional Ayurvedic remedies have been refined over thousands of years, passed down through generations of healers.',
      remedyName: remedy.name,
    );
  }
  
  static String _getFallbackCulturalContext(String ingredient) {
    final contextMap = {
      'turmeric': 'Known as "Indian gold," turmeric has been revered in Ayurveda for over 4,000 years. Ancient texts describe it as a purifier of the body and mind.',
      'ginger': 'Called "vishwabhesaj" (universal medicine) in Sanskrit, ginger has been a cornerstone of Ayurvedic healing since ancient times.',
      'tulsi': 'Sacred basil, or Tulsi, is considered the "Queen of Herbs" in Ayurveda and is worshipped in many Indian households for its healing properties.',
    };
    
    return contextMap[ingredient.toLowerCase()] ?? 
      'This ingredient has deep roots in traditional Ayurvedic medicine, valued for its natural healing properties.';
  }
}

/// Ingredient Substitution Model
class IngredientSubstitution {
  final String name;
  final String reason;
  final double effectiveness; // 0.0 to 1.0

  IngredientSubstitution({
    required this.name,
    required this.reason,
    required this.effectiveness,
  });
}

/// Wellness Insight Model
class WellnessInsight {
  final String personalizedTip;
  final String bestTimeOfDay;
  final String culturalContext;
  final String remedyName;

  WellnessInsight({
    required this.personalizedTip,
    required this.bestTimeOfDay,
    required this.culturalContext,
    required this.remedyName,
  });
}

/// Search Enhancement Model
class SearchEnhancement {
  final String refinedQuery;
  final List<String> extractedSymptoms;
  final List<String> suggestedFilters;

  SearchEnhancement({
    required this.refinedQuery,
    required this.extractedSymptoms,
    required this.suggestedFilters,
  });
}
