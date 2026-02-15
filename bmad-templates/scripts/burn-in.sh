#!/bin/bash
# Burn-In Test Runner
# Runs tests multiple times to detect flaky tests
# Usage: ./scripts/burn-in.sh [iterations] [base-branch]

set -e

# Configuration
ITERATIONS=${1:-10}
BASE_BRANCH=${2:-main}
SPEC_PATTERN='\.(spec|test)\.(ts|js|tsx|jsx)$'

echo "Burn-In Test Runner"
echo "============================================"
echo "Iterations: $ITERATIONS"
echo "Base branch: $BASE_BRANCH"
echo ""

# Check if we should run only changed specs
CHANGED_SPECS=""
if git rev-parse --git-dir > /dev/null 2>&1; then
  CHANGED_SPECS=$(git diff --name-only "$BASE_BRANCH"...HEAD 2>/dev/null | grep -E "$SPEC_PATTERN" || echo "")
fi

if [ -n "$CHANGED_SPECS" ]; then
  echo "Changed test files detected:"
  echo "$CHANGED_SPECS" | while read -r line; do echo "  - $line"; done
  echo ""
  echo "Running burn-in on changed specs only..."
  TEST_FILES="$CHANGED_SPECS"
else
  echo "No changed test files detected or not in git repo."
  echo "Running burn-in on full test suite..."
  TEST_FILES=""
fi

echo ""

# Burn-in loop
for i in $(seq 1 "$ITERATIONS"); do
  echo "============================================"
  echo "Iteration $i/$ITERATIONS"
  echo "============================================"

  if [ -n "$TEST_FILES" ]; then
    # Run only changed specs
    # shellcheck disable=SC2086
    if npm run test:e2e -- $TEST_FILES; then
      echo "Iteration $i passed"
    else
      echo ""
      echo "BURN-IN FAILED on iteration $i"
      echo "Tests are flaky - investigate and fix!"
      echo ""
      echo "Failure artifacts saved to: test-results/"
      exit 1
    fi
  else
    # Run full suite
    if npm run test:e2e; then
      echo "Iteration $i passed"
    else
      echo ""
      echo "BURN-IN FAILED on iteration $i"
      echo "Tests are flaky - investigate and fix!"
      echo ""
      echo "Failure artifacts saved to: test-results/"
      exit 1
    fi
  fi

  echo ""
done

echo "============================================"
echo "BURN-IN PASSED"
echo "============================================"
echo "All $ITERATIONS iterations passed."
echo "Tests are stable and ready to merge."
exit 0
