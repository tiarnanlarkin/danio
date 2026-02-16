# 🚀 Launch Night Verification Plan
**Date:** 2026-02-16  
**Goal:** Bulletproof app ready to build & ship tomorrow morning  
**Timeline:** Overnight automation (6-8h)

## Mission Statement
Final verification & quick wins only. NO risky changes. App is already launch-ready (B+ grade) - we're just making sure nothing breaks and catching obvious improvements.

## Phase 1: Pre-Launch QA (~3-4h)
**Goal:** Full app flow verification, edge case testing

### Agent 1: Core Flow Testing
**Task:** Test critical user journeys end-to-end
- Fresh install → onboarding → main app
- Add tank → add livestock → log parameters
- Browse learn section → complete quiz
- Check settings → test all toggles
- **Deliverable:** QA report with any P0 bugs found

### Agent 2: Edge Case Sweep
**Task:** Stress test edge cases
- Empty states (no tanks, no livestock, no logs)
- Error handling (invalid inputs, network failures if applicable)
- Boundary values (max tanks, max livestock, extreme parameters)
- Long text inputs (names, notes)
- **Deliverable:** Edge case report + fixes if needed

### Agent 3: Visual Polish Scan
**Task:** UI consistency check
- Screenshot every major screen
- Check for alignment issues, spacing inconsistencies
- Verify all buttons/cards use AppCard/AppButton where possible
- Check color usage (no obvious hardcoded colors on white backgrounds)
- **Deliverable:** Visual audit + quick fixes for obvious issues

## Phase 2: Build Verification (~1-2h)
**Goal:** Ensure release build config is perfect

### Agent 4: Release Config Check
**Task:** Verify all release settings
- ✅ android/app/build.gradle (release signing config)
- ✅ AndroidManifest.xml (permissions, app name, version)
- ✅ pubspec.yaml (version number, dependencies)
- ✅ No debug code left in release build
- ✅ Proguard/R8 config if applicable
- **Deliverable:** Build config checklist

## Phase 3: Documentation (~1h)
**Goal:** Make tomorrow morning's build foolproof

### Agent 5: Build Guide
**Task:** Create step-by-step PowerShell build instructions
- Complete AAB build command
- Signing verification steps
- Upload to Play Console process
- Pre-submission checklist
- **Deliverable:** LAUNCH_MORNING_GUIDE.md

## Execution Strategy

### Parallel Execution (Phases 1-2)
```
Agent 1 (Core Flow) ─┐
Agent 2 (Edge Cases) ├─→ Wait for all → Merge results → Phase 3
Agent 3 (Visual)     ┤
Agent 4 (Config)     ┘
```

### Conservative Rules
- ✅ Fix obvious bugs (missing null checks, typos)
- ✅ Quick visual improvements (alignment, spacing)
- ❌ NO architecture changes
- ❌ NO new features
- ❌ NO risky refactors
- ❌ NO dependency updates

### Success Criteria
- All critical flows work flawlessly
- No crashes in edge cases
- Visual consistency across app
- Release build config verified
- Clear build guide for morning

## Expected Deliverables (By Morning)

### Reports
- `docs/qa/PRE_LAUNCH_QA_REPORT.md` - Full test results
- `docs/qa/EDGE_CASE_REPORT.md` - Edge case findings
- `docs/qa/VISUAL_AUDIT.md` - UI consistency check
- `docs/build/BUILD_CONFIG_CHECKLIST.md` - Release verification

### Guide
- `docs/build/LAUNCH_MORNING_GUIDE.md` - Step-by-step build instructions

### Fixes
- 0-5 commits with P0 bug fixes (if any found)
- 0-3 commits with quick visual improvements

## Timeline
- **00:45-01:00 GMT:** Plan creation, agent spawn
- **01:00-05:00 GMT:** Parallel QA + verification (4h)
- **05:00-06:00 GMT:** Documentation + final checks (1h)
- **06:00+ GMT:** Ready for Tiarnan to build AAB

## Risk Mitigation
- All changes require build verification before commit
- Git commits only if tests pass
- Conservative approach - when in doubt, document don't change
- Focus on verification over optimization

---

**Status:** Ready to execute  
**Next:** Spawn 5 agents, monitor progress, compile results
