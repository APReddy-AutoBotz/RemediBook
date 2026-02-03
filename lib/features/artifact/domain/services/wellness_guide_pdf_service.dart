import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:remedibook/features/discovery/domain/models/fulfillment_models.dart';

class WellnessGuidePdfService {
  /// Generate a premium "Artifact" PDF for a remedy
  static Future<Uint8List> generateArtifact({
    required String title,
    required String description,
    required List<String> ingredients,
    required List<String> steps,
    required String safetyNotes,
    required String verificationLabel,
  }) async {
    final pdf = pw.Document();

    // Use standard fonts for now to ensure offline reliability
    // In a real premium app, we would load custom fonts here
    final fontHeading = pw.Font.times(); // Serif
    final fontBody = pw.Font.helvetica(); // Sans

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40), // Generous margins
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // --- Header (Ceremonial) ---
              pw.Center(
                child: pw.Text(
                  "REMEDIBOOK SANCTUARY",
                  style: pw.TextStyle(
                    font: fontBody,
                    fontSize: 10,
                    letterSpacing: 2.0,
                    color: PdfColors.grey600,
                  ),
                ),
              ),
              pw.SizedBox(height: 40),

              // --- Title & Verification ---
              pw.Text(
                title.toUpperCase(),
                style: pw.TextStyle(
                  font: fontHeading,
                  fontSize: 28,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColor.fromInt(0xFF1F4E5F), // Deep Teal
                ),
              ),
              pw.SizedBox(height: 8),
              
              // Verification Pill (Simulated)
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey400),
                  borderRadius: pw.BorderRadius.circular(12),
                ),
                child: pw.Text(
                  verificationLabel.toUpperCase(),
                  style: pw.TextStyle(
                    font: fontBody,
                    fontSize: 8,
                    color: PdfColor.fromInt(0xFF1F4E5F),
                  ),
                ),
              ),
              
              pw.SizedBox(height: 20),
              pw.Divider(color: PdfColors.grey300, thickness: 0.5),
              pw.SizedBox(height: 20),

              // --- Best For (Description) ---
              pw.Text(
                "WISDOM",
                style: pw.TextStyle(
                  font: fontBody,
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                  letterSpacing: 1.5,
                  color: PdfColors.grey600,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                description,
                style: pw.TextStyle(
                  font: fontHeading, // Use serif for body text for "book" feel
                  fontSize: 14,
                  lineSpacing: 4, // Relaxed reading
                  color: PdfColors.black,
                ),
              ),
              
              pw.SizedBox(height: 30),

              // --- Ingredients & Steps (2 Columns) ---
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Left: Ingredients
                  pw.Expanded(
                    flex: 4,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          "INGREDIENTS",
                          style: pw.TextStyle(
                            font: fontBody,
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                            letterSpacing: 1.5,
                            color: PdfColors.grey600,
                          ),
                        ),
                        pw.SizedBox(height: 12),
                        ...ingredients.map((ing) => pw.Padding(
                          padding: const pw.EdgeInsets.only(bottom: 8),
                          child: pw.Text(
                            "- $ing",
                            style: pw.TextStyle(font: fontHeading, fontSize: 12),
                          ),
                        )),
                      ],
                    ),
                  ),
                  pw.SizedBox(width: 20),
                  // Right: Ritual Steps
                  pw.Expanded(
                    flex: 6,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          "THE RITUAL",
                          style: pw.TextStyle(
                            font: fontBody,
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                            letterSpacing: 1.5,
                            color: PdfColors.grey600,
                          ),
                        ),
                        pw.SizedBox(height: 12),
                        ...List.generate(steps.length, (index) => pw.Padding(
                          padding: const pw.EdgeInsets.only(bottom: 12),
                          child: pw.Row(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(
                                "${index + 1}.",
                                style: pw.TextStyle(
                                  font: fontBody,
                                  fontSize: 12,
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColor.fromInt(0xFFD4A373), // Ember Gold
                                ),
                              ),
                              pw.SizedBox(width: 8),
                              pw.Expanded(
                                child: pw.Text(
                                  steps[index],
                                  style: pw.TextStyle(font: fontHeading, fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        )),
                      ],
                    ),
                  ),
                ],
              ),
              
              pw.Spacer(),

              // --- Safety Footer ---
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromInt(0xFFF9F7F2), // Light warm grey
                  borderRadius: pw.BorderRadius.circular(4),
                ),
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                     pw.Text(
                      "SAFETY:  ",
                      style: pw.TextStyle(font: fontBody, fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.red900),
                    ),
                    pw.Expanded(
                      child: pw.Text(
                        safetyNotes,
                        style: pw.TextStyle(font: fontBody, fontSize: 10, color: PdfColors.grey800),
                      ),
                    ),
                  ],
                ),
              ),
              
              pw.SizedBox(height: 20),
              
              // --- Watermark / Footer ---
              pw.Center(
                child: pw.Text(
                  "Generated by RemediBook | ${DateTime.now().year}",
                  style: pw.TextStyle(
                    font: fontBody,
                    fontSize: 8,
                    color: PdfColors.grey400,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }
}
