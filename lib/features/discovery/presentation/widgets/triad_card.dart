import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:remedibook/core/theme/remedi_theme.dart';

class TriadCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String content;
  final IconData icon;
  final String? imagePath;
  final VoidCallback? onAction;
  final Widget? safetyTag;

  const TriadCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.content,
    required this.icon,
    this.imagePath,
    this.onAction,
    this.safetyTag,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.7),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: Colors.white.withOpacity(0.8), width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (imagePath != null)
                  Expanded(
                    flex: 4,
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(imagePath!),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  )
                else
                  Expanded(
                    flex: 4,
                    child: Container(
                      width: double.infinity,
                      color: RemediTheme.mutedSage.withOpacity(0.1),
                      child: Icon(icon, size: 64, color: RemediTheme.deepTeal.withOpacity(0.4)),
                    ),
                  ),
                Expanded(
                  flex: 5,
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (safetyTag != null) ...[
                            safetyTag!,
                            const SizedBox(height: 12),
                          ],
                          Text(
                            subtitle.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2,
                              color: RemediTheme.deepTeal,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            title,
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            content,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: RemediTheme.charcoal.withOpacity(0.7),
                                  height: 1.4,
                                ),
                            maxLines: 8,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: onAction,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: RemediTheme.deepTeal.withOpacity(onAction == null ? 0.05 : 0.1),
                                foregroundColor: RemediTheme.deepTeal.withOpacity(onAction == null ? 0.3 : 1.0),
                                elevation: 0,
                              ),
                              child: const Text('Explore Deeply'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
