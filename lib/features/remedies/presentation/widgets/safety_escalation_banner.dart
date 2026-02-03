import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:remedibook/core/theme/remedi_theme.dart';

enum SafetyRiskLevel { safe, caution, urgent }

class SafetyEscalationBanner extends StatelessWidget {
  final SafetyRiskLevel level;
  final String title;
  final String description;
  final VoidCallback? onEscalate;

  const SafetyEscalationBanner({
    super.key,
    required this.level,
    required this.title,
    required this.description,
    this.onEscalate,
  });

  @override
  Widget build(BuildContext context) {
    if (level == SafetyRiskLevel.safe) return const SizedBox.shrink();

    final isUrgent = level == SafetyRiskLevel.urgent;
    
    // Urgent: Garnet Background, White Text
    // Caution: Amber/Orange Background (light), Dark Text to fit "Quiet Luxury"
    
    final bgColor = isUrgent 
        ? RemediTheme.safetyCritical 
        : const Color(0xFFFFF4E0); // Soft Amber
        
    final borderColor = isUrgent
        ? Colors.transparent
        : const Color(0xFFD4A373).withOpacity(0.5); // Ember Gold border
        
    final iconColor = isUrgent ? Colors.white : const Color(0xFFD4A373);
    final titleColor = isUrgent ? Colors.white : RemediTheme.deepTeal;
    final bodyColor = isUrgent ? Colors.white.withOpacity(0.9) : RemediTheme.charcoal;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: isUrgent 
                ? RemediTheme.safetyCritical.withOpacity(0.3) 
                : Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isUrgent ? Icons.warning_rounded : Icons.info_outline_rounded,
                color: iconColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title.toUpperCase(),
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                    color: titleColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              height: 1.5,
              color: bodyColor,
            ),
          ),
          
          if (isUrgent && onEscalate != null) ...[
            const SizedBox(height: 12),
            GestureDetector(
              onTap: onEscalate,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Find Professional Care",
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 14),
                  ],
                ),
              ),
            )
          ]
        ],
      ),
    );
  }
}
