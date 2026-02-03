import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/remedi_theme.dart';

/// RemediButton - Premium button component
/// Implements the Quiet Luxury design with proper spacing and typography
class RemediButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isPrimary;
  final bool isFullWidth;
  final IconData? icon;
  final bool isLoading;

  const RemediButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isPrimary = true,
    this.isFullWidth = false,
    this.icon,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final buttonChild = Row(
      mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading)
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          )
        else if (icon != null) ...[
          Icon(icon, size: 18),
          const SizedBox(width: RemediTheme.spaceSM),
        ],
        Text(label),
      ],
    );

    if (isPrimary) {
      return SizedBox(
        width: isFullWidth ? double.infinity : null,
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          child: buttonChild,
        ),
      );
    } else {
      return SizedBox(
        width: isFullWidth ? double.infinity : null,
        child: OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: RemediTheme.deepTeal,
            side: BorderSide(color: RemediTheme.deepTeal.withOpacity(0.3), width: 1.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(RemediTheme.radiusButton),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          ),
          child: buttonChild,
        ),
      );
    }
  }
}

/// RemediCard - Premium card component with Stone decoration
class RemediCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final bool useGlass;
  final Widget? safetyTag;

  const RemediCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.useGlass = false,
    this.safetyTag,
  });

  @override
  Widget build(BuildContext context) {
    final cardContent = Container(
      padding: padding ?? const EdgeInsets.all(RemediTheme.spaceMD),
      decoration: useGlass
          ? RemediDecorations.glass()
          : RemediDecorations.stoneBordered(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (safetyTag != null) ...[
            safetyTag!,
            const SizedBox(height: RemediTheme.spaceSM),
          ],
          child,
        ],
      ),
    );

    if (onTap != null) {
      return Container(
        margin: margin,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(
            useGlass ? RemediTheme.radiusGlass : RemediTheme.radiusStone,
          ),
          child: cardContent,
        ),
      );
    }

    return Container(
      margin: margin,
      child: cardContent,
    );
  }
}

/// SafetyTag - Profile-aware safety indicator
class SafetyTag extends StatelessWidget {
  final String message;

  const SafetyTag({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2), // Light red background
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFFCA5A5).withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.warning_amber_rounded, color: Color(0xFFDC2626), size: 14),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              message,
              style: GoogleFonts.inter(
                color: const Color(0xFF991B1B),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// RemediChip - Dynamic refiner chip component
class RemediChip extends StatelessWidget {
  final String label;
  final VoidCallback? onRemove;
  final bool isNew;

  const RemediChip({
    super.key,
    required this.label,
    this.onRemove,
    this.isNew = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: isNew
            ? RemediTheme.mutedSage.withOpacity(0.2)
            : RemediTheme.warmLimestone,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: RemediTheme.mutedSage.withOpacity(0.5),
          width: 1.0,
        ),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: RemediTheme.spaceSM + (onRemove != null ? 4 : 8),
        vertical: RemediTheme.spaceXS + 2,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: RemediTheme.deepTeal,
                  fontWeight: FontWeight.w500,
                ),
          ),
          if (onRemove != null) ...[
            const SizedBox(width: RemediTheme.spaceXS),
            GestureDetector(
              onTap: onRemove,
              child: const Icon(
                Icons.close,
                size: 14,
                color: RemediTheme.charcoal,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// RemediEvidenceLabel - Evidence badge for remedies
class RemediEvidenceLabel extends StatelessWidget {
  final String label;
  final bool isEvidenceSupported;

  const RemediEvidenceLabel({
    super.key,
    required this.label,
    this.isEvidenceSupported = false,
  });

  @override
  Widget build(BuildContext context) {
    final isWebSourced = label.contains('Web Sourced');
    
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: RemediTheme.spaceSM,
        vertical: RemediTheme.spaceXS,
      ),
      decoration: BoxDecoration(
        color: isEvidenceSupported
            ? RemediTheme.deepTeal.withOpacity(0.05)
            : (isWebSourced ? Colors.blue.withOpacity(0.05) : RemediTheme.mutedSage.withOpacity(0.05)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isEvidenceSupported ? Icons.verified : (isWebSourced ? Icons.public : Icons.history_edu),
            size: 11,
            color: isEvidenceSupported 
                ? RemediTheme.deepTeal 
                : (isWebSourced ? Colors.blue : RemediTheme.mutedSage),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: (isEvidenceSupported 
                      ? RemediTheme.deepTeal 
                      : (isWebSourced ? Colors.blue : RemediTheme.mutedSage)).withOpacity(0.7),
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
          ),
        ],
      ),
    );
  }
}

/// TrustStripBadges - Premium trust indicators
class TrustStripBadges extends StatelessWidget {
  final String evidenceLevel;

  const TrustStripBadges({
    super.key,
    this.evidenceLevel = "Limited",
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildBadge(context, "Traditional Use", Icons.auto_stories),
        _buildBadge(context, "Evidence: $evidenceLevel", Icons.verified_user_outlined),
        _buildBadge(context, "Safety: Check Profile", Icons.security_outlined),
      ],
    );
  }

  Widget _buildBadge(BuildContext context, String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: RemediTheme.deepTeal.withOpacity(0.1), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: RemediTheme.deepTeal.withOpacity(0.6)),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontSize: 10,
                  color: RemediTheme.deepTeal.withOpacity(0.7),
                  letterSpacing: 0.3,
                ),
          ),
        ],
      ),
    );
  }
}

/// PremiumAlertBanner - Concise, clean alert component
class PremiumAlertBanner extends StatelessWidget {
  final String message;
  final IconData icon;

  const PremiumAlertBanner({
    super.key,
    required this.message,
    this.icon = Icons.warning_amber_rounded,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB), // Very pale amber
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFEF3C7).withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFD97706), size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.inter(
                color: const Color(0xFF92400E),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// NumberedProtocolList - Preparation steps with premium numbering
class NumberedProtocolList extends StatelessWidget {
  final List<String> steps;
  final List<int?>? durations;

  const NumberedProtocolList({
    super.key,
    required this.steps,
    this.durations,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(steps.length, (index) {
        final stepText = steps[index];
        final duration = (durations != null && index < durations!.length) ? durations![index] : null;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 20,
                height: 20,
                margin: const EdgeInsets.only(top: 2, right: 12),
                decoration: BoxDecoration(
                  color: RemediTheme.deepTeal.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    "${index + 1}",
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: RemediTheme.deepTeal,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stepText,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    if (duration != null) ...[
                      const SizedBox(height: 4),
                      _buildDurationPill(duration),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildDurationPill(int seconds) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: RemediTheme.deepTeal.withOpacity(0.05),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        "${seconds ~/ 60}m",
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: RemediTheme.deepTeal.withOpacity(0.6),
        ),
      ),
    );
  }
}
