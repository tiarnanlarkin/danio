/// Maps species common names to fish sprite asset paths.
///
/// Provides a lookup from a species' [commonName] (as stored in
/// [SpeciesInfo]) to the corresponding sprite file under
/// `assets/images/fish/`.
///
/// Usage:
/// ```dart
/// final path = SpeciesSprites.pathFor('Neon Tetra'); // → 'assets/images/fish/neon_tetra.webp'
/// ```
library;

class SpeciesSprites {
  SpeciesSprites._();

  /// Common name → asset file name mapping.
  /// Keys are lower-cased common names from [SpeciesInfo].
  static const _map = <String, String>{
    'amano shrimp': 'assets/images/fish/amano_shrimp.webp',
    'angelfish': 'assets/images/fish/angelfish.webp',
    'betta': 'assets/images/fish/betta.webp',
    'bristlenose pleco': 'assets/images/fish/bristlenose_pleco.webp',
    'bronze corydoras': 'assets/images/fish/bronze_corydoras.webp',
    'cherry barb': 'assets/images/fish/cherry_barb.webp',
    'cherry shrimp': 'assets/images/fish/cherry_shrimp.webp',
    'guppy': 'assets/images/fish/guppy.webp',
    'harlequin rasbora': 'assets/images/fish/harlequin_rasbora.webp',
    'molly': 'assets/images/fish/molly.webp',
    'neon tetra': 'assets/images/fish/neon_tetra.webp',
    'nerite snail': 'assets/images/fish/nerite_snail.webp',
    'otocinclus': 'assets/images/fish/otocinclus.webp',
    'platy': 'assets/images/fish/platy.webp',
    'zebra danio': 'assets/images/fish/zebra_danio.webp',
  };

  /// Thumbnail path mapping (128×128 versions).
  static const _thumbMap = <String, String>{
    'amano shrimp': 'assets/images/fish/thumb/amano_shrimp.webp',
    'angelfish': 'assets/images/fish/thumb/angelfish.webp',
    'betta': 'assets/images/fish/thumb/betta.webp',
    'bristlenose pleco': 'assets/images/fish/thumb/bristlenose_pleco.webp',
    'bronze corydoras': 'assets/images/fish/thumb/bronze_corydoras.webp',
    'cherry barb': 'assets/images/fish/thumb/cherry_barb.webp',
    'cherry shrimp': 'assets/images/fish/thumb/cherry_shrimp.webp',
    'guppy': 'assets/images/fish/thumb/guppy.webp',
    'harlequin rasbora': 'assets/images/fish/thumb/harlequin_rasbora.webp',
    'molly': 'assets/images/fish/thumb/molly.webp',
    'neon tetra': 'assets/images/fish/thumb/neon_tetra.webp',
    'nerite snail': 'assets/images/fish/thumb/nerite_snail.webp',
    'otocinclus': 'assets/images/fish/thumb/otocinclus.webp',
    'platy': 'assets/images/fish/thumb/platy.webp',
    'zebra danio': 'assets/images/fish/thumb/zebra_danio.webp',
  };

  /// Returns the full-resolution sprite path for the given common name,
  /// or `null` if no sprite exists for that species.
  static String? pathFor(String commonName) =>
      _map[commonName.toLowerCase()];

  /// Returns the thumbnail sprite path for the given common name,
  /// or `null` if no sprite exists for that species.
  static String? thumbFor(String commonName) =>
      _thumbMap[commonName.toLowerCase()];

  /// Whether a sprite exists for the given common name.
  static bool hasSprite(String commonName) =>
      _map.containsKey(commonName.toLowerCase());
}
