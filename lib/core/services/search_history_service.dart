import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Represents a single search query in the user's history
class SearchHistoryItem {
  final String query;
  final DateTime timestamp;
  final String? selectedRemedy;

  SearchHistoryItem({
    required this.query,
    required this.timestamp,
    this.selectedRemedy,
  });

  Map<String, dynamic> toJson() => {
        'query': query,
        'timestamp': timestamp.toIso8601String(),
        'selectedRemedy': selectedRemedy,
      };

  factory SearchHistoryItem.fromJson(Map<String, dynamic> json) {
    return SearchHistoryItem(
      query: json['query'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      selectedRemedy: json['selectedRemedy'] as String?,
    );
  }
}

/// Service for tracking and retrieving user search history
/// Used by the Dynamic Healing Schedule to inject ailment-specific recommendations
class SearchHistoryService {
  static const String _storageKey = 'remedi_search_history';
  static const int _maxHistoryItems = 100;

  /// Add a new search to history
  static Future<void> addSearch(String query, {String? selectedRemedy}) async {
    final prefs = await SharedPreferences.getInstance();
    final history = await getAll();

    // Add new search at the beginning
    history.insert(
      0,
      SearchHistoryItem(
        query: query,
        timestamp: DateTime.now(),
        selectedRemedy: selectedRemedy,
      ),
    );

    // Trim to max size
    if (history.length > _maxHistoryItems) {
      history.removeRange(_maxHistoryItems, history.length);
    }

    // Save to storage
    final jsonList = history.map((item) => item.toJson()).toList();
    await prefs.setString(_storageKey, jsonEncode(jsonList));
  }

  /// Get all search history items
  static Future<List<SearchHistoryItem>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);

    if (jsonString == null) return [];

    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList.map((json) => SearchHistoryItem.fromJson(json)).toList();
  }

  /// Get searches within a specific time window
  static Future<List<SearchHistoryItem>> getRecentSearches(Duration window) async {
    final allSearches = await getAll();
    final cutoffTime = DateTime.now().subtract(window);

    return allSearches.where((item) => item.timestamp.isAfter(cutoffTime)).toList();
  }

  /// Extract health conditions/ailments from search queries
  /// Returns a set of detected ailment keywords
  static Set<String> extractAilments(List<SearchHistoryItem> searches) {
    final ailments = <String>{};

    // Define ailment keywords to look for
    final ailmentKeywords = {
      // Metabolic conditions
      'diabetes': 'diabetes',
      'blood sugar': 'diabetes',
      'high sugar': 'diabetes',
      'diabetic': 'diabetes',
      
      // Respiratory
      'cold': 'common_cold',
      'cough': 'common_cold',
      'flu': 'common_cold',
      'congestion': 'common_cold',
      'sore throat': 'common_cold',
      
      // Digestive
      'acidity': 'acidity',
      'indigestion': 'indigestion',
      'bloating': 'indigestion',
      'gas': 'indigestion',
      
      // Pain
      'headache': 'headache',
      'migraine': 'headache',
      
      // Stress/Sleep
      'stress': 'stress',
      'anxiety': 'stress',
      'insomnia': 'sleep_issues',
      'sleep': 'sleep_issues',
    };

    for (final search in searches) {
      final queryLower = search.query.toLowerCase();
      
      for (final entry in ailmentKeywords.entries) {
        if (queryLower.contains(entry.key)) {
          ailments.add(entry.value);
        }
      }
    }

    return ailments;
  }

  /// Clear all search history
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }

  /// Get searches for a specific ailment
  static Future<List<SearchHistoryItem>> getSearchesForAilment(String ailment) async {
    final allSearches = await getAll();
    final ailmentLower = ailment.toLowerCase();

    return allSearches.where((item) {
      return item.query.toLowerCase().contains(ailmentLower);
    }).toList();
  }
}
