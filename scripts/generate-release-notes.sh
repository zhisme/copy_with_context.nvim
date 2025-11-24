#!/bin/bash
# Generate release notes from git commit history
# Usage: ./scripts/generate-release-notes.sh [TAG]
# If TAG is not provided, generates notes since last tag

set -e

# Get the tag to compare against
if [ -n "$1" ]; then
  LAST_TAG="$1"
else
  LAST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "")
fi

if [ -z "$LAST_TAG" ]; then
  echo "## All Commits"
  echo ""
  git log --pretty=format:"- %s (%h)" --reverse
  exit 0
fi

echo "## Changes since ${LAST_TAG}"
echo ""

# Function to print commits matching a pattern
print_commits() {
  local pattern="$1"
  local commits=$(git log ${LAST_TAG}..HEAD --grep="$pattern" --pretty=format:"- %s (%h)" --reverse 2>/dev/null)
  if [ -n "$commits" ]; then
    echo "$commits"
  fi
}

# Breaking changes (highest priority)
echo "### ⚠️  Breaking Changes"
breaking=$(print_commits "BREAKING")
if [ -z "$breaking" ]; then
  echo "_None_"
else
  echo "$breaking"
fi
echo ""

# Features
echo "### ✨ Features"
features=$(print_commits "^feat")
if [ -z "$features" ]; then
  echo "_None_"
else
  echo "$features"
fi
echo ""

# Bug fixes
echo "### 🐛 Bug Fixes"
fixes=$(print_commits "^fix")
if [ -z "$fixes" ]; then
  echo "_None_"
else
  echo "$fixes"
fi
echo ""

# Refactoring
echo "### ♻️  Refactoring"
refactor=$(print_commits "^refactor")
if [ -z "$refactor" ]; then
  echo "_None_"
else
  echo "$refactor"
fi
echo ""

# Documentation
echo "### 📚 Documentation"
docs=$(print_commits "^docs")
if [ -z "$docs" ]; then
  echo "_None_"
else
  echo "$docs"
fi
echo ""

# Tests
echo "### ✅ Tests"
tests=$(print_commits "^test")
if [ -z "$tests" ]; then
  echo "_None_"
else
  echo "$tests"
fi
echo ""

# Chores
echo "### 🔧 Maintenance"
chores=$(print_commits "^chore")
if [ -z "$chores" ]; then
  echo "_None_"
else
  echo "$chores"
fi
echo ""

# All other commits not matching patterns above
echo "### 📝 Other Changes"
other=$(git log ${LAST_TAG}..HEAD \
  --invert-grep \
  --grep="BREAKING" \
  --grep="^feat" \
  --grep="^fix" \
  --grep="^refactor" \
  --grep="^docs" \
  --grep="^test" \
  --grep="^chore" \
  --pretty=format:"- %s (%h)" \
  --reverse 2>/dev/null)
if [ -z "$other" ]; then
  echo "_None_"
else
  echo "$other"
fi
echo ""

# Summary statistics
echo "---"
echo ""
total=$(git rev-list ${LAST_TAG}..HEAD --count)
contributors=$(git log ${LAST_TAG}..HEAD --format='%an' | sort -u | wc -l)
echo "**Total commits:** $total"
echo "**Contributors:** $contributors"
