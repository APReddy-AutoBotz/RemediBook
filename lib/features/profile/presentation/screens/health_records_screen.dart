import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:remedibook/core/theme/remedi_theme.dart';
import 'package:remedibook/core/widgets/sanctuary_glass_card.dart';
import 'package:remedibook/core/models/user_profile.dart'; // Ensure this model is fully updated

class HealthRecordsScreen extends StatefulWidget {
  const HealthRecordsScreen({super.key});

  @override
  State<HealthRecordsScreen> createState() => _HealthRecordsScreenState();
}

class _HealthRecordsScreenState extends State<HealthRecordsScreen> {
  // Mock data for display, in real app this would come from SecureProfileStorage
  final List<HealthRecord> _records = [
    HealthRecord(
      id: '1',
      title: 'Blood Work - Complete Panel',
      date: 'Jan 15, 2026',
      type: 'Lab Report',
    ),
    HealthRecord(
      id: '2',
      title: 'Pediatric Prescription',
      date: 'Dec 22, 2025',
      type: 'Prescription',
    ),
  ];

  void _onUpload() {
    // Simulate upload
    setState(() {
      _records.insert(0, HealthRecord(
        id: DateTime.now().toString(),
        title: 'New Document Upload',
        date: 'Today',
        type: 'Insurance',
      ));
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Document uploaded successfully")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // Assumes stacked on SanctuaryScaffold
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Health Records",
              style: GoogleFonts.crimsonPro(
                fontSize: 28,
                color: RemediTheme.deepTeal,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Securely store your medical history.",
              style: GoogleFonts.inter(
                fontSize: 14,
                color: RemediTheme.charcoal.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 24),
            
            // Upload Button
            GestureDetector(
              onTap: _onUpload,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: RemediTheme.deepTeal.withOpacity(0.3),
                    style: BorderStyle.none, // actually lets make it dashed if possible, or just standard
                  ),
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Icon(Icons.cloud_upload_outlined, size: 32, color: RemediTheme.deepTeal.withOpacity(0.6)),
                    const SizedBox(height: 8),
                    Text(
                      "Tap to Upload Document",
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: RemediTheme.deepTeal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // List
            Text(
              "RECENT DOCUMENTS",
               style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                  color: RemediTheme.charcoal.withOpacity(0.5),
                ),
            ),
            const SizedBox(height: 16),
            
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _records.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final rec = _records[index];
                return SanctuaryGlassCard(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: RemediTheme.deepTeal.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          rec.type == 'Lab Report' ? Icons.science_outlined :
                          rec.type == 'Prescription' ? Icons.medication_outlined :
                          Icons.description_outlined,
                          color: RemediTheme.deepTeal,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              rec.title,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: RemediTheme.charcoal,
                              ),
                            ),
                            Text(
                              "${rec.type} • ${rec.date}",
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: RemediTheme.charcoal.withOpacity(0.5),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
