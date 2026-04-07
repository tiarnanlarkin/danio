/// Setup mode for the tank creation flow.
///
/// Selected via [SetupPathSelector] on the empty-tank scene.
/// Controls whether [CreateTankScreen] shows the full 3-page guided
/// wizard or collapses to a single expert form.
enum SetupMode {
  /// Multi-page wizard with progress indicator, hints, and dimension
  /// inputs. Default for new users via the empty-tank flow and for all
  /// other entry points (tank log board, "add tank" buttons).
  guided,

  /// Single-form shortcut for experienced hobbyists.
  ///
  /// Asks only for name, volume, and water type. Tank type defaults to
  /// freshwater, dimensions are left empty, and the start date defaults
  /// to today. Expert users can edit anything later via tank settings.
  expert,
}
