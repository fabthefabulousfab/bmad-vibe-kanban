#!/bin/bash
# Selective Test Runner
# Runs only tests for changed files
# Usage: ./scripts/test-changed.sh [base-branch]

set -e

BASE_BRANCH=${1:-main}
SPEC_PATTERN='\.(spec|test)\.(ts|js|tsx|jsx)$'

echo "Selective Test Runner"
echo "============================================"
echo "Base branch: $BASE_BRANCH"
echo ""

# Detect changed test files
CHANGED_SPECS=$(git diff --name-only "$BASE_BRANCH"...HEAD | grep -E "$SPEC_PATTERN" || echo "")

if [ -z "$CHANGED_SPECS" ]; then
  echo "No test files changed since $BASE_BRANCH."
  echo "Skipping tests."
  exit 0
fi

echo "Changed test files:"
echo "$CHANGED_SPECS" | while read -r line; do echo "  - $line"; done
echo ""

# Count specs
SPEC_COUNT=$(echo "$CHANGED_SPECS" | wc -l | xargs)
echo "Running $SPEC_COUNT changed test file(s)..."
echo ""

# Run changed tests
# shellcheck disable=SC2086
npm run test:e2e -- $CHANGED_SPECS

echo ""
echo "============================================"
echo "Changed tests completed"
echo "============================================"
