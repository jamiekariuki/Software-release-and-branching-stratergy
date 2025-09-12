#!/bin/bash
set -e

EC2_IP=$1
PORT=$2

echo "Running smoke tests against http://$EC2_IP:$PORT"

# Default result
RESULT=true

# Wait for app to boot
for i in {1..10}; do
  if curl -sSf http://$EC2_IP:$PORT > /dev/null; then
    echo "App is up ✅"
    break
  fi
  echo "Not ready yet... retrying ($i/10)"
  sleep 5
done

# Basic smoke tests
if ! curl -f http://$EC2_IP:$PORT > /dev/null; then
  echo "❌ Root endpoint failed"
  RESULT=false
fi


if ! curl -s http://$EC2_IP:$PORT | grep -q '<div id="root">'; then
  echo "❌ Homepage content check failed"
  RESULT=false
fi

echo "Final smoke test result: $RESULT"

# Write to GitHub Actions output (if running inside Actions)
if [ -n "$GITHUB_OUTPUT" ]; then
  echo "result=$RESULT" >> "$GITHUB_OUTPUT"
fi

# Also print for local debugging
echo "$RESULT"
