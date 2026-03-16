/// Aquarium domain constants for Danio.
///
/// Centralises aquarium-science thresholds so they're easy to find,
/// update, and reference from any part of the codebase without magic
/// numbers scattered everywhere.
library;

// ────────────────────────────────────────────────────────────────────────────
// Water parameter safe / warning / danger thresholds
// All values are in the standard hobby units: ppm, °C, dGH, dKH, pH units.
// ────────────────────────────────────────────────────────────────────────────

class WaterLimits {
  // Ammonia (NH₃/NH₄⁺) — ppm
  static const double ammoniaSafe = 0.0; // Target: undetectable
  static const double ammoniaWarning = 0.25; // Slightly elevated — investigate
  static const double ammoniaDanger = 0.5; // Toxic — immediate action required

  // Nitrite (NO₂⁻) — ppm
  static const double nitriteSafe = 0.0; // Target: undetectable
  static const double nitriteWarning =
      0.25; // Slightly elevated — watch closely
  static const double nitriteDanger = 0.5; // Toxic — immediate water change

  // Nitrate (NO₃⁻) — ppm
  static const double nitrateIdeal = 20.0; // 0–20: excellent
  static const double nitrateAcceptable = 40.0; // 20–40: fine for most fish
  static const double nitrateWarning = 80.0; // 40–80: perform water change
  // > 80 ppm: danger — large water change needed immediately

  // pH
  static const double phAbsoluteMin = 0.0;
  static const double phAbsoluteMax = 14.0;
  static const double phFreshwaterMin = 6.0; // Soft, acidic floor for most fish
  static const double phFreshwaterMax =
      8.5; // Hard, alkaline ceiling for most fish
  static const double phNeutral = 7.0;

  // Temperature — °C
  static const double tempMinColdwater = 10.0; // Minimum for cold-water species
  static const double tempMaxColdwater = 22.0; // Maximum for cold-water species
  static const double tempMinTropical = 22.0; // Minimum for tropical species
  static const double tempMaxTropical = 30.0; // Maximum for tropical species
  static const double tempAbsoluteMin = 5.0; // Below this = fish emergency
  static const double tempAbsoluteMax = 35.0; // Above this = fish emergency

  // General hardness (GH) — dGH
  static const double ghSoft = 4.0; // < 4: soft water
  static const double ghMedium = 12.0; // 4–12: medium water
  static const double ghHard = 20.0; // > 12: hard water

  // Carbonate hardness / alkalinity (KH) — dKH
  static const double khLow = 3.0; // < 3: pH unstable, risk of crash
  static const double khStable = 6.0; // 3–6: adequate buffering
  static const double khHigh = 12.0; // > 12: very hard / alkaline

  // pH variance tolerance for parameter checks
  static const double phToleranceSlight =
      0.5; // Within ±0.5: slight out-of-range
}

// ────────────────────────────────────────────────────────────────────────────
// Tank size limits
// ────────────────────────────────────────────────────────────────────────────

class TankLimits {
  /// Minimum tank volume considered viable for a fish (litres).
  static const double minViableVolumeLitres = 10.0;

  /// Maximum tank volume the app UI is designed for (litres).
  /// Tanks larger than this will still work, but stocking recommendations
  /// may not be calibrated for nano-pond / public-aquarium scale.
  static const double maxReasonableVolumeLitres = 10000.0;

  /// Maximum number of distinct livestock species the stocking calculator
  /// will consider in a single compatibility check.
  static const int maxStockingSpeciesChecked = 50;

  /// Minimum tank age in days before "nitrogen cycle complete" prompts appear.
  static const int minCyclingDays = 14;

  /// Recommended cycling period in days.
  static const int recommendedCyclingDays = 28;
}

// ────────────────────────────────────────────────────────────────────────────
// Learning / gamification constants
// ────────────────────────────────────────────────────────────────────────────

class LearningLimits {
  /// Maximum number of review cards created per lesson completion.
  static const int maxReviewCardsPerLesson = 5;

  /// Number of weakest lessons returned for the "review now" prompt.
  static const int weakestLessonsCount = 5;

  /// Lesson progress strength below which a lesson is flagged as needing review.
  static const double reviewStrengthThreshold = 50.0;

  /// Maximum transactions to keep in gem history.
  static const int maxGemTransactionHistory = 100;

  /// XP goal presets (points/day) — must be kept in sync with UI.
  static const List<int> dailyXpGoalOptions = [25, 50, 100, 200];

  /// Default daily XP goal for new users.
  static const int defaultDailyXpGoal = 50;
}

// ────────────────────────────────────────────────────────────────────────────
// Maintenance schedule constants
// ────────────────────────────────────────────────────────────────────────────

class MaintenanceLimits {
  /// Recommended water change interval in days for tropical freshwater.
  static const int waterChangeIntervalDays = 7;

  /// Max days since last water change before the health score is penalised.
  static const int waterChangeWarningDays = 10;

  /// Max days since last water change before health score hits zero for that factor.
  static const int waterChangeCriticalDays = 14;

  /// Max days since last log entry before "logging regularity" score drops.
  static const int loggingWarningDays = 7;
  static const int loggingCriticalDays = 14;
}
