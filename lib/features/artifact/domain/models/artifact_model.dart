/// Artifact Models - Domain Layer
library;

/// Wellness Artifact Model
class WellnessArtifact {
  final String id;
  final String guideId; // RB-2026-XXXX format
  final String title;
  final DateTime generatedDate;
  final int evidenceCount;
  final bool isDownloaded;
  final String? pdfPath;

  const WellnessArtifact({
    required this.id,
    required this.guideId,
    required this.title,
    required this.generatedDate,
    required this.evidenceCount,
    this.isDownloaded = false,
    this.pdfPath,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'guideId': guideId,
      'title': title,
      'generatedDate': generatedDate.toIso8601String(),
      'evidenceCount': evidenceCount,
      'isDownloaded': isDownloaded,
      'pdfPath': pdfPath,
    };
  }

  factory WellnessArtifact.fromJson(Map<String, dynamic> json) {
    return WellnessArtifact(
      id: json['id'] as String,
      guideId: json['guideId'] as String,
      title: json['title'] as String,
      generatedDate: DateTime.parse(json['generatedDate'] as String),
      evidenceCount: json['evidenceCount'] as int,
      isDownloaded: json['isDownloaded'] as bool? ?? false,
      pdfPath: json['pdfPath'] as String?,
    );
  }
}

/// Artifact Metrics Model
class ArtifactMetrics {
  final int protocolsCompleted;
  final int guidesSaved;
  final int evidenceSourcesReviewed;

  const ArtifactMetrics({
    required this.protocolsCompleted,
    required this.guidesSaved,
    required this.evidenceSourcesReviewed,
  });

  Map<String, dynamic> toJson() {
    return {
      'protocolsCompleted': protocolsCompleted,
      'guidesSaved': guidesSaved,
      'evidenceSourcesReviewed': evidenceSourcesReviewed,
    };
  }

  factory ArtifactMetrics.fromJson(Map<String, dynamic> json) {
    return ArtifactMetrics(
      protocolsCompleted: json['protocolsCompleted'] as int? ?? 0,
      guidesSaved: json['guidesSaved'] as int? ?? 0,
      evidenceSourcesReviewed: json['evidenceSourcesReviewed'] as int? ?? 0,
    );
  }
}
