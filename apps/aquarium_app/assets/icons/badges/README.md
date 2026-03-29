# Badge Assets

This directory holds badge icon images for the Danio app.

## Required Badge Icons

The following badges are defined in `lib/data/shop_catalog.dart` and referenced throughout the app.
Each badge should be a **square PNG or WebP**, recommended size **256×256px** (or 512×512 for high-DPI).

### Profile Badges (ShopItemType.profileBadge)

| Badge ID                  | Name                    | Emoji | Description                                       | Visual Suggestion                                              |
|---------------------------|-------------------------|-------|---------------------------------------------------|----------------------------------------------------------------|
| `badge_early_bird`        | Early Bird Badge        | 🐦    | Show off your dedication with this special badge  | A golden bird/robin perched on a sunrise branch               |
| `badge_night_owl`         | Night Owl Badge         | 🦉    | For the late-night learners                       | An owl on a moonlit branch, dark blue palette                 |
| `badge_perfectionist`     | Perfectionist Badge     | 💯    | For those who ace every quiz                      | A gold 100 score mark with sparkles                           |
| `legendary_badge_display` | Legendary Badge Display | 🏅    | Exclusive showcase for achievements               | A premium gold medal/trophy with ornate border                |

### Achievement / Milestone Badges

These are referenced in `lib/screens/achievements_screen.dart` and `lib/screens/onboarding/xp_celebration_screen.dart`:

| Badge ID / Context        | Description                                        | Visual Suggestion                                              |
|---------------------------|----------------------------------------------------|----------------------------------------------------------------|
| XP Celebration badge      | Shown on completing onboarding/lesson milestones   | Animated star-burst with Danio fish silhouette                |
| Learning streak badge     | Shown on learn screen for streak tracking          | Flame icon with day counter (see `lib/widgets/learning_streak_badge.dart`) |

## File Naming Convention

```
assets/icons/badges/<badge_id>.png   (or .webp)
```

Examples:
- `assets/icons/badges/badge_early_bird.png`
- `assets/icons/badges/badge_night_owl.png`
- `assets/icons/badges/badge_perfectionist.png`
- `assets/icons/badges/legendary_badge_display.png`

## Style Guide

- **Colour palette:** Warm amber/teal tones consistent with the app theme
- **Border:** Subtle rounded square frame (squircle) or circular medal shape
- **Background:** Transparent (alpha channel preserved)
- **Format:** PNG with transparency preferred; WebP accepted
- **Size:** 256×256px minimum; 512×512px recommended for retina

## Status

🚧 **All badge icons are pending.** Only `.gitkeep` existed in this directory prior to Wave 4.
These assets need to be designed and generated in a future art wave.
