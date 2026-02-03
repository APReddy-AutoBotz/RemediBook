import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:printing/printing.dart';
import 'package:remedibook/core/theme/remedi_theme.dart';
import 'package:remedibook/core/widgets/sanctuary_background.dart';
import 'package:remedibook/core/widgets/sanctuary_glass_card.dart';
import 'package:remedibook/features/artifact/domain/services/wellness_guide_pdf_service.dart';
import 'package:remedibook/features/artifact/presentation/widgets/digital_wax_seal.dart';
import 'package:remedibook/core/motion/motion_prefs.dart';
import 'dart:typed_data';

import 'package:remedibook/features/discovery/domain/models/remedy.dart';
import 'package:remedibook/features/discovery/domain/models/evidence_ledger.dart';

class ArtifactExperienceScreen extends StatefulWidget {
  final String remedyId;
  final String title;
  final Remedy remedy;

  const ArtifactExperienceScreen({
    super.key,
    required this.remedyId,
    required this.title,
    required this.remedy,
  });

  @override
  State<ArtifactExperienceScreen> createState() => _ArtifactExperienceScreenState();
}

class _ArtifactExperienceScreenState extends State<ArtifactExperienceScreen> {
  Uint8List? _pdfBytes;
  String _loadingText = "Preparing parchment...";
  bool _showPdf = false;
  bool _showSeal = false;

  @override
  void initState() {
    super.initState();
    _startCeremony();
  }

  Future<void> _startCeremony() async {
    // 1. "Preparing parchment..." (Initial State)
    await Future.delayed(const Duration(milliseconds: 600));

    // 2. "Inscribing wisdom..."
    if (mounted) setState(() => _loadingText = "Inscribing wisdom...");
    
    // Determine verification label
    String verificationLabel = "AI Generated";
    if (widget.remedy.evidenceLedger != null) {
      verificationLabel = widget.remedy.evidenceLedger!.label == EvidenceLabel.evidenceSupported
          ? "Physician Verified"
          : "Traditional Wisdom";
    }

    // Generate PDF with real data
    final pdfData = await WellnessGuidePdfService.generateArtifact(
      title: widget.remedy.name,
      description: widget.remedy.description,
      ingredients: widget.remedy.ingredients,
      steps: widget.remedy.instructions,
      safetyNotes: "Consult a healthcare provider before use. ${_getSafetyNote()}",
      verificationLabel: verificationLabel,
    );
    
    // Artificial delay for "Inscribing" feel if generation was too fast
    await Future.delayed(const Duration(milliseconds: 600));
    
    // Artificial delay for "Inscribing" feel if generation was too fast
    await Future.delayed(const Duration(milliseconds: 600));

    if (mounted) {
      setState(() {
        _pdfBytes = pdfData;
        _showPdf = true;
      });
      
      // 3. Trigger Seal (Slight delay after PDF appears)
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) setState(() => _showSeal = true);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: RemediTheme.deepTeal),
      ),
      body: Stack(
        children: [
          // Background
          const SanctuaryBackground(child: SizedBox.expand()),
          
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                   Text(
                    "Wellness Artifact",
                    style: GoogleFonts.crimsonPro(
                      fontSize: 32,
                      color: RemediTheme.deepTeal,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Preserving wisdom for ${widget.title}",
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: RemediTheme.charcoal.withOpacity(0.6),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  
                  // Preview Area
                  Expanded(
                    child: Stack(
                      children: [
                        // Glass Frame
                        SanctuaryGlassCard(
                          padding: const EdgeInsets.all(16),
                          child: AnimatedOpacity(
                            duration: const Duration(milliseconds: 600),
                            opacity: _showPdf ? 1.0 : 0.0,
                            child: _pdfBytes != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: PdfPreview(
                                    build: (format) => _pdfBytes!,
                                    useActions: false,
                                    scrollViewDecoration: const BoxDecoration(color: Colors.transparent),
                                    pdfPreviewPageDecoration: const BoxDecoration(
                                      color: Colors.white,
                                      boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black12)],
                                    ),
                                  ),
                                )
                              : const SizedBox.shrink(),
                          ),
                        ),

                        // Loading State Overlay
                        if (!_showPdf)
                          Positioned.fill(
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const CircularProgressIndicator(color: RemediTheme.emberGold),
                                  const SizedBox(height: 16),
                                  AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 300),
                                    child: Text(
                                      _loadingText,
                                      key: ValueKey(_loadingText),
                                      style: GoogleFonts.inter(color: RemediTheme.deepTeal),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                        // The Wax Seal (Bottom Right)
                        if (_showSeal)
                          Positioned(
                            bottom: 30,
                            right: 30,
                            child: DigitalWaxSeal(
                              animate: true,
                            ),
                          ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Action Bar (Only when ready)
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 400),
                    opacity: _showPdf ? 1.0 : 0.0,
                    child: SanctuaryGlassCard(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                           _buildActionButton(Icons.download_rounded, "Save", () async {
                             if (_pdfBytes != null) {
                               await Printing.sharePdf(bytes: _pdfBytes!, filename: '${widget.title}_Guide.pdf');
                             }
                           }),
                           Container(width: 1, height: 24, color: RemediTheme.deepTeal.withOpacity(0.2)),
                           _buildActionButton(Icons.share_outlined, "Share", () async {
                             if (_pdfBytes != null) {
                               await Printing.sharePdf(bytes: _pdfBytes!, filename: '${widget.title}_Guide.pdf');
                             }
                           }),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: RemediTheme.deepTeal, size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: RemediTheme.deepTeal),
          ),
        ],
      ),
    );
  }

  String _getSafetyNote() {
    if (widget.remedy.category.toLowerCase().contains('diabetes')) {
      return "Monitor blood sugar levels.";
    }
    return "Discontinue if adverse reactions occur.";
  }
}
