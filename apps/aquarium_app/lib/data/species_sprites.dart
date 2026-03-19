/// Maps species common names to fish sprite asset paths.
///
/// Provides a lookup from a species' [commonName] (as stored in
/// [SpeciesInfo]) to the corresponding sprite file under
/// `assets/images/fish/`.
///
/// Usage:
/// ```dart
/// final path = SpeciesSprites.pathFor('Neon Tetra'); // → 'assets/images/fish/neon_tetra.png'
/// ```
library;

class SpeciesSprites {
  SpeciesSprites._();

  /// Common name → asset file name mapping.
  /// Keys are lower-cased common names from [SpeciesInfo].
  static const _map = <String, String>{
    'amano shrimp': 'assets/images/fish/amano_shrimp.png',
    'angelfish': 'assets/images/fish/angelfish.png',
    'betta': 'assets/images/fish/betta.png',
    'bristlenose pleco': 'assets/images/fish/bristlenose_pleco.png',
    'bronze corydoras': 'assets/images/fish/bronze_corydoras.png',
    'cherry barb': 'assets/images/fish/cherry_barb.png',
    'cherry shrimp': 'assets/images/fish/cherry_shrimp.png',
    'guppy': 'assets/images/fish/guppy.png',
    'harlequin rasbora': 'assets/images/fish/harlequin_rasbora.png',
    'molly': 'assets/images/fish/molly.png',
    'neon tetra': 'assets/images/fish/neon_tetra.png',
    'nerite snail': 'assets/images/fish/nerite_snail.png',
    'otocinclus': 'assets/images/fish/otocinclus.png',
    'platy': 'assets/images/fish/platy.png',
    'zebra danio': 'assets/images/fish/zebra_danio.png',
  };

  /// Thumbnail path mapping (128×128 versions).
  static const _thumbMap = <String, String>{
    'amano shrimp': 'assets/images/fish/thumb/amano_shrimp.png',
    'angelfish': 'assets/images/fish/thumb/angelfish.png',
    'betta': 'assets/images/fish/thumb/betta.png',
    'bristlenose pleco': 'assets/images/fish/thumb/bristlenose_pleco.png',
    'bronze corydoras': 'assets/images/fish/thumb/bronze_corydoras.png',
    'cherry barb': 'assets/images/fish/thumb/cherry_barb.png',
    'cherry shrimp': 'assets/images/fish/thumb/cherry_shrimp.png',
    'guppy': 'assets/images/fish/thumb/guppy.png',
    'harlequin rasbora': 'assets/images/fish/thumb/harlequin_rasbora.png',
    'molly': 'assets/images/fish/thumb/molly.png',
    'neon tetra': 'assets/images/fish/thumb/neon_tetra.png',
    'nerite snail': 'assets/images/fish/thumb/nerite_snail.png',
    'otocinclus': 'assets/images/fish/thumb/otocinclus.png',
    'platy': 'assets/images/fish/thumb/platy.png',
    'zebra danio': 'assets/images/fish/thumb/zebra_danio.png',
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
