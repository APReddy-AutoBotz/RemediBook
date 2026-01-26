import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/theme/remedi_theme.dart';
import '../../../../core/services/governance_guard.dart';

/// Safety Twin Preview - Pillar 4 UI Component
/// Displays profile match and caution areas before remedy generation
class SafetyTwinPreview extends StatelessWidget {
  final UserProfile userProfile;
  final Remedy remedy;
  final double profileMatchPercentage;
  final List<CautionArea> cautionAreas;
  final VoidCallback? onAdjustProtocol;
  final VoidCallback? onProceedWithCaution;

  const SafetyTwinPreview({
    super.key,
    required this.userProfile,
    required this.remedy,
    required this.profileMatchPercentage,
    required this.cautionAreas,
    this.onAdjustProtocol,
    this.onProceedWithCaution,
  });

  @override
  Widget build(BuildContext context) {
    final governanceResult = GovernanceGuard.canProceed(userProfile, remedy);
    final hasWarnings = cautionAreas.isNotEmpty || governanceResult.isBlocked;

    return Container(
      margin: const EdgeInsets.all(RemediTheme.spaceMD),
      decoration: RemediDecorations.stoneBordered(
        borderRadius: RemediTheme.radiusStone,
        shadowOpacity: 0.06,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(RemediTheme.radiusStone),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(RemediTheme.spaceMD),
              decoration: BoxDecoration(
                color: governanceResult.canProceed
                    ? RemediTheme.deepTeal.withOpacity(0.05)
                    : const Color(0xFFDC2626).withOpacity(0.05),
              ),
              child: Row(
                children: [
                  Icon(
                    governanceResult.canProceed
                        ? Icons.verified_user
                        : Icons.block,
                    color: governanceResult.canProceed
                        ? RemediTheme.deepTeal
                        : const Color(0xFFDC2626),
                    size: 24,
                  ),
                  const SizedBox(width: RemediTheme.spaceSM),
                  Expanded(
                    child: Text(
                      governanceResult.canProceed
                          ? 'SAFETY TWIN PREVIEW'
                          : 'SAFETY RESTRICTION',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: governanceResult.canProceed
                                ? RemediTheme.deepTeal
                                : const Color(0xFFDC2626),
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.0,
                          ),
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(RemediTheme.spaceMD),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Governance Block (if applicable)
                  if (governanceResult.isBlocked) ...[
                    _buildGovernanceBlock(context, governanceResult),
                  ] else ...[
                    // Profile Match
                    _buildProfileMatch(context),

                    // Caution Areas (if any)
                    if (cautionAreas.isNotEmpty) ...[
                      const SizedBox(height: RemediTheme.spaceMD),
                      _buildCautionAreas(context),
                    ],

                    // Actions
                    const SizedBox(height: RemediTheme.spaceMD),
                    _buildActions(context, hasWarnings),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGovernanceBlock(
      BuildContext context, GovernanceResult result) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Refusal Reason
        Container(
          padding: const EdgeInsets.all(RemediTheme.spaceSM),
          decoration: BoxDecoration(
            color: const Color(0xFFDC2626).withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.block,
                color: Color(0xFFDC2626),
                size: 20,
              ),
              const SizedBox(width: RemediTheme.spaceXS),
              Expanded(
                child: Text(
                  result.refusalReason ?? 'Access Restricted',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: const Color(0xFFDC2626),
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: RemediTheme.spaceSM),

        // Professional Guidance
        Text(
          result.professionalGuidance ?? GovernanceGuard.generalConsultation,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                height: 1.5,
              ),
        ),

        const SizedBox(height: RemediTheme.spaceMD),

        // Contact Healthcare Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              // In real app, would provide healthcare provider contact options
            },
            icon: const Icon(Icons.local_hospital, size: 18),
            label: const Text('Find Healthcare Provider'),
            style: ElevatedButton.styleFrom(
              backgroundColor: RemediTheme.deepTeal,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileMatch(BuildContext context) {
    return Row(
      children: [
        // Match Percentage Circle
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: _getMatchColor(profileMatchPercentage),
              width: 4,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${profileMatchPercentage.toInt()}%',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: _getMatchColor(profileMatchPercentage),
                        fontWeight: FontWeight.w700,
                      ),
                ),
                Text(
                  'Match',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: RemediTheme.charcoal.withOpacity(0.6),
                        fontSize: 10,
                      ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(width: RemediTheme.spaceMD),

        // Match Description
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Profile Compatibility',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                _getMatchDescription(profileMatchPercentage),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: RemediTheme.charcoal.withOpacity(0.7),
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCautionAreas(BuildContext context) {
    return RemediDecorations.glassContainer(
      blur: 15.0,
      opacity: 0.1,
      borderRadius: RemediTheme.radiusGlass,
      padding: const EdgeInsets.all(RemediTheme.spaceMD),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: Color(0xFFF59E0B),
                size: 20,
              ),
              const SizedBox(width: RemediTheme.spaceXS),
              Text(
                'Caution Areas Identified',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: const Color(0xFFF59E0B),
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          const SizedBox(height: RemediTheme.spaceSM),
          ...cautionAreas.map((area) => _buildCautionItem(context, area)),
        ],
      ),
    );
  }

  Widget _buildCautionItem(BuildContext context, CautionArea area) {
    return Padding(
      padding: const EdgeInsets.only(bottom: RemediTheme.spaceSM),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(top: 6),
            decoration: const BoxDecoration(
              color: Color(0xFFF59E0B),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: RemediTheme.spaceSM),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: Theme.of(context).textTheme.bodySmall,
                children: [
                  TextSpan(
                    text: '${area.ingredient}: ',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: area.warning),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context, bool hasWarnings) {
    return Row(
      children: [
        if (hasWarnings && onAdjustProtocol != null) ...[
          Expanded(
            child: OutlinedButton(
              onPressed: onAdjustProtocol,
              style: OutlinedButton.styleFrom(
                foregroundColor: RemediTheme.deepTeal,
                side: const BorderSide(color: RemediTheme.deepTeal),
              ),
              child: const Text('Adjust Protocol'),
            ),
          ),
          const SizedBox(width: RemediTheme.spaceSM),
        ],
        Expanded(
          child: ElevatedButton(
            onPressed: onProceedWithCaution,
            child: Text(hasWarnings ? 'Proceed with Caution' : 'Continue'),
          ),
        ),
      ],
    );
  }

  Color _getMatchColor(double percentage) {
    if (percentage >= 90) return RemediTheme.deepTeal;
    if (percentage >= 70) return RemediTheme.mutedSage;
    return const Color(0xFFF59E0B);
  }

  String _getMatchDescription(double percentage) {
    if (percentage >= 90) return 'Excellent compatibility with your profile';
    if (percentage >= 70) return 'Good compatibility with minor considerations';
    return 'Moderate compatibility - review cautions carefully';
  }
}

/// Caution Area Model
class CautionArea {
  final String ingredient;
  final String warning;
  final String? userProfileContext;

  const CautionArea({
    required this.ingredient,
    required this.warning,
    this.userProfileContext,
  });
}
