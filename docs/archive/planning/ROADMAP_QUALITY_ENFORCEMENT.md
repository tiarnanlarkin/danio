> ⚠️ **SUPPORTING DOCUMENT** - This is a detailed reference document.
> 
> **Source of Truth:** [`MASTER_INTEGRATION_ROADMAP.md`](../../MASTER_INTEGRATION_ROADMAP.md)
> 
> Use this document for detailed implementation guidance. Track progress in the MASTER roadmap.

---

# 🚨 ROADMAP: Quality Gate Enforcement Implementation
**Created:** February 11, 2026  
**Purpose:** Transform quality gate system from "documentation theater" to automatic enforcement  
**Context:** Audit found quality gates defined but NEVER enforced (0% compliance)  
**Goal:** Make quality gates impossible to skip, automatic to run, and systematic to track  

---

## 🎯 EXECUTIVE SUMMARY

### The Problem

**Audit Finding:** Quality gate system was beautifully designed but completely ignored.
- ✅ ROADMAP_QUALITY_GATE_SYSTEM.md exists (comprehensive workflow)
- ✅ AUTOMATED_QUALITY_CHECKS_SYSTEM.md exists (3-tier checks)
- ❌ No PHASE_X_TEST_REPORT.md files created
- ❌ No automated checks ever run
- ❌ P0 bug documented but not tracked in fixes system
- ❌ Phase 1 marked "complete" despite failing quality gates
- **Quality Gate Compliance: 0% (F)**

### The Solution

**Transform from manual → automatic:**
1. ✅ **Pre-commit hooks** - Run checks before code commits
2. ✅ **CI/CD pipeline** - Automated testing on every push
3. ✅ **GitHub Actions** - Quality gate enforcement in the cloud
4. ✅ **Phase completion script** - Can't mark phase complete without passing gates
5. ✅ **Bug tracker integration** - P0/P1/P2/P3 bugs tracked systematically
6. ✅ **Regression test suite** - Old features tested automatically
7. ✅ **Documentation updates** - Docs auto-checked for completeness

### Success Criteria

**Phase 2+ cannot begin until:**
- [ ] All automated quality checks pass (Tier 1 mandatory)
- [ ] Manual testing workflow completed with test report
- [ ] All P0 bugs fixed and verified
- [ ] All P1 bugs fixed or explicitly deferred
- [ ] Regression tests pass (previous phases still work)
- [ ] Documentation updated (changelog, features list)
- [ ] Phase completion script approves transition

---

## 📋 IMPLEMENTATION PLAN

### Phase 0: Setup & Infrastructure (Week 1)
**Goal:** Build the enforcement infrastructure before Phase 2 work begins

#### 0.1: Create Scripts Directory Structure
```
repo/
├── scripts/
│   ├── quality_gates/
│   │   ├── run_all_checks.sh              # Master orchestrator
│   │   ├── tier1_mandatory_checks.sh      # Blocking checks
│   │   ├── tier2_recommended_checks.sh    # Warning checks
│   │   ├── tier3_optional_checks.sh       # Nice-to-have checks
│   │   ├── check_coverage.sh              # Code coverage threshold
│   │   ├── check_vulnerabilities.sh       # Security scanning
│   │   ├── check_complexity.sh            # Cyclomatic complexity
│   │   ├── check_apk_size.sh              # APK size monitoring
│   │   ├── check_licenses.sh              # Dependency licenses
│   │   ├── measure_startup.sh             # App launch time
│   │   └── generate_quality_report.sh     # HTML summary report
│   │
│   ├── testing/
│   │   ├── run_manual_testing.sh          # App testing workflow
│   │   ├── build_and_install.sh           # Build + emulator install
│   │   ├── capture_screenshots.sh         # Screenshot automation
│   │   ├── run_smoke_tests.sh             # Previous phase regression
│   │   └── verify_fixes.sh                # Re-test after bug fixes
│   │
│   ├── bug_tracking/
│   │   ├── create_fixes_report.sh         # Generate FIXES_REQUIRED.md
│   │   ├── track_bug_status.sh            # Update bug statuses
│   │   ├── check_p0_blockers.sh           # Alert on critical bugs
│   │   └── migrate_to_backlog.sh          # Move P3 bugs to backlog
│   │
│   ├── phase_completion/
│   │   ├── can_complete_phase.sh          # Validate all gates passed
│   │   ├── mark_phase_complete.sh         # Official completion script
│   │   ├── update_roadmap.sh              # Auto-update checkboxes
│   │   └── generate_completion_report.sh  # Summary document
│   │
│   └── hooks/
│       ├── pre-commit                     # Git hook (linting, format)
│       └── pre-push                       # Git hook (tests, security)
│
├── .github/
│   └── workflows/
│       ├── quality_gates.yml              # CI/CD quality checks
│       ├── regression_tests.yml           # Auto-run on PR
│       └── phase_completion.yml           # Approve phase transition
│
└── docs/
    ├── testing/
    │   ├── PHASE_1_AUTOMATED_CHECKS_REPORT.md
    │   ├── PHASE_1_TEST_REPORT.md
    │   ├── PHASE_1_FIXES_REQUIRED.md
    │   ├── PHASE_2_AUTOMATED_CHECKS_REPORT.md
    │   └── ...
    │
    └── bugs/
        ├── ACTIVE_BUGS.md                 # Current P0/P1/P2 tracker
        ├── FIXED_BUGS.md                  # Historical record
        └── BACKLOG.md                     # P3 deferred bugs
```

**Deliverables:**
- [ ] Create all directories
- [ ] Write stub scripts (to be filled in next steps)
- [ ] Set up GitHub Actions workflows
- [ ] Create bug tracking templates

**Time Estimate:** 4 hours

---

#### 0.2: Install Required Tools

**Testing Tools:**
```bash
# Flutter testing
flutter pub add --dev test
flutter pub add --dev integration_test
flutter pub add --dev mockito
flutter pub add --dev build_runner

# Code coverage
flutter pub add --dev coverage

# Linting & formatting (already have)
# flutter analyze (built-in)
# dart format (built-in)
```

**Security Tools:**
```bash
# Dependency vulnerability scanning
flutter pub global activate vulnerability_scanner

# Secret detection
brew install gitleaks  # macOS
# or
wget https://github.com/gitleaks/gitleaks/releases/download/v8.18.0/gitleaks_8.18.0_linux_x64.tar.gz
tar -xzf gitleaks_8.18.0_linux_x64.tar.gz
sudo mv gitleaks /usr/local/bin/
```

**Performance Tools:**
```bash
# App startup measurement
adb shell (Android Debug Bridge - already have)

# APK analysis
flutter pub add --dev flutter_launcher_icons
```

**CI/CD Tools:**
```yaml
# GitHub Actions (already available)
# Free tier: 2,000 minutes/month
# Enough for quality gates
```

**Deliverables:**
- [ ] All tools installed and tested
- [ ] Document tool versions in README
- [ ] Verify tools work on WSL + Windows

**Time Estimate:** 2 hours

---

#### 0.3: Write Tier 1 Automated Checks Script

**File:** `scripts/quality_gates/tier1_mandatory_checks.sh`

```bash
#!/bin/bash
# Tier 1 Mandatory Checks (BLOCKING)
# Exit code 0 = pass, non-zero = fail

set -e  # Exit on first error

PHASE=$1
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$REPO_ROOT/apps/aquarium_app"

echo "🔴 TIER 1: MANDATORY CHECKS (BLOCKING)"
echo "Phase: $PHASE"
echo "========================================"

PASS=0
FAIL=0

# Helper function
run_check() {
    local name="$1"
    local command="$2"
    
    echo ""
    echo "Running: $name"
    
    if eval "$command" > /tmp/check_output.txt 2>&1; then
        echo "✅ PASS: $name"
        ((PASS++))
        return 0
    else
        echo "❌ FAIL: $name"
        cat /tmp/check_output.txt
        ((FAIL++))
        return 1
    fi
}

# 1. DART ANALYZER (Static Analysis)
run_check "Dart Analyzer" "flutter analyze --no-pub"

# 2. CODE FORMATTING
run_check "Code Formatting" "dart format --set-exit-if-changed lib/"

# 3. UNIT TESTS (Must pass 100%)
run_check "Unit Tests" "flutter test --no-pub"

# 4. CODE COVERAGE (≥70%)
echo ""
echo "Running: Code Coverage ≥70%"
flutter test --coverage --no-pub
COVERAGE=$(bash "$REPO_ROOT/scripts/quality_gates/check_coverage.sh" 70)
if [ $? -eq 0 ]; then
    echo "✅ PASS: Code Coverage ($COVERAGE%)"
    ((PASS++))
else
    echo "❌ FAIL: Code Coverage ($COVERAGE% < 70%)"
    ((FAIL++))
fi

# 5. DEPENDENCY SECURITY SCAN
run_check "Dependency Security" "bash $REPO_ROOT/scripts/quality_gates/check_vulnerabilities.sh"

# 6. SECRET DETECTION
if command -v gitleaks &> /dev/null; then
    run_check "Secret Detection" "gitleaks detect --source $REPO_ROOT --no-banner"
else
    echo "⚠️ SKIP: Secret Detection (gitleaks not installed)"
fi

# 7. CLEAN BUILD
echo ""
echo "Running: Clean Build"
flutter clean > /dev/null 2>&1
flutter pub get > /dev/null 2>&1
if flutter build apk --debug --quiet; then
    echo "✅ PASS: Clean Build"
    ((PASS++))
else
    echo "❌ FAIL: Clean Build"
    ((FAIL++))
fi

# 8. SMOKE TESTS (Regression - Previous Phases)
if [ -d "test/smoke" ]; then
    run_check "Smoke Tests" "flutter test test/smoke/ --no-pub"
else
    echo "⚠️ SKIP: Smoke Tests (test/smoke/ not found)"
fi

# RESULTS
echo ""
echo "========================================"
echo "📊 TIER 1 RESULTS"
echo "========================================"
echo "✅ Passed: $PASS"
echo "❌ Failed: $FAIL"
echo ""

if [ $FAIL -gt 0 ]; then
    echo "🔴 TIER 1: FAILED ($FAIL checks)"
    echo "Fix errors before proceeding"
    exit 1
else
    echo "🟢 TIER 1: PASSED (All mandatory checks)"
    exit 0
fi
```

**Deliverables:**
- [ ] tier1_mandatory_checks.sh written and tested
- [ ] All helper scripts (check_coverage.sh, check_vulnerabilities.sh)
- [ ] Verify script runs on Windows/WSL

**Time Estimate:** 3 hours

---

#### 0.4: Write Phase Completion Validation Script

**File:** `scripts/phase_completion/can_complete_phase.sh`

```bash
#!/bin/bash
# Validates if a phase can be marked complete
# Checks all quality gate requirements

PHASE=$1
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

echo "🎯 PHASE $PHASE COMPLETION VALIDATION"
echo "========================================"

REQUIREMENTS_MET=0
REQUIREMENTS_TOTAL=0

check_requirement() {
    local name="$1"
    local condition="$2"
    
    ((REQUIREMENTS_TOTAL++))
    
    echo ""
    echo "Checking: $name"
    
    if eval "$condition"; then
        echo "✅ PASS: $name"
        ((REQUIREMENTS_MET++))
        return 0
    else
        echo "❌ FAIL: $name"
        return 1
    fi
}

# REQUIREMENT 1: Automated checks passed
check_requirement "Tier 1 Automated Checks Passed" \
    "[ -f docs/testing/PHASE_${PHASE}_AUTOMATED_CHECKS_REPORT.md ]"

# REQUIREMENT 2: Manual testing completed
check_requirement "Manual Testing Report Exists" \
    "[ -f docs/testing/PHASE_${PHASE}_TEST_REPORT.md ]"

# REQUIREMENT 3: Fixes document created
check_requirement "Fixes Required Document Exists" \
    "[ -f docs/testing/PHASE_${PHASE}_FIXES_REQUIRED.md ]"

# REQUIREMENT 4: No P0 bugs active
P0_COUNT=$(grep -c "^### Fix.*P0" docs/testing/PHASE_${PHASE}_FIXES_REQUIRED.md 2>/dev/null || echo 0)
check_requirement "No Active P0 Bugs" \
    "[ $P0_COUNT -eq 0 ]"

# REQUIREMENT 5: No P1 bugs active (or explicitly deferred)
P1_COUNT=$(grep -c "^### Fix.*P1" docs/testing/PHASE_${PHASE}_FIXES_REQUIRED.md 2>/dev/null || echo 0)
check_requirement "No Active P1 Bugs (or deferred)" \
    "[ $P1_COUNT -eq 0 ]"

# REQUIREMENT 6: Smoke tests passing
check_requirement "Smoke Tests Pass (Regression)" \
    "flutter test test/smoke/ --no-pub > /dev/null 2>&1"

# REQUIREMENT 7: Documentation updated
check_requirement "CHANGELOG.md Updated for Phase $PHASE" \
    "grep -q \"Phase $PHASE\" CHANGELOG.md 2>/dev/null"

# REQUIREMENT 8: APK size reasonable
APK_SIZE=$(stat -c%s "build/app/outputs/flutter-apk/app-debug.apk" 2>/dev/null || echo 0)
APK_SIZE_MB=$((APK_SIZE / 1024 / 1024))
check_requirement "APK Size <50MB (Currently ${APK_SIZE_MB}MB)" \
    "[ $APK_SIZE_MB -lt 50 ]"

# RESULTS
echo ""
echo "========================================"
echo "📊 PHASE $PHASE COMPLETION STATUS"
echo "========================================"
echo "Requirements Met: $REQUIREMENTS_MET / $REQUIREMENTS_TOTAL"
echo ""

if [ $REQUIREMENTS_MET -eq $REQUIREMENTS_TOTAL ]; then
    echo "🟢 PHASE $PHASE CAN BE MARKED COMPLETE"
    echo ""
    echo "Next steps:"
    echo "1. Run: bash scripts/phase_completion/mark_phase_complete.sh $PHASE"
    echo "2. Update master roadmap status to 🟢 Complete"
    echo "3. Commit all test reports and fixes documents"
    exit 0
else
    MISSING=$((REQUIREMENTS_TOTAL - REQUIREMENTS_MET))
    echo "🔴 PHASE $PHASE CANNOT BE MARKED COMPLETE"
    echo ""
    echo "Missing requirements: $MISSING"
    echo "Fix the failed checks above before proceeding"
    exit 1
fi
```

**Deliverables:**
- [ ] can_complete_phase.sh written
- [ ] mark_phase_complete.sh written (updates roadmap)
- [ ] Test with Phase 1 (should fail initially)

**Time Estimate:** 2 hours

---

#### 0.5: Create Bug Tracking System

**File:** `docs/bugs/ACTIVE_BUGS.md`

```markdown
# 🐛 Active Bugs Tracker
**Last Updated:** [Auto-generated timestamp]

## 🔴 P0 - CRITICAL (Blocking)

### P0-001: Tank Creation Form Validation
- **Severity:** P0 - Blocking new user flow
- **Found In:** Tank Creation Screen
- **Phase:** Phase 1
- **Reported:** Feb 8, 2026
- **Issue:** Text inputs don't persist values, preset buttons don't populate fields
- **Impact:** New users cannot create first tank, must skip
- **Status:** 🔴 OPEN
- **Assigned To:** [TBD]
- **Fix ETA:** [TBD]
- **Repro Steps:**
  1. Fresh install app
  2. Complete onboarding
  3. Try to create first tank
  4. Enter name, select 40L preset
  5. Bug: Fields reset, form won't submit
- **Expected:** Form accepts input and creates tank
- **Actual:** Form validation fails, user blocked
- **Fix Required:** Debug form state management, fix value persistence

---

## 🟡 P1 - HIGH PRIORITY

(None currently)

---

## 🟢 P2 - MEDIUM PRIORITY

(None currently)

---

## ⚪ P3 - LOW PRIORITY (Can Defer)

(None currently)

---

## 📊 SUMMARY

- 🔴 P0 (Critical): 1
- 🟡 P1 (High): 0
- 🟢 P2 (Medium): 0
- ⚪ P3 (Low): 0

**Total Active Bugs:** 1

---

**Rules:**
- P0 bugs MUST be fixed before phase completion
- P1 bugs MUST be fixed or explicitly deferred
- P2 bugs SHOULD be fixed (or documented if deferred)
- P3 bugs CAN be moved to backlog

**This file is auto-updated by:** `scripts/bug_tracking/track_bug_status.sh`
```

**Bug Tracking Script:**
```bash
#!/bin/bash
# scripts/bug_tracking/track_bug_status.sh
# Auto-update ACTIVE_BUGS.md with latest status

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
ACTIVE_BUGS="$REPO_ROOT/docs/bugs/ACTIVE_BUGS.md"

# Update timestamp
sed -i "s/\*\*Last Updated:\*\* .*/\*\*Last Updated:\*\* $(date '+%Y-%m-%d %H:%M:%S')/" "$ACTIVE_BUGS"

# Count bugs by priority
P0_COUNT=$(grep -c "^### P0-" "$ACTIVE_BUGS" || echo 0)
P1_COUNT=$(grep -c "^### P1-" "$ACTIVE_BUGS" || echo 0)
P2_COUNT=$(grep -c "^### P2-" "$ACTIVE_BUGS" || echo 0)
P3_COUNT=$(grep -c "^### P3-" "$ACTIVE_BUGS" || echo 0)

TOTAL=$((P0_COUNT + P1_COUNT + P2_COUNT + P3_COUNT))

# Update summary
sed -i "s/- 🔴 P0 (Critical): .*/- 🔴 P0 (Critical): $P0_COUNT/" "$ACTIVE_BUGS"
sed -i "s/- 🟡 P1 (High): .*/- 🟡 P1 (High): $P1_COUNT/" "$ACTIVE_BUGS"
sed -i "s/- 🟢 P2 (Medium): .*/- 🟢 P2 (Medium): $P2_COUNT/" "$ACTIVE_BUGS"
sed -i "s/- ⚪ P3 (Low): .*/- ⚪ P3 (Low): $P3_COUNT/" "$ACTIVE_BUGS"
sed -i "s/\*\*Total Active Bugs:\*\* .*/\*\*Total Active Bugs:\*\* $TOTAL/" "$ACTIVE_BUGS"

echo "✅ Bug tracker updated:"
echo "   P0: $P0_COUNT | P1: $P1_COUNT | P2: $P2_COUNT | P3: $P3_COUNT"
echo "   Total: $TOTAL"
```

**Deliverables:**
- [ ] Create docs/bugs/ directory
- [ ] Create ACTIVE_BUGS.md with P0-001 (tank creation bug)
- [ ] Create FIXED_BUGS.md template
- [ ] Create BACKLOG.md template
- [ ] Write track_bug_status.sh script
- [ ] Test bug counting automation

**Time Estimate:** 2 hours

---

#### 0.6: Create GitHub Actions CI/CD Workflow

**File:** `.github/workflows/quality_gates.yml`

```yaml
name: Quality Gates

on:
  pull_request:
    branches: [ master, main ]
  push:
    branches: [ master, main ]
  workflow_dispatch:  # Allow manual trigger

jobs:
  tier1-checks:
    name: Tier 1 Mandatory Checks
    runs-on: ubuntu-latest
    timeout-minutes: 20
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.16.0'  # Match project version
          channel: 'stable'
      
      - name: Get dependencies
        working-directory: apps/aquarium_app
        run: flutter pub get
      
      - name: Run Dart Analyzer
        working-directory: apps/aquarium_app
        run: flutter analyze
      
      - name: Check code formatting
        working-directory: apps/aquarium_app
        run: dart format --set-exit-if-changed lib/
      
      - name: Run unit tests
        working-directory: apps/aquarium_app
        run: flutter test
      
      - name: Generate coverage report
        working-directory: apps/aquarium_app
        run: flutter test --coverage
      
      - name: Check code coverage (≥70%)
        working-directory: apps/aquarium_app
        run: |
          COVERAGE=$(bash ../../scripts/quality_gates/check_coverage.sh 70)
          echo "Coverage: $COVERAGE%"
      
      - name: Install gitleaks
        run: |
          wget https://github.com/gitleaks/gitleaks/releases/download/v8.18.0/gitleaks_8.18.0_linux_x64.tar.gz
          tar -xzf gitleaks_8.18.0_linux_x64.tar.gz
          sudo mv gitleaks /usr/local/bin/
      
      - name: Run secret detection
        run: gitleaks detect --source . --no-banner
      
      - name: Build debug APK
        working-directory: apps/aquarium_app
        run: flutter build apk --debug
      
      - name: Check APK size
        working-directory: apps/aquarium_app
        run: bash ../../scripts/quality_gates/check_apk_size.sh 50
      
      - name: Upload APK artifact
        uses: actions/upload-artifact@v4
        with:
          name: debug-apk
          path: apps/aquarium_app/build/app/outputs/flutter-apk/app-debug.apk
          retention-days: 7
      
      - name: Generate quality report
        if: always()
        run: bash scripts/quality_gates/generate_quality_report.sh
      
      - name: Upload quality report
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: quality-report
          path: quality_report.html
          retention-days: 30

  smoke-tests:
    name: Smoke Tests (Regression)
    runs-on: ubuntu-latest
    needs: tier1-checks
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.16.0'
          channel: 'stable'
      
      - name: Get dependencies
        working-directory: apps/aquarium_app
        run: flutter pub get
      
      - name: Run smoke tests
        working-directory: apps/aquarium_app
        run: |
          if [ -d "test/smoke" ]; then
            flutter test test/smoke/
          else
            echo "No smoke tests found (test/smoke/ doesn't exist)"
            echo "Creating placeholder for future tests"
            mkdir -p test/smoke
          fi

  phase-completion-check:
    name: Phase Completion Validation
    runs-on: ubuntu-latest
    needs: [tier1-checks, smoke-tests]
    if: github.event_name == 'workflow_dispatch'
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
      
      - name: Validate phase completion
        run: |
          PHASE=${GITHUB_REF##*/phase-}
          bash scripts/phase_completion/can_complete_phase.sh $PHASE
```

**Deliverables:**
- [ ] Create .github/workflows/ directory
- [ ] Write quality_gates.yml
- [ ] Test workflow on a test branch
- [ ] Verify all checks run successfully

**Time Estimate:** 3 hours

---

### Summary: Phase 0 Deliverables

**Infrastructure Created:**
- ✅ Scripts directory with all automation
- ✅ Tier 1 automated checks (mandatory)
- ✅ Phase completion validation
- ✅ Bug tracking system
- ✅ GitHub Actions CI/CD
- ✅ All required tools installed

**Time Estimate:** 16 hours (2 working days)

**Outcome:** Quality gates are now AUTOMATIC and ENFORCED

---

## 🧪 TESTING WORKFLOW FOR EACH PHASE

### Pre-Phase Testing (Before Development Starts)

**Regression Baseline:**
```bash
# Run smoke tests to verify previous phases still work
bash scripts/testing/run_smoke_tests.sh

# Expected: All smoke tests pass
# If failures: Fix regressions before starting new phase
```

**Time:** 15 minutes

---

### During Development (Continuous)

**On Every Commit:**
```bash
# Pre-commit hook runs automatically:
# 1. dart format lib/
# 2. flutter analyze (warnings only)

# Manual tests during development:
flutter test              # Unit tests
flutter test test/widget/ # Widget tests
```

**On Every Push:**
```bash
# GitHub Actions runs automatically:
# 1. Tier 1 checks
# 2. Build verification
# 3. Smoke tests
```

**Time:** Automatic (5-10 min per push in CI)

---

### Post-Development (Phase Completion)

**Step 1: Run Automated Quality Checks**
```bash
# Run Tier 1 (mandatory, blocking)
bash scripts/quality_gates/tier1_mandatory_checks.sh PHASE_2

# Run Tier 2 (recommended, warnings)
bash scripts/quality_gates/tier2_recommended_checks.sh PHASE_2

# Run Tier 3 (optional, if time)
bash scripts/quality_gates/tier3_optional_checks.sh PHASE_2

# Expected output:
# - PHASE_2_AUTOMATED_CHECKS_REPORT.md created
# - All Tier 1 checks pass (or fix and re-run)
```

**Time:** 10-15 minutes (mostly automated)

**Deliverable:** `docs/testing/PHASE_2_AUTOMATED_CHECKS_REPORT.md`

---

**Step 2: Run Manual App Testing Workflow**
```bash
# Build and install on emulator
bash scripts/testing/build_and_install.sh

# Manual testing checklist:
# 1. Test all new features from this phase
# 2. Test critical paths from previous phases (regression)
# 3. Test edge cases (empty states, errors, long inputs)
# 4. Test on different screen sizes (if applicable)
# 5. Capture screenshots of key screens

# Screenshot automation:
bash scripts/testing/capture_screenshots.sh PHASE_2

# Document findings in test report
```

**Time:** 30-60 minutes (depends on phase complexity)

**Deliverable:** `docs/testing/PHASE_2_TEST_REPORT.md`

**Template:**
```markdown
# 📱 Phase 2 Manual Testing Report
**Phase:** Phase 2 - [Feature Name]
**Test Date:** [Date]
**Tester:** [Name]
**Device:** [Emulator/Device Details]
**Grade:** [A-F] ([Score]/100)

---

## 🎯 NEW FEATURES TESTED

### Feature 1: [Name]
- **Status:** ✅ PASS / ⚠️ ISSUES / ❌ FAIL
- **Tests:**
  - [ ] Basic functionality works
  - [ ] Edge cases handled
  - [ ] Error states display correctly
  - [ ] UI matches design
  - [ ] Performance acceptable
- **Issues Found:** [None / List bugs]
- **Screenshots:** [Links]

---

## 🔄 REGRESSION TESTING

### Phase 1 Features
- [ ] Onboarding flow still works
- [ ] Tank creation working (P0 bug check!)
- [ ] Navigation intact
- **Issues:** [None / List]

---

## 📊 TEST SUMMARY

**Tests Run:** [Count]
**Passed:** [Count]
**Failed:** [Count]
**Pass Rate:** [X]%

**Critical Issues (P0):** [Count]
**High Priority (P1):** [Count]
**Medium Priority (P2):** [Count]
**Low Priority (P3):** [Count]

**Overall Grade:** [A-F] ([Score]/100)

---

## 🐛 BUGS FOUND

(See PHASE_2_FIXES_REQUIRED.md for detailed list)
```

---

**Step 3: Create Fixes Required Document**
```bash
# Auto-generate from test report findings
bash scripts/bug_tracking/create_fixes_report.sh PHASE_2

# Manual: Fill in bug details, priority, repro steps
```

**Time:** 15-30 minutes

**Deliverable:** `docs/testing/PHASE_2_FIXES_REQUIRED.md`

**Template:**
```markdown
# 🔧 Phase 2 - Fixes Required

**Phase:** Phase 2 - [Feature Name]
**Test Date:** [Date]
**Status:** 🔴 Pending / 🟡 In Progress / 🟢 All Fixed

---

## 🔴 P0 - CRITICAL (Must Fix Before Next Phase)

### Fix 1: [Bug Title]
- **ID:** P0-002
- **Severity:** P0 - Blocking
- **Found In:** [Screen/Feature]
- **Impact:** [User impact description]
- **Repro Steps:**
  1. [Step]
  2. [Step]
  3. [Bug occurs]
- **Expected Behavior:** [What should happen]
- **Actual Behavior:** [What actually happens]
- **Fix Required:** [What needs to be done]
- **Status:** [ ] Not Started → [ ] In Progress → [x] Fixed → [ ] Verified
- **Fixed By:** [Name/Date]
- **Verified By:** [Name/Date]

---

## 🟡 P1 - HIGH PRIORITY

[Same format]

---

## 🟢 P2 - MEDIUM PRIORITY

[Same format]

---

## ⚪ P3 - LOW PRIORITY (Can Defer to Backlog)

[Same format]

---

## 📊 COMPLETION CHECKLIST

- [ ] All P0 fixes completed
- [ ] All P0 fixes verified
- [ ] All P1 fixes completed OR deferred (with justification)
- [ ] All P1 fixes verified
- [ ] P2/P3 fixes triaged (fix now or move to backlog)
- [ ] App re-tested after all fixes
- [ ] No new bugs introduced by fixes
- [ ] Smoke tests still pass

**Fixes Complete:** YES / NO  
**Sign-off:** [Name/Date]
```

---

**Step 4: Fix All P0 and P1 Bugs**
```bash
# Work through bugs in priority order
# 1. Fix P0 bugs first (blocking)
# 2. Fix P1 bugs second (high priority)
# 3. Triage P2/P3 (fix or defer)

# As each bug is fixed:
# 1. Update status in FIXES_REQUIRED.md
# 2. Mark checkbox as complete
# 3. Test the specific fix

# Update bug tracker
bash scripts/bug_tracking/track_bug_status.sh
```

**Time:** Varies (depends on bug count and complexity)

---

**Step 5: Verify Fixes (Re-test)**
```bash
# Re-run manual testing on fixed areas
bash scripts/testing/verify_fixes.sh PHASE_2

# Verify:
# 1. All fixed bugs are actually fixed
# 2. No new bugs introduced
# 3. Smoke tests still pass (regression)

# Update test report with verification results
```

**Time:** 20-30 minutes

---

**Step 6: Validate Phase Completion**
```bash
# Run validation script
bash scripts/phase_completion/can_complete_phase.sh PHASE_2

# Expected output:
# 🟢 PHASE 2 CAN BE MARKED COMPLETE
# Requirements Met: 8 / 8

# If fails:
# - Fix missing requirements
# - Re-run validation
```

**Time:** 5 minutes

---

**Step 7: Mark Phase Complete**
```bash
# Official completion (updates roadmap, generates report)
bash scripts/phase_completion/mark_phase_complete.sh PHASE_2

# This script:
# 1. Updates roadmap checkboxes
# 2. Generates completion summary
# 3. Commits test reports
# 4. Creates git tag: phase-2-complete
# 5. Announces completion
```

**Time:** 5 minutes

**Deliverable:** `docs/completed/PHASE_2_COMPLETION_REPORT.md`

---

### Total Time Per Phase

**Automated Checks:** 10-15 min  
**Manual Testing:** 30-60 min  
**Bug Documentation:** 15-30 min  
**Bug Fixes:** Varies (1-8 hours typically)  
**Verification:** 20-30 min  
**Validation & Completion:** 10 min  

**Total:** 2-10 hours per phase (depends on bugs found)

**Recommendation:** Budget 1 full day per phase for quality gates

---

## 🤖 AUTOMATED CHECKS INTEGRATION

### When to Run Each Tier

#### Tier 1: MANDATORY (Blocking)
**When:**
- Before marking phase complete (manual trigger)
- On every push to master (GitHub Actions)
- Before creating release builds

**What:**
1. Dart Analyzer (0 errors, ≤5 warnings)
2. Code Formatting (100% formatted)
3. Unit Tests (100% pass, ≥70% coverage)
4. Security Scan (0 critical/high vulnerabilities)
5. Secret Detection (0 exposed secrets)
6. Clean Build (build succeeds)
7. Smoke Tests (regression tests pass)

**Outcome:** MUST pass to proceed

**Report:** `PHASE_X_AUTOMATED_CHECKS_REPORT.md`

---

#### Tier 2: RECOMMENDED (Warnings)
**When:**
- During phase development (weekly check)
- Before marking phase complete

**What:**
1. Code Complexity (cyclomatic complexity <15)
2. Widget Tests (all pass)
3. Integration Tests (critical flows)
4. APK Size (<50MB debug, <25MB release)
5. Accessibility (no critical issues)
6. Performance (startup <3s)
7. Database Migration Tests

**Outcome:** Should pass, can proceed with documented warnings

**Report:** Appended to automated checks report

---

#### Tier 3: OPTIONAL (Nice to Have)
**When:**
- Monthly check
- Before major releases
- When performance issues suspected

**What:**
1. Golden Tests (visual regression)
2. Performance Profiling (memory, CPU)
3. Frame Rate Monitoring (animations)
4. Advanced Accessibility (screen reader)

**Outcome:** Track trends, fix if time allows

**Report:** Separate performance report (not blocking)

---

### Automated Check Schedule

```
Daily (Pre-commit):
  ├─ dart format
  └─ flutter analyze (warnings only)

On Push (GitHub Actions):
  ├─ Tier 1 checks (blocking)
  └─ Smoke tests (regression)

Weekly (During Phase):
  ├─ Tier 2 checks (warnings)
  └─ Review technical debt

Phase Completion:
  ├─ Tier 1 checks (MUST pass)
  ├─ Tier 2 checks (SHOULD pass)
  └─ Tier 3 checks (optional)

Monthly:
  ├─ Full Tier 3 performance audit
  └─ Dependency updates check
```

---

### Integration with Development Workflow

```
Feature Development:
  ├─ [Write Code]
  ├─ [Write Unit Tests]
  ├─ git add .
  ├─ git commit (pre-commit hook: format + analyze)
  ├─ git push (GitHub Actions: Tier 1 + smoke tests)
  └─ [Continue if passes]

Phase Completion:
  ├─ [All features done]
  ├─ Run: bash scripts/quality_gates/run_all_checks.sh PHASE_2
  ├─ [Automated checks report generated]
  ├─ Run: bash scripts/testing/run_manual_testing.sh PHASE_2
  ├─ [Manual test report created]
  ├─ [Create FIXES_REQUIRED.md]
  ├─ [Fix P0/P1 bugs]
  ├─ [Verify fixes]
  ├─ Run: bash scripts/phase_completion/can_complete_phase.sh PHASE_2
  ├─ [Validation passes]
  └─ Run: bash scripts/phase_completion/mark_phase_complete.sh PHASE_2
```

---

## 🐛 BUG TRACKING SYSTEM

### Priority Definitions

#### P0 - CRITICAL (Blocking)
**Definition:** Prevents core functionality, blocks users

**Examples:**
- App crashes on launch
- Cannot create tanks (current P0-001)
- Data loss on save
- Login impossible

**Rules:**
- MUST fix before phase completion
- CANNOT move to next phase with active P0
- Daily standup: P0 status reported

---

#### P1 - HIGH PRIORITY
**Definition:** Major feature broken, significant UX issue

**Examples:**
- Photo upload fails
- Export button doesn't work
- Navigation broken in one flow
- Performance severely degraded

**Rules:**
- MUST fix OR explicitly defer (with justification)
- Deferral requires approval
- Track in active bugs until resolved

---

#### P2 - MEDIUM PRIORITY
**Definition:** Minor feature issue, cosmetic problem

**Examples:**
- Button misaligned
- Text truncated in one case
- Loading indicator missing
- Non-critical error message unclear

**Rules:**
- SHOULD fix during phase
- CAN defer to backlog if time-constrained
- Document reason if deferred

---

#### P3 - LOW PRIORITY (Backlog)
**Definition:** Enhancement, nice-to-have, edge case

**Examples:**
- Add tooltip to button
- Improve animation smoothness
- Support dark mode better
- Handle 100+ tanks edge case

**Rules:**
- CAN defer to backlog
- Auto-migrate to BACKLOG.md
- Revisit during polish phases

---

### Bug Lifecycle

```
Bug Found (Testing)
  ↓
Added to PHASE_X_FIXES_REQUIRED.md
  ↓
Priority Assigned (P0/P1/P2/P3)
  ↓
Status: Not Started
  ↓
Status: In Progress (developer assigned)
  ↓
Status: Fixed (code complete)
  ↓
Status: Verified (re-tested, confirmed)
  ↓
Moved to FIXED_BUGS.md (historical record)
```

---

### Bug Tracking Files

**docs/bugs/ACTIVE_BUGS.md**
- All open bugs across all phases
- Updated by `track_bug_status.sh` script
- Auto-counts by priority
- Dashboard view of current bug state

**docs/testing/PHASE_X_FIXES_REQUIRED.md**
- Phase-specific bugs found during testing
- Detailed repro steps
- Fix status tracking
- Part of phase completion checklist

**docs/bugs/FIXED_BUGS.md**
- Historical record of all fixed bugs
- Useful for pattern analysis
- Reference for similar future bugs

**docs/bugs/BACKLOG.md**
- P3 bugs deferred
- Enhancement requests
- Future improvement ideas
- Triaged periodically

---

### Bug Tracking Automation

**Auto-update bug counts:**
```bash
# Run after fixing bugs or changing status
bash scripts/bug_tracking/track_bug_status.sh

# Output:
# ✅ Bug tracker updated:
#    P0: 0 | P1: 2 | P2: 5 | P3: 8
#    Total: 15
```

**Check for P0 blockers:**
```bash
# Run before attempting phase completion
bash scripts/bug_tracking/check_p0_blockers.sh

# Output:
# 🔴 BLOCKING: 1 P0 bug found
# - P0-001: Tank creation form validation
# Fix P0 bugs before marking phase complete
```

**Migrate P3 to backlog:**
```bash
# Move low-priority bugs to backlog
bash scripts/bug_tracking/migrate_to_backlog.sh PHASE_2

# Moves all P3 bugs from PHASE_2_FIXES_REQUIRED.md to BACKLOG.md
```

---

## 🔄 REGRESSION TESTING STRATEGY

### Purpose
Ensure new features don't break old features

### Smoke Test Suite

**Location:** `test/smoke/`

**Structure:**
```
test/smoke/
├── phase_0_smoke_test.dart      # P0 critical fixes
├── phase_1_smoke_test.dart      # Onboarding + core features
├── phase_2_smoke_test.dart      # [Future phase tests]
└── all_smoke_tests.dart         # Run all together
```

**What to Include:**
- Critical user paths from each phase
- Core functionality (create, read, update, delete)
- Navigation flows
- Data persistence

**Example:** `test/smoke/phase_1_smoke_test.dart`
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:aquarium_app/main.dart';

void main() {
  group('Phase 1 Smoke Tests', () {
    testWidgets('App launches without crashing', (tester) async {
      await tester.pumpWidget(MyApp());
      expect(find.byType(MyApp), findsOneWidget);
    });

    testWidgets('Onboarding flow completes', (tester) async {
      // Test placement test
      // Test tutorial
      // Test profile creation
    });

    testWidgets('Tank creation works (P0 regression check)', (tester) async {
      // CRITICAL: This was P0-001 bug
      // Must verify it stays fixed
    });

    testWidgets('Bottom navigation works', (tester) async {
      // Test all tabs accessible
    });
  });
}
```

---

### Regression Testing Schedule

**On Every Commit:**
- Pre-commit hook: Basic linting (fast)

**On Every Push:**
- GitHub Actions: All smoke tests (5-10 min)

**During Development:**
- Manual: Test related features when making changes

**Before Phase Completion:**
- Manual: Full app testing (all features)
- Automated: All smoke tests

**Before Release:**
- Manual: Full regression suite (2-4 hours)
- Automated: All tiers of checks

---

### Building the Smoke Test Suite

**For Each Completed Phase:**
1. Identify 5-10 critical features
2. Write smoke tests for each
3. Add to `test/smoke/phase_X_smoke_test.dart`
4. Update `all_smoke_tests.dart` to include new phase

**Example Critical Features (Phase 1):**
- App launches
- Onboarding completes
- Tank creation works (P0 regression)
- Navigation accessible
- Lessons display
- XP/Hearts/Streaks track

**Test Complexity:**
- Keep tests FAST (< 5 sec each)
- Focus on CRITICAL paths only
- Avoid UI details (use finders sparingly)
- Mock external dependencies

---

### Regression Test Failure Protocol

**If Smoke Test Fails:**
1. 🚨 **STOP** - Don't merge/deploy
2. 🔍 **Investigate** - What changed? What broke?
3. 🐛 **Create Bug** - Add to ACTIVE_BUGS.md as P1 regression
4. 🔧 **Fix** - Restore functionality
5. ✅ **Verify** - Re-run smoke tests
6. 📝 **Document** - Update test if needed

**Example:**
```
Smoke test failed: phase_1_smoke_test.dart
  - Test: 'Tank creation works'
  - Error: FormState null reference
  - Cause: Recent refactor broke form controller
  - Action: Create P1-005 regression bug
  - Fix: Restore form controller initialization
  - Verify: Smoke test now passes
```

---

## 📚 DOCUMENTATION STANDARDS

### Documentation Requirements for Phase Completion

**Must Update:**
1. `CHANGELOG.md` - What changed this phase
2. Master Roadmap - Mark phase complete, update checkboxes
3. Feature list - Add new features
4. Test reports - All phase testing docs
5. Bug tracker - Update active bugs

**Should Update:**
6. README.md - If user-facing changes
7. API docs - If new services/models
8. Screenshots - If UI changed significantly

**Nice to Update:**
9. CONTRIBUTING.md - If workflow changed
10. Architecture docs - If structure changed

---

### CHANGELOG.md Template

**Format:**
```markdown
# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased]

(Work in progress)

## [Phase 2] - 2026-02-XX

### Added
- New feature X with Y capability
- Screen Z for managing ABC

### Changed
- Improved performance of XYZ by 40%
- Updated navigation to include new section

### Fixed
- P0-001: Tank creation form validation bug
- P1-003: Photo upload retry logic

### Deprecated
- Old feature X (will remove in Phase 3)

### Removed
- Debug scaffolding from Phase 0

### Security
- Updated dependency X to fix CVE-2024-12345

## [Phase 1] - 2026-02-08

### Added
- Enhanced onboarding flow with placement test
- Tutorial walkthrough system
- First tank wizard
- 50 comprehensive lessons across 9 learning paths
- Privacy policy and terms of service screens
- CSV export functionality

### Changed
- Improved photo gallery with pinch-zoom
- Optimized file image loading

### Fixed
- (List actual bugs fixed in Phase 1)

## [Phase 0] - 2026-02-01

### Added
- Initial project structure
- Bottom navigation
- Core architecture (Models/Providers/Services)
- Basic database setup

### Fixed
- Storage race condition
```

---

### Feature List Documentation

**File:** `docs/FEATURES.md`

**Update After Each Phase:**
```markdown
# 📱 Aquarium App - Feature List

**Last Updated:** [Phase X Completion Date]

## ✅ Implemented Features

### Phase 1: Core Experience
- [x] Enhanced onboarding with placement test
- [x] Interactive tutorial walkthrough
- [x] First tank wizard
- [x] 50 lessons across 9 learning paths
- [x] Gamification system (XP, hearts, streaks, achievements)
- [x] Photo gallery with optimization
- [x] Privacy policy & terms of service
- [x] CSV export

### Phase 2: [Feature Name]
- [x] Feature A
- [x] Feature B
- [x] Feature C

## 🚧 In Progress

### Phase 3: [Next Phase]
- [ ] Feature X
- [ ] Feature Y

## 📋 Planned

### Phase 4: [Future]
- [ ] Feature Z
```

---

### Test Report Documentation Standard

**Required Sections:**
1. **Header** - Phase, date, tester, device, grade
2. **New Features Tested** - Each feature with status
3. **Regression Testing** - Previous phases verified
4. **Test Summary** - Counts, pass rate, grade
5. **Bugs Found** - Summary (details in FIXES_REQUIRED.md)
6. **Screenshots** - Links to test screenshots
7. **Sign-off** - Tester approval

**Quality Standards:**
- Be specific (not "button works" but "create tank button submits form")
- Include repro steps for bugs
- Screenshot key screens
- Grade honestly (A-F based on bug severity)

---

### Documentation Update Automation

**Script:** `scripts/phase_completion/update_docs.sh`

```bash
#!/bin/bash
# Auto-update documentation for phase completion

PHASE=$1
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

echo "📚 Updating documentation for Phase $PHASE"

# 1. Update CHANGELOG.md
echo "Updating CHANGELOG.md..."
# (Add phase section to changelog)

# 2. Update master roadmap checkboxes
echo "Updating roadmap..."
bash scripts/phase_completion/update_roadmap.sh $PHASE

# 3. Generate feature list from completed tasks
echo "Updating feature list..."
# (Extract completed features from roadmap)

# 4. Update README if needed
echo "Checking README..."
# (Prompt for README updates)

echo "✅ Documentation updated for Phase $PHASE"
```

---

## ✅ CHECKPOINT TEMPLATE

### Phase Completion Checkpoint

**Use this template for each phase:**

```markdown
## 🎯 Phase [X]: [Feature Name]

**Status:** 🔴 Not Started / 🟡 In Progress / 🟢 Complete

---

### DEVELOPMENT TASKS
- [ ] Task 1: [Description]
- [ ] Task 2: [Description]
- [ ] Task 3: [Description]

---

### QUALITY GATE: AUTOMATED CHECKS

#### 🤖 Tier 1 (Mandatory - BLOCKING)
- [ ] ✅ Dart Analyzer (0 errors, ≤5 warnings)
- [ ] ✅ Code Formatting (100% formatted)
- [ ] ✅ Unit Tests (100% pass, ≥70% coverage)
- [ ] ✅ Security Scan (0 critical/high vulnerabilities)
- [ ] ✅ Secret Detection (0 exposed secrets)
- [ ] ✅ Clean Build (build succeeds)
- [ ] ✅ Smoke Tests (all previous phases still work)

**Report:** `docs/testing/PHASE_[X]_AUTOMATED_CHECKS_REPORT.md`

#### 🟡 Tier 2 (Recommended - Warnings OK)
- [ ] Code Complexity (≤15 per function)
- [ ] Widget Tests (all pass)
- [ ] Integration Tests (critical flows)
- [ ] APK Size (<50MB debug)
- [ ] Accessibility (no critical issues)
- [ ] Performance (startup <3s)

**Warnings Documented:** YES / NO

#### 🟢 Tier 3 (Optional - Nice to Have)
- [ ] Golden Tests (visual regression)
- [ ] Performance Profiling
- [ ] Frame Rate Monitoring

**Tier 3 Run:** YES / NO / SKIPPED

---

### QUALITY GATE: MANUAL TESTING

- [ ] 🧪 Manual app testing workflow completed
  - **Test Report:** `docs/testing/PHASE_[X]_TEST_REPORT.md`
  - **Test Date:** [YYYY-MM-DD]
  - **Grade:** [A-F] ([Score]/100)
  - **Device:** [Emulator/Device]

- [ ] 🐛 Bugs documented
  - **Fixes Document:** `docs/testing/PHASE_[X]_FIXES_REQUIRED.md`
  - **P0 Bugs:** [Count]
  - **P1 Bugs:** [Count]
  - **P2 Bugs:** [Count]
  - **P3 Bugs:** [Count]

---

### QUALITY GATE: BUG FIXES

- [ ] 🔧 All P0 bugs fixed
  - [x] P0-001: [Bug title] - FIXED [Date]
  - (List all P0 bugs with fix status)

- [ ] 🔧 All P1 bugs fixed OR deferred
  - [x] P1-002: [Bug title] - FIXED [Date]
  - [ ] P1-003: [Bug title] - DEFERRED (Reason: [justification])

- [ ] 🔧 P2/P3 bugs triaged
  - **Fixed Now:** [Count]
  - **Moved to Backlog:** [Count]

---

### QUALITY GATE: VERIFICATION

- [ ] ✔️ All fixes verified (re-tested)
  - **Verification Date:** [YYYY-MM-DD]
  - **New Bugs Introduced:** NONE / [Count]
  - **Smoke Tests Pass:** YES / NO

---

### QUALITY GATE: DOCUMENTATION

- [ ] 📚 CHANGELOG.md updated
- [ ] 📚 Feature list updated
- [ ] 📚 Roadmap checkboxes updated
- [ ] 📚 Screenshots captured (key screens)

---

### PHASE COMPLETION VALIDATION

- [ ] 🎯 **Validation Script Passed**
  - **Command:** `bash scripts/phase_completion/can_complete_phase.sh [X]`
  - **Result:** ✅ PASSED / ❌ FAILED
  - **Date:** [YYYY-MM-DD]

- [ ] 🎯 **Phase Marked Complete**
  - **Command:** `bash scripts/phase_completion/mark_phase_complete.sh [X]`
  - **Completion Report:** `docs/completed/PHASE_[X]_COMPLETION_REPORT.md`
  - **Git Tag:** `phase-[X]-complete`
  - **Date:** [YYYY-MM-DD]

---

**Section Complete:** YES ✅ / NO ❌

**Sign-off:**
- **Developer:** [Name/Date]
- **Tester:** [Name/Date]
- **Quality Gate:** PASSED ✅ / FAILED ❌

---
```

---

## ⏱️ TIME ESTIMATES

### Per-Phase Quality Gate Time Budget

**Setup (One-Time):**
- Infrastructure setup: 16 hours (2 days)
- Create first smoke test suite: 4 hours
- Document templates: 2 hours
- **Total Setup:** 22 hours (3 days)

**Per Phase (Recurring):**

| Activity | Time | Who | When |
|----------|------|-----|------|
| Automated Checks (Tier 1) | 10-15 min | Automatic | After dev complete |
| Automated Checks (Tier 2) | 10 min | Automatic | After dev complete |
| Manual App Testing | 30-60 min | Human | After automated pass |
| Bug Documentation | 15-30 min | Human | After testing |
| Bug Fixes (P0/P1) | 2-8 hours | Developer | As needed |
| Bug Fixes (P2) | 1-3 hours | Developer | If time allows |
| Verification (Re-test) | 20-30 min | Human | After fixes |
| Documentation Updates | 15-30 min | Human | After verification |
| Validation & Completion | 10 min | Automatic | Before mark complete |

**Total Per Phase:** 4-12 hours (depends on bug count)

**Recommendation:** Budget 1 full working day per phase for quality gates

---

### Continuous Quality Time (During Development)

| Activity | Time | Frequency |
|----------|------|-----------|
| Pre-commit hooks | 5-10 sec | Every commit |
| GitHub Actions CI | 10-15 min | Every push |
| Manual testing (during dev) | 10-20 min/day | Daily |
| Code review | 15-30 min | Per PR |

**Impact:** Minimal (mostly automatic)

---

### Monthly Quality Maintenance

| Activity | Time | Purpose |
|----------|------|---------|
| Tier 3 performance audit | 2 hours | Track trends |
| Dependency updates | 1 hour | Security patches |
| Backlog triage | 1 hour | Prioritize P3 bugs |
| Smoke test review | 1 hour | Keep tests current |

**Total Monthly:** 5 hours

---

## 🛠️ TOOLS NEEDED

### Testing Frameworks

**Flutter Testing:**
```yaml
# pubspec.yaml (already have most)
dev_dependencies:
  test: ^1.24.0
  flutter_test:
    sdk: flutter
  integration_test:
    sdk: flutter
  mockito: ^5.4.0
  build_runner: ^2.4.0
```

**Code Coverage:**
```bash
flutter pub add --dev coverage
# Generates coverage/lcov.info
```

---

### Code Quality Tools

**Linting & Formatting:**
```bash
# Built-in Flutter tools
flutter analyze
dart format
```

**Complexity Analysis:**
```bash
# Install scc (Source Code Counter)
brew install scc  # macOS
# or
snap install scc  # Linux
```

---

### Security Tools

**Dependency Scanning:**
```bash
# Flutter pub outdated (built-in)
flutter pub outdated

# Vulnerability scanner (optional)
flutter pub global activate vulnerability_scanner
```

**Secret Detection:**
```bash
# Gitleaks (recommended)
brew install gitleaks  # macOS
# or
wget https://github.com/gitleaks/gitleaks/releases/latest
```

---

### Performance Tools

**App Profiling:**
```bash
# Flutter DevTools (built-in)
flutter pub global activate devtools
flutter run --profile

# ADB (Android Debug Bridge - already have)
adb shell am start -W <package>  # Startup time
adb shell dumpsys meminfo <package>  # Memory
```

---

### CI/CD Tools

**GitHub Actions:**
- Free tier: 2,000 minutes/month (enough)
- No setup needed (already on GitHub)

**Alternative (if needed):**
- GitLab CI/CD
- Jenkins (self-hosted)
- Travis CI

---

### Bug Tracking Tools

**Current Approach:** Markdown files (simple, version-controlled)

**Future Options:**
- GitHub Issues (native integration)
- Linear (modern issue tracker)
- Jira (enterprise)

**Recommendation:** Start with markdown, migrate to GitHub Issues when team grows

---

### Screenshot/Testing Tools

**Manual Screenshots:**
```bash
# ADB screenshot
adb exec-out screencap -p > screenshot.png

# Flutter integration test screenshots
await binding.takeScreenshot('test_name');
```

**Automated Screenshot Testing (Future):**
```bash
# Golden file testing
flutter test --update-goldens
```

---

### Documentation Tools

**Current:** Markdown (simple, effective)

**Future Enhancements:**
- MkDocs (static site generator for docs)
- Docusaurus (React-based docs)
- GitHub Wiki

---

## 🚀 IMPLEMENTATION ROADMAP

### Week 1: Infrastructure Setup

**Day 1-2: Scripts & Automation**
- [ ] Create scripts/ directory structure
- [ ] Write tier1_mandatory_checks.sh
- [ ] Write tier2_recommended_checks.sh
- [ ] Write helper scripts (coverage, vulnerabilities, etc.)
- [ ] Test all scripts locally

**Day 3: Bug Tracking System**
- [ ] Create docs/bugs/ directory
- [ ] Write ACTIVE_BUGS.md template
- [ ] Write bug tracking scripts
- [ ] Migrate P0-001 (tank creation bug) to tracker
- [ ] Test bug counting automation

**Day 4: Phase Completion System**
- [ ] Write can_complete_phase.sh
- [ ] Write mark_phase_complete.sh
- [ ] Write update_roadmap.sh
- [ ] Create completion report template
- [ ] Test validation logic

**Day 5: CI/CD Setup**
- [ ] Create .github/workflows/ directory
- [ ] Write quality_gates.yml
- [ ] Write regression_tests.yml
- [ ] Test workflows on test branch
- [ ] Verify all checks run successfully

---

### Week 2: Testing & Documentation

**Day 1: Smoke Test Suite**
- [ ] Create test/smoke/ directory
- [ ] Write phase_0_smoke_test.dart
- [ ] Write phase_1_smoke_test.dart
- [ ] Write all_smoke_tests.dart
- [ ] Run smoke tests, ensure they pass

**Day 2: Documentation Templates**
- [ ] Create phase checkpoint template
- [ ] Create test report template
- [ ] Create fixes required template
- [ ] Update CHANGELOG.md format
- [ ] Document all templates in README

**Day 3: Retroactive Phase 1 Testing**
- [ ] Run automated checks on current codebase
- [ ] Create PHASE_1_AUTOMATED_CHECKS_REPORT.md
- [ ] Create PHASE_1_TEST_REPORT.md (from existing testing)
- [ ] Create PHASE_1_FIXES_REQUIRED.md (with P0-001)
- [ ] Document current state honestly

**Day 4-5: Fix P0-001 (Tank Creation Bug)**
- [ ] Investigate form state management issue
- [ ] Fix value persistence bug
- [ ] Fix preset button population
- [ ] Test fix thoroughly
- [ ] Update PHASE_1_FIXES_REQUIRED.md (mark fixed)
- [ ] Verify fix with smoke test

---

### Week 3: Enforcement & Polish

**Day 1: Pre-commit Hooks**
- [ ] Write pre-commit hook (format + analyze)
- [ ] Write pre-push hook (tests + security)
- [ ] Install hooks in repo
- [ ] Test hook execution
- [ ] Document hook setup for contributors

**Day 2: Master Orchestration Script**
- [ ] Write run_all_checks.sh (master script)
- [ ] Integrate all tiers
- [ ] Generate HTML quality report
- [ ] Test full workflow end-to-end
- [ ] Document usage in README

**Day 3: Phase 1 Completion (Retroactive)**
- [ ] Run: can_complete_phase.sh PHASE_1
- [ ] Fix any missing requirements
- [ ] Run: mark_phase_complete.sh PHASE_1
- [ ] Verify roadmap updated
- [ ] Create PHASE_1_COMPLETION_REPORT.md

**Day 4: Documentation**
- [ ] Write ROADMAP_QUALITY_ENFORCEMENT.md (this document)
- [ ] Update README with quality gate info
- [ ] Create CONTRIBUTING.md with workflow
- [ ] Document all scripts with usage examples
- [ ] Create quality gate video walkthrough (optional)

**Day 5: Review & Testing**
- [ ] Full walkthrough of entire system
- [ ] Test on clean checkout
- [ ] Fix any edge cases found
- [ ] Get feedback from team (if applicable)
- [ ] Finalize and commit all changes

---

### Week 4: Phase 2 Preparation

**Day 1: Phase 2 Planning**
- [ ] Define Phase 2 features
- [ ] Create Phase 2 checkpoint in roadmap
- [ ] Set up Phase 2 branch
- [ ] Document quality gate requirements

**Day 2: Baseline Testing**
- [ ] Run smoke tests (verify Phase 1 stable)
- [ ] Check for regressions
- [ ] Document baseline performance metrics
- [ ] Create Phase 2 test plan

**Day 3-5: Phase 2 Development Begins**
- [ ] Start Phase 2 feature work
- [ ] Quality gates run automatically (CI/CD)
- [ ] Fix issues as they arise
- [ ] Track progress in roadmap

---

## 📊 SUCCESS METRICS

### Quality Gate Compliance

**Target:** 100% compliance for Phase 2+

**Metrics:**
- % of phases with automated checks run
- % of phases with test reports created
- % of phases with all P0 bugs fixed
- % of phases with smoke tests passing

**Current Baseline (Phase 1):** 0% → **Target: 100%**

---

### Bug Tracking Effectiveness

**Metrics:**
- Average time to fix P0 bugs (target: <24h)
- Average time to fix P1 bugs (target: <3 days)
- % of bugs caught in testing (vs production)
- Bug recurrence rate (target: <5%)

**Dashboard:** `docs/bugs/BUG_METRICS.md` (auto-generated)

---

### Code Quality Trends

**Metrics:**
- Code coverage % (target: ≥70%, stretch: 80%)
- Test pass rate (target: 100%)
- Analyzer warnings (target: ≤5 per phase)
- APK size growth (target: <10% per phase)
- App startup time (target: <3 seconds)

**Dashboard:** Updated in each `PHASE_X_AUTOMATED_CHECKS_REPORT.md`

---

### Development Velocity

**Metrics:**
- Average phase duration (goal: consistent)
- Quality gate time % of total (goal: <20%)
- Rework due to regressions (goal: <10%)
- Time saved by catching bugs early (measure vs production fixes)

**Review:** Monthly retrospective

---

## 🎯 ENFORCEMENT MECHANISMS

### How Quality Gates are ENFORCED (Not Optional)

**1. GitHub Actions (Automatic Blocking)**
```yaml
# Pull requests CANNOT merge if:
# - Tier 1 checks fail
# - Smoke tests fail
# - Build fails

# This is AUTOMATIC - no human override
```

**2. Phase Completion Script (Validation Required)**
```bash
# can_complete_phase.sh returns exit code 1 if:
# - Test reports missing
# - P0 bugs active
# - Smoke tests failing

# Cannot proceed without passing validation
```

**3. Pre-commit Hooks (Local Enforcement)**
```bash
# Commit REJECTED if:
# - Code not formatted
# - Analyzer errors present

# Happens locally before code even pushed
```

**4. Code Review Checklist (Human Verification)**
```markdown
## PR Checklist

- [ ] All tests pass
- [ ] Code coverage ≥70%
- [ ] No new analyzer warnings
- [ ] Manual testing completed
- [ ] Documentation updated

# Reviewers check these before approval
```

**5. Phase Transition Approval (Final Gate)**
```bash
# Master roadmap cannot be updated to "Complete" without:
# 1. Running mark_phase_complete.sh (generates evidence)
# 2. All validation checks passing
# 3. Test reports committed to repo
# 4. Git tag created (phase-X-complete)

# Historical record in git history
```

---

### Making It Impossible to Skip

**Technical Enforcement:**
- Branch protection rules (require CI passing)
- Pre-commit hooks (format/analyze automatically)
- Phase completion script (validates requirements)
- Git tags (mark official completion)

**Process Enforcement:**
- Quality gate checklist in roadmap (visible progress)
- Test reports required (evidence-based)
- Bug tracker integration (P0/P1 must be fixed)
- Sign-off required (accountability)

**Cultural Enforcement:**
- Quality gates documented (clear expectations)
- Automation removes friction (easy to do right thing)
- Fast feedback (CI runs in 10-15 min)
- Visible progress (checkboxes, reports)

---

## 🏁 NEXT STEPS

### Immediate Actions (This Week)

**Priority 1: Fix P0-001 (Blocker)**
- [ ] Investigate tank creation form bug
- [ ] Fix value persistence issue
- [ ] Test fix thoroughly
- [ ] Update ACTIVE_BUGS.md (mark fixed)

**Priority 2: Set Up Infrastructure**
- [ ] Create scripts/ directory structure
- [ ] Write tier1_mandatory_checks.sh
- [ ] Write can_complete_phase.sh
- [ ] Create bug tracking system

**Priority 3: Retroactive Phase 1 Documentation**
- [ ] Create PHASE_1_AUTOMATED_CHECKS_REPORT.md
- [ ] Create PHASE_1_TEST_REPORT.md (from existing testing)
- [ ] Create PHASE_1_FIXES_REQUIRED.md
- [ ] Mark Phase 1 as "95% complete, fixing P0-001"

---

### Short-Term (Next 2 Weeks)

**Week 1:**
- [ ] Complete infrastructure setup
- [ ] Write all quality gate scripts
- [ ] Set up GitHub Actions CI/CD
- [ ] Create smoke test suite
- [ ] Fix P0-001 bug

**Week 2:**
- [ ] Test entire quality gate system end-to-end
- [ ] Complete retroactive Phase 1 documentation
- [ ] Mark Phase 1 officially complete
- [ ] Prepare for Phase 2 with quality gates enforced

---

### Long-Term (Ongoing)

**For Each Future Phase:**
- [ ] Run quality gates automatically (CI/CD)
- [ ] Create phase-specific test reports
- [ ] Track bugs systematically
- [ ] Verify fixes before completion
- [ ] Update documentation

**Monthly Maintenance:**
- [ ] Review bug backlog
- [ ] Update dependencies
- [ ] Run Tier 3 performance audit
- [ ] Review smoke test coverage

**Quarterly:**
- [ ] Retrospective on quality gate effectiveness
- [ ] Adjust thresholds if needed
- [ ] Update automation scripts
- [ ] Celebrate quality improvements 🎉

---

## 📝 APPENDIX

### A. Quality Gate Checklist (Quick Reference)

**Before Marking Phase Complete:**
- [ ] All development tasks done
- [ ] Tier 1 automated checks passed
- [ ] Manual testing completed (test report created)
- [ ] All bugs documented (fixes required document)
- [ ] All P0 bugs fixed and verified
- [ ] All P1 bugs fixed or deferred
- [ ] P2/P3 bugs triaged
- [ ] Smoke tests passing (no regressions)
- [ ] Documentation updated
- [ ] Validation script passed
- [ ] Phase marked complete (script run)

---

### B. File Naming Conventions

**Test Reports:**
- `PHASE_[X]_AUTOMATED_CHECKS_REPORT.md`
- `PHASE_[X]_TEST_REPORT.md`
- `PHASE_[X]_FIXES_REQUIRED.md`

**Completion Reports:**
- `PHASE_[X]_COMPLETION_REPORT.md`

**Bug Tracking:**
- `ACTIVE_BUGS.md`
- `FIXED_BUGS.md`
- `BACKLOG.md`

**Smoke Tests:**
- `test/smoke/phase_[X]_smoke_test.dart`

**Git Tags:**
- `phase-[X]-complete`

---

### C. Command Reference

**Run Quality Checks:**
```bash
# Tier 1 (mandatory)
bash scripts/quality_gates/tier1_mandatory_checks.sh PHASE_2

# Tier 2 (recommended)
bash scripts/quality_gates/tier2_recommended_checks.sh PHASE_2

# All checks
bash scripts/quality_gates/run_all_checks.sh PHASE_2
```

**Bug Tracking:**
```bash
# Update bug counts
bash scripts/bug_tracking/track_bug_status.sh

# Check for P0 blockers
bash scripts/bug_tracking/check_p0_blockers.sh

# Migrate P3 to backlog
bash scripts/bug_tracking/migrate_to_backlog.sh PHASE_2
```

**Phase Completion:**
```bash
# Validate phase can be completed
bash scripts/phase_completion/can_complete_phase.sh PHASE_2

# Mark phase complete (after validation passes)
bash scripts/phase_completion/mark_phase_complete.sh PHASE_2
```

**Testing:**
```bash
# Run smoke tests
bash scripts/testing/run_smoke_tests.sh

# Build and install
bash scripts/testing/build_and_install.sh

# Verify fixes
bash scripts/testing/verify_fixes.sh PHASE_2
```

---

### D. Troubleshooting

**Issue: Tier 1 checks fail**
- Review automated checks report
- Fix errors in priority order
- Re-run checks
- Don't skip - these are blocking for a reason

**Issue: can_complete_phase.sh fails**
- Check which requirement failed
- Create missing test reports
- Fix P0/P1 bugs
- Update documentation
- Re-run validation

**Issue: Smoke tests fail (regression)**
- Identify which previous phase broke
- Create regression bug (P1 priority)
- Fix before proceeding
- Update smoke test if needed

**Issue: CI/CD taking too long**
- Optimize tests (mock external deps)
- Run expensive tests less frequently
- Parallelize test execution
- Cache dependencies

---

## ✅ CONCLUSION

### What This Roadmap Achieves

**Transforms Quality Gates From:**
- ❌ Documentation theater
- ❌ Manual, easy to skip
- ❌ Optional "nice to have"
- ❌ 0% compliance

**To:**
- ✅ Automatic enforcement
- ✅ Impossible to skip
- ✅ Required for phase completion
- ✅ 100% compliance (target)

---

### Key Success Factors

**1. Automation**
- Pre-commit hooks run automatically
- CI/CD enforces on every push
- Scripts validate phase completion
- No manual gatekeeping needed

**2. Integration**
- Built into git workflow
- Part of development process
- Fast feedback (10-15 min CI)
- Minimal friction

**3. Accountability**
- Test reports as evidence
- Bug tracker shows progress
- Git tags mark official completion
- Historical record in repo

**4. Continuous Improvement**
- Metrics track quality trends
- Retrospectives refine process
- Scripts evolve with project
- Smoke tests grow over time

---

### Expected Outcomes

**Quality:**
- Fewer bugs in production
- Regressions caught early
- Consistent code quality
- Better user experience

**Velocity:**
- Less rework (catch bugs early)
- Faster debugging (better tests)
- Confident deployments
- Predictable timelines

**Confidence:**
- Know what "done" means
- Trust phase completions
- Rely on quality gates
- Sleep better at night 😴

---

**This roadmap provides the foundation for sustainable, high-quality development.**

**Implementation starts now. Quality is no longer optional.**

---

**Document Version:** 1.0  
**Created:** February 11, 2026  
**Authors:** Sub-Agent 5 (Quality Enforcement Specialist)  
**Status:** ✅ READY FOR IMPLEMENTATION

**Next Action:** Begin Week 1 infrastructure setup
