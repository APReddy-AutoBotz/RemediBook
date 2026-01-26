import 'package:flutter/material.dart';
import '../../../../core/theme/remedi_theme.dart';
import '../../domain/models/evidence_ledger.dart';

/// RemediEvidenceBadge - Clinical Calm Evidence Label
/// Displays Traditional or Evidence-Supported badges with proper styling
class RemediEvidenceBadge extends StatelessWidget {
  final EvidenceLabel label;
  final bool isCompact;

  const RemediEvidenceBadge({
    super.key,
    required this.label,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final isEvidenceSupported = label == EvidenceLabel.evidenceSupported;
    
    // Clinical Calm colors - muted tones
    final backgroundColor = isEvidenceSupported
        ? RemediTheme.deepTeal.withOpacity(0.08)
        : RemediTheme.mutedSage.withOpacity(0.08);
    
    final borderColor = isEvidenceSupported
        ? RemediTheme.deepTeal.withOpacity(0.25)
        : RemediTheme.mutedSage.withOpacity(0.25);
    
    final textColor = isEvidenceSupported
        ? RemediTheme.deepTeal
        : RemediTheme.mutedSage;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? RemediTheme.spaceSM : RemediTheme.spaceSM + 2,
        vertical: isCompact ? RemediTheme.spaceXS : RemediTheme.spaceXS + 2,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: borderColor,
          width: 1.0,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isEvidenceSupported ? Icons.verified : Icons.history_edu,
            size: isCompact ? 12 : 14,
            color: textColor,
          ),
          SizedBox(width: isCompact ? 4 : 6),
          Text(
            label.displayName,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: textColor,
                  fontSize: isCompact ? 10 : 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
          ),
        ],
      ),
    );
  }
}

/// Evidence Source Count Badge
/// Shows number of citations in a minimal badge
class EvidenceSourceCount extends StatelessWidget {
  final int count;

  const EvidenceSourceCount({
    super.key,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: RemediTheme.spaceSM,
        vertical: RemediTheme.spaceXS,
      ),
      decoration: BoxDecoration(
        color: RemediTheme.charcoal.withOpacity(0.05),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.library_books,
            size: 12,
            color: RemediTheme.charcoal.withOpacity(0.6),
          ),
          const SizedBox(width: 4),
          Text(
            '$count source${count != 1 ? 's' : ''}',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: RemediTheme.charcoal.withOpacity(0.7),
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }
}

/// Review Status Indicator
/// Shows if evidence review is current or overdue
class ReviewStatusIndicator extends StatelessWidget {
  final EvidenceLedger ledger;

  const ReviewStatusIndicator({
    super.key,
    required this.ledger,
  });

  @override
  Widget build(BuildContext context) {
    final isCurrent = ledger.isReviewCurrent();
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isCurrent ? Icons.check_circle : Icons.warning,
          size: 12,
          color: isCurrent 
              ? RemediTheme.deepTeal.withOpacity(0.6)
              : const Color(0xFFF59E0B).withOpacity(0.8),
        ),
        const SizedBox(width: 4),
        Text(
          ledger.getReviewStatus(),
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: RemediTheme.charcoal.withOpacity(0.6),
                fontSize: 10,
              ),
        ),
      ],
    );
  }
}
