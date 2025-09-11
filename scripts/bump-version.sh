#!/bin/bash
set -e

# 1. Get last tag, detect if none exist
LAST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "")

if [ -z "$LAST_TAG" ]; then
  echo "No previous tag found. Using all commits."
  COMMITS=$(git log HEAD --pretty=format:"%s")
else
  echo "Last tag: $LAST_TAG"
  COMMITS=$(git log $LAST_TAG..HEAD --pretty=format:"%s")
fi

echo "Commits to analyze:"
echo "$COMMITS"

# 2. Decide bump type
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

# 3. Determine last tag version numbers
if [ -z "$LAST_TAG" ]; then
  MAJOR=0
  MINOR=0
  PATCH=0
else
  IFS='.' read -r MAJOR MINOR PATCH <<< "${LAST_TAG#v}"
fi

# 4. Increment version
case $BUMP in
  major) MAJOR=$((MAJOR+1)); MINOR=0; PATCH=0 ;;
  minor) MINOR=$((MINOR+1)); PATCH=0 ;;
  patch) PATCH=$((PATCH+1)) ;;
esac

NEW_TAG="v$MAJOR.$MINOR.$PATCH"
echo "New version: $NEW_TAG"

# 5. Expose version to GitHub Actions
echo "version=$NEW_TAG" >> $GITHUB_OUTPUT


#------------environment based
#!/bin/bash
set -e

# Accept ENVIRONMENT as input
ENVIRONMENT=${ENVIRONMENT:-dev}  # default to 'dev' if not provided

echo "Environment: $ENVIRONMENT"

# 1. Fetch all tags
git fetch --tags

# 2. Get last tag globally, ignore branch history
LAST_TAG=$(git tag --sort=-v:refname | head -n1 || echo "")

if [ -z "$LAST_TAG" ]; then
  echo "No previous tag found. Using all commits."
  COMMITS=$(git log HEAD --pretty=format:"%s")
else
  echo "Last tag: $LAST_TAG"
  COMMITS=$(git log $LAST_TAG..HEAD --pretty=format:"%s")
fi

echo "Commits to analyze:"
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

# 4. Determine last tag version numbers
if [ -z "$LAST_TAG" ]; then
  MAJOR=0
  MINOR=0
  PATCH=0
else
  # Remove environment prefix if it exists
  TAG_NO_ENV=${LAST_TAG#*-}  # removes "dev-", "stage-", "prod-" prefix
  IFS='.' read -r MAJOR MINOR PATCH <<< "${TAG_NO_ENV#v}"
fi

# 5. Increment version
case $BUMP in
  major) MAJOR=$((MAJOR+1)); MINOR=0; PATCH=0 ;;
  minor) MINOR=$((MINOR+1)); PATCH=0 ;;
  patch) PATCH=$((PATCH+1)) ;;
esac

# 6. Compose new tag with environment prefix
NEW_TAG="${ENVIRONMENT}-v$MAJOR.$MINOR.$PATCH"
echo "New version: $NEW_TAG"

# 7. Expose version to GitHub Actions
echo "version=$NEW_TAG" >> $GITHUB_OUTPUT


