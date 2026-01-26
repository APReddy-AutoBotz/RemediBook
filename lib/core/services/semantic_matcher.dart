import 'package:google_generative_ai/google_generative_ai.dart';
import '../../../core/services/vault_service.dart';

/// AI-Powered Semantic Matcher
/// Uses Gemini to intelligently map user queries to vault ailments
class SemanticMatcher {
  static GenerativeModel? _model;
  static const String _apiKey = ''; // To be provided via .env or initialize

  /// Initialize Gemini model
  static void initialize({String? apiKey}) {
    final key = apiKey ?? const String.fromEnvironment('GEMINI_API_KEY', defaultValue: _apiKey);
    if (key.isEmpty) {
      print('Warning: Gemini API Key is missing. AI features will not work.');
      return;
    }
    _model = GenerativeModel(
      model: 'gemini-pro',
      apiKey: key,
    );
  }

  /// Semantic search: Map user query to vault ailment
  /// Examples:
  /// - "running nose" → "Common Cold"
  /// - "stomach ache" → "Indigestion"  
  /// - "can't sleep" → "Insomnia"
  /// - "sugar problem" → "Type 2 Diabetes Support"
  static Future<String?> matchAilment(String userQuery) async {
    if (_model == null) initialize();

    try {
      // Get all vault ailments
      final entries = await VaultService.getAllEntries();
      final ailmentList = entries.map((e) => e.name).toList();

      // Create prompt for Gemini
      final prompt = '''
You are a medical symptom matcher. Given a user's symptom description, match it to the most appropriate ailment from the list below.

Available Ailments:
${ailmentList.asMap().entries.map((e) => '${e.key + 1}. ${e.value}').join('\n')}

User Query: "$userQuery"

Instructions:
1. Analyze the user's query semantically
2. Match it to the MOST APPROPRIATE ailment from the list
3. Return ONLY the exact ailment name from the list (nothing else)
4. If no good match exists, return "NO_MATCH"

Examples:
- "running nose" → "Common Cold"
- "stomach pain" → "Indigestion"
- "can't sleep" → "Insomnia"
- "high sugar" → "Type 2 Diabetes Support"
- "itchy throat" → "Sore Throat"
- "chest tightness" → "Respiratory Support"

Your response (exact ailment name only):''';

      final content = [Content.text(prompt)];
      final response = await _model!.generateContent(content);
      
      final matchedAilment = response.text?.trim() ?? '';
      
      // Validate response
      if (matchedAilment == 'NO_MATCH' || matchedAilment.isEmpty) {
        return null;
      }

      // Verify it's actually in our list
      if (ailmentList.contains(matchedAilment)) {
        return matchedAilment;
      }

      // Fallback: Try fuzzy matching
      for (final ailment in ailmentList) {
        if (ailment.toLowerCase().contains(matchedAilment.toLowerCase()) ||
            matchedAilment.toLowerCase().contains(ailment.toLowerCase())) {
          return ailment;
        }
      }

      return null;
    } catch (e) {
      print('Semantic matching error: $e');
      return null;
    }
  }

  /// Enhanced search with semantic understanding
  static Future<List<String>> semanticSearch(String query) async {
    if (_model == null) initialize();

    try {
      final entries = await VaultService.getAllEntries();
      final ailmentList = entries.map((e) => e.name).toList();

      final prompt = '''
You are a medical symptom analyzer. Given a user's query, identify ALL relevant ailments from the list.

Available Ailments:
${ailmentList.asMap().entries.map((e) => '${e.key + 1}. ${e.value}').join('\n')}

User Query: "$query"

Instructions:
1. Identify all ailments that could be related to the user's query
2. Return them as a comma-separated list
3. Order by relevance (most relevant first)
4. Return "NONE" if no matches

Examples:
- "cold and cough" → "Common Cold, Dry Cough, Sore Throat"
- "digestive issues" → "Indigestion, Bloating, Acidity, Constipation"
- "skin problems" → "Itchy Skin, Skin Dryness, Minor Burns"

Your response (comma-separated ailment names):''';

      final content = [Content.text(prompt)];
      final response = await _model!.generateContent(content);
      
      final result = response.text?.trim() ?? '';
      
      if (result == 'NONE' || result.isEmpty) {
        return [];
      }

      // Parse comma-separated results
      final matches = result.split(',').map((s) => s.trim()).toList();
      
      // Validate each match
      final validMatches = <String>[];
      for (final match in matches) {
        if (ailmentList.contains(match)) {
          validMatches.add(match);
        }
      }

      return validMatches;
    } catch (e) {
      print('Semantic search error: $e');
      return [];
    }
  }

  /// Symptom expansion: Understand related symptoms
  /// Example: "headache" → ["head pain", "migraine", "tension headache"]
  static Future<List<String>> expandSymptoms(String symptom) async {
    if (_model == null) initialize();

    try {
      final prompt = '''
Given a symptom, list related symptom descriptions that a user might use.

Symptom: "$symptom"

Return 3-5 related descriptions as comma-separated values.

Example:
- "headache" → "head pain, migraine, tension headache, throbbing head"
- "cold" → "running nose, sneezing, congestion, stuffy nose"

Your response (comma-separated):''';

      final content = [Content.text(prompt)];
      final response = await _model!.generateContent(content);
      
      final result = response.text?.trim() ?? '';
      return result.split(',').map((s) => s.trim()).toList();
    } catch (e) {
      print('Symptom expansion error: $e');
      return [];
    }
  }
}
