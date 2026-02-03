/// Evidence Ledger - Domain Models
/// Implements Pillar 4: Governance Layer evidence tracking
library;

/// Evidence Label Enum
/// Categorizes remedies by their evidence backing
enum EvidenceLabel {
  /// Traditional knowledge without modern clinical studies
  traditional,
  
  /// Backed by peer-reviewed research and clinical studies
  evidenceSupported,
  
  /// General Guidance - Web Sourced (Tier 3: AI Grounding)
  webSourced;

  /// Display name for UI
  String get displayName {
    switch (this) {
      case EvidenceLabel.traditional:
        return 'Traditional';
      case EvidenceLabel.evidenceSupported:
        return 'Evidence-Supported';
      case EvidenceLabel.webSourced:
        return 'General Guidance - Web Sourced';
    }
  }

  /// Icon name for UI
  String get iconName {
    switch (this) {
      case EvidenceLabel.traditional:
        return 'history_edu';
      case EvidenceLabel.evidenceSupported:
        return 'verified';
      case EvidenceLabel.webSourced:
        return 'public';
    }
  }
}

/// Citation Model
/// Represents a single evidence source
class Citation {
  final String id;
  final String title;
  final String source;
  final String url;
  final DateTime publicationDate;
  final String authors;

  const Citation({
    required this.id,
    required this.title,
    required this.source,
    required this.url,
    required this.publicationDate,
    required this.authors,
  });

  /// Create from JSON
  factory Citation.fromJson(Map<String, dynamic> json) {
    return Citation(
      id: json['id'] as String,
      title: json['title'] as String,
      source: json['source'] as String,
      url: json['url'] as String,
      publicationDate: DateTime.parse(json['publicationDate'] as String),
      authors: json['authors'] as String,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'source': source,
      'url': url,
      'publicationDate': publicationDate.toIso8601String(),
      'authors': authors,
    };
  }
}

/// Evidence Ledger Model
/// Tracks evidence backing for each remedy (Pillar 4)
class EvidenceLedger {
  final String remedyId;
  final EvidenceLabel label;
  final DateTime reviewDate;
  final int sourceCount;
  final List<Citation> primarySources;
  final String? notes;

  const EvidenceLedger({
    required this.remedyId,
    required this.label,
    required this.reviewDate,
    required this.sourceCount,
    required this.primarySources,
    this.notes,
  });

  /// Check if the evidence review is current (within 365 days)
  bool isReviewCurrent() {
    return DateTime.now().difference(reviewDate).inDays < 365;
  }

  /// Get review status message
  String getReviewStatus() {
    if (isReviewCurrent()) {
      return 'Current';
    } else {
      final daysOverdue = DateTime.now().difference(reviewDate).inDays - 365;
      return 'Review overdue by $daysOverdue days';
    }
  }

  /// Get next review date (365 days from last review)
  DateTime getNextReviewDate() {
    return reviewDate.add(const Duration(days: 365));
  }

  /// Get top N citations
  List<Citation> getTopCitations(int count) {
    return primarySources.take(count).toList();
  }

  /// Create from JSON
  factory EvidenceLedger.fromJson(Map<String, dynamic> json) {
    return EvidenceLedger(
      remedyId: json['remedyId'] as String,
      label: EvidenceLabel.values.firstWhere(
        (e) => e.name == json['label'],
      ),
      reviewDate: DateTime.parse(json['reviewDate'] as String),
      sourceCount: json['sourceCount'] as int,
      primarySources: (json['primarySources'] as List)
          .map((e) => Citation.fromJson(e as Map<String, dynamic>))
          .toList(),
      notes: json['notes'] as String?,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'remedyId': remedyId,
      'label': label.name,
      'reviewDate': reviewDate.toIso8601String(),
      'sourceCount': sourceCount,
      'primarySources': primarySources.map((e) => e.toJson()).toList(),
      'notes': notes,
    };
  }

  /// Copy with modifications
  EvidenceLedger copyWith({
    String? remedyId,
    EvidenceLabel? label,
    DateTime? reviewDate,
    int? sourceCount,
    List<Citation>? primarySources,
    String? notes,
  }) {
    return EvidenceLedger(
      remedyId: remedyId ?? this.remedyId,
      label: label ?? this.label,
      reviewDate: reviewDate ?? this.reviewDate,
      sourceCount: sourceCount ?? this.sourceCount,
      primarySources: primarySources ?? this.primarySources,
      notes: notes ?? this.notes,
    );
  }
}
