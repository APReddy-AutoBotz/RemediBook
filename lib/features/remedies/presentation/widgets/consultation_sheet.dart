import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:remedibook/core/theme/remedi_theme.dart';
import 'package:remedibook/core/services/deep_link_builder.dart';
import 'package:url_launcher/url_launcher.dart';

class ConsultationSheet extends StatelessWidget {
  final String ailmentName;

  const ConsultationSheet({
    super.key,
    required this.ailmentName,
  });

  void _handleConsultation(BuildContext context, String discipline) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: RemediTheme.charcoal.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: RemediTheme.emberGold.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.star_rounded, color: RemediTheme.emberGold, size: 32),
              ),
              const SizedBox(height: 20),
              
              Text(
                "Care Network Expanding",
                textAlign: TextAlign.center,
                style: GoogleFonts.lora(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: RemediTheme.darkForest,
                ),
              ),
              const SizedBox(height: 12),
              
              Text(
                "We are currently verifying the best $discipline clinics in your vicinity.\n\nDirect appointment booking will be available in the next update.",
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  height: 1.5,
                  color: RemediTheme.charcoal.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 24),
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: RemediTheme.deepTeal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: Text(
                    "Notify Me When Ready",
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85), // Increased height
      decoration: BoxDecoration(
        color: RemediTheme.warmLimestone.withOpacity(0.98),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
      child: SingleChildScrollView( // Added Scroll
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: RemediTheme.charcoal.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            Text(
              "PROFESSIONAL CARE",
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
                color: RemediTheme.charcoal.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Consult a Specialist",
              style: GoogleFonts.lora(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: RemediTheme.darkForest,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Find verified doctors for '$ailmentName' near you.",
              style: GoogleFonts.inter(
                fontSize: 14,
                color: RemediTheme.charcoal.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 32),
            
            // Options
            _buildOptionCard(
              context,
              "Allopathy",
              "Modern Science",
               Icons.medical_services_outlined,
              const Color(0xFF1E88E5), // Blue
              () => _handleConsultation(context, 'Allopathy'),
            ),
            const SizedBox(height: 16),
            _buildOptionCard(
              context,
              "Ayurveda",
              "Holistic Tradition",
              Icons.spa_outlined,
              const Color(0xFF43A047), // Green
              () => _handleConsultation(context, 'Ayurveda'),
            ),
            const SizedBox(height: 16),
            _buildOptionCard(
              context,
              "Homeopathy",
              "Gentle Healing",
              Icons.water_drop_outlined,
              const Color(0xFF00ACC1), // Cyan
              () => _handleConsultation(context, 'Homeopathy'),
            ),
            
            const SizedBox(height: 32), // Spacer inside scroll
            
            Center(
               child: Text(
                "Powered by Practo Verified Doctors",
                style: GoogleFonts.inter(
                  fontSize: 10,
                  color: RemediTheme.charcoal.withOpacity(0.4),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildOptionCard(
    BuildContext context, 
    String title, 
    String subtitle, 
    IconData icon, 
    Color color, 
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: RemediTheme.charcoal.withOpacity(0.05)),
          boxShadow: [
             BoxShadow(
              color: RemediTheme.charcoal.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: RemediTheme.charcoal,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: RemediTheme.charcoal.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 14, color: RemediTheme.charcoal.withOpacity(0.3)),
          ],
        ),
      ),
    );
  }
}
