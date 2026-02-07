# Testing Guide
## Aquarium App - Complete Testing Documentation

Welcome to the comprehensive testing documentation for the Aquarium App! This guide provides everything you need to test the app thoroughly and ensure quality releases.

---

## 📚 Documentation Overview

This testing suite consists of four main documents:

### 1. **USER_FLOWS.md** 📍
**Purpose:** Visual maps of all user journeys through the app

**Contains:**
- First-time user flow (onboarding → first lesson)
- Daily active user flow (daily goals, streaks, learning)
- Tank management flow (create tank, add livestock, log parameters)
- Social flow (friends, leaderboard, encouragement)
- Shop & progression flow (earn gems, purchase items)
- Cross-flow interactions
- Navigation maps

**Use this when:**
- Understanding how users navigate the app
- Identifying missing steps in user journeys
- Planning new features or improvements
- Creating test scenarios

---

### 2. **TEST_SCENARIOS.md** 🧪
**Purpose:** Detailed step-by-step test scripts for manual QA

**Contains:**
- Happy path tests for all major features
- Edge case scenarios
- Error recovery tests
- Offline behavior tests
- Performance and load tests
- Boundary value testing
- Test coverage summary
- Pre-release smoke test checklist

**Use this when:**
- Manually testing features
- Verifying bug fixes
- Regression testing before releases
- Onboarding new QA team members

---

### 3. **ACCEPTANCE_CRITERIA.md** ✅
**Purpose:** Define what "done" looks like for each feature

**Contains:**
- General acceptance criteria (all features)
- Feature-specific criteria:
  - Onboarding & Profile Creation
  - Learning System
  - Gamification (XP, Streaks, Levels)
  - Tank Management
  - Social Features
  - Shop & Gem Economy
  - Offline Functionality
  - Performance & Quality
- Release checklist
- Success metrics

**Use this when:**
- Validating feature completion
- Reviewing pull requests
- Planning releases
- Measuring success

---

### 4. **BUG_REPORT_TEMPLATE.md** 🐛
**Purpose:** Standard template for logging and tracking bugs

**Contains:**
- Complete bug report template
- Example bug reports (Critical, Medium, Low)
- Bug labels and tags
- Severity and priority guidelines
- Bug lifecycle diagram
- Best practices for bug reporting
- Emergency bug procedure

**Use this when:**
- Reporting bugs
- Triaging issues
- Prioritizing fixes
- Tracking bug resolution

---

## 🎯 Quick Start Guide

### For QA Testers

**Before Each Test Session:**
1. Read USER_FLOWS.md to understand the feature flow
2. Open TEST_SCENARIOS.md for step-by-step instructions
3. Have BUG_REPORT_TEMPLATE.md ready to log issues
4. Check ACCEPTANCE_CRITERIA.md to know success criteria

**During Testing:**
1. Follow test scenarios methodically
2. Note any deviations from expected behavior
3. Capture screenshots/videos of issues
4. Log bugs using the standard template

**After Testing:**
1. Review acceptance criteria - are they met?
2. Update test results
3. Report findings to team
4. Track bug resolution

---

### For Developers

**Before Starting a Feature:**
1. Review ACCEPTANCE_CRITERIA.md for requirements
2. Check USER_FLOWS.md to understand user journey
3. Note edge cases mentioned in TEST_SCENARIOS.md

**Before Submitting PR:**
1. Test happy path from TEST_SCENARIOS.md
2. Verify acceptance criteria are met
3. Test edge cases relevant to your changes
4. Check for regressions in related features

**After PR Merged:**
1. Notify QA which test scenarios to run
2. Be available to fix bugs quickly
3. Update documentation if flows changed

---

### For Product Managers

**During Planning:**
1. Use USER_FLOWS.md to visualize features
2. Define acceptance criteria for new features
3. Identify gaps in user journeys

**Before Release:**
1. Review acceptance criteria - all met?
2. Check bug metrics - acceptable quality?
3. Verify success metrics are defined
4. Approve release checklist

---

## 🔄 Testing Workflow

```
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│  1. PLAN                                                    │
│     └─ Review USER_FLOWS.md                                │
│     └─ Review ACCEPTANCE_CRITERIA.md                       │
│                                                             │
│  2. TEST                                                    │
│     └─ Follow TEST_SCENARIOS.md                            │
│     └─ Test happy paths                                    │
│     └─ Test edge cases                                     │
│     └─ Test offline behavior                               │
│                                                             │
│  3. REPORT                                                  │
│     └─ Use BUG_REPORT_TEMPLATE.md                          │
│     └─ Capture evidence (screenshots, logs)                │
│     └─ Assign severity and priority                        │
│                                                             │
│  4. VERIFY                                                  │
│     └─ Re-test fixed bugs                                  │
│     └─ Check ACCEPTANCE_CRITERIA.md                        │
│     └─ Regression testing                                  │
│                                                             │
│  5. RELEASE                                                 │
│     └─ Complete release checklist                          │
│     └─ Monitor metrics                                     │
│     └─ Track user feedback                                 │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## 📋 Pre-Release Testing Checklist

Use this checklist before every release:

### Critical Path Testing (MUST PASS)
- [ ] **Onboarding Flow**
  - [ ] New user can complete onboarding
  - [ ] Profile creation succeeds
  - [ ] Placement test works (take or skip)
  - [ ] First lesson completes successfully
  - [ ] XP and gems awarded correctly

- [ ] **Learning System**
  - [ ] Can browse lesson catalog
  - [ ] Can complete a lesson
  - [ ] Quiz questions work
  - [ ] XP/gems awarded on completion
  - [ ] Progress saves correctly

- [ ] **Daily Goal & Streaks**
  - [ ] Daily goal tracks XP accurately
  - [ ] Streak increments when earned XP
  - [ ] Streak breaks after missed day
  - [ ] Streak freeze works

- [ ] **Tank Management**
  - [ ] Can create tank
  - [ ] Can add livestock
  - [ ] Can log water test
  - [ ] Can complete maintenance task
  - [ ] Charts display correctly

- [ ] **Social Features**
  - [ ] Can add friends
  - [ ] Leaderboard displays correctly
  - [ ] Friend comparison works
  - [ ] Activity feed shows updates

- [ ] **Shop**
  - [ ] Can browse catalog
  - [ ] Can purchase items with gems
  - [ ] Power-ups activate correctly
  - [ ] Insufficient gems handled

### Platform Testing
- [ ] **iOS Testing**
  - [ ] Tested on iOS 16
  - [ ] Tested on iOS 17
  - [ ] Tested on iPhone (various sizes)
  - [ ] Tested on iPad (if supported)

- [ ] **Android Testing**
  - [ ] Tested on Android 12
  - [ ] Tested on Android 13
  - [ ] Tested on Android 14
  - [ ] Tested on various screen sizes

### Quality Checks
- [ ] **Performance**
  - [ ] App launches in <3 seconds
  - [ ] Navigation is smooth (<300ms)
  - [ ] Animations are at 60fps
  - [ ] No memory leaks

- [ ] **Offline**
  - [ ] Core features work offline
  - [ ] Data syncs when online
  - [ ] No data loss during sync

- [ ] **Bugs**
  - [ ] No critical bugs
  - [ ] No high-priority bugs without workarounds
  - [ ] Acceptable number of medium/low bugs

### Documentation
- [ ] Release notes prepared
- [ ] Known issues documented
- [ ] User-facing docs updated
- [ ] Support team briefed

---

## 🎓 Testing Best Practices

### Exploratory Testing
Beyond scripted tests, spend time exploring:
- Try unusual input combinations
- Navigate in unexpected ways
- Test rapid interactions (tap things quickly)
- Switch between online/offline
- Interrupt flows (minimize app, switch apps)
- Fill storage to capacity
- Test on slow networks

### Regression Testing
After any change, test:
- The changed feature (obviously)
- Related features (might be affected)
- Core critical paths (onboarding, learning, tank creation)
- Previously buggy areas (regression-prone)

### Device Coverage
Test on a variety of:
- **Screen sizes:** Small (iPhone SE), Medium (iPhone 14), Large (iPhone 14 Pro Max), Tablet
- **OS versions:** Current, N-1, N-2 (e.g., iOS 17, 16, 15)
- **Performance tiers:** High-end (flagship), Mid-range, Low-end
- **Network conditions:** WiFi, 5G, 4G, 3G, Offline

### Test Data
Maintain test accounts with:
- Fresh new user (never onboarded)
- New user (completed onboarding, few lessons)
- Active user (many lessons, streak, tanks)
- Power user (max XP, all achievements, multiple tanks)
- Edge case user (thousands of tanks, hundreds of livestock)

---

## 📊 Test Metrics & Reporting

Track these metrics for each test cycle:

### Test Execution
- Total test cases run
- Test cases passed
- Test cases failed
- Test cases blocked (cannot test)
- Pass rate percentage

### Bug Metrics
- New bugs found (by severity)
- Bugs fixed (by severity)
- Bugs verified
- Open bug count
- Bug trends (increasing/decreasing)

### Coverage
- Features tested
- Features not tested (with reason)
- Test coverage percentage
- Code coverage (if automated tests exist)

### Quality Indicators
- Crash-free rate
- Critical bug count (target: 0)
- High-priority bug count (target: <3)
- Regression count (target: <10%)
- User-reported bugs (target: <5 per release)

---

## 🚀 Release Decision Criteria

### Release GO Criteria ✅
- All critical path tests pass
- Zero critical bugs
- <3 high-priority bugs (with workarounds)
- Pass rate >95%
- Performance benchmarks met
- Offline functionality verified
- Tested on minimum supported OS versions

### Release NO-GO Criteria ❌
- Any critical bugs
- >5 high-priority bugs
- Critical path tests failing
- Known data loss issues
- Crash rate >1%
- Performance significantly degraded
- Major features broken

### Conditional Release 🤔
- 3-5 high-priority bugs (evaluate impact)
- <10 medium bugs (with workarounds)
- Known issues clearly documented
- Hotfix plan ready if needed

---

## 🛠️ Testing Tools & Resources

### Recommended Tools
- **Screen Recording:** Built-in iOS/Android screen recording
- **Screenshots:** Built-in screenshot tools
- **Network Simulation:** Xcode Network Link Conditioner, Android network throttling
- **Device Farms:** Firebase Test Lab, BrowserStack (for broad device coverage)
- **Bug Tracking:** GitHub Issues, Jira, Linear, etc.
- **Test Management:** TestRail, Zephyr, or simple spreadsheets

### Helpful Commands

**Check app version:**
```
Settings → About → Version
```

**Clear app data (Android):**
```
Settings → Apps → Aquarium App → Storage → Clear Data
```

**Clear app data (iOS):**
```
Uninstall and reinstall app
```

**Enable developer options:**
- See specific platform documentation

---

## 🆘 When You Find a Critical Bug

1. **Stop testing** that feature immediately
2. **Notify team** via Slack/Discord/emergency channel
3. **Create bug report** using template with P0 priority
4. **Capture evidence** (video if possible)
5. **Document user impact** and reproduction rate
6. **Suggest workaround** if any exists
7. **Block release** if it's a showstopper

---

## 📞 Support & Questions

### Testing Questions?
- Review USER_FLOWS.md for feature understanding
- Check TEST_SCENARIOS.md for step-by-step instructions
- Consult ACCEPTANCE_CRITERIA.md for "done" definition

### Bug Reporting Questions?
- Use BUG_REPORT_TEMPLATE.md
- Include all required sections
- Add severity and priority
- Capture screenshots/videos

### Feature Questions?
- Ask product manager
- Review acceptance criteria
- Check user flows for context

---

## 🎯 Testing Priorities by Release Phase

### Alpha (Internal Testing)
**Focus:** Core functionality, major bugs
- Critical path flows work
- No crashes on basic operations
- Data persists correctly
- Major features functional

### Beta (Limited External Testing)
**Focus:** User experience, edge cases
- All features tested
- Edge cases handled
- Error messages clear
- Performance acceptable

### Release Candidate
**Focus:** Polish, regression, performance
- All acceptance criteria met
- No critical or high bugs
- Performance optimized
- Regression testing complete
- Documentation finalized

### Production
**Focus:** Monitoring, hotfixes
- Monitor crash rates
- Track user feedback
- Quick response to critical issues
- Plan next improvements

---

## 📈 Continuous Improvement

After each release:

### Retrospective
- What testing went well?
- What bugs slipped through?
- Which test scenarios need updating?
- What new edge cases emerged?

### Update Documentation
- Add new user flows for new features
- Update test scenarios based on bugs found
- Refine acceptance criteria
- Improve bug template if needed

### Metrics Review
- Analyze bug trends
- Identify regression-prone areas
- Track test coverage gaps
- Measure quality improvements

---

## 🏆 Testing Success Metrics

Track these over time to measure testing effectiveness:

### Quality Metrics
- **Defect Detection Rate:** Bugs found in testing vs. production (target: >90% in testing)
- **Defect Leakage:** Bugs found in production (target: <5 per release)
- **Regression Rate:** % of bugs that are regressions (target: <10%)
- **Reopen Rate:** % of bugs reopened after fix (target: <5%)

### Efficiency Metrics
- **Test Coverage:** % of features tested (target: 100% critical paths)
- **Test Execution Time:** Time to complete full test cycle (track trend)
- **Time to Find Bugs:** Average time to discover a bug (earlier is better)
- **Time to Fix:** Average bug resolution time (track by severity)

### User Impact Metrics
- **Crash-Free Users:** % of users with no crashes (target: >99%)
- **Critical Bugs in Production:** Count (target: 0)
- **User-Reported Bugs:** Count per 1000 users (target: <5)
- **App Store Rating:** Average rating (target: >4.5 stars)

---

## 📝 Quick Reference Cards

### Severity Guide
| Severity | Impact | Examples |
|----------|--------|----------|
| **Critical** | App unusable | Crashes, data loss, cannot onboard |
| **High** | Major feature broken | Streak not tracking, shop broken |
| **Medium** | Feature partially broken | Chart display issue, slow performance |
| **Low** | Cosmetic/minor | Icon misalignment, typo |

### Priority Guide
| Priority | When to Fix | Examples |
|----------|-------------|----------|
| **P0** | Immediately | Blocks release, production down |
| **P1** | Before release | Major features broken |
| **P2** | Next release | Medium impact, has workaround |
| **P3** | Backlog | Low impact, nice to have |

### Test Types
| Type | When | Focus |
|------|------|-------|
| **Smoke** | Every build | Core functionality works |
| **Functional** | Feature complete | Feature works as designed |
| **Regression** | Before release | Existing features still work |
| **Exploratory** | Ongoing | Find unexpected issues |
| **Performance** | Before release | Speed and responsiveness |
| **Offline** | Before release | Works without internet |

---

## 🎓 Appendix: Testing Glossary

- **Acceptance Criteria:** Conditions that must be met for a feature to be considered complete
- **Edge Case:** Unusual or extreme scenario that tests boundary conditions
- **Happy Path:** The ideal user flow with no errors or deviations
- **Regression:** A bug in previously working functionality
- **Reproduction Rate:** How often a bug occurs when steps are followed
- **Severity:** Impact of a bug on the user experience
- **Priority:** Urgency of fixing a bug
- **Smoke Test:** Quick test to verify basic functionality after a build
- **User Flow:** A sequence of steps a user takes to accomplish a goal
- **Workaround:** An alternative way to achieve a goal when the primary method is broken

---

## 📚 Further Reading

- Flutter Testing Documentation: https://docs.flutter.dev/testing
- iOS Testing Best Practices: https://developer.apple.com/documentation/xcode/testing
- Android Testing Guide: https://developer.android.com/training/testing
- Mobile App Testing Checklist: https://www.ministryoftesting.com/

---

## 🎉 You're Ready!

You now have everything you need to thoroughly test the Aquarium App. Remember:

1. **Plan** using USER_FLOWS.md
2. **Test** following TEST_SCENARIOS.md
3. **Verify** against ACCEPTANCE_CRITERIA.md
4. **Report** using BUG_REPORT_TEMPLATE.md

Happy testing! 🐠🧪

---

*Last Updated: 2025-02-07*
*Version: 1.0*

**Questions or suggestions for improving this testing documentation?**
Contact the QA team or submit feedback via GitHub Issues.
