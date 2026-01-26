import '../domain/models/remedy.dart';
import '../domain/models/evidence_ledger.dart';

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
      description: 'Kodo millet (Siridhanya) porridge for metabolic support and sustained energy. High fiber-to-carb ratio makes it ideal for blood sugar management.',
      symptoms: ['diabetes', 'metabolic', 'energy', 'digestion', 'weight management'],
      ingredients: [
        '1/2 cup kodo millet',
        '2 cups water',
        '1/4 teaspoon turmeric',
        'Pinch of salt',
        '1 teaspoon ghee',
      ],
      instructions: [
        'Rinse kodo millet thoroughly',
        'Dry roast millet for 2-3 minutes',
        'Add water and bring to boil',
        'Add turmeric and salt',
        'Simmer for 20-25 minutes until soft',
        'Add ghee and serve warm',
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
      category: 'Metabolic Support',
    ),

    // 3. Foxtail Millet Salad (Traditional - Respiratory Support)
    Remedy(
      id: 'remedy_003',
      name: 'Foxtail Millet Salad',
      description: 'Cooling foxtail millet salad with vegetables for respiratory wellness and inflammation reduction. Light and nourishing.',
      symptoms: ['inflammation', 'respiratory', 'heat', 'digestion'],
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
      category: 'Respiratory Support',
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
