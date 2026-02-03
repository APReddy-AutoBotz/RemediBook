import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../../../discovery/domain/models/evidence_ledger.dart';

/// PDF Generator Service - Clinical-Grade Wellness Guides
/// Implements Pillar 3: Artifact Experience with Quiet Luxury editorial style
class PDFGeneratorService {
  // ═══════════════════════════════════════════════════════════════════════
  // GUIDE ID GENERATION
  // ═══════════════════════════════════════════════════════════════════════

  /// Generate unique Guide ID in RB-YYYY-XXXX format
  static String generateGuideId() {
    final now = DateTime.now();
    final year = now.year;
    final sequence = now.millisecondsSinceEpoch % 10000;
    return 'RB-PREMIER-$year-${sequence.toString().padLeft(4, '0')}';
  }

  // ═══════════════════════════════════════════════════════════════════════
  // PDF GENERATION
  // ═══════════════════════════════════════════════════════════════════════

  /// Generate wellness guide PDF
  Future<File> generateWellnessGuide({
    required String title,
    required String remedyDescription,
    required List<String> ingredients,
    required List<String> instructions,
    required EvidenceLedger evidenceLedger,
    required List<String> contraindications,
    String? userProfileSummary,
  }) async {
    final pdf = pw.Document();
    final guideId = generateGuideId();

    // Load fonts for Quiet Luxury typography
    final loraFont = await PdfGoogleFonts.loraRegular();
    final loraBold = await PdfGoogleFonts.loraBold();
    final interFont = await PdfGoogleFonts.interRegular();
    final interBold = await PdfGoogleFonts.interSemiBold();

    // Page 1: Cover
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(48), // Generous margins
        build: (context) => _buildCoverPage(
          guideId: guideId,
          title: title,
          userProfileSummary: userProfileSummary,
          loraFont: loraBold,
          interFont: interFont,
        ),
      ),
    );

    // Page 2: Safety Panel & Remedy Details
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(48),
        build: (context) => _buildRemedyPage(
          title: title,
          description: remedyDescription,
          ingredients: ingredients,
          instructions: instructions,
          contraindications: contraindications,
          evidenceLedger: evidenceLedger,
          loraFont: loraBold,
          interFont: interFont,
        ),
      ),
    );

    // Page 3: Evidence Ledger
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(48),
        build: (context) => _buildEvidencePage(
          evidenceLedger: evidenceLedger,
          guideId: guideId,
          loraFont: loraBold,
          interFont: interFont,
        ),
      ),
    );

    // Save PDF
    final output = await getApplicationDocumentsDirectory();
    final file = File('${output.path}/wellness_guide_$guideId.pdf');
    await file.writeAsBytes(await pdf.save());

    return file;
  }

  // ═══════════════════════════════════════════════════════════════════════
  // PAGE BUILDERS
  // ═══════════════════════════════════════════════════════════════════════

  pw.Widget _buildCoverPage({
    required String guideId,
    required String title,
    String? userProfileSummary,
    required pw.Font loraFont,
    required pw.Font interFont,
  }) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Guide ID
        pw.Text(
          guideId,
          style: pw.TextStyle(
            font: interFont,
            fontSize: 12,
            color: PdfColor.fromHex('#1F4E5F'),
            letterSpacing: 1.5,
          ),
        ),
        pw.SizedBox(height: 48),

        // Title (Lora Serif)
        pw.Text(
          title,
          style: pw.TextStyle(
            font: loraFont,
            fontSize: 32,
            color: PdfColor.fromHex('#1A3A3A'),
            letterSpacing: -0.5,
          ),
        ),
        pw.SizedBox(height: 16),

        // Subtitle
        pw.Text(
          'Wellness Guide',
          style: pw.TextStyle(
            font: interFont,
            fontSize: 14,
            color: PdfColor.fromHex('#8FA998'),
          ),
        ),

        pw.Spacer(),

        // User Profile Summary (if provided)
        if (userProfileSummary != null) ...[
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              color: PdfColor.fromHex('#F2F0E6'),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(12)),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Personalized For:',
                  style: pw.TextStyle(
                    font: interFont,
                    fontSize: 10,
                    color: PdfColor.fromHex('#2C2C2C'),
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  userProfileSummary,
                  style: pw.TextStyle(
                    font: interFont,
                    fontSize: 12,
                    color: PdfColor.fromHex('#1A3A3A'),
                  ),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 24),
        ],

        // Generation Date
        pw.Text(
          'Generated: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
          style: pw.TextStyle(
            font: interFont,
            fontSize: 10,
            color: PdfColor.fromHex('#2C2C2C'),
          ),
        ),

        // Digital Wax Seal Watermark
        pw.SizedBox(height: 48),
        pw.Align(
          alignment: pw.Alignment.centerRight,
          child: _buildWaxSeal(interFont),
        ),
      ],
    );
  }

  pw.Widget _buildRemedyPage({
    required String title,
    required String description,
    required List<String> ingredients,
    required List<String> instructions,
    required List<String> contraindications,
    required EvidenceLedger evidenceLedger,
    required pw.Font loraFont,
    required pw.Font interFont,
  }) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Evidence Label Badge
        _buildEvidenceBadge(evidenceLedger.label, interFont),
        pw.SizedBox(height: 24),

        // Description
        pw.Text(
          description,
          style: pw.TextStyle(
            font: interFont,
            fontSize: 14,
            color: PdfColor.fromHex('#2C2C2C'),
            height: 1.5,
          ),
        ),
        pw.SizedBox(height: 24),

        // Ingredients
        pw.Text(
          'Ingredients',
          style: pw.TextStyle(
            font: loraFont,
            fontSize: 18,
            color: PdfColor.fromHex('#1A3A3A'),
          ),
        ),
        pw.SizedBox(height: 12),
        ...ingredients.map((ing) => pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 6),
              child: pw.Row(
                children: [
                  pw.Container(
                    width: 4,
                    height: 4,
                    decoration: pw.BoxDecoration(
                      color: PdfColor.fromHex('#1F4E5F'),
                      shape: pw.BoxShape.circle,
                    ),
                  ),
                  pw.SizedBox(width: 8),
                  pw.Text(
                    ing,
                    style: pw.TextStyle(font: interFont, fontSize: 12),
                  ),
                ],
              ),
            )),
        pw.SizedBox(height: 24),

        // Instructions
        pw.Text(
          'Instructions',
          style: pw.TextStyle(
            font: loraFont,
            fontSize: 18,
            color: PdfColor.fromHex('#1A3A3A'),
          ),
        ),
        pw.SizedBox(height: 12),
        ...instructions.asMap().entries.map((entry) => pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 8),
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    '${entry.key + 1}.',
                    style: pw.TextStyle(
                      font: interFont,
                      fontSize: 12,
                      color: PdfColor.fromHex('#1F4E5F'),
                    ),
                  ),
                  pw.SizedBox(width: 8),
                  pw.Expanded(
                    child: pw.Text(
                      entry.value,
                      style: pw.TextStyle(font: interFont, fontSize: 12),
                    ),
                  ),
                ],
              ),
            )),

        pw.Spacer(),

        // Safety Panel with Stop Signs
        if (contraindications.isNotEmpty) _buildSafetyPanel(contraindications, loraFont, interFont),
      ],
    );
  }

  pw.Widget _buildEvidencePage({
    required EvidenceLedger evidenceLedger,
    required String guideId,
    required pw.Font loraFont,
    required pw.Font interFont,
  }) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Evidence Ledger Title
        pw.Text(
          'Evidence Ledger',
          style: pw.TextStyle(
            font: loraFont,
            fontSize: 24,
            color: PdfColor.fromHex('#1A3A3A'),
          ),
        ),
        pw.SizedBox(height: 24),

        // Citations
        ...evidenceLedger.primarySources.map((citation) => pw.Container(
              margin: const pw.EdgeInsets.only(bottom: 16),
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(
                  color: PdfColor.fromHex('#1F4E5F'),
                ),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    citation.title,
                    style: pw.TextStyle(
                      font: interFont,
                      fontSize: 12,
                      color: PdfColor.fromHex('#1A3A3A'),
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    '${citation.authors} • ${citation.source}',
                    style: pw.TextStyle(
                      font: interFont,
                      fontSize: 10,
                      color: PdfColor.fromHex('#2C2C2C'),
                    ),
                  ),
                ],
              ),
            )),

        pw.Spacer(),

        // QR Code & Disclaimer
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Disclaimer',
                    style: pw.TextStyle(
                      font: interFont,
                      fontSize: 10,
                      color: PdfColor.fromHex('#2C2C2C'),
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    'This guide is for informational purposes only. Consult a healthcare professional before starting any new wellness protocol.',
                    style: pw.TextStyle(
                      font: interFont,
                      fontSize: 8,
                      color: PdfColor.fromHex('#2C2C2C'),
                    ),
                  ),
                ],
              ),
            ),
            pw.SizedBox(width: 24),
            // QR Code placeholder (would link to digital ledger)
            pw.Container(
              width: 80,
              height: 80,
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColor.fromHex('#1F4E5F')),
              ),
              child: pw.Center(
                child: pw.Text(
                  'QR\nCode',
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(
                    font: interFont,
                    fontSize: 10,
                    color: PdfColor.fromHex('#1F4E5F'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // COMPONENT BUILDERS
  // ═══════════════════════════════════════════════════════════════════════

  pw.Widget _buildEvidenceBadge(EvidenceLabel label, pw.Font font) {
    final isEvidenceSupported = label == EvidenceLabel.evidenceSupported;
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: pw.BoxDecoration(
        color: isEvidenceSupported
            ? PdfColor.fromHex('#1F4E5F')
            : PdfColor.fromHex('#8FA998'),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
        border: pw.Border.all(
          color: isEvidenceSupported
              ? PdfColor.fromHex('#1F4E5F')
              : PdfColor.fromHex('#8FA998'),
        ),
      ),
      child: pw.Text(
        label.displayName,
        style: pw.TextStyle(
          font: font,
          fontSize: 10,
          color: isEvidenceSupported
              ? PdfColor.fromHex('#1F4E5F')
              : PdfColor.fromHex('#8FA998'),
        ),
      ),
    );
  }

  pw.Widget _buildSafetyPanel(
    List<String> contraindications,
    pw.Font loraFont,
    pw.Font interFont,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromHex('#DC2626'),
        border: pw.Border.all(
          color: PdfColor.fromHex('#DC2626'),
          width: 2,
        ),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(12)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            children: [
              pw.Text(
                '⚠',
                style: const pw.TextStyle(fontSize: 20),
              ),
              pw.SizedBox(width: 8),
              pw.Text(
                'Safety Information',
                style: pw.TextStyle(
                  font: loraFont,
                  fontSize: 14,
                  color: PdfColor.fromHex('#DC2626'),
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 8),
          ...contraindications.map((contra) => pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 4),
                child: pw.Row(
                  children: [
                    pw.Text('• ', style: const pw.TextStyle(fontSize: 12)),
                    pw.Expanded(
                      child: pw.Text(
                        contra,
                        style: pw.TextStyle(font: interFont, fontSize: 10),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  pw.Widget _buildWaxSeal(pw.Font font) {
    return pw.Container(
      width: 90,
      height: 90,
      padding: const pw.EdgeInsets.all(4),
      decoration: pw.BoxDecoration(
        shape: pw.BoxShape.circle,
        border: pw.Border.all(
          color: PdfColor.fromHex('#D4A373'),
          width: 3,
        ),
      ),
      child: pw.Container(
        decoration: pw.BoxDecoration(
          shape: pw.BoxShape.circle,
          border: pw.Border.all(
            color: PdfColor.fromHex('#D4A373'),
            width: 1,
          ),
        ),
        child: pw.Center(
          child: pw.Column(
            mainAxisAlignment: pw.MainAxisAlignment.center,
            children: [
              pw.Text(
                'RB',
                style: pw.TextStyle(
                  font: font,
                  fontSize: 22,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColor.fromHex('#D4A373'),
                ),
              ),
              pw.SizedBox(height: 2),
              pw.Text(
                'PREMIER',
                style: pw.TextStyle(
                  font: font,
                  fontSize: 8,
                  color: PdfColor.fromHex('#D4A373'),
                  letterSpacing: 2.0,
                ),
              ),
              pw.SizedBox(height: 2),
              pw.Container(
                height: 0.5,
                width: 30,
                color: PdfColor.fromHex('#D4A373'),
              ),
              pw.SizedBox(height: 2),
              pw.Text(
                'VERIFIED',
                style: pw.TextStyle(
                  font: font,
                  fontSize: 6,
                  color: PdfColor.fromHex('#D4A373'),
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Generate remedy guide PDF (simplified method)
  Future<Uint8List> generateRemedyGuide({
    required String title,
    required String description,
    required List<String> ingredients,
    required List<String> instructions,
    required List<String> contraindications,
    required List<Citation> evidenceSources,
  }) async {
    final pdf = pw.Document();
    final guideId = generateGuideId();

    // Load fonts
    final loraFont = await PdfGoogleFonts.loraRegular();
    final loraBold = await PdfGoogleFonts.loraBold();
    final interFont = await PdfGoogleFonts.interRegular();

    // Create evidence ledger
    final evidenceLedger = EvidenceLedger(
      remedyId: 'RB-$title',
      label: evidenceSources.length > 2
          ? EvidenceLabel.evidenceSupported
          : EvidenceLabel.traditional,
      reviewDate: DateTime.now(),
      sourceCount: evidenceSources.length,
      primarySources: evidenceSources,
    );

    // Add pages
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(48),
        build: (context) => _buildCoverPage(
          guideId: guideId,
          title: title,
          userProfileSummary: null,
          loraFont: loraBold,
          interFont: interFont,
        ),
      ),
    );

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(48),
        build: (context) => _buildRemedyPage(
          title: title,
          description: description,
          ingredients: ingredients,
          instructions: instructions,
          contraindications: contraindications,
          evidenceLedger: evidenceLedger,
          loraFont: loraBold,
          interFont: interFont,
        ),
      ),
    );

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(48),
        build: (context) => _buildEvidencePage(
          evidenceLedger: evidenceLedger,
          guideId: guideId,
          loraFont: loraBold,
          interFont: interFont,
        ),
      ),
    );

    return pdf.save();
  }
}
