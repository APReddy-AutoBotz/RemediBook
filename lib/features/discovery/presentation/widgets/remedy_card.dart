import 'package:flutter/material.dart';
import '../../../../core/theme/remedi_theme.dart';
import '../../domain/models/evidence_ledger.dart';
import 'evidence_badge.dart';

/// RemedyCard - Triad of Trust UI Component
/// Displays remedy information with macro photo, evidence labels, and expandable citations
class RemedyCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final String? imagePath;
  final EvidenceLedger evidenceLedger;
  final String description;
  final List<String> benefits;
  final VoidCallback? onTap;

  const RemedyCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.imagePath,
    required this.evidenceLedger,
    required this.description,
    this.benefits = const [],
    this.onTap,
  });

  @override
  State<RemedyCard> createState() => _RemedyCardState();
}

class _RemedyCardState extends State<RemedyCard>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: RemediTheme.spaceMD,
        vertical: RemediTheme.spaceSM,
      ),
      decoration: RemediDecorations.stoneBordered(
        borderRadius: RemediTheme.radiusStone,
        shadowOpacity: 0.04,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(RemediTheme.radiusStone),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Macro Photo Header
            if (widget.imagePath != null)
              _buildMacroPhotoHeader(),

            // Content Section
            Padding(
              padding: const EdgeInsets.all(RemediTheme.spaceMD),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title & Evidence Badge
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title (Lora Serif)
                            Text(
                              widget.title,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                    fontSize: 20,
                                    height: 1.2,
                                  ),
                            ),
                            const SizedBox(height: RemediTheme.spaceXS),
                            // Subtitle
                            Text(
                              widget.subtitle,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: RemediTheme.charcoal.withOpacity(0.7),
                                  ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: RemediTheme.spaceSM),
                      RemediEvidenceBadge(label: widget.evidenceLedger.label),
                    ],
                  ),

                  const SizedBox(height: RemediTheme.spaceMD),

                  // Description
                  Text(
                    widget.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),

                  // Benefits
                  if (widget.benefits.isNotEmpty) ...[
                    const SizedBox(height: RemediTheme.spaceSM),
                    Wrap(
                      spacing: RemediTheme.spaceSM,
                      runSpacing: RemediTheme.spaceXS,
                      children: widget.benefits
                          .map((benefit) => _buildBenefitChip(benefit))
                          .toList(),
                    ),
                  ],

                  const SizedBox(height: RemediTheme.spaceSM),

                  // Evidence Metadata
                  Row(
                    children: [
                      EvidenceSourceCount(
                        count: widget.evidenceLedger.sourceCount,
                      ),
                      const SizedBox(width: RemediTheme.spaceSM),
                      ReviewStatusIndicator(ledger: widget.evidenceLedger),
                    ],
                  ),

                  // Receipts Drawer Toggle
                  const SizedBox(height: RemediTheme.spaceSM),
                  _buildReceiptsDrawerToggle(),
                ],
              ),
            ),

            // Expandable Receipts Drawer
            SizeTransition(
              sizeFactor: _expandAnimation,
              child: _buildReceiptsDrawer(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMacroPhotoHeader() {
    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        color: RemediTheme.mutedSage.withOpacity(0.1),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            widget.imagePath!,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Center(
                child: Icon(
                  Icons.image,
                  size: 48,
                  color: RemediTheme.mutedSage.withOpacity(0.3),
                ),
              );
            },
          ),
          // Gradient overlay for better text readability
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.1),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitChip(String benefit) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: RemediTheme.spaceSM,
        vertical: RemediTheme.spaceXS,
      ),
      decoration: BoxDecoration(
        color: RemediTheme.mutedSage.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: RemediTheme.mutedSage.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Text(
        benefit,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: RemediTheme.deepTeal,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
      ),
    );
  }

  Widget _buildReceiptsDrawerToggle() {
    return InkWell(
      onTap: _toggleExpanded,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: RemediTheme.spaceSM,
          vertical: RemediTheme.spaceXS + 2,
        ),
        decoration: BoxDecoration(
          border: Border.all(
            color: RemediTheme.deepTeal.withOpacity(0.2),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.receipt_long,
              size: 14,
              color: RemediTheme.deepTeal,
            ),
            const SizedBox(width: 6),
            Text(
              _isExpanded ? 'Hide Citations' : 'View Citations',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: RemediTheme.deepTeal,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
            ),
            const SizedBox(width: 4),
            AnimatedRotation(
              turns: _isExpanded ? 0.5 : 0,
              duration: const Duration(milliseconds: 300),
              child: Icon(
                Icons.keyboard_arrow_down,
                size: 16,
                color: RemediTheme.deepTeal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptsDrawer() {
    return Container(
      padding: const EdgeInsets.all(RemediTheme.spaceMD),
      decoration: BoxDecoration(
        color: RemediTheme.deepTeal.withOpacity(0.03),
        border: Border(
          top: BorderSide(
            color: RemediTheme.deepTeal.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.library_books,
                size: 16,
                color: RemediTheme.deepTeal,
              ),
              const SizedBox(width: RemediTheme.spaceXS),
              Text(
                'Clinical Citations',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: RemediTheme.deepTeal,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          const SizedBox(height: RemediTheme.spaceSM),
          ...widget.evidenceLedger.primarySources
              .take(3)
              .map((citation) => _buildCitationItem(citation))
              .toList(),
          if (widget.evidenceLedger.sourceCount > 3) ...[
            const SizedBox(height: RemediTheme.spaceXS),
            Text(
              '+${widget.evidenceLedger.sourceCount - 3} more sources',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: RemediTheme.charcoal.withOpacity(0.5),
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                  ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCitationItem(Citation citation) {
    return Padding(
      padding: const EdgeInsets.only(bottom: RemediTheme.spaceSM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            citation.title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
          ),
          const SizedBox(height: 2),
          Text(
            '${citation.authors} • ${citation.source}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: RemediTheme.charcoal.withOpacity(0.6),
                  fontSize: 11,
                ),
          ),
        ],
      ),
    );
  }
}
