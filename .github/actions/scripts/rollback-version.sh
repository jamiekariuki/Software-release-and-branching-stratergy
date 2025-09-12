#!/bin/bash
set -e

INPUT_VERSION=$1

if [ -n "$INPUT_VERSION" ]; then
  # Check if the input version exists as a tag
  if git rev-parse -q --verify "refs/tags/$INPUT_VERSION" >/dev/null; then
    ROLLBACK_VERSION="$INPUT_VERSION"
  else
    echo "❌ Version '$INPUT_VERSION' does not exist as a tag"
    exit 1
  fi
else
  # Get the previous version tag (2nd latest)
  ROLLBACK_VERSION=$(git tag --sort=-creatordate | sed -n 2p)
  if [ -z "$ROLLBACK_VERSION" ]; then
    echo "❌ No previous version found to rollback to"
    exit 1
  fi
fi

echo "✅ Rollback version resolved: $ROLLBACK_VERSION"

# Export for GitHub Actions if running in Actions
if [ -n "$GITHUB_OUTPUT" ]; then
  echo "version=$ROLLBACK_VERSION" >> "$GITHUB_OUTPUT"
fi

