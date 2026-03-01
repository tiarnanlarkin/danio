// Shop directory for aquarium supply links.
// All links are affiliate-free unless explicitly marked.

/// A shop entry with categorized links.
class ShopEntry {
  final String name;
  final String? description;
  final String url;
  final String region; // UK, US, EU, Global
  final List<String>
  categories; // Fish, Plants, Equipment, Food, Medication, etc.
  final bool isAffiliate;
  final String? affiliateDisclosure;

  const ShopEntry({
    required this.name,
    this.description,
    required this.url,
    required this.region,
    required this.categories,
    this.isAffiliate = false,
    this.affiliateDisclosure,
  });
}

/// Shop directory organized by region.
class ShopDirectory {
  static const List<ShopEntry> _allShops = [
    // UK Shops
    ShopEntry(
      name: 'Aquarium Gardens',
      description:
          'Specialist in aquascaping plants, hardscape, and CO2 equipment',
      url: 'https://www.aquariumgardens.co.uk',
      region: 'UK',
      categories: ['Plants', 'Hardscape', 'CO2', 'Aquascaping'],
    ),
    ShopEntry(
      name: 'Pro Shrimp UK',
      description: 'Specialist shrimp and invertebrate supplier',
      url: 'https://www.pro-shrimp.co.uk',
      region: 'UK',
      categories: ['Shrimp', 'Invertebrates', 'Plants'],
    ),
    ShopEntry(
      name: 'Horizon Aquatics',
      description: 'Tropical fish, plants, and equipment',
      url: 'https://www.horizonaquatics.co.uk',
      region: 'UK',
      categories: ['Fish', 'Plants', 'Equipment'],
    ),
    ShopEntry(
      name: 'Swallow Aquatics',
      description: 'Large UK aquatics retailer with physical stores',
      url: 'https://www.swallowaquatics.co.uk',
      region: 'UK',
      categories: ['Fish', 'Plants', 'Equipment', 'Food', 'Tanks'],
    ),
    ShopEntry(
      name: 'Maidenhead Aquatics',
      description: 'UK-wide chain with extensive store network',
      url: 'https://www.fishkeeper.co.uk',
      region: 'UK',
      categories: ['Fish', 'Plants', 'Equipment', 'Food', 'Tanks'],
    ),
    ShopEntry(
      name: 'Charterhouse Aquatics',
      description: 'Specialist supplier with rare fish and plants',
      url: 'https://www.charterhouseaquatics.co.uk',
      region: 'UK',
      categories: ['Fish', 'Plants', 'Rare Species'],
    ),
    ShopEntry(
      name: 'Aquacadabra',
      description: 'Online aquatics superstore',
      url: 'https://www.aquacadabra.com',
      region: 'UK',
      categories: ['Equipment', 'Food', 'Medication', 'Tanks'],
    ),

    // US Shops
    ShopEntry(
      name: 'Aquarium Co-Op',
      description: 'Popular retailer known for educational content',
      url: 'https://www.aquariumcoop.com',
      region: 'US',
      categories: ['Fish', 'Plants', 'Equipment', 'Food', 'Medication'],
    ),
    ShopEntry(
      name: 'Buceplant',
      description:
          'Aquascaping specialists - plants, hardscape, tissue cultures',
      url: 'https://buceplant.com',
      region: 'US',
      categories: ['Plants', 'Hardscape', 'Aquascaping', 'Shrimp'],
    ),
    ShopEntry(
      name: 'Flip Aquatics',
      description: 'Shrimp specialists with excellent variety',
      url: 'https://flipaquatics.com',
      region: 'US',
      categories: ['Shrimp', 'Snails', 'Invertebrates'],
    ),
    ShopEntry(
      name: 'Aquatic Arts',
      description: 'Fish, shrimp, snails, and plants',
      url: 'https://aquaticarts.com',
      region: 'US',
      categories: ['Fish', 'Shrimp', 'Snails', 'Plants'],
    ),
    ShopEntry(
      name: 'Dan\'s Fish',
      description: 'Freshwater fish specialists',
      url: 'https://shop.dansfish.com',
      region: 'US',
      categories: ['Fish', 'Food'],
    ),
    ShopEntry(
      name: 'Dustin\'s Fishtanks',
      description: 'Plants and fish with educational focus',
      url: 'https://dustinsfishtanks.com',
      region: 'US',
      categories: ['Plants', 'Fish', 'Equipment'],
    ),

    // EU Shops
    ShopEntry(
      name: 'Aquasabi',
      description: 'German aquascaping specialists',
      url: 'https://www.aquasabi.com',
      region: 'EU',
      categories: ['Plants', 'Hardscape', 'CO2', 'Aquascaping', 'Equipment'],
    ),
    ShopEntry(
      name: 'Tropica',
      description: 'Premium aquarium plants (Danish, ships EU-wide)',
      url: 'https://tropica.com',
      region: 'EU',
      categories: ['Plants', 'Fertilizers'],
    ),

    // Global / Informational
    ShopEntry(
      name: 'Seriously Fish',
      description: 'Fish species database and care guides (not a shop)',
      url: 'https://www.seriouslyfish.com',
      region: 'Global',
      categories: ['Information', 'Species Database'],
    ),
    ShopEntry(
      name: 'Aquarium Wiki',
      description: 'Community fish encyclopedia (not a shop)',
      url: 'https://www.theaquariumwiki.com',
      region: 'Global',
      categories: ['Information', 'Species Database'],
    ),
  ];

  /// Get all shops.
  static List<ShopEntry> get all => _allShops.toList();

  /// Get shops by region.
  static List<ShopEntry> byRegion(String region) {
    return _allShops.where((s) => s.region == region).toList();
  }

  /// Get shops by category.
  static List<ShopEntry> byCategory(String category) {
    return _allShops
        .where(
          (s) => s.categories.any(
            (c) => c.toLowerCase() == category.toLowerCase(),
          ),
        )
        .toList();
  }

  /// Search shops by name or category.
  static List<ShopEntry> search(String query) {
    final lower = query.toLowerCase();
    return _allShops.where((s) {
      return s.name.toLowerCase().contains(lower) ||
          (s.description?.toLowerCase().contains(lower) ?? false) ||
          s.categories.any((c) => c.toLowerCase().contains(lower));
    }).toList();
  }

  /// Get all unique regions.
  static List<String> get regions {
    return _allShops.map((s) => s.region).toSet().toList()..sort();
  }

  /// Get all unique categories.
  static List<String> get categories {
    return _allShops.expand((s) => s.categories).toSet().toList()..sort();
  }
}
