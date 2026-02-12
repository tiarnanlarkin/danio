#!/bin/bash
# ============================================
# Aquarium App - Quality Gate Checks
# ============================================
# Runs all quality checks before merge/deploy
# Exit codes: 0 = all pass, 1 = failure
# ============================================

set -e  # Exit on first failure

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# Configuration
MAX_APK_SIZE_MB=100
FLUTTER_CMD="${FLUTTER_PATH:-flutter}"

# Track results
PASSED=0
FAILED=0
RESULTS=()

# Get script directory and project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

echo ""
echo "🔍 Running Quality Gate Checks..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "   Project: $PROJECT_ROOT"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

cd "$PROJECT_ROOT"

# ============================================
# 1. Flutter Analyze
# ============================================
echo -n "Running Flutter Analyze... "
ANALYZE_OUTPUT=$($FLUTTER_CMD analyze 2>&1) || true

# Count actual errors (not info/warning)
ERROR_COUNT=$(echo "$ANALYZE_OUTPUT" | grep -cE "^\s*error •" || echo "0")
WARNING_COUNT=$(echo "$ANALYZE_OUTPUT" | grep -cE "^\s*warning •" || echo "0")
INFO_COUNT=$(echo "$ANALYZE_OUTPUT" | grep -cE "^\s*info •" || echo "0")

# Check for "No issues found"
if echo "$ANALYZE_OUTPUT" | grep -q "No issues found"; then
    ERROR_COUNT=0
    WARNING_COUNT=0
    INFO_COUNT=0
fi

if [ "$ERROR_COUNT" -eq 0 ]; then
    echo -e "${GREEN}✅${NC}"
    if [ "$INFO_COUNT" -gt 0 ] || [ "$WARNING_COUNT" -gt 0 ]; then
        RESULTS+=("✅ Flutter Analyze: PASS (0 errors, $WARNING_COUNT warnings, $INFO_COUNT info)")
    else
        RESULTS+=("✅ Flutter Analyze: PASS (0 errors)")
    fi
    ((PASSED++))
else
    echo -e "${RED}❌${NC}"
    RESULTS+=("❌ Flutter Analyze: FAIL ($ERROR_COUNT errors)")
    echo "$ANALYZE_OUTPUT" | grep -E "^\s*error •" | head -20
    ((FAILED++))
fi

# ============================================
# 2. Dart Format Check
# ============================================
echo -n "Running Dart Format Check... "
FORMAT_OUTPUT=$($FLUTTER_CMD format --set-exit-if-changed --dry-run lib test 2>&1) || FORMAT_EXIT=$?
FORMAT_EXIT=${FORMAT_EXIT:-0}

if [ "$FORMAT_EXIT" -eq 0 ]; then
    echo -e "${GREEN}✅${NC}"
    RESULTS+=("✅ Dart Format: PASS (100% compliant)")
    ((PASSED++))
else
    echo -e "${RED}❌${NC}"
    UNFORMATTED=$(echo "$FORMAT_OUTPUT" | wc -l)
    RESULTS+=("❌ Dart Format: FAIL ($UNFORMATTED files need formatting)")
    echo "   Files needing format:"
    echo "$FORMAT_OUTPUT" | head -10 | sed 's/^/     /'
    ((FAILED++))
fi

# ============================================
# 3. Flutter Tests
# ============================================
echo -n "Running Flutter Tests... "
TEST_OUTPUT=$($FLUTTER_CMD test 2>&1) || TEST_EXIT=$?
TEST_EXIT=${TEST_EXIT:-0}

# Extract test counts
TOTAL_TESTS=$(echo "$TEST_OUTPUT" | grep -oE "All [0-9]+ tests passed" | grep -oE "[0-9]+" || echo "0")
if [ "$TOTAL_TESTS" = "0" ]; then
    # Try alternative pattern
    TOTAL_TESTS=$(echo "$TEST_OUTPUT" | grep -oE "[0-9]+ tests? passed" | grep -oE "^[0-9]+" || echo "0")
fi

if [ "$TEST_EXIT" -eq 0 ]; then
    echo -e "${GREEN}✅${NC}"
    if [ "$TOTAL_TESTS" != "0" ]; then
        RESULTS+=("✅ Flutter Test: PASS ($TOTAL_TESTS/$TOTAL_TESTS tests)")
    else
        RESULTS+=("✅ Flutter Test: PASS (all tests passed)")
    fi
    ((PASSED++))
else
    echo -e "${RED}❌${NC}"
    FAILED_TESTS=$(echo "$TEST_OUTPUT" | grep -oE "[0-9]+ failed" | grep -oE "[0-9]+" || echo "?")
    RESULTS+=("❌ Flutter Test: FAIL ($FAILED_TESTS tests failed)")
    echo "$TEST_OUTPUT" | tail -20
    ((FAILED++))
fi

# ============================================
# 4. APK Size Check
# ============================================
echo -n "Checking APK Size... "
APK_PATH="$PROJECT_ROOT/build/app/outputs/flutter-apk/app-release.apk"
APK_DEBUG_PATH="$PROJECT_ROOT/build/app/outputs/flutter-apk/app-debug.apk"

# Try release first, then debug
if [ -f "$APK_PATH" ]; then
    APK_FILE="$APK_PATH"
    APK_TYPE="release"
elif [ -f "$APK_DEBUG_PATH" ]; then
    APK_FILE="$APK_DEBUG_PATH"
    APK_TYPE="debug"
else
    APK_FILE=""
fi

if [ -n "$APK_FILE" ]; then
    APK_SIZE_BYTES=$(stat -c%s "$APK_FILE" 2>/dev/null || stat -f%z "$APK_FILE" 2>/dev/null)
    APK_SIZE_MB=$((APK_SIZE_BYTES / 1024 / 1024))
    
    if [ "$APK_SIZE_MB" -lt "$MAX_APK_SIZE_MB" ]; then
        echo -e "${GREEN}✅${NC}"
        RESULTS+=("✅ APK Size: PASS (${APK_SIZE_MB}MB < ${MAX_APK_SIZE_MB}MB) [$APK_TYPE]")
        ((PASSED++))
    else
        echo -e "${RED}❌${NC}"
        RESULTS+=("❌ APK Size: FAIL (${APK_SIZE_MB}MB >= ${MAX_APK_SIZE_MB}MB)")
        ((FAILED++))
    fi
else
    echo -e "${YELLOW}⚠️${NC}"
    RESULTS+=("⚠️  APK Size: SKIP (no APK found - run flutter build apk first)")
fi

# ============================================
# Summary
# ============================================
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "${BOLD}QUALITY GATE RESULTS${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
for result in "${RESULTS[@]}"; do
    echo -e "$result"
done
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ "$FAILED" -eq 0 ]; then
    echo ""
    echo -e "${GREEN}${BOLD}🎉 ALL CHECKS PASSED${NC}"
    echo ""
    exit 0
else
    echo ""
    echo -e "${RED}${BOLD}💥 $FAILED CHECK(S) FAILED${NC}"
    echo ""
    exit 1
fi
