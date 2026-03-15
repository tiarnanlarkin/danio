/// Maps raw concept IDs (e.g. "nc_intro_section_2") to human-friendly names
/// for display in spaced-repetition review cards.
library;

/// Lesson ID → human-readable title, matched to actual IDs from lesson_provider.dart.
const Map<String, String> _lessonTitles = {
  // Nitrogen Cycle
  'nc_intro': 'Why New Tanks Kill Fish',
  'nc_stages': 'Ammonia → Nitrite → Nitrate',
  'nc_how_to': 'How to Cycle Your Tank',
  'nc_testing': 'Testing Your Water',
  'nc_spikes': 'Handling Cycle Spikes',
  'nc_minicycle': 'Mini-Cycles',

  // Water Parameters
  'wp_ph': 'pH: Acid vs Alkaline',
  'wp_temp': 'Temperature Control',
  'wp_hardness': 'Water Hardness (GH & KH)',
  'wp_stability': 'Keeping Parameters Stable',

  // Equipment
  'eq_filters': 'Choosing the Right Filter',
  'eq_heaters': 'Heater Selection & Safety',
  'eq_lighting': 'Lighting 101',
  'eq_substrate': 'Substrate Selection',
  'eq_air_pump': 'Air Pumps & Oxygenation',

  // First Fish
  'ff_choosing': 'Choosing Hardy Species',
  'ff_acclimation': 'Bringing Fish Home',
  'ff_hardy': 'Hardy Beginner Fish',
  'ff_compatibility': 'Fish Compatibility',
  'ff_stocking': 'Stocking Your Tank',

  // Fish Health
  'fh_prevention': 'Disease Prevention',
  'fh_ich': 'Ich: White Spot Disease',
  'fh_fin_rot': 'Fin Rot & Bacterial Infections',
  'fh_signs': 'Spotting Signs of Illness',
  'fh_quarantine': 'Quarantine Tanks',

  // Maintenance
  'tm_water_changes': 'Water Changes 101',
  'tm_filter': 'Filter Maintenance',
  'tm_algae': 'Algae Control',
  'tm_schedule': 'Maintenance Schedules',
  'tm_equipment': 'Equipment Upkeep',

  // Planted Tanks
  'pt_intro': 'Why Live Plants?',
  'pt_lighting': 'Light & Nutrients',
  'pt_easy_plants': 'Easy Beginner Plants',
  'pt_fertilizers': 'Fertilizers & Dosing',

  // Species Care
  'sc_bettas': 'Betta Fish Care',
  'sc_goldfish': 'Goldfish Care',
  'sc_tetras': 'Tetras',
  'sc_cichlids': 'Cichlids',
  'sc_guppies': 'Guppies',

  // Advanced Topics
  'at_breeding': 'Breeding Fish',
  'at_aquascaping': 'Aquascaping Fundamentals',
  'at_biotopes': 'Biotope Aquariums',
  'at_saltwater': 'Introduction to Saltwater',
};

/// Convert a raw concept ID like "nc_intro_section_2" or "nc_intro_quiz_q1"
/// into a user-friendly display string like "Why New Tanks Kill Fish - Section 3"
/// or "Why New Tanks Kill Fish - Quiz Q1".
String conceptDisplayName(String conceptId) {
  // Try matching "{lessonId}_section_{n}"
  final sectionMatch = RegExp(r'^(.+)_section_(\d+)$').firstMatch(conceptId);
  if (sectionMatch != null) {
    final lessonId = sectionMatch.group(1)!;
    final sectionNum = int.parse(sectionMatch.group(2)!) + 1; // 0-indexed → 1-indexed
    final title = _lessonTitles[lessonId] ?? _titleFromId(lessonId);
    return '$title - Key Point $sectionNum';
  }

  // Try matching "{lessonId}_quiz_q{n}"
  final quizMatch = RegExp(r'^(.+)_quiz_q(\d+)$').firstMatch(conceptId);
  if (quizMatch != null) {
    final lessonId = quizMatch.group(1)!;
    final qNum = (int.tryParse(quizMatch.group(2) ?? '') ?? 0) + 1;
    final title = _lessonTitles[lessonId] ?? _titleFromId(lessonId);
    return '$title - Quiz Q$qNum';
  }

  // Fallback: try the whole string as a lesson ID
  if (_lessonTitles.containsKey(conceptId)) {
    return _lessonTitles[conceptId]!;
  }

  // Last resort: humanise the ID itself
  return _titleFromId(conceptId);
}

/// Best-effort conversion of a snake_case ID to Title Case.
String _titleFromId(String id) {
  return id
      .replaceAll('_', ' ')
      .split(' ')
      .map((w) => w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1)}')
      .join(' ');
}
