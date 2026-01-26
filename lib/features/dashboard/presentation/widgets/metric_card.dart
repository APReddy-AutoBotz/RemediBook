import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:remedibook/core/theme/remedi_theme.dart';

class MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const MetricCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(RemediTheme.radiusStone),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.35),
            borderRadius: BorderRadius.circular(RemediTheme.radiusStone),
            border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
            // Suble stone texture pattern would be an image, here using gradient for feel
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                RemediTheme.warmLimestone.withOpacity(0.1),
                Colors.white.withOpacity(0.2),
              ],
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: RemediTheme.deepTeal, size: 28),
              const SizedBox(height: 20),
              Text(
                value,
                style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 28),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  color: RemediTheme.darkForest.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
