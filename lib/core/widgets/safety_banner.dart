import 'package:flutter/material.dart';
import '../theme/remedi_theme.dart';

enum SafetyBannerType { info, amber, critical }

/// SafetyBanner - Context-aware Warning/Info Display
/// Colors: Info (Sage), Amber (Ember Gold), Critical (Safety Red)
class SafetyBanner extends StatelessWidget {
  final SafetyBannerType type;
  final String message;
  final IconData? icon;

  const SafetyBanner({
    super.key,
    required this.type,
    required this.message,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final config = _getConfig();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: config.backgroundColor,
        borderRadius: BorderRadius.circular(RemediTheme.radiusButton),
        border: Border.all(
          color: config.borderColor,
          width: 1.2,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon ?? config.defaultIcon,
            size: 20,
            color: config.iconColor,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: config.textColor,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  _BannerConfig _getConfig() {
    switch (type) {
      case SafetyBannerType.info:
        return _BannerConfig(
          backgroundColor: RemediTheme.mutedSage.withOpacity(0.10),
          borderColor: RemediTheme.mutedSage.withOpacity(0.3),
          iconColor: RemediTheme.mutedSage,
          textColor: RemediTheme.darkForest,
          defaultIcon: Icons.info_outline_rounded,
        );
        
      case SafetyBannerType.amber:
        return _BannerConfig(
          backgroundColor: RemediTheme.emberGold.withOpacity(0.10),
          borderColor: RemediTheme.emberGold.withOpacity(0.35),
          iconColor: RemediTheme.emberGold,
          textColor: RemediTheme.darkForest,
          defaultIcon: Icons.warning_amber_rounded,
        );
        
      case SafetyBannerType.critical:
        return _BannerConfig(
          backgroundColor: RemediTheme.safetyCritical.withOpacity(0.12),
          borderColor: RemediTheme.safetyCritical.withOpacity(0.4),
          iconColor: RemediTheme.safetyCritical,
          textColor: RemediTheme.darkForest,
          defaultIcon: Icons.error_outline_rounded,
        );
    }
  }
}

class _BannerConfig {
  final Color backgroundColor;
  final Color borderColor;
  final Color iconColor;
  final Color textColor;
  final IconData defaultIcon;

  _BannerConfig({
    required this.backgroundColor,
    required this.borderColor,
    required this.iconColor,
    required this.textColor,
    required this.defaultIcon,
  });
}
