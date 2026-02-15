#!/bin/bash
# Local CI Mirror Script
# Mirrors the GitLab CI pipeline locally for debugging
# Usage: ./scripts/ci-local.sh

set -e

echo "Local CI Pipeline Mirror"
echo "============================================"
echo "This script mirrors the GitLab CI pipeline"
echo "for local debugging before pushing."
echo ""

# Install dependencies
echo "[1/3] Installing dependencies..."
npm ci --prefer-offline --no-audit
echo "Dependencies installed."
echo ""

# Run tests
echo "[2/3] Running E2E tests..."
if npm run test:e2e; then
  echo "Tests passed."
else
  echo ""
  echo "TESTS FAILED"
  echo "Fix failing tests before pushing."
  echo "View report: npx playwright show-report"
  exit 1
fi
echo ""

# Burn-in (reduced iterations for local)
echo "[3/3] Running burn-in (3 iterations)..."
for i in 1 2 3; do
  echo "  Burn-in iteration $i/3..."
  if npm run test:e2e > /dev/null 2>&1; then
    echo "  Iteration $i passed"
  else
    echo ""
    echo "BURN-IN FAILED on iteration $i"
    echo "Tests are flaky - investigate before pushing!"
    npm run test:e2e:report 2>/dev/null || true
    exit 1
  fi
done

echo ""
echo "============================================"
echo "LOCAL CI PIPELINE PASSED"
echo "============================================"
echo "Safe to push to GitLab."
echo ""
echo "Commands:"
echo "  git add ."
echo "  git commit -m 'your message'"
echo "  git push -u origin main"
exit 0
