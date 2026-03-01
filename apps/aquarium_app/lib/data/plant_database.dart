/// Information about an aquarium plant species.
class PlantInfo {
  final String commonName;
  final String scientificName;
  final String family;
  final String origin;
  final String difficulty; // Easy, Medium, Hard
  final String growthRate; // Slow, Medium, Fast
  final String lightLevel; // Low, Medium, High
  final bool needsCO2;
  final String placement; // Foreground, Midground, Background, Floating
  final double minHeightCm;
  final double maxHeightCm;
  final String propagation;
  final String description;
  final List<String> tips;

  const PlantInfo({
    required this.commonName,
    required this.scientificName,
    required this.family,
    required this.origin,
    required this.difficulty,
    required this.growthRate,
    required this.lightLevel,
    required this.needsCO2,
    required this.placement,
    required this.minHeightCm,
    required this.maxHeightCm,
    required this.propagation,
    required this.description,
    required this.tips,
  });
}

/// Database of common aquarium plants.
class PlantDatabase {
  static const List<PlantInfo> plants = [
    // ============================================================
    // ANUBIAS VARIETIES
    // ============================================================
    PlantInfo(
      commonName: 'Anubias Barteri',
      scientificName: 'Anubias barteri var. barteri',
      family: 'Araceae',
      origin: 'West Africa',
      difficulty: 'Easy',
      growthRate: 'Slow',
      lightLevel: 'Low',
      needsCO2: false,
      placement: 'Midground',
      minHeightCm: 15,
      maxHeightCm: 30,
      propagation: 'Rhizome division',
      description:
          'The standard Anubias variety with broad, dark green leaves. Extremely hardy and perfect for beginners.',
      tips: [
        'Don\'t bury rhizome',
        'Attach to wood or rocks',
        'Very slow growing',
        'Fish won\'t eat it',
      ],
    ),
    PlantInfo(
      commonName: 'Anubias Nana',
      scientificName: 'Anubias barteri var. nana',
      family: 'Araceae',
      origin: 'West Africa',
      difficulty: 'Easy',
      growthRate: 'Slow',
      lightLevel: 'Low',
      needsCO2: false,
      placement: 'Foreground/Midground',
      minHeightCm: 5,
      maxHeightCm: 15,
      propagation: 'Rhizome division',
      description:
          'Compact version of Anubias with smaller leaves. Great for small tanks and foreground placement.',
      tips: [
        'Perfect for nano tanks',
        'Attach to hardscape',
        'Prone to algae in high light',
        'Patient - very slow grower',
      ],
    ),
    PlantInfo(
      commonName: 'Anubias Nana Petite',
      scientificName: 'Anubias barteri var. nana \'Petite\'',
      family: 'Araceae',
      origin: 'West Africa (cultivar)',
      difficulty: 'Easy',
      growthRate: 'Very Slow',
      lightLevel: 'Low',
      needsCO2: false,
      placement: 'Foreground',
      minHeightCm: 2,
      maxHeightCm: 5,
      propagation: 'Rhizome division',
      description:
          'The smallest Anubias variety with tiny leaves. Excellent for nano tanks and creating scale.',
      tips: [
        'Ideal for nano tanks',
        'Super slow growth',
        'Use for detailed aquascaping',
        'Watch for algae on leaves',
      ],
    ),
    PlantInfo(
      commonName: 'Anubias Coffeefolia',
      scientificName: 'Anubias barteri var. coffeefolia',
      family: 'Araceae',
      origin: 'West Africa (cultivar)',
      difficulty: 'Easy',
      growthRate: 'Slow',
      lightLevel: 'Low',
      needsCO2: false,
      placement: 'Midground',
      minHeightCm: 10,
      maxHeightCm: 20,
      propagation: 'Rhizome division',
      description:
          'Distinctive variety with deeply ridged, coffee-plant-like leaves. Unique texture adds interest.',
      tips: [
        'Leaves resemble coffee plant',
        'New leaves emerge reddish',
        'Slower than regular Anubias',
        'Attach to hardscape',
      ],
    ),
    PlantInfo(
      commonName: 'Anubias Hastifolia',
      scientificName: 'Anubias hastifolia',
      family: 'Araceae',
      origin: 'West Africa',
      difficulty: 'Easy',
      growthRate: 'Slow',
      lightLevel: 'Low',
      needsCO2: false,
      placement: 'Background',
      minHeightCm: 20,
      maxHeightCm: 40,
      propagation: 'Rhizome division',
      description:
          'Large Anubias species with arrow-shaped leaves. Makes an impressive background plant.',
      tips: [
        'Largest Anubias variety',
        'Arrow-shaped leaves',
        'Best for larger tanks',
        'Still attach to hardscape',
      ],
    ),

    // ============================================================
    // JAVA FERN VARIETIES
    // ============================================================
    PlantInfo(
      commonName: 'Java Fern',
      scientificName: 'Microsorum pteropus',
      family: 'Polypodiaceae',
      origin: 'Southeast Asia',
      difficulty: 'Easy',
      growthRate: 'Slow',
      lightLevel: 'Low',
      needsCO2: false,
      placement: 'Midground/Background',
      minHeightCm: 15,
      maxHeightCm: 35,
      propagation: 'Rhizome division, plantlets',
      description:
          'Hardy, low-light plant perfect for beginners. Attach to wood or rocks - do not bury the rhizome.',
      tips: [
        'Attach with thread or glue',
        'Don\'t bury rhizome',
        'Grows plantlets on leaves',
        'Tolerates brackish water',
      ],
    ),
    PlantInfo(
      commonName: 'Java Fern Trident',
      scientificName: 'Microsorum pteropus \'Trident\'',
      family: 'Polypodiaceae',
      origin: 'Southeast Asia (cultivar)',
      difficulty: 'Easy',
      growthRate: 'Slow',
      lightLevel: 'Low',
      needsCO2: false,
      placement: 'Midground',
      minHeightCm: 10,
      maxHeightCm: 20,
      propagation: 'Rhizome division, plantlets',
      description:
          'Delicate variety with narrow, fork-tipped leaves resembling a trident. More compact than regular Java Fern.',
      tips: [
        'Finer texture than standard',
        'Great for nano tanks',
        'Attach to hardscape',
        'Produces plantlets on leaves',
      ],
    ),
    PlantInfo(
      commonName: 'Java Fern Windelov',
      scientificName: 'Microsorum pteropus \'Windelov\'',
      family: 'Polypodiaceae',
      origin: 'Southeast Asia (cultivar)',
      difficulty: 'Easy',
      growthRate: 'Slow',
      lightLevel: 'Low',
      needsCO2: false,
      placement: 'Midground',
      minHeightCm: 10,
      maxHeightCm: 20,
      propagation: 'Rhizome division, plantlets',
      description:
          'Beautiful variety with finely branched leaf tips creating a lacy appearance. Named after Tropica founder.',
      tips: [
        'Branched leaf tips',
        'More delicate appearance',
        'Same easy care as regular',
        'Popular aquascaping choice',
      ],
    ),
    PlantInfo(
      commonName: 'Java Fern Narrow Leaf',
      scientificName: 'Microsorum pteropus \'Narrow\'',
      family: 'Polypodiaceae',
      origin: 'Southeast Asia (cultivar)',
      difficulty: 'Easy',
      growthRate: 'Slow',
      lightLevel: 'Low',
      needsCO2: false,
      placement: 'Midground/Background',
      minHeightCm: 15,
      maxHeightCm: 30,
      propagation: 'Rhizome division, plantlets',
      description:
          'Elegant variety with long, narrow leaves that create a graceful, flowing effect.',
      tips: [
        'Slender elegant leaves',
        'Creates flowing effect',
        'Attach to driftwood',
        'Hardy like all Java Ferns',
      ],
    ),
    PlantInfo(
      commonName: 'Java Fern Philippine',
      scientificName: 'Microsorum pteropus \'Philippine\'',
      family: 'Polypodiaceae',
      origin: 'Philippines',
      difficulty: 'Easy',
      growthRate: 'Slow',
      lightLevel: 'Low',
      needsCO2: false,
      placement: 'Midground/Background',
      minHeightCm: 20,
      maxHeightCm: 40,
      propagation: 'Rhizome division, plantlets',
      description:
          'Larger variety with slightly crinkled leaves and interesting texture. Native to the Philippines.',
      tips: [
        'Larger than standard',
        'Crinkled leaf texture',
        'Same easy care',
        'Good for bigger tanks',
      ],
    ),

    // ============================================================
    // AMAZON SWORDS
    // ============================================================
    PlantInfo(
      commonName: 'Amazon Sword',
      scientificName: 'Echinodorus amazonicus',
      family: 'Alismataceae',
      origin: 'South America',
      difficulty: 'Easy',
      growthRate: 'Medium',
      lightLevel: 'Medium',
      needsCO2: false,
      placement: 'Background',
      minHeightCm: 20,
      maxHeightCm: 50,
      propagation: 'Runners, adventitious plants',
      description:
          'Classic centerpiece plant. Grows large with broad leaves. Heavy root feeder.',
      tips: [
        'Use root tabs',
        'Needs nutrient-rich substrate',
        'Can outgrow small tanks',
        'Produces runners',
      ],
    ),
    PlantInfo(
      commonName: 'Amazon Sword Bleheri',
      scientificName: 'Echinodorus bleheri',
      family: 'Alismataceae',
      origin: 'South America',
      difficulty: 'Easy',
      growthRate: 'Medium',
      lightLevel: 'Medium',
      needsCO2: false,
      placement: 'Background',
      minHeightCm: 25,
      maxHeightCm: 60,
      propagation: 'Runners, adventitious plants',
      description:
          'Larger Amazon Sword variety with broader leaves. Classic aquarium centerpiece plant.',
      tips: [
        'Larger than standard Amazon',
        'Heavy root feeder',
        'Use root tabs regularly',
        'Great focal point',
      ],
    ),

    // ============================================================
    // CRYPTOCORYNE VARIETIES
    // ============================================================
    PlantInfo(
      commonName: 'Cryptocoryne Wendtii Green',
      scientificName: 'Cryptocoryne wendtii \'Green\'',
      family: 'Araceae',
      origin: 'Sri Lanka',
      difficulty: 'Easy',
      growthRate: 'Slow',
      lightLevel: 'Low',
      needsCO2: false,
      placement: 'Foreground/Midground',
      minHeightCm: 10,
      maxHeightCm: 20,
      propagation: 'Runners',
      description:
          'Bright green variety of the popular Crypt wendtii. Adds fresh color to low-tech tanks.',
      tips: [
        'Expect initial melt',
        'Leave roots undisturbed',
        'Bright green color',
        'Patient - slow starter',
      ],
    ),
    PlantInfo(
      commonName: 'Cryptocoryne Wendtii Brown',
      scientificName: 'Cryptocoryne wendtii \'Brown\'',
      family: 'Araceae',
      origin: 'Sri Lanka',
      difficulty: 'Easy',
      growthRate: 'Slow',
      lightLevel: 'Low',
      needsCO2: false,
      placement: 'Foreground/Midground',
      minHeightCm: 10,
      maxHeightCm: 25,
      propagation: 'Runners',
      description:
          'Bronze-brown variety with ruffled leaves. Adds warm earth tones to aquascapes.',
      tips: [
        'Bronze-brown coloration',
        'Ruffled leaf edges',
        'Very hardy once established',
        'May melt when first planted',
      ],
    ),
    PlantInfo(
      commonName: 'Cryptocoryne Wendtii Red',
      scientificName: 'Cryptocoryne wendtii \'Red\'',
      family: 'Araceae',
      origin: 'Sri Lanka',
      difficulty: 'Easy',
      growthRate: 'Slow',
      lightLevel: 'Low',
      needsCO2: false,
      placement: 'Foreground/Midground',
      minHeightCm: 10,
      maxHeightCm: 20,
      propagation: 'Runners',
      description:
          'Reddish-brown variety that adds color without high-tech requirements. Great for low-tech red.',
      tips: [
        'Red/brown coloration',
        'Low-tech red plant option',
        'Hardy once established',
        'Classic aquarium choice',
      ],
    ),

    // ============================================================
    // VALLISNERIA VARIETIES
    // ============================================================
    PlantInfo(
      commonName: 'Vallisneria Spiralis',
      scientificName: 'Vallisneria spiralis',
      family: 'Hydrocharitaceae',
      origin: 'Worldwide',
      difficulty: 'Easy',
      growthRate: 'Fast',
      lightLevel: 'Medium',
      needsCO2: false,
      placement: 'Background',
      minHeightCm: 30,
      maxHeightCm: 100,
      propagation: 'Runners',
      description:
          'Classic grass-like plant that creates a flowing background. Spreads quickly via runners.',
      tips: [
        'Trim by cutting leaves, not pulling',
        'Spreads aggressively',
        'Sensitive to Excel/glutaraldehyde',
        'Great for tall tanks',
      ],
    ),
    PlantInfo(
      commonName: 'Jungle Vallisneria',
      scientificName: 'Vallisneria americana var. gigantea',
      family: 'Hydrocharitaceae',
      origin: 'Americas',
      difficulty: 'Easy',
      growthRate: 'Fast',
      lightLevel: 'Medium',
      needsCO2: false,
      placement: 'Background',
      minHeightCm: 50,
      maxHeightCm: 200,
      propagation: 'Runners',
      description:
          'Giant variety with very long, wide leaves. Creates dramatic jungle-like backgrounds.',
      tips: [
        'Can grow very tall',
        'Leaves float at surface',
        'Spreads via runners',
        'Best for large tanks',
      ],
    ),

    // ============================================================
    // STEM PLANTS - ROTALA
    // ============================================================
    PlantInfo(
      commonName: 'Rotala Rotundifolia',
      scientificName: 'Rotala rotundifolia',
      family: 'Lythraceae',
      origin: 'Southeast Asia',
      difficulty: 'Medium',
      growthRate: 'Fast',
      lightLevel: 'Medium-High',
      needsCO2: false,
      placement: 'Background',
      minHeightCm: 15,
      maxHeightCm: 40,
      propagation: 'Cuttings',
      description:
          'Popular stem plant that turns pink/red under high light. Versatile and attractive.',
      tips: [
        'More light = more red',
        'Trim and replant tops',
        'CO2 enhances color',
        'Dense growth with pruning',
      ],
    ),
    PlantInfo(
      commonName: 'Rotala Indica',
      scientificName: 'Rotala indica',
      family: 'Lythraceae',
      origin: 'Southeast Asia',
      difficulty: 'Easy',
      growthRate: 'Medium',
      lightLevel: 'Medium',
      needsCO2: false,
      placement: 'Midground/Background',
      minHeightCm: 15,
      maxHeightCm: 30,
      propagation: 'Cuttings',
      description:
          'Hardy stem plant with rounded leaves. Easier than other Rotalas, good for beginners.',
      tips: [
        'Easier than R. rotundifolia',
        'Rounded leaf shape',
        'Good beginner stem plant',
        'Trim regularly',
      ],
    ),
    PlantInfo(
      commonName: 'Rotala H\'Ra',
      scientificName: 'Rotala rotundifolia \'H\'Ra\'',
      family: 'Lythraceae',
      origin: 'Vietnam',
      difficulty: 'Medium',
      growthRate: 'Medium',
      lightLevel: 'High',
      needsCO2: true,
      placement: 'Midground/Background',
      minHeightCm: 10,
      maxHeightCm: 30,
      propagation: 'Cuttings',
      description:
          'Stunning red/orange variety that develops intense coloration under high light with CO2.',
      tips: [
        'Needs high light for color',
        'CO2 recommended',
        'One of the reddest Rotalas',
        'Iron supplementation helps',
      ],
    ),

    // ============================================================
    // STEM PLANTS - LUDWIGIA
    // ============================================================
    PlantInfo(
      commonName: 'Ludwigia Repens',
      scientificName: 'Ludwigia repens',
      family: 'Onagraceae',
      origin: 'North America',
      difficulty: 'Medium',
      growthRate: 'Medium',
      lightLevel: 'Medium-High',
      needsCO2: false,
      placement: 'Midground/Background',
      minHeightCm: 20,
      maxHeightCm: 50,
      propagation: 'Cuttings',
      description:
          'Red/orange stem plant that adds color. Relatively easy red plant for non-CO2 tanks.',
      tips: [
        'High light for best color',
        'Iron supplementation helps',
        'Trim regularly',
        'Lower leaves may drop',
      ],
    ),
    PlantInfo(
      commonName: 'Ludwigia Palustris',
      scientificName: 'Ludwigia palustris',
      family: 'Onagraceae',
      origin: 'Americas/Europe',
      difficulty: 'Easy',
      growthRate: 'Medium',
      lightLevel: 'Medium',
      needsCO2: false,
      placement: 'Midground/Background',
      minHeightCm: 15,
      maxHeightCm: 40,
      propagation: 'Cuttings',
      description:
          'Hardy Ludwigia with reddish undersides. More adaptable than other Ludwigia species.',
      tips: [
        'Hardy and adaptable',
        'Red undersides to leaves',
        'Good beginner red plant',
        'Trim and replant tops',
      ],
    ),
    PlantInfo(
      commonName: 'Ludwigia Arcuata',
      scientificName: 'Ludwigia arcuata',
      family: 'Onagraceae',
      origin: 'North America',
      difficulty: 'Medium',
      growthRate: 'Medium',
      lightLevel: 'High',
      needsCO2: false,
      placement: 'Midground/Background',
      minHeightCm: 15,
      maxHeightCm: 35,
      propagation: 'Cuttings',
      description:
          'Delicate needle-like leaves that turn orange-red under high light. Fine-textured accent plant.',
      tips: [
        'Needle-like leaves',
        'Fine delicate texture',
        'High light for best color',
        'Nice accent plant',
      ],
    ),

    // ============================================================
    // STEM PLANTS - BACOPA
    // ============================================================
    PlantInfo(
      commonName: 'Bacopa Caroliniana',
      scientificName: 'Bacopa caroliniana',
      family: 'Plantaginaceae',
      origin: 'North America',
      difficulty: 'Easy',
      growthRate: 'Medium',
      lightLevel: 'Medium',
      needsCO2: false,
      placement: 'Midground/Background',
      minHeightCm: 15,
      maxHeightCm: 40,
      propagation: 'Cuttings',
      description:
          'Hardy stem plant with thick, succulent-like leaves. Emits lemon scent when crushed.',
      tips: [
        'Lemon-scented leaves',
        'Very hardy stem plant',
        'Thick succulent leaves',
        'Good for beginners',
      ],
    ),
    PlantInfo(
      commonName: 'Moneywort',
      scientificName: 'Bacopa monnieri',
      family: 'Plantaginaceae',
      origin: 'Worldwide tropics',
      difficulty: 'Easy',
      growthRate: 'Medium',
      lightLevel: 'Medium',
      needsCO2: false,
      placement: 'Midground/Background',
      minHeightCm: 15,
      maxHeightCm: 30,
      propagation: 'Cuttings',
      description:
          'Traditional medicinal plant that adapts well to aquariums. Rounded leaves on upright stems.',
      tips: [
        'Also known as Brahmi',
        'Rounded paired leaves',
        'Hardy and adaptable',
        'Emersed or submerged',
      ],
    ),

    // ============================================================
    // STEM PLANTS - HYGROPHILA
    // ============================================================
    PlantInfo(
      commonName: 'Hygrophila Polysperma',
      scientificName: 'Hygrophila polysperma',
      family: 'Acanthaceae',
      origin: 'Indian subcontinent',
      difficulty: 'Easy',
      growthRate: 'Very Fast',
      lightLevel: 'Low',
      needsCO2: false,
      placement: 'Background',
      minHeightCm: 20,
      maxHeightCm: 50,
      propagation: 'Cuttings',
      description:
          'One of the easiest and fastest-growing stem plants. Great for new tanks and absorbing nitrates.',
      tips: [
        'Extremely fast grower',
        'Great nitrate absorber',
        'Needs frequent trimming',
        'Can become invasive',
      ],
    ),
    PlantInfo(
      commonName: 'Water Wisteria',
      scientificName: 'Hygrophila difformis',
      family: 'Acanthaceae',
      origin: 'Indian subcontinent',
      difficulty: 'Easy',
      growthRate: 'Fast',
      lightLevel: 'Medium',
      needsCO2: false,
      placement: 'Background',
      minHeightCm: 20,
      maxHeightCm: 50,
      propagation: 'Cuttings',
      description:
          'Fast-growing stem plant with lacy leaves. Great for absorbing nitrates.',
      tips: [
        'Trim and replant tops',
        'Leaf shape varies with light',
        'Excellent nitrate absorber',
        'Can float',
      ],
    ),

    // ============================================================
    // CARPETING PLANTS
    // ============================================================
    PlantInfo(
      commonName: 'Monte Carlo',
      scientificName: 'Micranthemum tweediei',
      family: 'Linderniaceae',
      origin: 'Argentina',
      difficulty: 'Medium',
      growthRate: 'Medium',
      lightLevel: 'Medium-High',
      needsCO2: false,
      placement: 'Foreground',
      minHeightCm: 2,
      maxHeightCm: 5,
      propagation: 'Runners',
      description:
          'Easier carpet alternative to HC Cuba. Forms dense, bright green mats.',
      tips: [
        'Easier than HC Cuba',
        'Better without CO2',
        'Spreads via runners',
        'Good beginner carpet',
      ],
    ),
    PlantInfo(
      commonName: 'Dwarf Hairgrass',
      scientificName: 'Eleocharis parvula',
      family: 'Cyperaceae',
      origin: 'Worldwide',
      difficulty: 'Medium',
      growthRate: 'Medium',
      lightLevel: 'Medium-High',
      needsCO2: false,
      placement: 'Foreground',
      minHeightCm: 3,
      maxHeightCm: 10,
      propagation: 'Runners',
      description:
          'Grass-like carpet plant that creates lawn effects. Spreads via runners to form dense mats.',
      tips: [
        'Creates lawn effect',
        'Plant in small clumps',
        'CO2 speeds carpet formation',
        'Trim to encourage density',
      ],
    ),
    PlantInfo(
      commonName: 'Dwarf Baby Tears',
      scientificName: 'Hemianthus callitrichoides',
      family: 'Linderniaceae',
      origin: 'Cuba',
      difficulty: 'Hard',
      growthRate: 'Slow',
      lightLevel: 'High',
      needsCO2: true,
      placement: 'Foreground',
      minHeightCm: 1,
      maxHeightCm: 3,
      propagation: 'Division',
      description:
          'The smallest aquarium plant. Creates stunning carpets but demanding to grow.',
      tips: [
        'Requires CO2 and high light',
        'Needs fine substrate',
        'Dry start method helps',
        'Patience required',
      ],
    ),
    PlantInfo(
      commonName: 'Marsilea Hirsuta',
      scientificName: 'Marsilea hirsuta',
      family: 'Marsileaceae',
      origin: 'Australia',
      difficulty: 'Easy',
      growthRate: 'Medium',
      lightLevel: 'Medium',
      needsCO2: false,
      placement: 'Foreground',
      minHeightCm: 2,
      maxHeightCm: 10,
      propagation: 'Runners',
      description:
          'Four-leaf clover plant that forms low carpets. Leaf shape varies from single to four-lobed.',
      tips: [
        'Clover-like leaves',
        'Easier carpet plant',
        'Leaf shape varies',
        'Good low-tech carpet',
      ],
    ),
    PlantInfo(
      commonName: 'Glossostigma',
      scientificName: 'Glossostigma elatinoides',
      family: 'Phrymaceae',
      origin: 'Australia/New Zealand',
      difficulty: 'Hard',
      growthRate: 'Fast',
      lightLevel: 'High',
      needsCO2: true,
      placement: 'Foreground',
      minHeightCm: 1,
      maxHeightCm: 3,
      propagation: 'Runners',
      description:
          'Classic carpet plant for iwagumi style. Requires high tech setup.',
      tips: [
        'High light prevents vertical growth',
        'CO2 essential',
        'Dense planting needed',
        'Trim regularly',
      ],
    ),

    // ============================================================
    // FLOATING PLANTS
    // ============================================================
    PlantInfo(
      commonName: 'Amazon Frogbit',
      scientificName: 'Limnobium laevigatum',
      family: 'Hydrocharitaceae',
      origin: 'Central/South America',
      difficulty: 'Easy',
      growthRate: 'Fast',
      lightLevel: 'Medium',
      needsCO2: false,
      placement: 'Floating',
      minHeightCm: 1,
      maxHeightCm: 5,
      propagation: 'Runners',
      description:
          'Attractive floating plant with round leaves and long roots. Provides shade and cover.',
      tips: [
        'Keep leaves dry (no splashing)',
        'Long roots provide fry cover',
        'Control spread manually',
        'Nutrient indicator',
      ],
    ),
    PlantInfo(
      commonName: 'Salvinia Minima',
      scientificName: 'Salvinia minima',
      family: 'Salviniaceae',
      origin: 'Americas',
      difficulty: 'Easy',
      growthRate: 'Fast',
      lightLevel: 'Medium',
      needsCO2: false,
      placement: 'Floating',
      minHeightCm: 0.5,
      maxHeightCm: 2,
      propagation: 'Division',
      description:
          'Small floating fern with water-repellent hairy leaves. Fast-growing surface cover.',
      tips: [
        'Tiny hairy leaves',
        'Multiplies quickly',
        'Good nitrate absorber',
        'Control spread regularly',
      ],
    ),
    PlantInfo(
      commonName: 'Red Root Floaters',
      scientificName: 'Phyllanthus fluitans',
      family: 'Phyllanthaceae',
      origin: 'South America',
      difficulty: 'Easy',
      growthRate: 'Fast',
      lightLevel: 'Medium-High',
      needsCO2: false,
      placement: 'Floating',
      minHeightCm: 1,
      maxHeightCm: 3,
      propagation: 'Division',
      description:
          'Beautiful floater with red roots and leaves that turn red under high light.',
      tips: [
        'Red coloration under high light',
        'Attractive red roots',
        'Keep water surface calm',
        'Multiplies quickly',
      ],
    ),
    PlantInfo(
      commonName: 'Duckweed',
      scientificName: 'Lemna minor',
      family: 'Araceae',
      origin: 'Worldwide',
      difficulty: 'Easy',
      growthRate: 'Very Fast',
      lightLevel: 'Low',
      needsCO2: false,
      placement: 'Floating',
      minHeightCm: 0.1,
      maxHeightCm: 0.5,
      propagation: 'Division',
      description:
          'Tiny floating plant that multiplies rapidly. Great nitrate absorber but can take over.',
      tips: [
        'Very hard to remove completely',
        'Blocks light for plants below',
        'Fish love eating it',
        'Good protein source',
      ],
    ),
    PlantInfo(
      commonName: 'Water Lettuce',
      scientificName: 'Pistia stratiotes',
      family: 'Araceae',
      origin: 'Pantropical',
      difficulty: 'Easy',
      growthRate: 'Fast',
      lightLevel: 'Medium-High',
      needsCO2: false,
      placement: 'Floating',
      minHeightCm: 5,
      maxHeightCm: 15,
      propagation: 'Runners',
      description:
          'Large rosette-forming floater with velvety leaves. Long roots provide excellent fry cover.',
      tips: [
        'Needs good light',
        'Long trailing roots',
        'Excellent fry shelter',
        'Can grow quite large',
      ],
    ),

    // ============================================================
    // OTHER EASY PLANTS
    // ============================================================
    PlantInfo(
      commonName: 'Java Moss',
      scientificName: 'Taxiphyllum barbieri',
      family: 'Hypnaceae',
      origin: 'Southeast Asia',
      difficulty: 'Easy',
      growthRate: 'Medium',
      lightLevel: 'Low',
      needsCO2: false,
      placement: 'Foreground/Midground',
      minHeightCm: 2,
      maxHeightCm: 10,
      propagation: 'Division',
      description:
          'Versatile moss that attaches to surfaces. Great for shrimp tanks and breeding setups.',
      tips: [
        'Attach with thread or mesh',
        'Trim regularly',
        'Excellent fry shelter',
        'Can trap debris',
      ],
    ),
    PlantInfo(
      commonName: 'Hornwort',
      scientificName: 'Ceratophyllum demersum',
      family: 'Ceratophyllaceae',
      origin: 'Worldwide',
      difficulty: 'Easy',
      growthRate: 'Fast',
      lightLevel: 'Low',
      needsCO2: false,
      placement: 'Background/Floating',
      minHeightCm: 30,
      maxHeightCm: 300,
      propagation: 'Cuttings',
      description:
          'Hardy, fast-growing plant. Can float or anchor. Excellent for new tanks and fry.',
      tips: [
        'Sheds needles if stressed',
        'Floats or weights down',
        'Allelopathic - may inhibit algae',
        'Cold tolerant',
      ],
    ),
    PlantInfo(
      commonName: 'Dwarf Sagittaria',
      scientificName: 'Sagittaria subulata',
      family: 'Alismataceae',
      origin: 'Americas',
      difficulty: 'Medium',
      growthRate: 'Medium',
      lightLevel: 'Medium',
      needsCO2: false,
      placement: 'Foreground',
      minHeightCm: 5,
      maxHeightCm: 15,
      propagation: 'Runners',
      description:
          'Grass-like carpet plant. Forms dense lawns without CO2 if light is adequate.',
      tips: [
        'Spreads via runners',
        'Height varies with light',
        'Good beginner carpet',
        'Root feeder',
      ],
    ),

    // ============================================================
    // MEDIUM DIFFICULTY PLANTS
    // ============================================================
    PlantInfo(
      commonName: 'Pogostemon Stellatus',
      scientificName: 'Pogostemon stellatus',
      family: 'Lamiaceae',
      origin: 'Southeast Asia',
      difficulty: 'Medium',
      growthRate: 'Fast',
      lightLevel: 'High',
      needsCO2: true,
      placement: 'Background',
      minHeightCm: 20,
      maxHeightCm: 60,
      propagation: 'Cuttings',
      description:
          'Stunning star-shaped leaves in pink/purple. Demanding but rewarding.',
      tips: [
        'Needs CO2 and high light',
        'Heavy nutrient feeder',
        'Trim frequently',
        'Iron brings out color',
      ],
    ),
    PlantInfo(
      commonName: 'Bucephalandra',
      scientificName: 'Bucephalandra sp.',
      family: 'Araceae',
      origin: 'Borneo',
      difficulty: 'Medium',
      growthRate: 'Very Slow',
      lightLevel: 'Low-Medium',
      needsCO2: false,
      placement: 'Foreground/Midground',
      minHeightCm: 3,
      maxHeightCm: 15,
      propagation: 'Rhizome division',
      description:
          'Collector\'s plant with beautiful leaves in many varieties. Attach to hardscape.',
      tips: [
        'Don\'t bury rhizome',
        'Many color varieties',
        'Produces small flowers',
        'Very slow growing',
      ],
    ),
    PlantInfo(
      commonName: 'Red Tiger Lotus',
      scientificName: 'Nymphaea zenkeri',
      family: 'Nymphaeaceae',
      origin: 'West Africa',
      difficulty: 'Medium',
      growthRate: 'Fast',
      lightLevel: 'Medium-High',
      needsCO2: false,
      placement: 'Midground',
      minHeightCm: 20,
      maxHeightCm: 80,
      propagation: 'Bulb division',
      description:
          'Stunning red/purple leaves from a bulb. Will send lily pads to surface if allowed.',
      tips: [
        'Trim lily pad shoots to keep submerged',
        'Grows from bulb',
        'Heavy root feeder',
        'Dramatic focal point',
      ],
    ),

    // ============================================================
    // ADDITIONAL MOSSES
    // ============================================================
    PlantInfo(
      commonName: 'Christmas Moss',
      scientificName: 'Vesicularia montagnei',
      family: 'Hypnaceae',
      origin: 'Southeast Asia',
      difficulty: 'Easy',
      growthRate: 'Slow',
      lightLevel: 'Low',
      needsCO2: false,
      placement: 'Foreground/Midground',
      minHeightCm: 2,
      maxHeightCm: 8,
      propagation: 'Division',
      description:
          'Triangular branching pattern resembles Christmas tree. Great for shrimp and aquascaping.',
      tips: [
        'Christmas tree-like growth',
        'Attach to hardscape',
        'Slower than Java Moss',
        'Excellent for shrimp tanks',
      ],
    ),
    PlantInfo(
      commonName: 'Flame Moss',
      scientificName: 'Taxiphyllum sp. \'Flame\'',
      family: 'Hypnaceae',
      origin: 'Southeast Asia',
      difficulty: 'Easy',
      growthRate: 'Slow',
      lightLevel: 'Low',
      needsCO2: false,
      placement: 'Foreground/Midground',
      minHeightCm: 3,
      maxHeightCm: 10,
      propagation: 'Division',
      description:
          'Unique upward-growing moss that looks like flames. Dramatic vertical texture.',
      tips: [
        'Grows upward like flames',
        'Dramatic visual effect',
        'Attach to vertical surfaces',
        'Slow but steady growth',
      ],
    ),
    PlantInfo(
      commonName: 'Weeping Moss',
      scientificName: 'Vesicularia ferriei',
      family: 'Hypnaceae',
      origin: 'China',
      difficulty: 'Easy',
      growthRate: 'Slow',
      lightLevel: 'Low',
      needsCO2: false,
      placement: 'Midground',
      minHeightCm: 3,
      maxHeightCm: 10,
      propagation: 'Division',
      description:
          'Drooping moss that hangs down like willow branches. Beautiful on driftwood.',
      tips: [
        'Hangs down like willow',
        'Best on elevated hardscape',
        'Creates weeping effect',
        'Low maintenance',
      ],
    ),

    // ============================================================
    // ADDITIONAL STEM PLANTS
    // ============================================================
    PlantInfo(
      commonName: 'Staurogyne Repens',
      scientificName: 'Staurogyne repens',
      family: 'Acanthaceae',
      origin: 'South America',
      difficulty: 'Medium',
      growthRate: 'Slow',
      lightLevel: 'Medium',
      needsCO2: false,
      placement: 'Foreground',
      minHeightCm: 3,
      maxHeightCm: 10,
      propagation: 'Cuttings',
      description:
          'Compact stem plant that stays low. Creates dense foreground bushes.',
      tips: [
        'Stays compact',
        'Good foreground plant',
        'Trim to encourage bushiness',
        'Root feeder',
      ],
    ),
    PlantInfo(
      commonName: 'Limnophila Sessiliflora',
      scientificName: 'Limnophila sessiliflora',
      family: 'Plantaginaceae',
      origin: 'Southeast Asia',
      difficulty: 'Easy',
      growthRate: 'Fast',
      lightLevel: 'Medium',
      needsCO2: false,
      placement: 'Background',
      minHeightCm: 20,
      maxHeightCm: 50,
      propagation: 'Cuttings',
      description:
          'Feathery-leaved stem plant similar to Cabomba but easier. Fast grower.',
      tips: [
        'Feathery delicate leaves',
        'Easier than Cabomba',
        'Fast growing',
        'Great beginner stem plant',
      ],
    ),
    PlantInfo(
      commonName: 'Giant Hygrophila',
      scientificName: 'Hygrophila corymbosa',
      family: 'Acanthaceae',
      origin: 'Southeast Asia',
      difficulty: 'Easy',
      growthRate: 'Fast',
      lightLevel: 'Medium',
      needsCO2: false,
      placement: 'Background',
      minHeightCm: 25,
      maxHeightCm: 60,
      propagation: 'Cuttings',
      description:
          'Large, robust stem plant with broad leaves. Hardy and fast-growing background plant.',
      tips: [
        'Large broad leaves',
        'Very hardy',
        'Fast grower',
        'Good for large tanks',
      ],
    ),

    // ============================================================
    // ADDITIONAL CRYPTS
    // ============================================================
    PlantInfo(
      commonName: 'Cryptocoryne Parva',
      scientificName: 'Cryptocoryne parva',
      family: 'Araceae',
      origin: 'Sri Lanka',
      difficulty: 'Medium',
      growthRate: 'Very Slow',
      lightLevel: 'Medium',
      needsCO2: false,
      placement: 'Foreground',
      minHeightCm: 3,
      maxHeightCm: 6,
      propagation: 'Runners',
      description:
          'The smallest Cryptocoryne species. Forms dense carpets over time but extremely slow.',
      tips: [
        'Smallest crypt species',
        'Very slow growth',
        'Good for nano tanks',
        'Patience required',
      ],
    ),
    PlantInfo(
      commonName: 'Cryptocoryne Lucens',
      scientificName: 'Cryptocoryne lucens',
      family: 'Araceae',
      origin: 'Sri Lanka',
      difficulty: 'Easy',
      growthRate: 'Slow',
      lightLevel: 'Low',
      needsCO2: false,
      placement: 'Foreground/Midground',
      minHeightCm: 8,
      maxHeightCm: 15,
      propagation: 'Runners',
      description:
          'Narrow-leaved Crypt with bright green color. Hardy and attractive.',
      tips: [
        'Narrow bright green leaves',
        'Very hardy',
        'Minimal crypt melt',
        'Good for low-tech tanks',
      ],
    ),

    // ============================================================
    // ADVANCED PLANTS
    // ============================================================
    PlantInfo(
      commonName: 'Scarlet Temple',
      scientificName: 'Alternanthera reineckii',
      family: 'Amaranthaceae',
      origin: 'South America',
      difficulty: 'Medium-Hard',
      growthRate: 'Medium',
      lightLevel: 'High',
      needsCO2: true,
      placement: 'Midground/Background',
      minHeightCm: 15,
      maxHeightCm: 40,
      propagation: 'Cuttings',
      description:
          'Vibrant red/magenta leaves. One of the reddest aquarium plants available.',
      tips: [
        'Needs CO2 and iron',
        'High light essential',
        'Lower leaves may drop',
        'Stunning color payoff',
      ],
    ),
  ];

  /// Search plants by name or characteristics.
  static List<PlantInfo> search(String query) {
    final q = query.toLowerCase();
    return plants
        .where(
          (p) =>
              p.commonName.toLowerCase().contains(q) ||
              p.scientificName.toLowerCase().contains(q) ||
              p.difficulty.toLowerCase().contains(q) ||
              p.placement.toLowerCase().contains(q),
        )
        .toList();
  }

  /// Filter plants by difficulty.
  static List<PlantInfo> byDifficulty(String difficulty) {
    return plants
        .where((p) => p.difficulty.toLowerCase() == difficulty.toLowerCase())
        .toList();
  }

  /// Filter plants suitable for low-tech (no CO2) setups.
  static List<PlantInfo> lowTech() {
    return plants.where((p) => !p.needsCO2).toList();
  }

  /// Filter plants by placement.
  static List<PlantInfo> byPlacement(String placement) {
    return plants
        .where(
          (p) => p.placement.toLowerCase().contains(placement.toLowerCase()),
        )
        .toList();
  }
}
