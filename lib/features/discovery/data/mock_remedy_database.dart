import 'package:flutter/material.dart';
import '../domain/models/remedy.dart';
import '../domain/models/evidence_ledger.dart';
import '../domain/models/fulfillment_models.dart';

/// Mock Remedy Database
/// 3 curated remedies aligned with Siridhanya Logic
class MockRemedyDatabase {
  static final List<Remedy> remedies = [
    // 1. Ginger-Tulsi Tea (Evidence-Supported)
    Remedy(
      id: 'remedy_001',
      name: 'Ginger-Tulsi Tea',
      description: 'A powerful combination of ginger and tulsi (holy basil) for respiratory health and immunity. Ginger provides anti-inflammatory benefits while tulsi offers adaptogenic properties.',
      symptoms: ['cold', 'cough', 'sore throat', 'respiratory', 'immunity'],
      ingredients: [
        '1-inch fresh ginger root, sliced',
        '8-10 fresh tulsi leaves',
        '2 cups water',
        '1 teaspoon honey (optional)',
      ],
      instructions: [
        'Bring water to a boil',
        'Add ginger slices and tulsi leaves',
        'Simmer for 10 minutes',
        'Strain into a cup',
        'Add honey if desired',
        'Drink warm, 2-3 times daily',
      ],
      prepSteps: [
        PrepStep('Bring 2 cups of filtered water to a rolling boil', durationSeconds: 180),
        PrepStep('Add freshly sliced ginger and tulsi leaves to the boiling water'),
        PrepStep('Reduce heat and simmer gently to extract medicinal compounds', durationSeconds: 600),
        PrepStep('Strain the tea into your favorite cup, discarding solids'),
        PrepStep('Allow to cool to warm (not hot) before adding honey to preserve enzymes'),
        PrepStep('Drink slowly, 2-3 times daily for optimal benefit'),
      ],
      fibreToCarbRatio: 0.15, // Low carb, minimal fiber
      evidenceLedger: EvidenceLedger(
        remedyId: 'remedy_001',
        label: EvidenceLabel.evidenceSupported,
        reviewDate: DateTime(2025, 12, 10),
        sourceCount: 3,
        primarySources: [
          Citation(
            id: 'cit_001_01',
            title: 'Ginger and its constituents: role in prevention and treatment',
            source: 'Pharmacogn Rev',
            url: 'https://pubmed.ncbi.nlm.nih.gov/23055638/',
            publicationDate: DateTime(2012, 7, 1),
            authors: 'Grzanna R, Lindmark L, Frondoza CG',
          ),
          Citation(
            id: 'cit_001_02',
            title: 'Tulsi - Ocimum sanctum: A herb for all reasons',
            source: 'J Ayurveda Integr Med',
            url: 'https://pubmed.ncbi.nlm.nih.gov/24250142/',
            publicationDate: DateTime(2014, 10, 1),
            authors: 'Cohen MM',
          ),
          Citation(
            id: 'cit_001_03',
            title: 'Pharmacological and therapeutic effects of Ocimum sanctum',
            source: 'Indian J Physiol Pharmacol',
            url: 'https://pubmed.ncbi.nlm.nih.gov/15991574/',
            publicationDate: DateTime(2005, 4, 1),
            authors: 'Gupta SK, Prakash J, Srivastava S',
          ),
        ],
      ),
      category: 'Respiratory Health',
    ),

    // 2. Kodo Millet Porridge (Traditional - Metabolic Support)
    Remedy(
      id: 'remedy_002',
      name: 'Kodo Millet Porridge',
      description: 'Expert-verified remedy for Metabolic Health & Sustained Energy. Stabilizes blood sugar and fights fatigue.',
      symptoms: ['diabetes', 'metabolic', 'energy', 'digestion', 'weight management'],
      ingredients: [
        '1/2 cup kodo millet',
        '2 cups water',
        '1/4 teaspoon turmeric',
        '1 tsp ghee',
      ],
      instructions: [
        'Soak kodo millet for 4-6 hours for enzyme activation',
        'Rinse thoroughly and dry roast for 2-3 minutes until fragrant',
        'Add water and bring to boil',
        'Add turmeric and simmer for 20-25 minutes until soft',
        'Stir in ghee and serve warm',
        'Once daily, preferably breakfast',
      ],
      prepSteps: [
        PrepStep('Soak 1/2 cup kodo millet in water for 4-6 hours to activate enzymes', durationSeconds: 14400),
        PrepStep('Drain and rinse thoroughly under running water'),
        PrepStep('Dry roast millet in a pan for 2-3 minutes until fragrant', durationSeconds: 150),
        PrepStep('Add 2 cups water and bring to a rolling boil', durationSeconds: 180),
        PrepStep('Add turmeric, reduce heat, and simmer until soft and fluffy', durationSeconds: 1500),
        PrepStep('Stir in 1 tsp ghee for lubrication and enhanced absorption'),
        PrepStep('Serve warm as breakfast (once daily) for sustained energy and blood sugar stability'),
      ],
      fibreToCarbRatio: 0.42, // High fiber-to-carb ratio (Siridhanya Logic)
      evidenceLedger: EvidenceLedger(
        remedyId: 'remedy_002',
        label: EvidenceLabel.traditional,
        reviewDate: DateTime(2025, 11, 15),
        sourceCount: 2,
        primarySources: [
          Citation(
            id: 'cit_002_01',
            title: 'Nutritional and health benefits of millets',
            source: 'IIMR Research Bulletin',
            url: 'https://millets.res.in/technologies/nutritional_health.php',
            publicationDate: DateTime(2018, 3, 1),
            authors: 'Saleh ASM, Zhang Q, Chen J, Shen Q',
          ),
          Citation(
            id: 'cit_002_02',
            title: 'Kodo millet: nutritional composition and health benefits',
            source: 'J Food Sci Technol',
            url: 'https://www.ncbi.nlm.nih.gov/pmc/articles/PMC6425490/',
            publicationDate: DateTime(2019, 2, 1),
            authors: 'Chandrasekara A, Shahidi F',
          ),
        ],
      ),
      category: 'Kodo Millet Porridge',
      practice: PracticeTechnique(
        title: 'Mandukasana (Frog Pose)',
        icon: Icons.self_improvement_outlined,
        howTo: [
          'Sit in Vajrasana (kneeling position)',
          'Place fists near navel, press inward gently',
          'Bend forward slowly, hold for 30 seconds',
          'Repeat 3 times for pancreatic activation',
        ],
      ),
      escalation: EscalationCriteria(
        hourThreshold: 24,
        guidance: 'Seek immediate care for blurred vision, extreme thirst, or if fasting glucose exceeds 250mg/dL despite dietary management.',
        redFlags: [
          'Fasting Glucose > 250mg/dL',
          'Persistent blurred vision or eye pain',
          'Sudden fatigue or confusion',
          'Excessive thirst despite hydration',
        ],
        isBookingAvailable: true,
        clinicName: 'Apollo Sugar Clinics',
      ),
    ),

    // 3. Foxtail Millet Salad (Traditional - Respiratory Support)
    Remedy(
      id: 'remedy_003',
      name: 'Foxtail Millet Salad',
      description: 'Cooling foxtail millet salad for Digestion and Acidity Relief. Reduces body heat and calming inflammation.',
      symptoms: ['inflammation', 'respiratory', 'heat', 'digestion', 'acidity', 'heartburn'],
      ingredients: [
        '1 cup cooked foxtail millet',
        '1/2 cucumber, diced',
        '1 tomato, diced',
        '1/4 cup fresh coriander',
        'Juice of 1 lemon',
        '1 teaspoon olive oil',
        'Salt and pepper to taste',
      ],
      instructions: [
        'Cook foxtail millet and let it cool',
        'Dice cucumber and tomato',
        'Chop fresh coriander',
        'Mix all ingredients in a bowl',
        'Add lemon juice, olive oil, salt, and pepper',
        'Toss well and serve chilled',
      ],
      prepSteps: [
        PrepStep('Cook foxtail millet and allow to cool completely', durationSeconds: 900),
        PrepStep('Dice cucumber and tomato into small cubes'),
        PrepStep('Finely chop fresh coriander leaves'),
        PrepStep('Combine millet and vegetables in a mixing bowl'),
        PrepStep('Whisk lemon juice, olive oil, salt, and pepper nearby'),
        PrepStep('Pour dressing over salad and toss to coat evenly'),
        PrepStep('Serve chilled for maximum cooling effect on the gut'),
      ],
      fibreToCarbRatio: 0.38, // Good fiber-to-carb ratio
      evidenceLedger: EvidenceLedger(
        remedyId: 'remedy_003',
        label: EvidenceLabel.traditional,
        reviewDate: DateTime(2025, 10, 20),
        sourceCount: 2,
        primarySources: [
          Citation(
            id: 'cit_003_01',
            title: 'Foxtail millet: Properties, processing, health benefits',
            source: 'Food Rev Int',
            url: 'https://www.tandfonline.com/doi/abs/10.1080/87559129.2020.1737709',
            publicationDate: DateTime(2020, 3, 1),
            authors: 'Devi PB, Vijayabharathi R, Sathyabama S',
          ),
          Citation(
            id: 'cit_003_02',
            title: 'Millets: nutritional composition, some health benefits and processing',
            source: 'Emirates J Food Agric',
            url: 'https://www.ejfa.me/index.php/journal/article/view/426',
            publicationDate: DateTime(2017, 1, 1),
            authors: 'Amadou I, Gounga ME, Le GW',
          ),
        ],
      ),
      category: 'Digestive & Respiratory Health',
    ),
  ];

  /// Search remedies by symptom
  static List<Remedy> searchBySymptom(String query) {
    final lowerQuery = query.toLowerCase().trim();
    return remedies.where((remedy) {
      return remedy.symptoms.any((symptom) => symptom.toLowerCase().contains(lowerQuery)) ||
          remedy.name.toLowerCase().contains(lowerQuery) ||
          remedy.description.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  /// Get remedy by ID
  static Remedy? getById(String id) {
    try {
      return remedies.firstWhere((r) => r.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get all remedies
  static List<Remedy> getAll() => remedies;
}
