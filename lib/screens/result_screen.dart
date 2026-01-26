import 'package:flutter/material.dart';
import 'dart:ui';
import '../theme.dart';
import '../services/remedy_service.dart';
import '../services/pdf_service.dart';

class ResultScreen extends StatefulWidget {
  final String symptom;
  const ResultScreen({super.key, required this.symptom});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  final RemedyService _service = RemedyService();
  final PdfService _pdfService = PdfService();
  late Future<Map<String, dynamic>> _remedyFuture;

  @override
  void initState() {
    super.initState();
    _remedyFuture = _service.getRemedy(widget.symptom);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Map<String, dynamic>>(
        future: _remedyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.deepTeal));
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text('Consult a healer (Error loading).'));
          }

          final data = snapshot.data!;
          final triage = data['triage'];

          return Stack(
            children: [
              // Background Motif
              Positioned.fill(
                child: Opacity(
                  opacity: 0.1,
                  child: Image.asset(
                    'assets/images/background_motif.png',
                    fit: BoxFit.cover,
                    repeat: ImageRepeat.repeat,
                  ),
                ),
              ),
              
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Macro Photography Header
                    SizedBox(
                      height: 400,
                      width: double.infinity,
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: Image.asset(
                              'assets/images/ginger_tulsi_macro.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    AppTheme.warmLimestone.withOpacity(0.5),
                                    AppTheme.warmLimestone,
                                  ],
                                  stops: const [0.5, 0.8, 1.0],
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 50,
                            left: 20,
                            child: IconButton(
                              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ),
                        ],
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(triage['remedy'], style: Theme.of(context).textTheme.displayLarge),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Icon(Icons.verified_rounded, color: AppTheme.deepTeal, size: 18),
                              const SizedBox(width: 8),
                              const Text(
                                'TRADITIONAL TEXT VERIFIED',
                                style: TextStyle(
                                  color: AppTheme.deepTeal,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 48),
                          Text('Triad of Trust', style: Theme.of(context).textTheme.headlineMedium),
                          const SizedBox(height: 20),

                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Row(
                              children: [
                                _buildTriadCard('Ancient Remedy', triage['evidence'], Icons.history_edu_rounded),
                                _buildTriadCard('Mind-Body', triage['practice'], Icons.self_improvement_rounded),
                                _buildTriadCard('Modern Logic', 'Gingerols effectively suppress cough reflex triggers.', Icons.science_rounded),
                              ],
                            ),
                          ),

                          const SizedBox(height: 48),
                          _buildSection('Ingredients', triage['ingredients']),
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Bottom Action Bar
              Positioned(
                bottom: 40,
                left: 24,
                right: 24,
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {},
                        child: const Text('Start Ritual'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    GestureDetector(
                          onTap: () => _pdfService.generateWellnessGuide(
                            triage['remedy'], 
                            'Apply ancient wisdom...',
                          ),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: AppTheme.glassDecoration(radius: 16, opacity: 0.8),
                        child: const Icon(Icons.picture_as_pdf_outlined, color: AppTheme.deepTeal),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontFamily: 'Serif', fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Text(content, style: const TextStyle(height: 1.6, fontSize: 16)),
      ],
    );
  }

  Widget _buildTriadCard(String title, String body, IconData icon) {
    return Container(
      width: 210,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(24),
      decoration: AppTheme.glassDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.deepTeal, size: 30),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.darkForest)),
          const SizedBox(height: 8),
          Text(
            body,
            style: TextStyle(fontSize: 12, color: AppTheme.charcoalBody.withOpacity(0.7), height: 1.5),
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
