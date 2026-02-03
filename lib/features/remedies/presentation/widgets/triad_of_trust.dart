import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:remedibook/core/theme/remedi_theme.dart';
import 'package:remedibook/core/widgets/sanctuary_glass_card.dart';

class TriadOfTrust extends StatefulWidget {
  final String traditionalRoot;
  final String scienceEvidence;
  final String safetyContraindications;
  final bool enableMotion;

  const TriadOfTrust({
    super.key,
    required this.traditionalRoot,
    required this.scienceEvidence,
    required this.safetyContraindications,
    this.enableMotion = true,
  });

  @override
  State<TriadOfTrust> createState() => _TriadOfTrustState();
}

class _TriadOfTrustState extends State<TriadOfTrust> {
  // Track expansion state of each layer. 0=Collapsed, 1=Expanded
  // Default: Traditional Open, others closed? Or all closed?
  // Let's have Traditional open by default for the "Unfolding" feel.
  final List<bool> _isExpanded = [true, false, false];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSectionHeader("Triad of Trust"),
        const SizedBox(height: 12),
        _buildLayer(0, "Traditional Root", Icons.spa_outlined, widget.traditionalRoot),
        const SizedBox(height: 8),
        _buildLayer(1, "Modern Science", Icons.science_outlined, widget.scienceEvidence),
        const SizedBox(height: 8),
        _buildLayer(2, "Safety Screen", Icons.shield_outlined, widget.safetyContraindications, isSafety: true),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.5,
          color: RemediTheme.charcoal.withOpacity(0.5),
        ),
      ),
    );
  }

  Widget _buildLayer(int index, String title, IconData icon, String content, {bool isSafety = false}) {
    final isExpanded = _isExpanded[index];
    final duration = widget.enableMotion ? const Duration(milliseconds: 400) : Duration.zero;
    final curve = Curves.easeInOutCubicEmphasized;

    // Colors
    final baseColor = isSafety 
        ? (isExpanded ? RemediTheme.garnet : RemediTheme.charcoal)
        : (isExpanded ? RemediTheme.deepTeal : RemediTheme.charcoal);
        
    final iconColor = isSafety 
         ? const Color(0xFFD4A373) // Ember Gold for safety icon
         : const Color(0xFFD4A373);

    return GestureDetector(
      onTap: () {
        setState(() {
          // Toggle this one
          _isExpanded[index] = !_isExpanded[index];
          // Optional: Auto-collapse others? User asked for "Unfolding", maybe keep them independent.
          // Let's keep them independent for now.
        });
      },
      child: AnimatedContainer(
        duration: duration,
        curve: curve,
        decoration: BoxDecoration(
          color: isExpanded ? Colors.white.withOpacity(0.4) : Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
             color: isExpanded 
                ? (isSafety ? RemediTheme.garnet.withOpacity(0.3) : RemediTheme.deepTeal.withOpacity(0.3))
                : Colors.white.withOpacity(0.2),
             width: 1,
          ),
          boxShadow: isExpanded 
              ? [
                  BoxShadow(
                    color: (isSafety ? RemediTheme.garnet : RemediTheme.deepTeal).withOpacity(0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ]
              : [],
        ),
        child: Column(
          children: [
            // Header Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Icon(icon, size: 20, color: iconColor),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: isExpanded ? FontWeight.w700 : FontWeight.w500,
                        color: baseColor,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                  // Verified Ornament (only if expanded)
                 if (isExpanded)
                    Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: const BoxDecoration(
                        color: Color(0xFFD4A373), // Ember Gold
                        shape: BoxShape.circle,
                      ),
                    ),
                  
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0.0,
                    duration: duration,
                    curve: curve,
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: baseColor.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
            
            // Content Body (Collapsible)
            AnimatedSize(
              duration: duration,
              curve: curve,
              alignment: Alignment.topCenter,
              child: SizedBox(
                width: double.infinity,
                child: isExpanded
                    ? Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Divider(height: 1, color: baseColor.withOpacity(0.1)),
                            const SizedBox(height: 12),
                            Text(
                              content,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                height: 1.6,
                                color: RemediTheme.charcoal.withOpacity(0.8),
                              ),
                            ),
                            if (!isSafety) ...[
                               const SizedBox(height: 12),
                               Row(
                                 mainAxisAlignment: MainAxisAlignment.end,
                                 children: [
                                   Text(
                                     "VERIFIED SOURCE",
                                      style: GoogleFonts.inter(
                                        fontSize: 9, 
                                        fontWeight: FontWeight.bold, 
                                        color: RemediTheme.deepTeal.withOpacity(0.6)
                                      ),
                                   ),
                                   const SizedBox(width: 4),
                                   const Icon(Icons.verified, size: 10, color: RemediTheme.deepTeal),
                                 ],
                               )
                            ],
                          ],
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
