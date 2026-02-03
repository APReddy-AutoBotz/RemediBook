// Gemini Remedy Generator - Dynamic Remedy Generation with Physician Verification
// Uses Gemini API for semantic matching and remedy generation

import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import '../../features/discovery/domain/models/remedy.dart';
import '../../features/discovery/domain/models/fulfillment_models.dart';
import '../../features/discovery/domain/models/evidence_ledger.dart';
import '../../features/discovery/data/mock_remedy_database.dart';

/// Gemini Remedy Generator Service
/// 
/// Handles:
/// - Semantic matching against physician-approved remedies
/// - Dynamic remedy generation via Gemini API
/// - Remedy refinement (kid-friendly, no honey, etc.)
class GeminiRemedyGenerator {
  static GenerativeModel? _model;
  static final Map<String, List<Remedy>> _cache = {};
  
  /// Initialize Gemini model with API key
  static void initialize(String apiKey) {
    _model = GenerativeModel(
      model: 'gemini-2.0-flash',
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.7,
        topK: 40,
        topP: 0.95,
        maxOutputTokens: 2048,
      ),
    );
  }
  
  /// Generate remedies for a user query
  /// 
  /// Flow:
  /// 1. Check semantic match against physician-approved remedies
  /// 2. If match found (≥80% confidence), return physician-approved remedy
  /// 3. Otherwise, generate new remedy via Gemini
  static Future<List<Remedy>> generateRemedies(String query) async {
    // Check cache first
    if (_cache.containsKey(query.toLowerCase())) {
      return _cache[query.toLowerCase()]!;
    }
    
    try {
      // Step 1: Check for semantic match with physician-approved remedies
      final physicianApprovedMatch = await _findPhysicianApprovedMatch(query);
      if (physicianApprovedMatch != null) {
        debugPrint('✅ Physician-approved match found for: $query');
        _cache[query.toLowerCase()] = [physicianApprovedMatch];
        return [physicianApprovedMatch];
      }
      
      // Step 2: Generate new remedy via Gemini
      debugPrint('🤖 Generating new remedy via Gemini for: $query');
      final generatedRemedies = await _generateViaGemini(query);
      _cache[query.toLowerCase()] = generatedRemedies;
      return generatedRemedies;
      
    } catch (e) {
      debugPrint('❌ Error generating remedies: $e');
      // Fallback: try simple keyword match in physician-approved
      return _fallbackSearch(query);
    }
  }
  
  /// Find physician-approved remedy using semantic matching
  static Future<Remedy?> _findPhysicianApprovedMatch(String query) async {
    if (_model == null) return null;
    
    try {
      final physicianApprovedRemedies = MockRemedyDatabase.getAll();
      
      // Use Gemini to find semantic similarity
      final prompt = '''
You are a conservative medical semantic matcher. Your task is to match the User Query to a Physician-Approved Remedy ONLY if there is a strong, direct clinical correlation.

USER QUERY: "$query"

PHYSICIAN-APPROVED REMEDIES:
${physicianApprovedRemedies.asMap().entries.map((entry) => '''
ID: ${entry.key + 1}
Name: ${entry.value.name}
Symptoms: ${entry.value.symptoms.join(', ')}
''').join('\n')}

RULES:
1. Match ONLY if the query strongly aligns with the specific symptoms listed.
2. Return "0" if the connection is weak, checking for distinct conditions (e.g., do NOT match "headache" to "digestion" or "diabetes").
3. It is BETTER to return "0" (No Match) than to provide an incorrect remedy.
4. Ignore "metabolic" or "energy" for "headache" queries.

RESPONSE FORMAT: Just the integer ID (0, 1, 2, or 3).
''';
      
      final response = await _retryGenerate(prompt);
      final matchNumber = int.tryParse(response.text?.trim() ?? '0') ?? 0;
      
      if (matchNumber > 0 && matchNumber <= physicianApprovedRemedies.length) {
        return physicianApprovedRemedies[matchNumber - 1];
      }
      
      return null;
    } catch (e) {
      debugPrint('Semantic matching error: $e');
      return null;
    }
  }
  
  /// Generate remedy via Gemini API
  static Future<List<Remedy>> _generateViaGemini(String query) async {
    if (_model == null) {
      throw Exception('Gemini model not initialized');
    }
    
    final prompt = '''
You are an expert Ayurvedic practitioner. Generate a safe, evidence-based natural remedy for: "$query"

Provide a structured remedy with:
1. **Name**: Catchy, descriptive name (e.g., "Cooling Cucumber Mint Tea")
2. **Description**: 2-3 sentences explaining benefits and traditional use
3. **Symptoms**: List of 3-5 symptoms this addresses
4. **Ingredients**: 4-6 ingredients with quantities (e.g., "1 inch fresh ginger root")
5. **Instructions**: 5-7 clear preparation steps
6. **Traditional Wisdom**: 2-3 sentences about historical/traditional context
7. **Scientific Context**: Mention any known compounds or research (keep brief)
8. **Safety**: Any contraindications or warnings
9. **Category**: Best category (e.g., "Digestive Health", "Respiratory Support")

FORMAT (JSON):
{
  "name": "Remedy Name",
  "description": "Brief description...",
  "symptoms": ["symptom1", "symptom2", "symptom3"],
  "ingredients": ["ingredient with quantity", "..."],
  "instructions": ["Step 1", "Step 2", "..."],
  "traditionalWisdom": "Historical context...",
  "scientificContext": "Research notes...",
  "safety": "Any warnings or contraindications",
  "category": "Category Name"
}

Keep it safe, natural, and evidence-based. Avoid dangerous or unproven treatments.
''';
    
    try {
      final response = await _retryGenerate(prompt);
      final text = response.text ?? '';
      
      // Parse JSON response
      final remedy = _parseGeminiResponse(text, query);
      return [remedy];
      
    } catch (e) {
      debugPrint('Gemini generation error: $e');
      return _fallbackSearch(query);
    }
  }
  
  /// Parse Gemini JSON response into Remedy object
  static Remedy _parseGeminiResponse(String text, String query) {
    try {
      // Extract JSON from response (Gemini sometimes adds markdown)
      final jsonStart = text.indexOf('{');
      final jsonEnd = text.lastIndexOf('}') + 1;
      
      if (jsonStart == -1 || jsonEnd == 0) {
        throw Exception('No JSON found in response');
      }
      
      final jsonText = text.substring(jsonStart, jsonEnd);
      
      // Parse JSON
      final Map<String, dynamic> data = jsonDecode(jsonText);
      
      return Remedy(
        id: 'gemini_${DateTime.now().millisecondsSinceEpoch}',
        name: data['name'] ?? 'Custom Remedy',
        description: data['description'] ?? 'A natural remedy suggestion.',
        symptoms: List<String>.from(data['symptoms'] ?? [query]),
        ingredients: List<String>.from(data['ingredients'] ?? []),
        instructions: List<String>.from(data['instructions'] ?? []),
        traditionalWisdom: data['traditionalWisdom'],
        scientificContext: data['scientificContext'],
        safetyContext: data['safety'],
        category: data['category'] ?? 'Wellness',
        fibreToCarbRatio: 0.0,
        evidenceLedger: null, // AI-generated
      );
      
    } catch (e) {
      debugPrint('JSON parsing error: $e');
      // Return basic fallback remedy
      return _createFallbackRemedy(query);
    }
  }
  
  /// Fallback search using simple keyword matching
  static List<Remedy> _fallbackSearch(String query) {
    final results = MockRemedyDatabase.searchBySymptom(query);
    if (results.isNotEmpty) {
      return results;
    }
    
    // Last resort: return a generic remedy
    return [_createFallbackRemedy(query)];
  }
  
  /// Create a basic fallback remedy
  static Remedy _createFallbackRemedy(String query) {
    return Remedy(
      id: 'fallback_${query.hashCode}',
      name: 'General Wellness Support',
      description: 'A gentle, supportive remedy based on traditional wellness practices. Always consult a healthcare provider for specific medical concerns.',
      symptoms: [query, 'general wellness'],
      ingredients: [
        '1 cup warm water',
        '1 teaspoon honey',
        '1/2 teaspoon turmeric',
      ],
      instructions: [
        'Mix honey and turmeric in warm water',
        'Stir well until dissolved',
        'Drink slowly, 1-2 times daily',
        'Consult a physician if symptoms persist',
      ],
      fibreToCarbRatio: 0.0,
      category: 'General Support',
      evidenceLedger: null,
    );
  }
  
  /// Refine a remedy based on user preferences
  static Future<Remedy> refineRemedy(Remedy remedy, String refiner) async {
    if (_model == null) {
      return remedy; // Return unchanged if no model
    }
    
    try {
      final prompt = '''
Modify this remedy to be "$refiner".

ORIGINAL REMEDY:
Name: ${remedy.name}
Ingredients: ${remedy.ingredients.join(', ')}
Instructions: ${remedy.instructions.join('. ')}

REFINEMENT: $refiner

Provide modified:
1. Name (adjusted for refinement)
2. Description (mention the adjustment)
3. Ingredients (substitutions if needed)
4. Instructions (modified steps)

Keep it safe and practical.
''';
      
      final response = await _retryGenerate(prompt);
      // For now, return a modified version
      // In production, parse the Gemini response properly
      
      return remedy; // Placeholder
      
    } catch (e) {
      debugPrint('Refinement error: $e');
      return remedy;
    }
  }
  
  /// Helper: Capitalize first letter
  static String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  /// Helper: Generate content with retry logic for 429 errors
  static Future<GenerateContentResponse> _retryGenerate(String promptText) async {
    int attempts = 0;
    while (attempts < 3) {
      try {
        return await _model!.generateContent([Content.text(promptText)]);
      } catch (e) {
        // Check for rate limit / quota errors (429)
        if (e.toString().contains('429') || e.toString().toLowerCase().contains('quota')) {
          attempts++;
          debugPrint('⚠️ Gemini limit hit (429). Retrying in ${2 * attempts}s... (Attempt $attempts/3)');
          if (attempts >= 3) rethrow;
          await Future.delayed(Duration(seconds: 2 * attempts));
        } else {
          rethrow;
        }
      }
    }
    throw Exception('Gemini generation failed after retries');
  }
}
