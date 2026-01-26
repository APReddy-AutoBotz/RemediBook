import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/artifact_model.dart';

/// Artifact Repository - Local Storage Management
/// Tracks generated guides, downloads, and evidence citations
class ArtifactRepository {
  static const String _artifactsKey = 'wellness_artifacts';
  static const String _metricsKey = 'artifact_metrics';

  // ═══════════════════════════════════════════════════════════════════════
  // ARTIFACT MANAGEMENT
  // ═══════════════════════════════════════════════════════════════════════

  /// Save a new artifact
  Future<void> saveArtifact(WellnessArtifact artifact) async {
    final prefs = await SharedPreferences.getInstance();
    final artifacts = await getAllArtifacts();
    
    artifacts.add(artifact);
    
    final jsonList = artifacts.map((a) => a.toJson()).toList();
    await prefs.setString(_artifactsKey, jsonEncode(jsonList));
    
    // Update metrics
    await _incrementProtocolsCompleted();
    if (artifact.isDownloaded) {
      await _incrementGuidesSaved();
    }
  }

  /// Get all artifacts
  Future<List<WellnessArtifact>> getAllArtifacts() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_artifactsKey);
    
    if (jsonString == null) return [];
    
    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList
        .map((json) => WellnessArtifact.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Get artifact by ID
  Future<WellnessArtifact?> getArtifactById(String id) async {
    final artifacts = await getAllArtifacts();
    try {
      return artifacts.firstWhere((a) => a.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Mark artifact as downloaded
  Future<void> markAsDownloaded(String id, String pdfPath) async {
    final artifacts = await getAllArtifacts();
    final index = artifacts.indexWhere((a) => a.id == id);
    
    if (index != -1) {
      final updated = WellnessArtifact(
        id: artifacts[index].id,
        guideId: artifacts[index].guideId,
        title: artifacts[index].title,
        generatedDate: artifacts[index].generatedDate,
        evidenceCount: artifacts[index].evidenceCount,
        isDownloaded: true,
        pdfPath: pdfPath,
      );
      
      artifacts[index] = updated;
      
      final prefs = await SharedPreferences.getInstance();
      final jsonList = artifacts.map((a) => a.toJson()).toList();
      await prefs.setString(_artifactsKey, jsonEncode(jsonList));
      
      await _incrementGuidesSaved();
    }
  }

  /// Delete artifact
  Future<void> deleteArtifact(String id) async {
    final artifacts = await getAllArtifacts();
    artifacts.removeWhere((a) => a.id == id);
    
    final prefs = await SharedPreferences.getInstance();
    final jsonList = artifacts.map((a) => a.toJson()).toList();
    await prefs.setString(_artifactsKey, jsonEncode(jsonList));
  }

  // ═══════════════════════════════════════════════════════════════════════
  // METRICS MANAGEMENT
  // ═══════════════════════════════════════════════════════════════════════

  /// Get current metrics
  Future<ArtifactMetrics> getMetrics() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_metricsKey);
    
    if (jsonString == null) {
      return const ArtifactMetrics(
        protocolsCompleted: 0,
        guidesSaved: 0,
        evidenceSourcesReviewed: 0,
      );
    }
    
    return ArtifactMetrics.fromJson(
      jsonDecode(jsonString) as Map<String, dynamic>,
    );
  }

  /// Increment protocols completed
  Future<void> _incrementProtocolsCompleted() async {
    final metrics = await getMetrics();
    final updated = ArtifactMetrics(
      protocolsCompleted: metrics.protocolsCompleted + 1,
      guidesSaved: metrics.guidesSaved,
      evidenceSourcesReviewed: metrics.evidenceSourcesReviewed,
    );
    await _saveMetrics(updated);
  }

  /// Increment guides saved
  Future<void> _incrementGuidesSaved() async {
    final metrics = await getMetrics();
    final updated = ArtifactMetrics(
      protocolsCompleted: metrics.protocolsCompleted,
      guidesSaved: metrics.guidesSaved + 1,
      evidenceSourcesReviewed: metrics.evidenceSourcesReviewed,
    );
    await _saveMetrics(updated);
  }

  /// Increment evidence sources reviewed
  Future<void> incrementEvidenceSourcesReviewed(int count) async {
    final metrics = await getMetrics();
    final updated = ArtifactMetrics(
      protocolsCompleted: metrics.protocolsCompleted,
      guidesSaved: metrics.guidesSaved,
      evidenceSourcesReviewed: metrics.evidenceSourcesReviewed + count,
    );
    await _saveMetrics(updated);
  }

  /// Save metrics
  Future<void> _saveMetrics(ArtifactMetrics metrics) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_metricsKey, jsonEncode(metrics.toJson()));
  }

  /// Reset all metrics (for testing)
  Future<void> resetMetrics() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_metricsKey);
  }

  /// Clear all artifacts (for testing)
  Future<void> clearAllArtifacts() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_artifactsKey);
  }
}
