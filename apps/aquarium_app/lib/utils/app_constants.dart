/// App-wide named constants to replace magic numbers.
/// Import this file anywhere you need these values.
library;

// ---------------------------------------------------------------------------
// Duration constants
// ---------------------------------------------------------------------------

/// Standard debounce delay for search fields.
const kDebounceDuration = Duration(milliseconds: 300);

/// Delay before revealing the correct quiz answer.
const kQuizRevealDelay = Duration(milliseconds: 1200);

/// Duration for SnackBars with undo actions. Must exceed the soft-delete
/// timer (5s) so the SnackBar is still visible when the timer fires.
const kSnackbarDuration = Duration(seconds: 6);
const kSoftDeleteDelay = Duration(seconds: 5);

/// Toast / snack duration for transient (no-action) messages.
const kToastDuration = Duration(seconds: 2);

/// Duration for equipment-related snackbars (longer read time).
const kEquipmentSnackDuration = Duration(seconds: 5);

/// Celebration auto-dismiss duration.
const kCelebrationDuration = Duration(seconds: 3);

// ---------------------------------------------------------------------------
// Input-limit constants
// ---------------------------------------------------------------------------

/// Maximum characters for a tank name.
const kTankNameMaxLength = 50;

/// Maximum characters for notes / feedback fields.
const kNotesMaxLength = 200;

// ---------------------------------------------------------------------------
// Layout constants
// ---------------------------------------------------------------------------

const kScrollEndPadding = 100.0;

// ---------------------------------------------------------------------------
// Avatar size constants
// ---------------------------------------------------------------------------

const kAvatarSizeLg = 40.0;
const kAvatarSizeMd = 32.0;
const kAvatarSizeSm = 24.0;
