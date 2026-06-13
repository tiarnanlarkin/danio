# Design System

Danio is a local-first Flutter aquarium app with a warm illustrated identity:
chibi-proportioned fish, soft rooms, glassmorphism, warm cream/amber/teal
tokens, and playful but readable typography.

## Sources Of Truth

- Art direction: `docs/design-direction.md`.
- Theme tokens: `docs/theme-system.md`.
- Current screenshot plan: `docs/screenshot-plan.md`.
- Accessibility docs: `docs/accessibility-audit.md` and
  `docs/accessibility/`.
- Flutter golden helper: `test/golden_tests/golden_test_helpers.dart`.
- Broad screenshot evidence:
  `docs/qa/screenshots/whole-app-map-2026-05-18/`.

## Codex UI Rules

- Start from a visual target before changing UI: current screenshot, golden
  test, mockup, Figma frame, or existing app surface.
- Use `AppColors`, `AppTypography`, `AppSpacing`, `AppRadius`, and existing
  app widgets rather than raw styling.
- Preserve local-first Smart Hub behavior and calm optional-AI fallback copy.
- Keep care guidance educational and practical; do not imply veterinary advice.
- Use 48dp touch targets, WCAG-aware text colors, reduced-motion support, and
  readable layouts at larger text sizes.
- Avoid fake premium, fake social, fake cloud sync, fake AI success states,
  paid assets, paid Figma features, Figma Code Connect, and cloud visual QA.

## Figma Posture

Figma MCP can be used for reference or no-cost exploration when access permits.
The current setup may only have a View seat, so local screenshots and Flutter
goldens remain the reliable baseline.
