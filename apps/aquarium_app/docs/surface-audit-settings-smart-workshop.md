# Surface Audit: Settings Hub · Smart Screen · Workshop
**Audited by:** Hephaestus  
**Date:** 2026-03-29  
**Scope:** Settings Hub, all Settings sub-screens, Guides section, Smart Screen (AI Hub), Workshop + all calculators, all modals/dialogs in these areas.  
**Method:** Static code analysis of every screen file, followed every `onTap`/`onPressed`/`Navigator.push`/`showDialog` call, checked all state branches and edge cases.

---

## Legend
| Classification | Meaning |
|---|---|
| ✅ Complete | Works, looks good, nothing to action |
| 🔴 Must Fix | Broken, dead, or dangerous to users |
| 🟠 Should Fix | Clear UX problem or potential crash |
| 🔵 Research First | Ambiguous — need design decision before acting |
| 🟡 Defer | Nice-to-have, not blocking |
| ⛔ Blocked | Can't fix until something else is resolved |
| 🔮 Future Scope | Good idea, out of current scope |

---

## 1. Settings Hub (`settings_hub_screen.dart`)

| Surface | Element | States Checked | Status | Issues | Classification |
|---|---|---|---|---|---|
| Settings Hub | Profile card — Avatar, Name, Level, XP, Streak | Loaded (profile data), Streak=0 hides fire emoji, XP progress bar | ✅ | — | ✅ Complete |
| Settings Hub | Profile card — Edit (pencil) button | Taps navigate to SettingsScreen | ✅ | Tooltip says "Settings" but edit icon implies profile edit — misleading | 🟠 Should Fix |
| Settings Hub | Section header "Shop & Rewards" | Always visible | ✅ | — | ✅ Complete |
| Settings Hub | Shop Street tile | Navigates to `ShopStreetScreen` | ✅ | — | ✅ Complete |
| Settings Hub | Achievements tile | Navigates to `AchievementsScreen` | ✅ | — | ✅ Complete |
| Settings Hub | Section header "Tank Tools" | Always visible | ✅ | — | ✅ Complete |
| Settings Hub | Workshop tile | Navigates to `WorkshopScreen` | ✅ | — | ✅ Complete |
| Settings Hub | Analytics tile | Navigates to `AnalyticsScreen` | ✅ | — | ✅ Complete |
| Settings Hub | Section header "App Settings" | Always visible | ✅ | — | ✅ Complete |
| Settings Hub | Preferences tile | Navigates to `SettingsScreen` | ✅ | — | ✅ Complete |
| Settings Hub | Backup & Restore tile | Navigates to `BackupRestoreScreen`, ConstrainedBox ensures 80px min height | ✅ | — | ✅ Complete |
| Settings Hub | About tile | Navigates to `AboutScreen` | ✅ | — | ✅ Complete |
| Settings Hub | Version footer tap (5x, debug only) | In debug: opens `DebugMenuScreen`; in release: does nothing | ✅ | No-op in release is correct | ✅ Complete |
| Settings Hub | First-visit tooltip | Shows once, dismisses, state persisted via SharedPrefs | ✅ | — | ✅ Complete |
| Settings Hub | Body — loading state | Profile provider loading: level=1, XP=0, streak=0 defaults used — no spinner | 🟠 | No loading skeleton — profile card renders with all-zero fallbacks during load. Looks fine in practice but could flash | 🟡 Defer |
| Settings Hub | Friends section | Code has commented-out `friends_screen.dart` (CA-002) | — | Section is intentionally hidden; no dead tiles shown | ✅ Complete |
| Settings Hub | Leaderboard section | Code has commented-out `leaderboard_screen.dart` (CA-003) | — | Intentionally hidden | ✅ Complete |

---

## 2. Settings Screen (`settings/settings_screen.dart`)

### 2a. Account section

| Surface | Element | States Checked | Status | Issues | Classification |
|---|---|---|---|---|---|
| Settings — Account | "Account & Sync" tile | Navigates to `AccountScreen` | ✅ | — | ✅ Complete |

### 2b. Your Progress section

| Surface | Element | States Checked | Status | Issues | Classification |
|---|---|---|---|---|---|
| Settings — Progress | Learn card | Loaded (stats), null stats (shows "Start your learning journey"), streak freeze shown/hidden | ✅ | — | ✅ Complete |
| Settings — Progress | Learn card tap | Navigates to `LearnScreen` | ✅ | — | ✅ Complete |
| Settings — Progress | Daily Goal tile | Opens drag sheet with 4 goal options | ✅ | — | ✅ Complete |
| Settings — Progress | Daily Goal sheet — 4 options (25/50/100/200 XP) | Each has loading state, success/error feedback, auto-closes | ✅ | — | ✅ Complete |

### 2c. Explore section

| Surface | Element | States Checked | Status | Issues | Classification |
|---|---|---|---|---|---|
| Settings — Explore | RoomNavigation widget | House-navigation tiles | ✅ | Depends on RoomNavigation widget which is out of scope for this audit | ✅ Complete |

### 2d. App Settings section

| Surface | Element | States Checked | Status | Issues | Classification |
|---|---|---|---|---|---|
| Settings — Appearance | Light/Dark Mode tile | Opens picker sheet with System/Light/Dark options; active option has checkmark | ✅ | — | ✅ Complete |
| Settings — Appearance | Room Themes tile | Navigates to `ThemeGalleryScreen` | ✅ | — | ✅ Complete |
| Settings — Appearance | Difficulty Settings tile | Navigates to `DifficultySettingsScreen` (wrapped) | ✅ | — | ✅ Complete |
| Settings — Appearance | Day/Night Ambiance toggle | Reads/writes `settingsProvider.ambientLightingEnabled` | ✅ | — | ✅ Complete |
| Settings — Appearance | Reduce Motion toggle | 3-state logic: system override detection, manual override, contextual footnote | ✅ | — | ✅ Complete |
| Settings — Appearance | Haptic Feedback toggle | Reads/writes `settingsProvider.hapticFeedbackEnabled` | ✅ | — | ✅ Complete |

### 2e. Notifications section

| Surface | Element | States Checked | Status | Issues | Classification |
|---|---|---|---|---|---|
| Settings — Notifications | Streak Reminders tile | Navigates to `NotificationSettingsScreen` | ✅ | — | ✅ Complete |
| Settings — Notifications | Task Reminders toggle | Requests permission on enable, shows snackbar success/error | ✅ | Permission denied path shows warning but doesn't flip toggle back to false — state may be inconsistent | 🟠 Should Fix |
| Settings — Notifications | Test Notification button | Only appears when toggle is on; calls `showTestNotification()` | ✅ | — | ✅ Complete |

### 2f. Smart Hub section

| Surface | Element | States Checked | Status | Issues | Classification |
|---|---|---|---|---|---|
| Settings — Smart Hub | Configure AI tile | Shows key status (active/inactive), opens `_ConfigureAiDialog` | ✅ | — | ✅ Complete |
| Configure AI dialog | OpenAI key field | Obscured by default; toggle show/hide; prefix validation (`sk-`) | ✅ | — | ✅ Complete |
| Configure AI dialog | Save button | Loading state; shows success or error message inline | ✅ | — | ✅ Complete |
| Configure AI dialog | Remove Key button | Destructive, loading state, confirms removal | ✅ | Button only appears when key is set; confirmed via `_hasUserKey` | ✅ Complete |
| Configure AI dialog | Close button | Calls `onDismissed` then pops | ✅ | — | ✅ Complete |

### 2g. Tools & Shop section

| Surface | Element | States Checked | Status | Issues | Classification |
|---|---|---|---|---|---|
| Settings — Tools | Reminders, Fish Wishlist, Compare Tanks, Water Change Calc, Dosing Calc, Unit Converter, Tank Volume Calc, Compatibility Checker, Lighting Schedule, Stocking Calc | All navigate to their respective screens | ✅ | These are **duplicate** entry points — the same tools are in Workshop. Not a bug, but adds settings-screen bloat | 🟡 Defer |
| Settings — Tools | Shop Street tile | Navigates to `ShopStreetScreen` | ✅ | — | ✅ Complete |

### 2h. Guides & Education section

| Surface | Element | States Checked | Status | Issues | Classification |
|---|---|---|---|---|---|
| Settings — Guides | All ExpansionTiles and NavListTiles | See Section 3 (Guides) below | ✅ | — | see §3 |

### 2i. About & Privacy section

| Surface | Element | States Checked | Status | Issues | Classification |
|---|---|---|---|---|---|
| Settings — About | Danio tile (version) | In debug: calls `handleVersionTap`; in release: `onTap: null` (dead) | 🟠 | In release this tile is permanently non-interactive with no visual affordance. It just sits there. Confusing. | 🟠 Should Fix |
| Settings — About | About tile | Opens Flutter's `showAboutDialog` — **not** `AboutScreen` | 🟠 | There are now **two** About entries in this screen (see also Help & Support). The top one opens a generic system dialog; the bottom one navigates to `AboutScreen`. Contradictory UX. | 🔴 Must Fix |
| Settings — About | Analytics & Crash Reports toggle | Loads from SharedPrefs; writes consent; applies `applyAnalyticsConsent()` | ✅ | Shows nothing while loading (`SizedBox.shrink`) — fine | ✅ Complete |
| Settings — Data | Export All Data | Calls `exportData()` — shows loading snackbar, shares JSON file | ✅ | If `aquarium_data.json` doesn't exist: shows "Nothing to export yet" — good empty state | ✅ Complete |
| Settings — Data | Import Data | Shows destructive confirm dialog first; validates JSON schema | ✅ | After import: shows "Restart app to see changes" — **no app restart mechanism**, user must manually close app | 🟠 Should Fix |
| Settings — Data | Photo Storage | Shows dialog with path + count | ✅ | — | ✅ Complete |

### 2j. Help & Support section

| Surface | Element | States Checked | Status | Issues | Classification |
|---|---|---|---|---|---|
| Settings — Help | Replay Onboarding | Resets onboarding, pops to root | ✅ | — | ✅ Complete |
| Settings — Help | Add Sample Tank | Adds demo tank, navigates to its detail | Loaded, error (snackbar) | ✅ | — | ✅ Complete |
| Settings — Help | Backup & Restore tile | Navigates to `BackupRestoreScreen` | ✅ | **Duplicate** — also in About & Privacy section above (and in Hub). Minor | 🟡 Defer |
| Settings — Help | About tile | Navigates to `AboutScreen` | ✅ | **Duplicate** — `About` appears twice in this screen (once in About & Privacy with inline dialog, again here with full screen) | 🔴 Must Fix |

### 2k. Danger Zone section

| Surface | Element | States Checked | Status | Issues | Classification |
|---|---|---|---|---|---|
| Settings — Danger | Clear All Data | Double-confirm destructive dialog, then clears JSON + photos + resets onboarding | ✅ | — | ✅ Complete |
| Settings — Danger | Delete My Data (GDPR) | Single confirm dialog with GDPR email disclosure, clears SharedPrefs + data + resets | ✅ | — | ✅ Complete |
| Settings — Debug | Debug section | Only in kDebugMode | ✅ | — | ✅ Complete |

---

## 3. Account Screen (`account_screen.dart`)

| Surface | Element | States Checked | Status | Issues | Classification |
|---|---|---|---|---|---|
| Account — Not Init | Cloud not configured state | Shows offline-only message with cloud-off icon | ✅ | Good empty/disabled state | ✅ Complete |
| Account — Signed Out | Email field | Validation: empty = error, no @ = error | ✅ | — | ✅ Complete |
| Account — Signed Out | Password field | Validation: empty = error, sign-up < 6 chars | ✅ | — | ✅ Complete |
| Account — Signed Out | Password visibility toggle | Works | ✅ | — | ✅ Complete |
| Account — Signed Out | Sign In / Create Account button | Loading state, disabled during load | ✅ | — | ✅ Complete |
| Account — Signed Out | Toggle sign-in / sign-up | Works, label updates correctly | ✅ | — | ✅ Complete |
| Account — Signed Out | Forgot Password | Validates email first, sends reset email, shows snackbar | ✅ | — | ✅ Complete |
| Account — Signed Out | Continue with Google | Loading state | ✅ | Google Sign-In icon uses `Icons.g_mobiledata` which is a material letter, not the Google logo — looks hacky | 🟠 Should Fix |
| Account — Signed Out | Error message display | `auth.error` shown in red above submit button | ✅ | — | ✅ Complete |
| Account — Signed Out | Back-navigation with unsaved input | `PopScope` triggers destructive confirm dialog | ✅ | — | ✅ Complete |
| Account — Signed In | Profile card (avatar, name, email) | Loaded | ✅ | — | ✅ Complete |
| Account — Signed In | Sync status card | All 5 states: synced, syncing, offline, error, disabled | ✅ | Sync error state shows refresh button with wrong tooltip "Edit profile" | 🟠 Should Fix |
| Account — Signed In | Backup Now | Calls `CloudBackupService`, shows info/success/error snackbars | ✅ | — | ✅ Complete |
| Account — Signed In | Restore from Backup | Confirm dialog first, then calls `CloudBackupService` | ✅ | — | ✅ Complete |
| Account — Signed In | Sign Out button | Confirm dialog, then signs out | ✅ | — | ✅ Complete |

---

## 4. Notification Settings Screen (`notification_settings_screen.dart`)

| Surface | Element | States Checked | Status | Issues | Classification |
|---|---|---|---|---|---|
| Notification Settings | Loading state | BubbleLoader while profile loads | ✅ | — | ✅ Complete |
| Notification Settings | Error state | `AppErrorState` with retry | ✅ | — | ✅ Complete |
| Notification Settings | Profile null state | Shows "No profile found" text | 🟠 | Plain text, no guidance on how to fix — unfriendly | 🟡 Defer |
| Notification Settings | Streak Reminders toggle | Requests permission on enable; success/warning snackbars | ✅ | — | ✅ Complete |
| Notification Settings | Permission denied path | Shows warning snackbar, does **not** update toggle (correct) | ✅ | — | ✅ Complete |
| Notification Settings | Morning / Evening / Night time pickers | Each opens `showTimePicker`, saves, reschedules notifications | ✅ | Times displayed as `${profile.morningReminderTime}` which could be `null` — null-safety is handled with fallback defaults but would render as "null" if backend doesn't initialise | 🔵 Research First |
| Notification Settings | Info section | "How it works" card with emoji bullets | ✅ | — | ✅ Complete |
| Notification Settings | Send Test Notification button | Only shown when reminders enabled; calls service | ✅ | — | ✅ Complete |
| Notification Settings | Additional items when disabled | Returns `SizedBox.shrink()` — no crash | ✅ | — | ✅ Complete |

---

## 5. Difficulty Settings Screen (`difficulty_settings_screen.dart`)

| Surface | Element | States Checked | Status | Issues | Classification |
|---|---|---|---|---|---|
| Difficulty Settings | Overall Skill Card | Shows skill %, difficulty badge | ✅ | — | ✅ Complete |
| Difficulty Settings | Skills by Topic | Cards per topic with progress bar, stats, mastery badge | ✅ | — | ✅ Complete |
| Difficulty Settings | Empty state (no lessons done) | `AppCard` with school icon + "No lessons completed yet" message | ✅ | — | ✅ Complete |
| Difficulty Settings | Performance History | Last 5 attempts with timestamp, difficulty, score | ✅ | — | ✅ Complete |
| Difficulty Settings | Performance History empty state | "Complete lessons to see your performance history" text | ✅ | — | ✅ Complete |
| Difficulty Settings | Manual Override dropdowns | One per topic, each has Auto + all DifficultyLevels | ✅ | — | ✅ Complete |
| Difficulty Settings | AI Recommendations | Shows increase/decrease cards, or "no changes needed" | ✅ | — | ✅ Complete |
| Difficulty Settings | Profile state persistence | `_DifficultySettingsWrapper` in settings screen creates a fresh `UserSkillProfile` each time — **changes are lost on back-navigation** | 🔴 | Override changes are not persisted to any provider or storage | 🔴 Must Fix |

---

## 6. About Screen (`about_screen.dart`)

| Surface | Element | States Checked | Status | Issues | Classification |
|---|---|---|---|---|---|
| About | App icon | Has `errorBuilder` fallback — shows gradient + icon if asset missing | ✅ | — | ✅ Complete |
| About | Version string | Uses `appVersion` from `settings_hub_screen.dart` (build-time env var, default `1.0.0`) | ✅ | `showAboutDialog` in settings_screen.dart hardcodes `'0.1.0 (MVP)'` — inconsistent version strings | 🟠 Should Fix |
| About | Privacy button | Navigates to `PrivacyPolicyScreen` | ✅ | — | ✅ Complete |
| About | Terms button | Navigates to `TermsOfServiceScreen` | ✅ | — | ✅ Complete |
| About | Licenses button | Calls `showLicensePage` — hardcodes `'1.0.0'` | 🟠 | Third version string, still hardcoded | 🟠 Should Fix |
| About | Feature list | Static text items | ✅ | — | ✅ Complete |

---

## 7. Backup & Restore Screen (`backup_restore_screen.dart`)

| Surface | Element | States Checked | Status | Issues | Classification |
|---|---|---|---|---|---|
| Backup & Restore | Export button | Loading state with progress bar+status; disabled when no tanks or exporting | ✅ | — | ✅ Complete |
| Backup & Restore | Tanks loading state | BubbleLoader | ✅ | — | ✅ Complete |
| Backup & Restore | Tanks error state | `AppErrorState` with retry | ✅ | — | ✅ Complete |
| Backup & Restore | Export — 0 tanks (empty) | Button disabled (`tanks.isEmpty`) | ✅ | — | ✅ Complete |
| Backup & Restore | Last backup timestamp | Shows after successful export | ✅ | Not persisted — disappears if user navigates away | 🟡 Defer |
| Backup & Restore | Import button | Loading state with progress bar; opens FilePicker for .zip | ✅ | — | ✅ Complete |
| Backup & Restore | Import — shows tank count preview dialog | ✅ | — | ✅ Complete |
| Backup & Restore | Import — confirms before replacing | ✅ | — | ✅ Complete |
| Backup & Restore | Import — corrupt/invalid file | Catches exception, shows error snackbar | ✅ | — | ✅ Complete |
| Backup & Restore | What Gets Exported list | Static informational, all items marked ✓ | ✅ | — | ✅ Complete |
| Backup & Restore | Import Warning card | Yellow warning card | ✅ | — | ✅ Complete |

---

## 8. Guides Section (via `settings/widgets/guides_section.dart`)

All guide screens are accessed via `ExpansionTile` groups. Each navigates using `NavigationThrottle.push`.

| Surface | Element | States Checked | Status | Issues | Classification |
|---|---|---|---|---|---|
| Essential Guides | Quick Start Guide | Navigates to `QuickStartGuideScreen` | ✅ | — | ✅ Complete |
| Essential Guides | Emergency Guide | Navigates to `EmergencyGuideScreen` | ✅ | — | ✅ Complete |
| Essential Guides | Nitrogen Cycle Guide | Navigates to `NitrogenCycleGuideScreen` | ✅ | — | ✅ Complete |
| Water & Parameters | Water Parameters Guide | Navigates to `ParameterGuideScreen` | ✅ | — | ✅ Complete |
| Water & Parameters | Algae Guide | Navigates to `AlgaeGuideScreen` — static data, searchable list | ✅ | — | ✅ Complete |
| Fish Care | Feeding Guide | Navigates to `FeedingGuideScreen` | ✅ | — | ✅ Complete |
| Fish Care | Fish Disease Guide | Navigates to `DiseaseGuideScreen` — has search + disclaimer banner | ✅ | — | ✅ Complete |
| Fish Care | Acclimation Guide | Navigates to `AcclimationGuideScreen` | ✅ | — | ✅ Complete |
| Fish Care | Quarantine Guide | Navigates to `QuarantineGuideScreen` | ✅ | — | ✅ Complete |
| Fish Care | Breeding Guide | Navigates to `BreedingGuideScreen` | ✅ | — | ✅ Complete |
| Tank Setup | Equipment Guide | Navigates to `EquipmentGuideScreen` | ✅ | — | ✅ Complete |
| Tank Setup | Substrate Guide | Navigates to `SubstrateGuideScreen` | ✅ | — | ✅ Complete |
| Tank Setup | Hardscape Guide | Navigates to `HardscapeGuideScreen` | ✅ | — | ✅ Complete |
| Planning & Travel | Vacation Planning | Navigates to `VacationGuideScreen` | ✅ | — | ✅ Complete |
| Reference | Fish Database | Navigates to `SpeciesBrowserScreen` | ✅ | — | ✅ Complete |
| Reference | Plant Database | Navigates to `PlantBrowserScreen` | ✅ | — | ✅ Complete |
| Reference | Glossary | Navigates to `GlossaryScreen` | ✅ | — | ✅ Complete |
| Reference | FAQ | Navigates to `FaqScreen` | ✅ | — | ✅ Complete |
| Reference | Troubleshooting | Navigates to `TroubleshootingScreen` | ✅ | — | ✅ Complete |
| All guide screens | Back navigation | Standard AppBar back button | ✅ | — | ✅ Complete |
| All guide screens | Empty/error/offline states | All guides are static data — no loading or error states needed | ✅ | — | ✅ Complete |
| Species Browser | Search | Debounced, filters by name/care level/temperament | ✅ | — | ✅ Complete |
| Species Browser | Species detail sheet | Opens bottom sheet with care details | ✅ | — | ✅ Complete |
| Species Browser | Filter chips (care level, temperament) | Works, cache invalidated on filter change | ✅ | — | ✅ Complete |
| Plant Browser | Search | Debounced | ✅ | — | ✅ Complete |
| Plant Browser | Low-tech only toggle | Bool filter | ✅ | — | ✅ Complete |
| Plant Browser | Placement filter | Dropdown | ✅ | — | ✅ Complete |

---

## 9. Smart Screen (`smart_screen.dart`)

### 9a. Main Smart Hub

| Surface | Element | States Checked | Status | Issues | Classification |
|---|---|---|---|---|---|
| Smart Hub | First-visit tooltip | Shows once, dismisses | ✅ | — | ✅ Complete |
| Smart Hub | No API key state (`_OfflineBanner`) | Shows friendly message + notes offline tools available | ✅ | — | ✅ Complete |
| Smart Hub | Online + API key — usage chip | Shows call count | ✅ | — | ✅ Complete |
| Smart Hub | Online + API key — offline chip | `OfflineIndicatorCompact` | ✅ | — | ✅ Complete |
| Smart Hub | Fish & Plant ID card | Disabled (locked icon) with no API key; online check before navigate; offline snackbar | ✅ | — | ✅ Complete |
| Smart Hub | Symptom Checker card | Same guard: API key + online check | ✅ | — | ✅ Complete |
| Smart Hub | Weekly Care Plan card | Same guard | ✅ | — | ✅ Complete |
| Smart Hub | Compatibility Checker (no API key) | Shows `_FeatureCard` navigating to `CompatibilityCheckerScreen` — always works offline | ✅ | — | ✅ Complete |
| Smart Hub | Compatibility Checker widget (with API key) | Shows inline `CompatibilityCheckerWidget` | ✅ | — | ✅ Complete |
| Smart Hub | Ask Danio text field | Only shown with API key; has Send icon button; `onSubmitted` triggers `_askDanio` | ✅ | — | ✅ Complete |
| Smart Hub | Ask Danio — empty submit | `if (question.isEmpty) return` — silently ignores | 🟠 | No user feedback when submitting empty question — field just does nothing | 🟠 Should Fix |
| Smart Hub | Ask Danio — offline | Sets `_askResponse` to offline message | ✅ | — | ✅ Complete |
| Smart Hub | Ask Danio — rate limited | Sets `_askResponse` to rate limited message | ✅ | — | ✅ Complete |
| Smart Hub | Ask Danio — no API key | `if (!openai.isConfigured) return` — silently no-ops | 🟠 | This case can't actually occur (field is hidden without key) but defensive | ✅ Complete |
| Smart Hub | Ask Danio — success | Response in styled container; `SelectableText` for copy | ✅ | — | ✅ Complete |
| Smart Hub | Ask Danio — timeout | Sets error message in response area | ✅ | — | ✅ Complete |
| Smart Hub | Ask Danio — auth error (401/403) | Specific "API key invalid/expired" message | ✅ | — | ✅ Complete |
| Smart Hub | Ask Danio — loading spinner | Replaces Send icon with BubbleLoader | ✅ | — | ✅ Complete |
| Smart Hub | Anomaly History card | Shows count of active anomalies or "All clear" | ✅ | — | ✅ Complete |
| Smart Hub | Anomaly History — tap | Opens scrollable bottom sheet | ✅ | — | ✅ Complete |
| Smart Hub | Anomaly History sheet — empty | Icon + message + "Run Symptom Triage" button | 🔴 | **Dead button**: "Run Symptom Triage" button calls `Navigator.maybePop` but the actual navigation is commented out (`// Navigate to symptom triage`). Pressing it just closes the sheet — no navigation. | 🔴 Must Fix |
| Smart Hub | Anomaly History sheet — with anomalies | List of anomalies with severity icons, parameter, time | ✅ | No dismiss button on anomalies in this view — can only dismiss via water log entry? | 🔵 Research First |
| Smart Hub | Recent AI Activity list | Shows last 10 interactions | ✅ | — | ✅ Complete |
| Smart Hub | Recent AI Activity — empty | Section hidden when `history.isEmpty` | ✅ | — | ✅ Complete |

### 9b. Fish & Plant ID (`features/smart/fish_id/fish_id_screen.dart`)

| Surface | Element | States Checked | Status | Issues | Classification |
|---|---|---|---|---|---|
| Fish ID | Image placeholder | Shows prompt with camera icon | ✅ | — | ✅ Complete |
| Fish ID | Camera button | Picks from camera; max 1024×1024, quality 85 | ✅ | — | ✅ Complete |
| Fish ID | Gallery button | Picks from gallery | ✅ | — | ✅ Complete |
| Fish ID | Image pick error | Sets `_error` state | ✅ | — | ✅ Complete |
| Fish ID | OpenAI disclosure dialog | One-time; persisted in SharedPrefs | ✅ | — | ✅ Complete |
| Fish ID | OpenAI disclosure — cancel | Returns `false`, no identification proceeds | ✅ | — | ✅ Complete |
| Fish ID | Offline state | Sets error message | ✅ | — | ✅ Complete |
| Fish ID | Rate limited | Sets error message | ✅ | — | ✅ Complete |
| Fish ID | API not configured | Sets friendly "coming soon" error | ✅ | — | ✅ Complete |
| Fish ID | Loading state | BubbleLoader + "Analysing image with AI..." | ✅ | — | ✅ Complete |
| Fish ID | Error state | Red error card | ✅ | — | ✅ Complete |
| Fish ID | Timeout | Sets timeout message | ✅ | — | ✅ Complete |
| Fish ID | JSON parse failure | Caught, sets generic error | ✅ | — | ✅ Complete |
| Fish ID | Result card | Common name, scientific name, care level stars, water params, tank mates chips, compatibility notes, care tips | ✅ | — | ✅ Complete |
| Fish ID | Result — low confidence indicator | Shows italic warning | ✅ | — | ✅ Complete |
| Fish ID | Add to My Tank button | Pops with `IdentificationResult` — caller can use to pre-fill livestock | ✅ | No downstream handler in the app currently uses this return value — dead handshake | 🔵 Research First |
| Fish ID | Camera/Gallery buttons after result | Re-shown when result is present | ✅ | — | ✅ Complete |
| Fish ID | AI disclaimer | Shown in result card | ✅ | — | ✅ Complete |

### 9c. Symptom Triage (`features/smart/symptom_triage/symptom_triage_screen.dart`)

| Surface | Element | States Checked | Status | Issues | Classification |
|---|---|---|---|---|---|
| Symptom Triage | Step 1 — Symptom chips | 10 common symptoms as FilterChips; multi-select | ✅ | — | ✅ Complete |
| Symptom Triage | Step 1 — Free text field | Max 500 chars | ✅ | — | ✅ Complete |
| Symptom Triage | Step 1 — Next with empty input | Snackbar "Select at least one symptom" | ✅ | — | ✅ Complete |
| Symptom Triage | Step 2 — Water params | pH, Temp, Ammonia, Nitrite, Nitrate all optional; all have `LengthLimitingTextInputFormatter(500)` | ✅ | Using length limiter on numeric fields rather than numeric formatter — user can type anything (letters) without validation | 🟠 Should Fix |
| Symptom Triage | Step 2 — Get Diagnosis button | Shows OpenAI disclosure if needed, then runs diagnosis | ✅ | — | ✅ Complete |
| Symptom Triage | Stepper Back button | Disabled during streaming (`_streaming`) | ✅ | — | ✅ Complete |
| Symptom Triage | Diagnosis — streaming state | BubbleLoader + "Analysing symptoms..." | ✅ | — | ✅ Complete |
| Symptom Triage | Diagnosis — streaming in progress | Text streams in, "Thinking..." shown | ✅ | — | ✅ Complete |
| Symptom Triage | Diagnosis — offline | Error state shown | ✅ | — | ✅ Complete |
| Symptom Triage | Diagnosis — rate limited | Error state | ✅ | — | ✅ Complete |
| Symptom Triage | Diagnosis — API not configured | Friendly "coming soon" error | ✅ | — | ✅ Complete |
| Symptom Triage | Diagnosis — error state | Red card with "Try Again" button that resets to step 1 | ✅ | — | ✅ Complete |
| Symptom Triage | Save to Journal button | Pops with `_diagnosis` string | 🔴 | **Dead handshake**: pops with diagnosis text but no upstream screen handles the result — nothing is saved to the journal | 🔴 Must Fix |
| Symptom Triage | New Triage button | Resets to step 0, clears all state | ✅ | — | ✅ Complete |
| Symptom Triage | AI disclaimer | Shown after complete diagnosis | ✅ | — | ✅ Complete |
| Symptom Triage | Markdown formatting | Diagnosis uses section headers (## 🔍 etc.) — rendered as plain text in `SelectableText`, not parsed | 🟠 | Markdown headers/bold will render as raw `##` symbols in the UI | 🟠 Should Fix |

### 9d. Weekly Care Plan (`features/smart/weekly_plan/weekly_plan_screen.dart`)

| Surface | Element | States Checked | Status | Issues | Classification |
|---|---|---|---|---|---|
| Weekly Plan | Initial load — generates automatically if no cached plan | ✅ | — | ✅ Complete |
| Weekly Plan | Loading state | BubbleLoader + "Generating your weekly plan..." | ✅ | — | ✅ Complete |
| Weekly Plan | No tanks error | "Add a tank first" message | ✅ | — | ✅ Complete |
| Weekly Plan | Offline error | Error with Retry button | ✅ | — | ✅ Complete |
| Weekly Plan | Rate limited error | Error with Retry button | ✅ | — | ✅ Complete |
| Weekly Plan | API not configured | Friendly "coming soon" error | ✅ | — | ✅ Complete |
| Weekly Plan | Timeout | Error state | ✅ | — | ✅ Complete |
| Weekly Plan | JSON parse failure | Caught, error state | ✅ | — | ✅ Complete |
| Weekly Plan | Empty state (provider null) | "No plan yet — tap generate" with button | ✅ | — | ✅ Complete |
| Weekly Plan | Plan display — day cards | Expandable tiles, Mon auto-expanded | ✅ | — | ✅ Complete |
| Weekly Plan | Plan display — task rows | Task text, duration, priority icon | ✅ | — | ✅ Complete |
| Weekly Plan | Refresh button (AppBar) | Re-runs `_generate()`, shows disclosure if needed | ✅ | — | ✅ Complete |
| Weekly Plan | Regenerate Plan button (footer) | Same as refresh | ✅ | — | ✅ Complete |
| Weekly Plan | Plan generation with livestock | Includes fish list in prompt for context-aware planning | ✅ | — | ✅ Complete |
| Weekly Plan | OpenAI disclosure | One-time; shared key with other AI features | ✅ | — | ✅ Complete |
| Weekly Plan | AI disclaimer (footer) | Shown below plan | ✅ | — | ✅ Complete |

---

## 10. Workshop Screen (`workshop_screen.dart`)

### 10a. Workshop Hub

| Surface | Element | States Checked | Status | Issues | Classification |
|---|---|---|---|---|---|
| Workshop | First-visit snackbar | Shows once via SharedPrefs | ✅ | — | ✅ Complete |
| Workshop | Gradient background (dark/light variants) | ✅ | — | ✅ Complete |
| Workshop | Header — icon + title + subtitle | ✅ | — | ✅ Complete |
| Workshop | Water Change card | Navigates to `WaterChangeCalculatorScreen` | ✅ | — | ✅ Complete |
| Workshop | Stocking card | Navigates to `StockingCalculatorScreen` | ✅ | — | ✅ Complete |
| Workshop | CO₂ Calculator card | Navigates to `Co2CalculatorScreen` | ✅ | — | ✅ Complete |
| Workshop | Dosing card | Navigates to `DosingCalculatorScreen` | ✅ | — | ✅ Complete |
| Workshop | Unit Converter card | Navigates to `UnitConverterScreen` | ✅ | — | ✅ Complete |
| Workshop | Tank Volume card | Navigates to `TankVolumeCalculatorScreen` | ✅ | — | ✅ Complete |
| Workshop | Lighting card | Navigates to `LightingScheduleScreen` | ✅ | — | ✅ Complete |
| Workshop | Compatibility card | Navigates to `CompatibilityCheckerScreen` | ✅ | — | ✅ Complete |
| Workshop | Cost Tracker (full-width bottom card) | Navigates to `CostTrackerScreen` | ✅ | — | ✅ Complete |
| Workshop | Quick Reference section | Static conversion facts, non-interactive | ✅ | — | ✅ Complete |
| Workshop | **Cycling Assistant** | **Not present** in Workshop grid | 🔴 | Task brief lists Cycling Assistant as a Workshop tool. It exists (`cycling_assistant_screen.dart`) but is **only reachable via Tank Detail screen**, not from Workshop. No entry point in Workshop at all. | 🔴 Must Fix |
| Workshop | 2-column grid layout | 8 tools in grid + 1 full-width = 9 tool entries | ✅ | — | ✅ Complete |

### 10b. Water Change Calculator (`water_change_calculator_screen.dart`)

| Surface | Element | States Checked | Status | Issues | Classification |
|---|---|---|---|---|---|
| Water Change Calc | Tank Volume field | Default 100L; digits only | ✅ | — | ✅ Complete |
| Water Change Calc | Current Nitrate field | Default 40; digits only | ✅ | — | ✅ Complete |
| Water Change Calc | Target Nitrate field | Default 20; digits only | ✅ | — | ✅ Complete |
| Water Change Calc | Tap Water Nitrate field | Default 5; digits only | ✅ | — | ✅ Complete |
| Water Change Calc | Zero/null inputs | Returns "Please fill in all fields" | ✅ | — | ✅ Complete |
| Water Change Calc | Tank volume = 0 | "Must be greater than 0" | ✅ | — | ✅ Complete |
| Water Change Calc | Tank volume > 5000 | "Seems too large" message | ✅ | — | ✅ Complete |
| Water Change Calc | Nitrate out of 0–500 range | Validation messages | ✅ | — | ✅ Complete |
| Water Change Calc | Current ≤ Target nitrate | "Already at or below target" — 0% change | ✅ | — | ✅ Complete |
| Water Change Calc | Tap ≥ Target nitrate | RO water recommendation | ✅ | — | ✅ Complete |
| Water Change Calc | Denominator = 0 guard | "Unable to calculate" message | ✅ | — | ✅ Complete |
| Water Change Calc | >50% change recommendation | Suggests splitting changes | ✅ | — | ✅ Complete |
| Water Change Calc | >100% change needed | RO water recommendation, shows 100% cap | ✅ | — | ✅ Complete |
| Water Change Calc | Result card | % change + volume in L, colour-coded | ✅ | — | ✅ Complete |
| Water Change Calc | Input type restriction | `FilteringTextInputFormatter.digitsOnly` — **blocks decimal input** | 🟠 | Can't enter decimal tank volumes (e.g., 112.5L) — digits only | 🟠 Should Fix |
| Water Change Calc | Quick Reference card | Static reference table | ✅ | — | ✅ Complete |
| Water Change Calc | Multi-Change Strategy card | Static tips | ✅ | — | ✅ Complete |

### 10c. Stocking Calculator (`stocking_calculator_screen.dart`)

| Surface | Element | States Checked | Status | Issues | Classification |
|---|---|---|---|---|---|
| Stocking Calc | Tank volume field | Default 100L; digits only | ✅ | Same decimal issue as water change calc | 🟠 Should Fix |
| Stocking Calc | Filter × field | Default 1.0; decimal input allowed | ✅ | No bounds validation — negative value or 0 would give nonsense capacity | 🟠 Should Fix |
| Stocking Calc | Live Plants toggle | Multiplies capacity by 1.2 | ✅ | — | ✅ Complete |
| Stocking Calc | Search field | Debounced (kDebounceDuration); searches SpeciesDatabase | ✅ | — | ✅ Complete |
| Stocking Calc | Search results dropdown | Max 8 results; tapping adds species | ✅ | — | ✅ Complete |
| Stocking Calc | Empty fish list state | "Search and add fish above" placeholder text | ✅ | — | ✅ Complete |
| Stocking Calc | Stock entry — increment/decrement | +/- buttons; removes entry at 0 | ✅ | — | ✅ Complete |
| Stocking Calc | Stocking meter | Coloured progress bar with % and level label | ✅ | — | ✅ Complete |
| Stocking Calc | Overstocked warning | Shows at >100% | ✅ | — | ✅ Complete |
| Stocking Calc | 0L tank volume | `_capacity` = 0, `_stockingPercent` = 0 (guard in getter) | ✅ | — | ✅ Complete |
| Stocking Calc | 0 fish added | Shows placeholder, no result panel | ✅ | — | ✅ Complete |
| Stocking Calc | Bioload multipliers | Named species heuristics (goldfish=2x, shrimp=0.3x, etc.) | ✅ | Simplistic — not a real scientific model, but adequate for a hobby tool | 🟡 Defer |

### 10d. CO₂ Calculator (`co2_calculator_screen.dart`)

| Surface | Element | States Checked | Status | Issues | Classification |
|---|---|---|---|---|---|
| CO₂ Calc | pH field | Default 7.0; decimal allowed | ✅ | — | ✅ Complete |
| CO₂ Calc | KH field | Default 4; decimal allowed | ✅ | — | ✅ Complete |
| CO₂ Calc | pH < 0.1 or > 14 | Validation error shown inline | ✅ | — | ✅ Complete |
| CO₂ Calc | KH ≤ 0 or > 50 | Validation error shown inline | ✅ | — | ✅ Complete |
| CO₂ Calc | Null/empty inputs | `_co2Level = null`, no error shown, result shows dash | ✅ | — | ✅ Complete |
| CO₂ Calc | Result card | ppm value + status label (Too Low/Low/Optimal/High/Dangerous) | ✅ | — | ✅ Complete |
| CO₂ Calc | Extreme high pH (e.g. 14, KH 50) | CO₂ ≈ 0 (very small number) — renders as 0.0 ppm "Too Low" | ✅ | — | ✅ Complete |
| CO₂ Calc | Extreme low pH with high KH | Very high CO₂ (thousands ppm) — shows as "Dangerous" | ✅ | Result can be astronomically large (no cap) — 6.0 pH / 10 KH = 119 ppm shown correctly | ✅ Complete |
| CO₂ Calc | Reference chart | Static table | ✅ | — | ✅ Complete |
| CO₂ Calc | Drop checker guide | ✅ | — | ✅ Complete |
| CO₂ Calc | pH/KH/CO₂ lookup table | Horizontally scrollable DataTable | ✅ | — | ✅ Complete |
| CO₂ Calc | _buildItems called twice | `_buildItems()` is called twice in `build()` (once for count, once for items) — **rebuilds widget tree on every frame** | 🟠 | Minor performance issue — should cache the list | 🟠 Should Fix |

### 10e. Dosing Calculator (`dosing_calculator_screen.dart`)

| Surface | Element | States Checked | Status | Issues | Classification |
|---|---|---|---|---|---|
| Dosing Calc | Tank volume field | Optional initial value from `tankVolumeLitres` param | ✅ | — | ✅ Complete |
| Dosing Calc | Dose per field | Default 1; decimal allowed | ✅ | — | ✅ Complete |
| Dosing Calc | "Per litres" dropdown | 5/10/20/25/40/50/100 options | ✅ | — | ✅ Complete |
| Dosing Calc | Empty/null volume | Shows "Enter your tank volume above" placeholder card | ✅ | — | ✅ Complete |
| Dosing Calc | Negative or zero tank volume | `double.tryParse` will accept "-5" — gives negative dose result | 🟠 | No bounds validation on tank volume or dose amount | 🟠 Should Fix |
| Dosing Calc | Product presets | 5 presets (Seachem Prime, Stability, API Stress Coat, Tropica, Easy Green) — tap to fill | ✅ | — | ✅ Complete |
| Dosing Calc | Result display | Shows total ml + breakdown | ✅ | — | ✅ Complete |
| Dosing Calc | Product presets when no volume | Presets still shown and tappable even without volume entered — may confuse | 🟠 | Product presets should be hidden or disabled until volume is entered | 🟡 Defer |

### 10f. Unit Converter (`unit_converter_screen.dart`)

| Surface | Element | States Checked | Status | Issues | Classification |
|---|---|---|---|---|---|
| Unit Converter | 4 tabs: Volume, Temp, Length, Hardness | Tab navigation | ✅ | — | ✅ Complete |
| Unit Converter — Volume | Input + from-unit dropdown | Converts to all other units on input | ✅ | — | ✅ Complete |
| Unit Converter — Volume | Empty input | Results hidden (`_value != null`) | ✅ | — | ✅ Complete |
| Unit Converter — Volume | Negative value | `FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))` — negatives blocked on volume | ✅ | — | ✅ Complete |
| Unit Converter — Temp | Input + from-unit dropdown | Converts between °C, °F, K | ✅ | — | ✅ Complete |
| Unit Converter — Temp | Negative temp input | Formatter `[\d.\-]` allows negatives for temperature | ✅ | — | ✅ Complete |
| Unit Converter — Temp | Absolute zero (−273.15°C → Kelvin) | Will compute to 0K correctly | ✅ | — | ✅ Complete |
| Unit Converter — Length | Input + from-unit | Converts cm/mm/in/ft/m | ✅ | — | ✅ Complete |
| Unit Converter — Hardness | Input + from-unit | Converts dGH/ppm/mg-L/mmol/gpg | ✅ | — | ✅ Complete |
| Unit Converter — Hardness | Reference card | Shows hardness categories | ✅ | — | ✅ Complete |
| Unit Converter | Large value precision | Truncates to 1 decimal for >100, 2 decimal otherwise | ✅ | — | ✅ Complete |

### 10g. Tank Volume Calculator (`tank_volume_calculator_screen.dart`)

| Surface | Element | States Checked | Status | Issues | Classification |
|---|---|---|---|---|---|
| Tank Volume Calc | Metric/Imperial toggle (ChoiceChip) | Converts dimensions on switch | ✅ | — | ✅ Complete |
| Tank Volume Calc | Shape selector | 5 shapes: Rectangular, Cylindrical, Bow Front, Hexagonal, Corner | ✅ | — | ✅ Complete |
| Tank Volume Calc | Rectangular — Length/Width/Height | All null until entered; result when all filled | ✅ | — | ✅ Complete |
| Tank Volume Calc | Cylindrical — Diameter/Height | ✅ | — | ✅ Complete |
| Tank Volume Calc | Bow Front — Length/Width/Height/Bow Depth | ✅ | — | ✅ Complete |
| Tank Volume Calc | Hexagonal — Side/Height | ✅ | — | ✅ Complete |
| Tank Volume Calc | Corner — Side/Height | ✅ | — | ✅ Complete |
| Tank Volume Calc | Empty / partial inputs | "Enter dimensions above to calculate" placeholder card | ✅ | — | ✅ Complete |
| Tank Volume Calc | Result card | Shows L, US gal, UK gal, usable 90%, weight | ✅ | — | ✅ Complete |
| Tank Volume Calc | Zero or negative dimension | `_volume` will be 0 or negative — shows result as 0.0L | 🟠 | No validation for non-positive dimensions | 🟠 Should Fix |
| Tank Volume Calc | Very large values (10000cm) | Result will be enormous — no cap | 🟡 | No upper bound, but result still technically accurate | 🟡 Defer |
| Tank Volume Calc | Tips card | Static text | ✅ | — | ✅ Complete |

### 10h. Lighting Schedule (`lighting_schedule_screen.dart`)

| Surface | Element | States Checked | Status | Issues | Classification |
|---|---|---|---|---|---|
| Lighting Schedule | Live Plants toggle | Affects recommendation | ✅ | — | ✅ Complete |
| Lighting Schedule | CO2 Injection toggle | Affects recommendation + shows CO2 timing card | ✅ | — | ✅ Complete |
| Lighting Schedule | Algae Issues toggle | Changes recommendation text + warning card | ✅ | — | ✅ Complete |
| Lighting Schedule | Light Intensity segmented button (Low/Med/High) | Updates `_lightIntensity` | 🟠 | `_lightIntensity` is stored but **never used** in any calculation or recommendation — the field is dead | 🔴 Must Fix |
| Lighting Schedule | Lights On time picker | `showTimePicker`, updates `_lightsOn` | ✅ | — | ✅ Complete |
| Lighting Schedule | Lights Off time picker | `showTimePicker`, updates `_lightsOff` | ✅ | — | ✅ Complete |
| Lighting Schedule | Siesta Period toggle | Shows/hides Siesta Start/End pickers | ✅ | — | ✅ Complete |
| Lighting Schedule | Siesta Start/End time pickers | Work correctly | ✅ | — | ✅ Complete |
| Lighting Schedule | Lights On == Lights Off edge case | `totalMinutes = 0` → `_totalLightHours = 0` — shows recommendation as "low for fish" | ✅ | No explicit guard but result is logically coherent | ✅ Complete |
| Lighting Schedule | Siesta > light period | Could give negative `_totalLightHours` | 🟠 | No validation that siesta window fits within light window — negative hours possible | 🟠 Should Fix |
| Lighting Schedule | CO2 timing card | Calculates CO2 on/off as 1hr before lights | 🟠 | If `_lightsOn.hour < 1`, `TimeOfDay(hour: -1, ...)` — negative hour crashes or gives wrong time | 🔴 Must Fix |
| Lighting Schedule | Timeline visualisation | Bar shows light/dark periods across 24h | ✅ | — | ✅ Complete |
| Lighting Schedule | Quick Guide table | Static | ✅ | — | ✅ Complete |

### 10i. Compatibility Checker (`compatibility_checker_screen.dart`)

| Surface | Element | States Checked | Status | Issues | Classification |
|---|---|---|---|---|---|
| Compat Checker | Search field | Debounced; filters SpeciesDatabase | ✅ | — | ✅ Complete |
| Compat Checker | Search results dropdown | Max 10 results; excludes already-selected | ✅ | — | ✅ Complete |
| Compat Checker | Empty state (no fish selected) | Big empty card with fish icon + instruction text | ✅ | — | ✅ Complete |
| Compat Checker | Selected fish chips | Chip + delete icon | ✅ | — | ✅ Complete |
| Compat Checker | 1 fish selected | No compatibility verdict (needs ≥ 2) | ✅ | — | ✅ Complete |
| Compat Checker | 2+ fish selected — bad match | Red "Not Recommended" verdict card | ✅ | — | ✅ Complete |
| Compat Checker | 2+ fish selected — warning | Orange "Proceed with Caution" verdict | ✅ | — | ✅ Complete |
| Compat Checker | 2+ fish selected — good match | Green "Good Match!" | ✅ | — | ✅ Complete |
| Compat Checker | Issues list | Severity icons, reason text | ✅ | — | ✅ Complete |
| Compat Checker | Tank size recommendation | Uses largest user tank for comparison | ✅ | — | ✅ Complete |
| Compat Checker | Recommended setup card | Min tank, temp range, pH range | ✅ | — | ✅ Complete |
| Compat Checker | No temp overlap | Shows "No overlap!" in red | ✅ | — | ✅ Complete |
| Compat Checker | No pH overlap | Shows "No overlap!" in red | ✅ | — | ✅ Complete |
| Compat Checker | No tanks in user data | `tanks?.isNotEmpty` guard — skips tank size check | ✅ | — | ✅ Complete |

### 10j. Cost Tracker (`cost_tracker_screen.dart`)

| Surface | Element | States Checked | Status | Issues | Classification |
|---|---|---|---|---|---|
| Cost Tracker | Empty state | Wallet icon + description + "Add First Expense" button | ✅ | — | ✅ Complete |
| Cost Tracker | FAB "Add Expense" | Opens `_AddExpenseSheet` drag sheet | ✅ | — | ✅ Complete |
| Cost Tracker | Settings icon (AppBar) | Opens settings dialog | ✅ | — | ✅ Complete |
| Cost Tracker | Summary cards | This Month, This Year, All Time | ✅ | — | ✅ Complete |
| Cost Tracker | By Category section | Only shown when expenses exist | ✅ | — | ✅ Complete |
| Cost Tracker | Category bars | Amount + %, progress bar | ✅ | — | ✅ Complete |
| Cost Tracker | Expense tiles | Swipe-to-delete (endToStart) | ✅ | — | ✅ Complete |
| Cost Tracker | Swipe-delete | Shows undo snackbar | ✅ | — | ✅ Complete |
| Cost Tracker | Settings dialog — currency picker | £/$€¥A$C$ | ✅ | — | ✅ Complete |
| Cost Tracker | Settings dialog — Clear All Data | Opens destructive confirm; clears list | ✅ | — | ✅ Complete |
| Cost Tracker | Add Expense sheet — description | Required | ✅ | — | ✅ Complete |
| Cost Tracker | Add Expense sheet — amount | Required; decimal allowed | ✅ | — | ✅ Complete |
| Cost Tracker | Add Expense sheet — amount validation | `if (_descController.text.isEmpty \|\| amount == null)` | ✅ | Amount `0` or negative passes validation — no lower bound check | 🟠 Should Fix |
| Cost Tracker | Add Expense sheet — category dropdown | 9 categories | ✅ | — | ✅ Complete |
| Cost Tracker | Add Expense sheet — date picker | Defaults to today; limited 2020–now | ✅ | — | ✅ Complete |
| Cost Tracker | Persistence | Saved to SharedPrefs as JSON | ✅ | — | ✅ Complete |
| Cost Tracker | Currency auto-detect | Uses `Platform.localeName` → `NumberFormat.simpleCurrency`; fallback '£' | ✅ | — | ✅ Complete |

### 10k. Cycling Assistant (`cycling_assistant_screen.dart`)

*Note: This screen is NOT accessible from Workshop. It's only accessible from Tank Detail. Tracked here per brief.*

| Surface | Element | States Checked | Status | Issues | Classification |
|---|---|---|---|---|---|
| Cycling Assistant | Loading state | BubbleLoader while tank loads | ✅ | — | ✅ Complete |
| Cycling Assistant | Tank not found | Error state (deleted tank) | ✅ | — | ✅ Complete |
| Cycling Assistant | Logs error state | `AppErrorState` with retry | ✅ | — | ✅ Complete |
| Cycling Assistant | No water tests | Phase = `notStarted`, shows "Ready to Start Cycling" | ✅ | — | ✅ Complete |
| Cycling Assistant | Phase 1 (ammonia spike) | Correct phase determination from latest log | ✅ | — | ✅ Complete |
| Cycling Assistant | Phase 2 (nitrite spike) | ✅ | — | ✅ Complete |
| Cycling Assistant | Phase 3 (nearly done) | ✅ | — | ✅ Complete |
| Cycling Assistant | Cycled | Shows celebration card + animation | ✅ | — | ✅ Complete |
| Cycling Assistant | Progress bar + phase dots | Visual progress indicator | ✅ | — | ✅ Complete |
| Cycling Assistant | Parameter timeline (< 2 tests) | Section hidden — no crash | ✅ | — | ✅ Complete |
| Cycling Assistant | Parameter timeline (≥ 2 tests) | Mini chart with NH3/NO2/NO3 lines | ✅ | — | ✅ Complete |
| Cycling Assistant | Educational content per phase | Phase-appropriate text | ✅ | — | ✅ Complete |
| Cycling Assistant | Action items per phase | Checklist with completion state | ✅ | — | ✅ Complete |
| Cycling Assistant | Workshop entry point | **Missing** | 🔴 | Not reachable from Workshop — see §10a | 🔴 Must Fix |

---

## 11. Modals & Dialogs (cross-cutting)

| Surface | Element | States Checked | Status | Issues | Classification |
|---|---|---|---|---|---|
| Clear All Data (double-confirm) | First dialog | Destructive, explicit label "Delete Everything" | ✅ | — | ✅ Complete |
| Clear All Data (double-confirm) | Second dialog | "Are you absolutely sure?" | ✅ | — | ✅ Complete |
| Clear All Data (double-confirm) | Success | Navigates to root | ✅ | — | ✅ Complete |
| Clear All Data (double-confirm) | Error | Error snackbar | ✅ | — | ✅ Complete |
| Delete My Data (GDPR) | Dialog with GDPR email + analytics note | Single confirm | ✅ | — | ✅ Complete |
| Delete My Data (GDPR) | Success | Navigates to root | ✅ | — | ✅ Complete |
| Daily Goal picker sheet | 4 options with loading state | ✅ | — | ✅ Complete |
| Theme picker sheet | System/Light/Dark with check marks | ✅ | — | ✅ Complete |
| Configure AI dialog | Save / Remove Key / Close | Loading states | ✅ | — | ✅ Complete |
| Backup import confirm | Tank count + "will NOT affect existing data" | ✅ | — | ✅ Complete |
| Account screen — unsaved input back | Destructive confirm before pop | ✅ | — | ✅ Complete |
| Anomaly history sheet — empty | "Run Symptom Triage" button is dead | 🔴 | Button closes sheet but doesn't navigate | 🔴 Must Fix |
| Photo Storage info dialog | Path + count | ✅ | — | ✅ Complete |
| Cost Tracker settings dialog | Currency + Clear All | ✅ | — | ✅ Complete |
| Cost Tracker clear confirm | Destructive | ✅ | — | ✅ Complete |
| Fish ID — OpenAI disclosure | One-time, `barrierDismissible: false` | ✅ | — | ✅ Complete |
| Symptom Triage — OpenAI disclosure | Shared key with Fish ID | ✅ | — | ✅ Complete |
| Weekly Plan — OpenAI disclosure | Shared key | ✅ | — | ✅ Complete |
| Sign Out confirm | Preserves local data message | ✅ | — | ✅ Complete |
| Restore backup confirm | Merge behaviour explained | ✅ | — | ✅ Complete |

---

## 12. Summary — Issues by Classification

### 🔴 Must Fix (8 issues)

| # | Area | Issue |
|---|---|---|
| MF-01 | Settings Screen | **Duplicate "About" entries** — one opens generic `showAboutDialog`, one navigates to `AboutScreen`. Contradictory UX — remove one. |
| MF-02 | Smart Hub — Anomaly History | **Dead "Run Symptom Triage" button** — only pops sheet, navigation is commented out. |
| MF-03 | Symptom Triage | **"Save to Journal" is a dead handshake** — pops with diagnosis text but no upstream screen catches the result. Nothing is saved. |
| MF-04 | Difficulty Settings | **Manual override changes are not persisted** — `_DifficultySettingsWrapper` creates a fresh `UserSkillProfile` on every mount — changes to manual overrides are lost immediately on navigation. |
| MF-05 | Workshop | **Cycling Assistant missing from Workshop** — screen exists and is fully functional but has zero entry points from Workshop. |
| MF-06 | Lighting Schedule | **Light Intensity field is dead** — segmented button stores `_lightIntensity` but no calculation or recommendation uses it. |
| MF-07 | Lighting Schedule | **CO2 timing calculation crashes on midnight** — `TimeOfDay(hour: _lightsOn.hour - 1, ...)` gives `hour: -1` when lights on is 00:xx. Flutter's `TimeOfDay` does not validate — will display wrong time or crash. |
| MF-08 | Settings Screen | **Version string inconsistency** — three different strings in the codebase: `appVersion` env var (default `1.0.0`), `showAboutDialog` hardcoded `'0.1.0 (MVP)'`, and `showLicensePage` hardcoded `'1.0.0'`. |

### 🟠 Should Fix (14 issues)

| # | Area | Issue |
|---|---|---|
| SF-01 | Settings Hub | Profile card edit button tooltip says "Settings" but icon implies profile edit — fix tooltip or make it navigate to profile edit. |
| SF-02 | Settings — Notifications | Task Reminders toggle: permission denied does not revert toggle to `false` — UI state mismatch. |
| SF-03 | Account Screen | Sync error card: retry button tooltip says "Edit profile" — wrong copy. |
| SF-04 | Account Screen | Google Sign-In uses `Icons.g_mobiledata` — not the Google logo. Use a proper Google SVG asset. |
| SF-05 | Settings — Data | Import Data: shows "Restart the app to see changes" but provides no restart mechanism or hint on how. |
| SF-06 | Smart Hub — Ask Danio | Empty question submit is silently ignored — add a snackbar or shake the field. |
| SF-07 | Symptom Triage | Water params fields use `LengthLimitingTextInputFormatter(500)` instead of numeric formatter — user can type letters. |
| SF-08 | Symptom Triage | Diagnosis response uses markdown headers (`## 🔍`) rendered as raw text in `SelectableText` — use `flutter_markdown` or strip markdown. |
| SF-09 | Water Change Calculator | All nitrate fields use `digitsOnly` — blocks decimal input (e.g. 7.5 ppm). Change to allow decimals. |
| SF-10 | Stocking Calculator | Tank volume field uses `digitsOnly` — same decimal block as above. |
| SF-11 | Stocking Calculator | Filter × field: no bounds validation — zero or negative value gives nonsensical capacity. Add min=0.1 guard. |
| SF-12 | Dosing Calculator | Tank volume and dose per fields accept negative numbers — add non-negative validation. |
| SF-13 | Tank Volume Calculator | Negative or zero dimension gives negative/zero volume with no error message. |
| SF-14 | Lighting Schedule | Siesta period not validated against light window — siesta wider than light window gives negative `_totalLightHours`. |

### 🔵 Research First (3 issues)

| # | Area | Issue |
|---|---|---|
| RF-01 | Notification Settings | `profile.morningReminderTime` et al could display as "null" if not initialised — verify backend always sets defaults. |
| RF-02 | Smart Hub — Anomaly History | No way to dismiss individual anomalies from the Smart screen sheet — only via water log entry? Confirm intended flow. |
| RF-03 | Fish ID | "Add to My Tank" pops with `IdentificationResult` but no upstream screen handles the return value — decide if this should pre-fill the Add Livestock flow. |

### 🟡 Defer (5 issues)

| # | Area | Issue |
|---|---|---|
| D-01 | Settings Hub | Profile card has no loading skeleton — renders with fallback zeros during load. Minor flash only. |
| D-02 | Settings Screen | Tools section duplicates all Workshop entry points — not wrong, just bloat. |
| D-03 | Backup & Restore | Last backup timestamp not persisted across navigation. |
| D-04 | Stocking Calculator | Bioload multipliers are simplistic heuristics, not a rigorous model. Acceptable for MVP. |
| D-05 | Dosing Calculator | Product presets shown even before tank volume is entered — minor UX friction. |

### ✅ Everything Else

All remaining surfaces — guide screens, Fish Disease Guide search, Species Browser filters, Plant Browser filters, Compatibility Checker full logic, CO₂ table, Unit Converter all tabs, Tank Volume all shapes, Cost Tracker expense/delete/undo, Weekly Plan generation/caching, Fish ID full flow including disclosures and confidence indicators, Account Screen all auth states — are **complete and functional** based on static analysis.

---

## 13. Navigation Connectivity Map

```
More Tab (SettingsHubScreen)
├── SettingsScreen (Preferences tile + Edit button)
│   ├── AccountScreen
│   ├── LearnScreen (Learn card)
│   ├── DailyGoalPickerSheet (inline)
│   ├── ThemeGalleryScreen
│   ├── DifficultySettingsScreen
│   ├── NotificationSettingsScreen
│   ├── _ConfigureAiDialog (inline)
│   ├── All 10 Workshop tools (duplicated from Workshop)
│   ├── All 19 guide screens (via GuidesSection)
│   ├── BackupRestoreScreen (×2 — About & Privacy + Help sections)
│   ├── AboutScreen (×2 — inline showAboutDialog + AboutScreen push)
│   └── [Danger Zone] — no navigation, local action
├── ShopStreetScreen
├── AchievementsScreen
├── WorkshopScreen
│   ├── WaterChangeCalculatorScreen
│   ├── StockingCalculatorScreen
│   ├── Co2CalculatorScreen
│   ├── DosingCalculatorScreen
│   ├── UnitConverterScreen
│   ├── TankVolumeCalculatorScreen
│   ├── LightingScheduleScreen
│   ├── CompatibilityCheckerScreen
│   └── CostTrackerScreen
│   ✗ CyclingAssistantScreen [MISSING - only via TankDetailScreen]
├── AnalyticsScreen
├── AboutScreen
└── BackupRestoreScreen

Smart Tab (SmartScreen)
├── FishIdScreen [requires API key + online]
├── SymptomTriageScreen [requires API key + online]
├── WeeklyPlanScreen [requires API key + online]
├── CompatibilityCheckerScreen [always available]
├── AnomalyHistorySheet (inline bottom sheet)
│   └── ✗ SymptomTriageScreen [dead button - not navigating]
└── [Ask Danio] — inline AI chat
```

---

*End of audit. Total surfaces reviewed: 76. Total issues found: 30 (8 Must Fix, 14 Should Fix, 3 Research First, 5 Defer).*
