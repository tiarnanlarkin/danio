/// Maps species IDs (matching asset filenames without .png) to the lesson IDs
/// that unlock them.  When a lesson is completed, the species is automatically
/// unlocked for the user's tank.
///
/// The 15 species shipped in assets/images/fish/ are mapped here.
/// Species without a 1:1 lesson unlock are unlocked by default (listed in
/// [defaultUnlockedSpecies]) so first-time users always have some fish to
/// enjoy.
library;

/// Species-to-lesson mapping.  Key = species ID, value = lesson ID.
/// A species is unlocked when the corresponding lesson is completed.
const Map<String, String> speciesLessonMap = {
  // Species Care path lessons
  'betta': 'sc_betta',
  'neon_tetra': 'sc_tetras',
  // harlequin_rasbora remapped from sc_tetras to dedicated lesson
  'harlequin_rasbora': 'sc_rasboras',
  'cherry_barb': 'sc_tetras',
  'zebra_danio': 'ff_choosing',
  // guppy now also connects to dedicated livebearer lesson (default unlock preserved)
  'guppy': 'sc_livebearers',
  // molly and platy remapped from first_fish to dedicated livebearer lesson
  'molly': 'sc_livebearers',
  'platy': 'sc_livebearers',
  // angelfish remapped from sc_cichlids to dedicated lesson
  'angelfish': 'sc_angelfish',
  'amano_shrimp': 'sc_shrimp',
  'cherry_shrimp': 'sc_shrimp',
  'nerite_snail': 'sc_snails',
  // otocinclus remapped from planted_basics to dedicated pleco/algae eater lesson
  'otocinclus': 'sc_plecos',
  // bristlenose_pleco remapped from maint_algae to dedicated lesson
  'bristlenose_pleco': 'sc_plecos',
  // bronze_corydoras remapped from ff_quarantine to dedicated corydoras lesson
  'bronze_corydoras': 'sc_corydoras',
};

/// Species unlocked by default without any lesson requirement.
/// These give new users fish in their tank from day one.
const List<String> defaultUnlockedSpecies = [
  'zebra_danio',
  'neon_tetra',
  'guppy',
];

/// Human-readable display names for each species ID.
const Map<String, String> speciesDisplayNames = {
  'betta': 'Betta Fish',
  'neon_tetra': 'Neon Tetra',
  'harlequin_rasbora': 'Harlequin Rasbora',
  'cherry_barb': 'Cherry Barb',
  'zebra_danio': 'Zebra Danio',
  'guppy': 'Guppy',
  'molly': 'Molly',
  'platy': 'Platy',
  'angelfish': 'Angelfish',
  'amano_shrimp': 'Amano Shrimp',
  'cherry_shrimp': 'Cherry Shrimp',
  'nerite_snail': 'Nerite Snail',
  'otocinclus': 'Otocinclus',
  'bristlenose_pleco': 'Bristlenose Pleco',
  'bronze_corydoras': 'Bronze Corydoras',
};

/// Asset path for a species sprite (full-size).
String speciesAssetPath(String speciesId) =>
    'assets/images/fish/$speciesId.png';

/// Asset path for a species sprite (128px thumbnail).
String speciesThumbPath(String speciesId) =>
    'assets/images/fish/thumb/$speciesId.png';

/// Returns the species ID unlocked by [lessonId], or null if none.
String? speciesForLesson(String lessonId) {
  for (final entry in speciesLessonMap.entries) {
    if (entry.value == lessonId) return entry.key;
  }
  return null;
}
