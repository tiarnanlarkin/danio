# Visual QA Checklist

Use this checklist for Danio UI, illustration, chart, screenshot, or polish
work.

## Before Editing

- Run `git status --short`.
- Identify the visual target: screenshot, Flutter golden, mockup, Figma frame,
  or existing app surface.
- Read `docs/design/DESIGN_SYSTEM.md`, `docs/design-direction.md`, and the
  relevant row in `docs/design/BASELINES.md`.
- Confirm whether paid services, paid assets, cloud visual testing, Figma Code
  Connect, paid Figma features, OpenAI API calls, or external accounts are
  needed. If yes, use `docs/agent/PAID_TOOL_APPROVAL_LEDGER.md` before the
  tool is configured or run.

## During Implementation

- Use the app theme tokens and existing component patterns.
- Keep Smart Hub locally useful without AI and keep optional AI absence calm.
- Keep care guidance educational and not a professional/veterinary substitute.
- Preserve touch targets, contrast, reduced-motion behavior, and responsive
  layout at larger text sizes.

## Verification

- Run the smallest focused Flutter test first.
- For widget-level visual changes, run the relevant golden test.
- For broad UI changes, run:

```powershell
flutter test
flutter analyze
flutter build apk --debug --target lib/main.dart
git diff --check
```

- Capture local screenshots only when emulator/device ownership is clear.
- Review screenshots for clipped text, overlap, unreadable contrast, broken
  glassmorphism, misleading AI/premium/cloud states, and unsafe care claims.

## Completion Note

Record the target, changed surfaces, commands run, screenshot/golden evidence,
and any skipped emulator evidence in the active QA or agent docs.
