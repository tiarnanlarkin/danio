# 🎨 Assets Directory

This directory contains all visual assets for the Aquarium App.

## Structure

```
assets/
├── animations/          # Lottie JSON animation files
│   └── *.json          # e.g., confetti_celebration.json
│
├── icons/
│   └── badges/         # Achievement badge icons (SVG/PNG)
│       └── *.svg       # e.g., badge_streak_30.svg
│
└── images/
    ├── empty_states/   # Illustrations for empty content states
    ├── onboarding/     # Onboarding flow illustrations
    ├── illustrations/  # General illustrations
    ├── error_states/   # Error/status illustrations
    └── features/       # Feature-specific graphics
```

## File Naming Convention

- **Lowercase with underscores:** `empty_tanks.svg`
- **Include context:** `onboard_slide_1.png`
- **Resolution suffix for PNG:** `icon_fish@2x.png`, `icon_fish@3x.png`

## Supported Formats

| Type | Format | Use Case |
|------|--------|----------|
| Illustrations | SVG | Scalable vector graphics |
| Complex scenes | PNG | Detailed raster images |
| Animations | JSON | Lottie animation files |
| Icons | SVG/PNG | App icons and badges |

## Adding Assets

1. Place file in appropriate subdirectory
2. Update `pubspec.yaml` if adding new directory:
   ```yaml
   flutter:
     assets:
       - assets/images/empty_states/
       - assets/animations/
   ```
3. Run `flutter pub get`
4. Use `AssetImage` or `Lottie.asset` to load

## See Also

- `docs/ui-audit/ASSET_REQUIREMENTS.md` - Full asset manifest and specifications
