# Task Plan — Danio Windows-native Flutter lock-in

**Started:** 2026-03-18 02:46 GMT
**Goal:** Eliminate accidental WSL Flutter Android builds for Danio and make the Windows-native toolchain the clear, verified default.
**Status:** in_progress

## Phases
- [complete] Phase 1 — Inspect current toolchain/path state
- [complete] Phase 2 — Update project config to Windows-native Flutter/Android SDK paths
- [complete] Phase 3 — Add guardrails/documentation so WSL build use is explicitly blocked
- [in_progress] Phase 4 — Verify Windows-native analyze/build path still works
- [pending] Phase 5 — Record findings and commit workspace memory/docs changes

## Constraints
- Windows repo remains source of truth
- Do not disturb legitimate in-progress Patrol/test work beyond path/tooling cleanup
- Prefer small, reversible config edits

## Errors Encountered
| Error | Attempt | Resolution |
|-------|---------|------------|
| WSL `flutter build apk --debug --no-pub` mixed Linux/Windows plugin path failure | 1 | Clean toolchain paths and stop using WSL Flutter for this repo |
| Windows `bundleRelease` failed in `PackageBundleTask` with `Metaspace` | 1 | Remove restrictive `MaxMetaspaceSize=512m` cap and retry |
