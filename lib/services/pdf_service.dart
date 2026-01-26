import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfService {
  Future<void> generateWellnessGuide(String remedyName, String content) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Stack(
            children: [
              // Minimalist Border
              pw.Container(
                margin: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.teal, width: 0.5),
                ),
              ),
              
              pw.Padding(
                padding: const pw.EdgeInsets.all(40),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('REMEDIBOOK', 
                      style: pw.TextStyle(
                        fontSize: 10, 
                        letterSpacing: 5, 
                        color: PdfColors.grey700
                      )
                    ),
                    pw.SizedBox(height: 20),
                    pw.Text(remedyName, 
                      style: pw.TextStyle(
                        fontSize: 32, 
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.teal900
                      )
                    ),
                    pw.SizedBox(height: 10),
                    pw.Divider(color: PdfColors.teal),
                    pw.SizedBox(height: 30),
                    pw.Text('REMEDY STEPS', 
                      style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)
                    ),
                    pw.SizedBox(height: 10),
                    pw.Text(content, 
                      style: const pw.TextStyle(fontSize: 12)
                    ),
                    pw.Spacer(),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text('VERIFIED SOURCE', style: pw.TextStyle(fontSize: 8, color: PdfColors.grey)),
                            pw.Text('Traditional Ayurveda Vol. 4', style: const pw.TextStyle(fontSize: 10)),
                          ],
                        ),
                        // QR Code Placeholder
                        pw.BarcodeWidget(
                          barcode: pw.Barcode.qrCode(),
                          data: 'https://remedibook.health/verify/12345',
                          width: 40,
                          height: 40,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Digital Wax Seal (Watermark)
              pw.Positioned(
                bottom: 60,
                right: 60,
                child: pw.Opacity(
                  opacity: 0.1,
                  child: pw.Container(
                    width: 100,
                    height: 100,
                    decoration: const pw.BoxDecoration(
                      color: PdfColors.teal,
                      shape: pw.BoxShape.circle,
                    ),
                    child: pw.Center(
                      child: pw.Text('VERIFIED', 
                        style: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold)
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }
}
