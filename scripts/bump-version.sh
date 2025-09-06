#!/bin/bash
set -e

# 1. Get last tag, default to v0.0.0 if none exist
LAST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "v0.0.0")
echo "Last tag: $LAST_TAG"

# 2. Get commits since last tag
COMMITS=$(git log $LAST_TAG..HEAD --pretty=format:"%s")
echo "Commits since last tag:"
echo "$COMMITS"

# 3. Decide bump type
if echo "$COMMITS" | grep -q "BREAKING CHANGE"; then
  BUMP="major"
elif echo "$COMMITS" | grep -q "^feat"; then
  BUMP="minor"
elif echo "$COMMITS" | grep -q "^fix"; then
  BUMP="patch"
else
  BUMP="patch"
fi
echo "Version bump: $BUMP"

# 4. Increment version
IFS='.' read -r MAJOR MINOR PATCH <<< "${LAST_TAG#v}"
case $BUMP in
  major) MAJOR=$((MAJOR+1)); MINOR=0; PATCH=0 ;;
  minor) MINOR=$((MINOR+1)); PATCH=0 ;;
  patch) PATCH=$((PATCH+1)) ;;
esac
NEW_TAG="v$MAJOR.$MINOR.$PATCH"
echo "New version: $NEW_TAG"

# 5. Expose the version to GitHub Actions
echo "version=$NEW_TAG" >> $GITHUB_OUTPUT
