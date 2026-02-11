// Species database for common freshwater aquarium fish.
// This provides basic care requirements for compatibility checking.

/// Information about an aquarium species including care requirements.
class SpeciesInfo {
  final String commonName;
  final String scientificName;
  final String family;
  final String careLevel; // Beginner, Intermediate, Advanced
  final double minTankLitres;
  final double minTempC;
  final double maxTempC;
  final double minPh;
  final double maxPh;
  final double? minGh;
  final double? maxGh;
  final int minSchoolSize;
  final String temperament; // Peaceful, Semi-aggressive, Aggressive
  final String diet;
  final double adultSizeCm;
  final String swimLevel; // Top, Middle, Bottom, All
  final String description;
  final List<String> compatibleWith;
  final List<String> avoidWith;

  const SpeciesInfo({
    required this.commonName,
    required this.scientificName,
    required this.family,
    required this.careLevel,
    required this.minTankLitres,
    required this.minTempC,
    required this.maxTempC,
    required this.minPh,
    required this.maxPh,
    this.minGh,
    this.maxGh,
    required this.minSchoolSize,
    required this.temperament,
    required this.diet,
    required this.adultSizeCm,
    required this.swimLevel,
    required this.description,
    this.compatibleWith = const [],
    this.avoidWith = const [],
  });
}

/// Database of common freshwater species.
/// Lookup by common name (case-insensitive) or scientific name.
class SpeciesDatabase {
  static final Map<String, SpeciesInfo> _byCommonName = {};
  static final Map<String, SpeciesInfo> _byScientificName = {};
  static bool _initialized = false;

  /// Get all species in the database.
  static List<SpeciesInfo> get species {
    _ensureInitialized();
    return List.unmodifiable(_allSpecies);
  }

  static void _ensureInitialized() {
    if (_initialized) return;
    for (final species in _allSpecies) {
      _byCommonName[species.commonName.toLowerCase()] = species;
      _byScientificName[species.scientificName.toLowerCase()] = species;
    }
    _initialized = true;
  }

  /// Find species by common or scientific name (case-insensitive, partial match).
  static SpeciesInfo? lookup(String name) {
    _ensureInitialized();
    final lower = name.toLowerCase().trim();

    // Exact match first
    if (_byCommonName.containsKey(lower)) return _byCommonName[lower];
    if (_byScientificName.containsKey(lower)) return _byScientificName[lower];

    // Partial match
    for (final entry in _byCommonName.entries) {
      if (entry.key.contains(lower) || lower.contains(entry.key)) {
        return entry.value;
      }
    }
    for (final entry in _byScientificName.entries) {
      if (entry.key.contains(lower) || lower.contains(entry.key)) {
        return entry.value;
      }
    }

    return null;
  }

  /// Search species by keyword.
  static List<SpeciesInfo> search(String query) {
    _ensureInitialized();
    final lower = query.toLowerCase().trim();
    if (lower.isEmpty) return _allSpecies.toList();

    return _allSpecies.where((s) {
      return s.commonName.toLowerCase().contains(lower) ||
          s.scientificName.toLowerCase().contains(lower) ||
          s.family.toLowerCase().contains(lower);
    }).toList();
  }

  /// Get all species.
  static List<SpeciesInfo> get all {
    _ensureInitialized();
    return _allSpecies.toList();
  }
}

/// Common freshwater species data.
const List<SpeciesInfo> _allSpecies = [
  // Tetras
  SpeciesInfo(
    commonName: 'Neon Tetra',
    scientificName: 'Paracheirodon innesi',
    family: 'Characidae',
    careLevel: 'Beginner',
    minTankLitres: 40,
    minTempC: 20,
    maxTempC: 26,
    minPh: 6.0,
    maxPh: 7.0,
    minGh: 1,
    maxGh: 10,
    minSchoolSize: 6,
    temperament: 'Peaceful',
    diet: 'Omnivore — flakes, micro pellets, frozen/live foods',
    adultSizeCm: 3.5,
    swimLevel: 'Middle',
    description:
        'One of the most popular aquarium fish. Bright blue and red coloring. Thrives in schools of 6+. Prefers soft, slightly acidic water with plants.',
    compatibleWith: [
      'Cardinal Tetra',
      'Corydoras',
      'Rasbora',
      'Small Gourami',
      'Shrimp',
    ],
    avoidWith: ['Angelfish', 'Bettas', 'Large Cichlids'],
  ),
  SpeciesInfo(
    commonName: 'Cardinal Tetra',
    scientificName: 'Paracheirodon axelrodi',
    family: 'Characidae',
    careLevel: 'Beginner',
    minTankLitres: 40,
    minTempC: 23,
    maxTempC: 27,
    minPh: 5.5,
    maxPh: 7.0,
    minGh: 1,
    maxGh: 8,
    minSchoolSize: 6,
    temperament: 'Peaceful',
    diet: 'Omnivore — flakes, micro pellets, frozen/live foods',
    adultSizeCm: 5,
    swimLevel: 'Middle',
    description:
        'Similar to Neon Tetra but with more vibrant red extending the full body length. Prefers warmer, softer water. Beautiful in planted tanks.',
    compatibleWith: ['Neon Tetra', 'Corydoras', 'Rasbora', 'Small Gourami'],
    avoidWith: ['Large Cichlids', 'Aggressive fish'],
  ),
  SpeciesInfo(
    commonName: 'Rummy Nose Tetra',
    scientificName: 'Hemigrammus rhodostomus',
    family: 'Characidae',
    careLevel: 'Intermediate',
    minTankLitres: 75,
    minTempC: 24,
    maxTempC: 28,
    minPh: 5.5,
    maxPh: 7.0,
    minGh: 2,
    maxGh: 12,
    minSchoolSize: 6,
    temperament: 'Peaceful',
    diet: 'Omnivore — flakes, small pellets, frozen foods',
    adultSizeCm: 5,
    swimLevel: 'Middle',
    description:
        'Known for tight schooling behavior and distinctive red nose. The red nose fades when stressed — a good indicator of water quality.',
    compatibleWith: ['Other Tetras', 'Corydoras', 'Rasboras', 'Dwarf Cichlids'],
    avoidWith: ['Aggressive fish', 'Large predators'],
  ),

  // Livebearers
  SpeciesInfo(
    commonName: 'Guppy',
    scientificName: 'Poecilia reticulata',
    family: 'Poeciliidae',
    careLevel: 'Beginner',
    minTankLitres: 20,
    minTempC: 22,
    maxTempC: 28,
    minPh: 7.0,
    maxPh: 8.5,
    minGh: 8,
    maxGh: 20,
    minSchoolSize: 3,
    temperament: 'Peaceful',
    diet: 'Omnivore — flakes, small pellets, vegetable matter',
    adultSizeCm: 5,
    swimLevel: 'Top',
    description:
        'Hardy, colorful, and prolific breeders. Males are more colorful; females are larger. Prefer harder, alkaline water. Will breed readily.',
    compatibleWith: [
      'Platies',
      'Mollies',
      'Corydoras',
      'Peaceful community fish',
    ],
    avoidWith: ['Fin nippers', 'Aggressive fish', 'Bettas (male)'],
  ),
  SpeciesInfo(
    commonName: 'Platy',
    scientificName: 'Xiphophorus maculatus',
    family: 'Poeciliidae',
    careLevel: 'Beginner',
    minTankLitres: 40,
    minTempC: 20,
    maxTempC: 26,
    minPh: 7.0,
    maxPh: 8.2,
    minGh: 10,
    maxGh: 25,
    minSchoolSize: 3,
    temperament: 'Peaceful',
    diet: 'Omnivore — flakes, pellets, vegetable matter, algae',
    adultSizeCm: 6,
    swimLevel: 'Middle',
    description:
        'Hardy, peaceful livebearers available in many colors. Easy to breed. Great for beginners. Prefer harder, alkaline water.',
    compatibleWith: ['Guppies', 'Mollies', 'Swordtails', 'Corydoras'],
    avoidWith: ['Aggressive fish'],
  ),
  SpeciesInfo(
    commonName: 'Molly',
    scientificName: 'Poecilia sphenops',
    family: 'Poeciliidae',
    careLevel: 'Beginner',
    minTankLitres: 75,
    minTempC: 22,
    maxTempC: 28,
    minPh: 7.5,
    maxPh: 8.5,
    minGh: 15,
    maxGh: 30,
    minSchoolSize: 3,
    temperament: 'Peaceful',
    diet: 'Omnivore with herbivore tendencies — flakes, algae, vegetables',
    adultSizeCm: 10,
    swimLevel: 'All',
    description:
        'Popular livebearers that come in many varieties (black, dalmatian, sailfin). Prefer hard, alkaline water. Good algae eaters.',
    compatibleWith: [
      'Guppies',
      'Platies',
      'Swordtails',
      'Larger community fish',
    ],
    avoidWith: ['Soft-water fish', 'Very small fish'],
  ),

  // Corydoras
  SpeciesInfo(
    commonName: 'Bronze Corydoras',
    scientificName: 'Corydoras aeneus',
    family: 'Callichthyidae',
    careLevel: 'Beginner',
    minTankLitres: 40,
    minTempC: 22,
    maxTempC: 26,
    minPh: 6.0,
    maxPh: 8.0,
    minGh: 2,
    maxGh: 20,
    minSchoolSize: 6,
    temperament: 'Peaceful',
    diet: 'Omnivore — sinking pellets, wafers, frozen foods',
    adultSizeCm: 7,
    swimLevel: 'Bottom',
    description:
        'Hardy bottom-dwelling catfish. Excellent scavengers. Keep in groups of 6+ on soft substrate (sand preferred). Active during day.',
    compatibleWith: [
      'Most community fish',
      'Tetras',
      'Rasboras',
      'Peaceful fish',
    ],
    avoidWith: ['Aggressive bottom dwellers', 'Large cichlids'],
  ),
  SpeciesInfo(
    commonName: 'Panda Corydoras',
    scientificName: 'Corydoras panda',
    family: 'Callichthyidae',
    careLevel: 'Beginner',
    minTankLitres: 40,
    minTempC: 20,
    maxTempC: 25,
    minPh: 6.0,
    maxPh: 7.4,
    minGh: 2,
    maxGh: 15,
    minSchoolSize: 6,
    temperament: 'Peaceful',
    diet: 'Omnivore — sinking pellets, wafers, frozen foods',
    adultSizeCm: 5,
    swimLevel: 'Bottom',
    description:
        'Adorable black and white pattern resembling a panda. Prefers cooler water than most tropicals. Needs groups and soft substrate.',
    compatibleWith: [
      'Other Corydoras',
      'Tetras',
      'White Cloud Minnows',
      'Peaceful fish',
    ],
    avoidWith: ['Aggressive fish', 'Hot water species'],
  ),

  // Rasboras
  SpeciesInfo(
    commonName: 'Harlequin Rasbora',
    scientificName: 'Trigonostigma heteromorpha',
    family: 'Cyprinidae',
    careLevel: 'Beginner',
    minTankLitres: 40,
    minTempC: 22,
    maxTempC: 28,
    minPh: 6.0,
    maxPh: 7.5,
    minGh: 2,
    maxGh: 15,
    minSchoolSize: 6,
    temperament: 'Peaceful',
    diet: 'Omnivore — flakes, micro pellets, frozen foods',
    adultSizeCm: 5,
    swimLevel: 'Middle',
    description:
        'Beautiful orange fish with distinctive black triangular patch. Peaceful schooling fish that does well in planted tanks.',
    compatibleWith: ['Tetras', 'Corydoras', 'Gouramis', 'Other Rasboras'],
    avoidWith: ['Large aggressive fish'],
  ),
  SpeciesInfo(
    commonName: 'Chili Rasbora',
    scientificName: 'Boraras brigittae',
    family: 'Cyprinidae',
    careLevel: 'Intermediate',
    minTankLitres: 20,
    minTempC: 20,
    maxTempC: 28,
    minPh: 4.0,
    maxPh: 7.0,
    minGh: 1,
    maxGh: 10,
    minSchoolSize: 8,
    temperament: 'Peaceful',
    diet: 'Omnivore — micro foods, crushed flakes, baby brine shrimp',
    adultSizeCm: 2,
    swimLevel: 'Middle',
    description:
        'Tiny, vibrantly red nano fish. Perfect for planted nano tanks. Needs very clean water and small food. Best in species-only or with small shrimp.',
    compatibleWith: ['Small shrimp', 'Other nano fish', 'Snails'],
    avoidWith: ['Any fish that could eat them', 'Fast/aggressive feeders'],
  ),

  // Bettas
  SpeciesInfo(
    commonName: 'Betta',
    scientificName: 'Betta splendens',
    family: 'Osphronemidae',
    careLevel: 'Beginner',
    minTankLitres: 20,
    minTempC: 24,
    maxTempC: 28,
    minPh: 6.5,
    maxPh: 7.5,
    minGh: 3,
    maxGh: 15,
    minSchoolSize: 1,
    temperament: 'Semi-aggressive',
    diet: 'Carnivore — betta pellets, frozen bloodworms, brine shrimp',
    adultSizeCm: 7,
    swimLevel: 'Top',
    description:
        'Beautiful labyrinth fish with flowing fins. Males must be kept alone or with peaceful tankmates. Needs access to surface air. Many color varieties.',
    compatibleWith: [
      'Corydoras',
      'Snails',
      'Some shrimp',
      'Calm bottom dwellers',
    ],
    avoidWith: [
      'Other Bettas',
      'Fin nippers',
      'Colorful/long-finned fish',
      'Guppies',
    ],
  ),

  // Gouramis
  SpeciesInfo(
    commonName: 'Dwarf Gourami',
    scientificName: 'Trichogaster lalius',
    family: 'Osphronemidae',
    careLevel: 'Beginner',
    minTankLitres: 40,
    minTempC: 22,
    maxTempC: 28,
    minPh: 6.0,
    maxPh: 7.5,
    minGh: 4,
    maxGh: 15,
    minSchoolSize: 1,
    temperament: 'Peaceful',
    diet: 'Omnivore — flakes, pellets, frozen foods, some vegetable matter',
    adultSizeCm: 9,
    swimLevel: 'Top',
    description:
        'Colorful labyrinth fish. Males are more vibrant (red/blue stripes). Can be kept singly or in pairs. Needs calm water and hiding spots.',
    compatibleWith: [
      'Tetras',
      'Rasboras',
      'Corydoras',
      'Peaceful community fish',
    ],
    avoidWith: ['Aggressive fish', 'Other male Gouramis', 'Very active fish'],
  ),
  SpeciesInfo(
    commonName: 'Honey Gourami',
    scientificName: 'Trichogaster chuna',
    family: 'Osphronemidae',
    careLevel: 'Beginner',
    minTankLitres: 40,
    minTempC: 22,
    maxTempC: 28,
    minPh: 6.0,
    maxPh: 7.5,
    minGh: 4,
    maxGh: 15,
    minSchoolSize: 1,
    temperament: 'Peaceful',
    diet: 'Omnivore — flakes, small pellets, frozen foods',
    adultSizeCm: 5,
    swimLevel: 'Top',
    description:
        'Smaller and more peaceful than Dwarf Gourami. Golden-honey coloration. Less prone to disease than other Gouramis. Great community fish.',
    compatibleWith: ['Tetras', 'Rasboras', 'Corydoras', 'Small peaceful fish'],
    avoidWith: ['Large aggressive fish', 'Very active fish'],
  ),

  // Cichlids (dwarf)
  SpeciesInfo(
    commonName: 'German Blue Ram',
    scientificName: 'Mikrogeophagus ramirezi',
    family: 'Cichlidae',
    careLevel: 'Intermediate',
    minTankLitres: 75,
    minTempC: 26,
    maxTempC: 30,
    minPh: 5.5,
    maxPh: 7.0,
    minGh: 3,
    maxGh: 10,
    minSchoolSize: 1,
    temperament: 'Peaceful',
    diet: 'Omnivore — high-quality pellets, frozen foods, live foods',
    adultSizeCm: 7,
    swimLevel: 'Bottom',
    description:
        'Stunningly beautiful dwarf cichlid. Needs warm, soft, acidic water. Sensitive to water quality. Best in mature, planted tanks.',
    compatibleWith: ['Tetras', 'Corydoras', 'Rasboras', 'Other peaceful fish'],
    avoidWith: ['Aggressive fish', 'Cold water species'],
  ),
  SpeciesInfo(
    commonName: 'Apistogramma Cacatuoides',
    scientificName: 'Apistogramma cacatuoides',
    family: 'Cichlidae',
    careLevel: 'Intermediate',
    minTankLitres: 60,
    minTempC: 23,
    maxTempC: 28,
    minPh: 6.0,
    maxPh: 7.5,
    minGh: 2,
    maxGh: 15,
    minSchoolSize: 1,
    temperament: 'Semi-aggressive',
    diet: 'Carnivore — frozen foods, live foods, high-protein pellets',
    adultSizeCm: 8,
    swimLevel: 'Bottom',
    description:
        'Colorful dwarf cichlid with dramatic dorsal fin. Males are territorial but generally community-safe. Needs caves and hiding spots.',
    compatibleWith: ['Tetras', 'Corydoras', 'Rasboras'],
    avoidWith: ['Other bottom-dwelling cichlids', 'Very small fish'],
  ),

  // Plecos
  SpeciesInfo(
    commonName: 'Bristlenose Pleco',
    scientificName: 'Ancistrus sp.',
    family: 'Loricariidae',
    careLevel: 'Beginner',
    minTankLitres: 75,
    minTempC: 23,
    maxTempC: 27,
    minPh: 6.5,
    maxPh: 7.5,
    minGh: 6,
    maxGh: 20,
    minSchoolSize: 1,
    temperament: 'Peaceful',
    diet:
        'Herbivore — algae wafers, vegetables (zucchini, cucumber), driftwood',
    adultSizeCm: 15,
    swimLevel: 'Bottom',
    description:
        'Excellent algae eater that stays reasonably small (unlike Common Pleco). Needs driftwood for digestion. Mostly nocturnal. Males have bristles.',
    compatibleWith: [
      'Most community fish',
      'Tetras',
      'Cichlids',
      'Livebearers',
    ],
    avoidWith: ['Other territorial plecos in small tanks'],
  ),
  SpeciesInfo(
    commonName: 'Otocinclus',
    scientificName: 'Otocinclus vittatus',
    family: 'Loricariidae',
    careLevel: 'Intermediate',
    minTankLitres: 40,
    minTempC: 22,
    maxTempC: 26,
    minPh: 6.0,
    maxPh: 7.5,
    minGh: 3,
    maxGh: 15,
    minSchoolSize: 6,
    temperament: 'Peaceful',
    diet: 'Herbivore — algae, algae wafers, blanched vegetables',
    adultSizeCm: 4,
    swimLevel: 'Bottom',
    description:
        'Tiny algae-eating catfish. Must be kept in groups. Sensitive to water quality and needs established tank with natural algae. Do not add to new tanks.',
    compatibleWith: ['Small peaceful fish', 'Shrimp', 'Tetras', 'Rasboras'],
    avoidWith: ['Large fish', 'Aggressive fish', 'New/unstable tanks'],
  ),

  // Shrimp
  SpeciesInfo(
    commonName: 'Cherry Shrimp',
    scientificName: 'Neocaridina davidi',
    family: 'Atyidae',
    careLevel: 'Beginner',
    minTankLitres: 10,
    minTempC: 18,
    maxTempC: 28,
    minPh: 6.5,
    maxPh: 8.0,
    minGh: 6,
    maxGh: 20,
    minSchoolSize: 6,
    temperament: 'Peaceful',
    diet: 'Omnivore/detritivore — biofilm, algae, shrimp pellets, vegetables',
    adultSizeCm: 3,
    swimLevel: 'Bottom',
    description:
        'Hardy and colorful freshwater shrimp. Excellent algae and detritus cleaners. Breed readily in planted tanks. Many color varieties available.',
    compatibleWith: ['Small peaceful fish', 'Snails', 'Other dwarf shrimp'],
    avoidWith: ['Any fish large enough to eat them', 'Aggressive fish'],
  ),
  SpeciesInfo(
    commonName: 'Amano Shrimp',
    scientificName: 'Caridina multidentata',
    family: 'Atyidae',
    careLevel: 'Beginner',
    minTankLitres: 40,
    minTempC: 18,
    maxTempC: 26,
    minPh: 6.5,
    maxPh: 7.5,
    minGh: 6,
    maxGh: 15,
    minSchoolSize: 3,
    temperament: 'Peaceful',
    diet:
        'Omnivore/detritivore — algae (especially hair algae), biofilm, pellets',
    adultSizeCm: 5,
    swimLevel: 'Bottom',
    description:
        'The best algae-eating shrimp. Larger than Cherry Shrimp. Cannot breed in freshwater (larvae need brackish). Voracious appetite for hair algae.',
    compatibleWith: ['Most community fish', 'Other shrimp', 'Snails'],
    avoidWith: ['Large predatory fish'],
  ),

  // Snails
  SpeciesInfo(
    commonName: 'Nerite Snail',
    scientificName: 'Neritina natalensis',
    family: 'Neritidae',
    careLevel: 'Beginner',
    minTankLitres: 10,
    minTempC: 22,
    maxTempC: 26,
    minPh: 7.0,
    maxPh: 8.5,
    minGh: 8,
    maxGh: 20,
    minSchoolSize: 1,
    temperament: 'Peaceful',
    diet: 'Herbivore — algae, biofilm, algae wafers',
    adultSizeCm: 2.5,
    swimLevel: 'Bottom',
    description:
        'Excellent algae eaters with beautiful shell patterns. Cannot reproduce in freshwater. Will not overpopulate. Need calcium for shell health.',
    compatibleWith: ['All peaceful fish', 'Shrimp', 'Other snails'],
    avoidWith: ['Snail-eating fish (loaches, puffers)'],
  ),
  SpeciesInfo(
    commonName: 'Mystery Snail',
    scientificName: 'Pomacea bridgesii',
    family: 'Ampullariidae',
    careLevel: 'Beginner',
    minTankLitres: 20,
    minTempC: 20,
    maxTempC: 28,
    minPh: 7.0,
    maxPh: 8.0,
    minGh: 8,
    maxGh: 18,
    minSchoolSize: 1,
    temperament: 'Peaceful',
    diet: 'Omnivore — algae, vegetables, fish food, calcium supplements',
    adultSizeCm: 5,
    swimLevel: 'All',
    description:
        'Large, attractive snails available in many colors (gold, blue, purple, ivory). Peaceful scavengers. Lay eggs above waterline. Need calcium.',
    compatibleWith: ['All peaceful fish', 'Shrimp', 'Other snails'],
    avoidWith: ['Snail-eating fish', 'Aggressive fish'],
  ),

  // Loaches
  SpeciesInfo(
    commonName: 'Kuhli Loach',
    scientificName: 'Pangio kuhlii',
    family: 'Cobitidae',
    careLevel: 'Beginner',
    minTankLitres: 75,
    minTempC: 24,
    maxTempC: 28,
    minPh: 5.5,
    maxPh: 7.0,
    minGh: 3,
    maxGh: 10,
    minSchoolSize: 6,
    temperament: 'Peaceful',
    diet: 'Omnivore — sinking pellets, frozen foods, live worms',
    adultSizeCm: 10,
    swimLevel: 'Bottom',
    description:
        'Eel-like loach with distinctive banding. Nocturnal and shy. Needs soft substrate (sand) and lots of hiding spots. Keep in groups.',
    compatibleWith: [
      'Tetras',
      'Rasboras',
      'Corydoras',
      'Peaceful community fish',
    ],
    avoidWith: ['Large aggressive fish', 'Gravel substrate'],
  ),

  // Danios
  SpeciesInfo(
    commonName: 'Zebra Danio',
    scientificName: 'Danio rerio',
    family: 'Cyprinidae',
    careLevel: 'Beginner',
    minTankLitres: 40,
    minTempC: 18,
    maxTempC: 24,
    minPh: 6.5,
    maxPh: 7.5,
    minGh: 5,
    maxGh: 20,
    minSchoolSize: 6,
    temperament: 'Peaceful',
    diet: 'Omnivore — flakes, pellets, frozen foods',
    adultSizeCm: 5,
    swimLevel: 'Top',
    description:
        'Extremely hardy and active schooling fish. Great for cycling new tanks. Very fast swimmers — need horizontal swimming space.',
    compatibleWith: ['Other Danios', 'Barbs', 'Tetras', 'Most community fish'],
    avoidWith: ['Slow-moving fish', 'Very small fish', 'Long-finned fish'],
  ),

  // Barbs
  SpeciesInfo(
    commonName: 'Cherry Barb',
    scientificName: 'Puntius titteya',
    family: 'Cyprinidae',
    careLevel: 'Beginner',
    minTankLitres: 75,
    minTempC: 23,
    maxTempC: 27,
    minPh: 6.0,
    maxPh: 7.5,
    minGh: 5,
    maxGh: 15,
    minSchoolSize: 6,
    temperament: 'Peaceful',
    diet: 'Omnivore — flakes, pellets, frozen foods',
    adultSizeCm: 5,
    swimLevel: 'Middle',
    description:
        'One of the most peaceful barbs. Males turn bright red when breeding. Hardy and adaptable. Great community fish.',
    compatibleWith: ['Tetras', 'Rasboras', 'Corydoras', 'Gouramis'],
    avoidWith: ['Aggressive fish'],
  ),

  // Angelfish
  SpeciesInfo(
    commonName: 'Angelfish',
    scientificName: 'Pterophyllum scalare',
    family: 'Cichlidae',
    careLevel: 'Intermediate',
    minTankLitres: 150,
    minTempC: 24,
    maxTempC: 28,
    minPh: 6.0,
    maxPh: 7.5,
    minGh: 3,
    maxGh: 12,
    minSchoolSize: 1,
    temperament: 'Semi-aggressive',
    diet: 'Omnivore — flakes, pellets, frozen foods, live foods',
    adultSizeCm: 15,
    swimLevel: 'Middle',
    description:
        'Elegant cichlid with tall, triangular shape. Needs a tall tank. Can be kept in pairs or small groups. Will eat very small fish and shrimp.',
    compatibleWith: [
      'Larger Tetras',
      'Corydoras',
      'Peaceful medium-sized fish',
    ],
    avoidWith: [
      'Neon Tetras',
      'Small fish',
      'Fin nippers',
      'Aggressive cichlids',
    ],
  ),

  // Additional Tetras
  SpeciesInfo(
    commonName: 'Ember Tetra',
    scientificName: 'Hyphessobrycon amandae',
    family: 'Characidae',
    careLevel: 'Beginner',
    minTankLitres: 30,
    minTempC: 23,
    maxTempC: 29,
    minPh: 5.5,
    maxPh: 7.0,
    minGh: 2,
    maxGh: 10,
    minSchoolSize: 8,
    temperament: 'Peaceful',
    diet: 'Omnivore — micro pellets, crushed flakes, baby brine shrimp',
    adultSizeCm: 2,
    swimLevel: 'Middle',
    description:
        'Tiny, vibrant orange nano fish. Perfect for planted nano tanks. Active schoolers that bring warmth and movement to small aquariums.',
    compatibleWith: ['Other nano fish', 'Shrimp', 'Snails', 'Rasboras'],
    avoidWith: ['Large fish', 'Fast aggressive feeders'],
  ),
  SpeciesInfo(
    commonName: 'Black Skirt Tetra',
    scientificName: 'Gymnocorymbus ternetzi',
    family: 'Characidae',
    careLevel: 'Beginner',
    minTankLitres: 75,
    minTempC: 20,
    maxTempC: 26,
    minPh: 6.0,
    maxPh: 7.5,
    minGh: 4,
    maxGh: 18,
    minSchoolSize: 6,
    temperament: 'Semi-aggressive',
    diet: 'Omnivore — flakes, pellets, frozen foods',
    adultSizeCm: 6,
    swimLevel: 'Middle',
    description:
        'Hardy tetra with distinctive black fins. Can be nippy, especially with long-finned fish. Best kept in larger groups to diffuse aggression.',
    compatibleWith: [
      'Other robust tetras',
      'Barbs',
      'Corydoras',
      'Larger community fish',
    ],
    avoidWith: ['Slow long-finned fish', 'Bettas', 'Guppies', 'Angelfish'],
  ),
  SpeciesInfo(
    commonName: 'Serpae Tetra',
    scientificName: 'Hyphessobrycon eques',
    family: 'Characidae',
    careLevel: 'Beginner',
    minTankLitres: 75,
    minTempC: 22,
    maxTempC: 26,
    minPh: 5.5,
    maxPh: 7.5,
    minGh: 5,
    maxGh: 20,
    minSchoolSize: 6,
    temperament: 'Semi-aggressive',
    diet: 'Omnivore — flakes, pellets, frozen foods',
    adultSizeCm: 4,
    swimLevel: 'Middle',
    description:
        'Beautiful deep red tetra. Known for fin nipping — keep in groups of 8+ to reduce aggression. Avoid with slow or long-finned tankmates.',
    compatibleWith: [
      'Other Serpae Tetras',
      'Robust tetras',
      'Barbs',
      'Bottom dwellers',
    ],
    avoidWith: ['Bettas', 'Guppies', 'Angelfish', 'Any long-finned fish'],
  ),

  // White Cloud Mountain Minnow
  SpeciesInfo(
    commonName: 'White Cloud Mountain Minnow',
    scientificName: 'Tanichthys albonubes',
    family: 'Cyprinidae',
    careLevel: 'Beginner',
    minTankLitres: 40,
    minTempC: 15,
    maxTempC: 22,
    minPh: 6.0,
    maxPh: 8.0,
    minGh: 5,
    maxGh: 20,
    minSchoolSize: 6,
    temperament: 'Peaceful',
    diet: 'Omnivore — flakes, small pellets, frozen foods',
    adultSizeCm: 4,
    swimLevel: 'Top',
    description:
        'Hardy coldwater fish — perfect for unheated tanks. Beautiful iridescent stripe. Very peaceful and easy to breed. Excellent beginner fish.',
    compatibleWith: [
      'Other coldwater fish',
      'Hillstream loaches',
      'Danios',
      'Corydoras',
    ],
    avoidWith: ['Tropical fish requiring warm water', 'Large aggressive fish'],
  ),

  // Endlers
  SpeciesInfo(
    commonName: 'Endler Livebearer',
    scientificName: 'Poecilia wingei',
    family: 'Poeciliidae',
    careLevel: 'Beginner',
    minTankLitres: 20,
    minTempC: 22,
    maxTempC: 28,
    minPh: 7.0,
    maxPh: 8.5,
    minGh: 10,
    maxGh: 25,
    minSchoolSize: 3,
    temperament: 'Peaceful',
    diet: 'Omnivore — flakes, small pellets, algae, vegetable matter',
    adultSizeCm: 3,
    swimLevel: 'Top',
    description:
        'Smaller, more colorful relative of the guppy. Males are incredibly vibrant. Hardy and prolific breeders. Perfect for nano tanks.',
    compatibleWith: ['Guppies', 'Small peaceful fish', 'Shrimp', 'Snails'],
    avoidWith: ['Aggressive fish', 'Fish that will eat fry'],
  ),

  // More Corydoras
  SpeciesInfo(
    commonName: 'Pygmy Corydoras',
    scientificName: 'Corydoras pygmaeus',
    family: 'Callichthyidae',
    careLevel: 'Intermediate',
    minTankLitres: 30,
    minTempC: 22,
    maxTempC: 26,
    minPh: 6.0,
    maxPh: 7.5,
    minGh: 2,
    maxGh: 15,
    minSchoolSize: 8,
    temperament: 'Peaceful',
    diet: 'Omnivore — micro sinking foods, baby brine shrimp',
    adultSizeCm: 2.5,
    swimLevel: 'Bottom',
    description:
        'Tiny catfish that also swims in midwater, unlike larger Corydoras. Perfect for nano tanks. Needs groups and clean water.',
    compatibleWith: [
      'Nano fish',
      'Shrimp',
      'Small tetras',
      'Other peaceful fish',
    ],
    avoidWith: ['Large fish', 'Aggressive bottom dwellers'],
  ),
  SpeciesInfo(
    commonName: 'Sterbai Corydoras',
    scientificName: 'Corydoras sterbai',
    family: 'Callichthyidae',
    careLevel: 'Beginner',
    minTankLitres: 75,
    minTempC: 24,
    maxTempC: 28,
    minPh: 6.0,
    maxPh: 7.5,
    minGh: 2,
    maxGh: 15,
    minSchoolSize: 6,
    temperament: 'Peaceful',
    diet: 'Omnivore — sinking pellets, wafers, frozen foods',
    adultSizeCm: 7,
    swimLevel: 'Bottom',
    description:
        'Beautiful spotted pattern with orange pectoral fins. Tolerates warmer water than most Corydoras — perfect with discus or German Blue Rams.',
    compatibleWith: ['Most community fish', 'Discus', 'Rams', 'Tetras'],
    avoidWith: ['Aggressive bottom dwellers'],
  ),
  SpeciesInfo(
    commonName: 'Julii Corydoras',
    scientificName: 'Corydoras julii',
    family: 'Callichthyidae',
    careLevel: 'Beginner',
    minTankLitres: 60,
    minTempC: 22,
    maxTempC: 26,
    minPh: 6.0,
    maxPh: 7.8,
    minGh: 2,
    maxGh: 18,
    minSchoolSize: 6,
    temperament: 'Peaceful',
    diet: 'Omnivore — sinking pellets, wafers, frozen foods',
    adultSizeCm: 5,
    swimLevel: 'Bottom',
    description:
        'Attractive spotted pattern (often confused with C. trilineatus). Hardy and active. One of the most popular Corydoras species.',
    compatibleWith: [
      'Most community fish',
      'Tetras',
      'Rasboras',
      'Peaceful fish',
    ],
    avoidWith: ['Aggressive fish', 'Sharp gravel substrate'],
  ),

  // More Gouramis
  SpeciesInfo(
    commonName: 'Pearl Gourami',
    scientificName: 'Trichopodus leerii',
    family: 'Osphronemidae',
    careLevel: 'Beginner',
    minTankLitres: 120,
    minTempC: 24,
    maxTempC: 28,
    minPh: 6.0,
    maxPh: 8.0,
    minGh: 5,
    maxGh: 20,
    minSchoolSize: 1,
    temperament: 'Peaceful',
    diet: 'Omnivore — flakes, pellets, frozen foods, some vegetable matter',
    adultSizeCm: 12,
    swimLevel: 'Top',
    description:
        'One of the most beautiful gouramis with pearl-like spots. Peaceful and hardy. Males develop orange breast when breeding.',
    compatibleWith: [
      'Tetras',
      'Rasboras',
      'Corydoras',
      'Peaceful community fish',
    ],
    avoidWith: ['Aggressive fish', 'Fin nippers', 'Multiple male gouramis'],
  ),
  SpeciesInfo(
    commonName: 'Sparkling Gourami',
    scientificName: 'Trichopsis pumila',
    family: 'Osphronemidae',
    careLevel: 'Intermediate',
    minTankLitres: 30,
    minTempC: 22,
    maxTempC: 28,
    minPh: 6.0,
    maxPh: 7.5,
    minGh: 3,
    maxGh: 12,
    minSchoolSize: 3,
    temperament: 'Peaceful',
    diet: 'Omnivore — small foods, frozen daphnia, micro pellets',
    adultSizeCm: 4,
    swimLevel: 'Top',
    description:
        'Tiny gourami that makes audible croaking sounds! Iridescent blue eyes. Best in planted nano tanks with calm water.',
    compatibleWith: [
      'Small peaceful fish',
      'Shrimp',
      'Snails',
      'Other nano fish',
    ],
    avoidWith: ['Large fish', 'Strong currents', 'Aggressive tankmates'],
  ),

  // Algae Eaters
  SpeciesInfo(
    commonName: 'Siamese Algae Eater',
    scientificName: 'Crossocheilus oblongus',
    family: 'Cyprinidae',
    careLevel: 'Beginner',
    minTankLitres: 100,
    minTempC: 24,
    maxTempC: 26,
    minPh: 6.5,
    maxPh: 7.5,
    minGh: 5,
    maxGh: 15,
    minSchoolSize: 1,
    temperament: 'Peaceful',
    diet: 'Herbivore/Omnivore — algae, algae wafers, vegetables, some protein',
    adultSizeCm: 15,
    swimLevel: 'Bottom',
    description:
        'The true SAE — excellent at eating black beard algae. Active fish that needs swimming room. May become less algae-focused as it ages.',
    compatibleWith: ['Most community fish', 'Tetras', 'Barbs', 'Corydoras'],
    avoidWith: ['Territorial bottom dwellers', 'Very small tanks'],
  ),

  // More Shrimp
  SpeciesInfo(
    commonName: 'Ghost Shrimp',
    scientificName: 'Palaemonetes paludosus',
    family: 'Palaemonidae',
    careLevel: 'Beginner',
    minTankLitres: 10,
    minTempC: 18,
    maxTempC: 28,
    minPh: 7.0,
    maxPh: 8.0,
    minGh: 5,
    maxGh: 15,
    minSchoolSize: 3,
    temperament: 'Peaceful',
    diet: 'Omnivore/scavenger — detritus, algae, leftover fish food',
    adultSizeCm: 4,
    swimLevel: 'Bottom',
    description:
        'Transparent shrimp — you can see their internal organs! Hardy and inexpensive. Great for beginners and as tank cleaners.',
    compatibleWith: ['Small peaceful fish', 'Other shrimp', 'Snails'],
    avoidWith: ['Medium to large fish that may eat them'],
  ),
  SpeciesInfo(
    commonName: 'Blue Velvet Shrimp',
    scientificName: 'Neocaridina davidi var. blue',
    family: 'Atyidae',
    careLevel: 'Beginner',
    minTankLitres: 10,
    minTempC: 18,
    maxTempC: 28,
    minPh: 6.5,
    maxPh: 8.0,
    minGh: 6,
    maxGh: 20,
    minSchoolSize: 6,
    temperament: 'Peaceful',
    diet: 'Omnivore/detritivore — biofilm, algae, shrimp pellets, vegetables',
    adultSizeCm: 3,
    swimLevel: 'Bottom',
    description:
        'Striking deep blue variety of Neocaridina. Same hardy care as Cherry Shrimp. Breed readily in stable conditions.',
    compatibleWith: ['Small peaceful fish', 'Snails', 'Other dwarf shrimp'],
    avoidWith: ['Any fish large enough to eat them'],
  ),

  // More Snails
  SpeciesInfo(
    commonName: 'Ramshorn Snail',
    scientificName: 'Planorbella duryi',
    family: 'Planorbidae',
    careLevel: 'Beginner',
    minTankLitres: 5,
    minTempC: 18,
    maxTempC: 28,
    minPh: 7.0,
    maxPh: 8.0,
    minGh: 6,
    maxGh: 18,
    minSchoolSize: 1,
    temperament: 'Peaceful',
    diet: 'Omnivore — algae, decaying plant matter, fish food, vegetables',
    adultSizeCm: 2.5,
    swimLevel: 'All',
    description:
        'Flat-coiled shell in red, blue, or brown. Excellent cleaners. Will reproduce readily — control population by limiting food.',
    compatibleWith: ['All peaceful fish', 'Shrimp', 'Other snails'],
    avoidWith: ['Snail-eating fish (loaches, puffers)', 'Assassin snails'],
  ),
  SpeciesInfo(
    commonName: 'Malaysian Trumpet Snail',
    scientificName: 'Melanoides tuberculata',
    family: 'Thiaridae',
    careLevel: 'Beginner',
    minTankLitres: 5,
    minTempC: 18,
    maxTempC: 28,
    minPh: 7.0,
    maxPh: 8.5,
    minGh: 8,
    maxGh: 20,
    minSchoolSize: 1,
    temperament: 'Peaceful',
    diet: 'Detritivore — decaying matter, leftover food, some algae',
    adultSizeCm: 3,
    swimLevel: 'Bottom',
    description:
        'Burrowing snails that aerate substrate and prevent gas pockets. Nocturnal — mostly hidden during day. Reproduce prolifically.',
    compatibleWith: ['All peaceful fish', 'Shrimp', 'Other snails'],
    avoidWith: ['Snail-eating fish', 'Those who dislike snail populations'],
  ),

  // Dwarf Cichlids
  SpeciesInfo(
    commonName: 'Kribensis',
    scientificName: 'Pelvicachromis pulcher',
    family: 'Cichlidae',
    careLevel: 'Beginner',
    minTankLitres: 75,
    minTempC: 24,
    maxTempC: 28,
    minPh: 6.0,
    maxPh: 8.0,
    minGh: 5,
    maxGh: 20,
    minSchoolSize: 1,
    temperament: 'Semi-aggressive',
    diet: 'Omnivore — pellets, flakes, frozen foods',
    adultSizeCm: 10,
    swimLevel: 'Bottom',
    description:
        'Colorful West African dwarf cichlid. Easy to breed — great first cichlid. Territorial when breeding but generally community-safe.',
    compatibleWith: ['Tetras', 'Barbs', 'Corydoras', 'Robust community fish'],
    avoidWith: [
      'Other bottom-dwelling cichlids',
      'Very small fish when breeding',
    ],
  ),
  SpeciesInfo(
    commonName: 'Bolivian Ram',
    scientificName: 'Mikrogeophagus altispinosus',
    family: 'Cichlidae',
    careLevel: 'Beginner',
    minTankLitres: 75,
    minTempC: 22,
    maxTempC: 26,
    minPh: 6.0,
    maxPh: 7.5,
    minGh: 3,
    maxGh: 15,
    minSchoolSize: 1,
    temperament: 'Peaceful',
    diet: 'Omnivore — high-quality pellets, frozen foods',
    adultSizeCm: 8,
    swimLevel: 'Bottom',
    description:
        'Hardier than German Blue Ram, tolerating cooler water and wider parameters. Peaceful dwarf cichlid perfect for community tanks.',
    compatibleWith: [
      'Tetras',
      'Corydoras',
      'Rasboras',
      'Most peaceful community fish',
    ],
    avoidWith: ['Aggressive fish', 'Very small fry'],
  ),

  // More popular fish
  SpeciesInfo(
    commonName: 'Swordtail',
    scientificName: 'Xiphophorus hellerii',
    family: 'Poeciliidae',
    careLevel: 'Beginner',
    minTankLitres: 75,
    minTempC: 22,
    maxTempC: 28,
    minPh: 7.0,
    maxPh: 8.5,
    minGh: 10,
    maxGh: 25,
    minSchoolSize: 3,
    temperament: 'Peaceful',
    diet: 'Omnivore — flakes, pellets, vegetables, algae',
    adultSizeCm: 12,
    swimLevel: 'Middle',
    description:
        'Males have distinctive sword-shaped tail extension. Hardy livebearers that prefer harder, alkaline water. Many color varieties.',
    compatibleWith: ['Platies', 'Mollies', 'Larger tetras', 'Corydoras'],
    avoidWith: ['Aggressive fish', 'Very small fish'],
  ),
  SpeciesInfo(
    commonName: 'Clown Loach',
    scientificName: 'Chromobotia macracanthus',
    family: 'Botiidae',
    careLevel: 'Intermediate',
    minTankLitres: 400,
    minTempC: 25,
    maxTempC: 30,
    minPh: 6.0,
    maxPh: 7.5,
    minGh: 5,
    maxGh: 15,
    minSchoolSize: 5,
    temperament: 'Peaceful',
    diet: 'Omnivore — sinking pellets, frozen foods, snails, vegetables',
    adultSizeCm: 30,
    swimLevel: 'Bottom',
    description:
        'Vibrant orange and black striped loach. Gets VERY large — needs big tank long-term. Excellent snail control. Playful and social.',
    compatibleWith: [
      'Large peaceful fish',
      'Other loaches',
      'Robust community fish',
    ],
    avoidWith: ['Small fish', 'Aggressive cichlids', 'Small tanks'],
  ),
  SpeciesInfo(
    commonName: 'Discus',
    scientificName: 'Symphysodon spp.',
    family: 'Cichlidae',
    careLevel: 'Advanced',
    minTankLitres: 250,
    minTempC: 28,
    maxTempC: 32,
    minPh: 5.5,
    maxPh: 7.0,
    minGh: 1,
    maxGh: 8,
    minSchoolSize: 5,
    temperament: 'Peaceful',
    diet:
        'Omnivore — high-quality pellets, frozen bloodworms, beef heart, vegetables',
    adultSizeCm: 20,
    swimLevel: 'Middle',
    description:
        'The "King of the Aquarium". Stunning disc-shaped cichlids requiring pristine, warm, soft water. High maintenance but incredibly rewarding.',
    compatibleWith: [
      'Cardinal Tetras',
      'Sterbai Corydoras',
      'Rummy Nose Tetras',
    ],
    avoidWith: ['Aggressive fish', 'Coldwater species', 'Poor water quality'],
  ),
];
