#!/bin/sh
#
# Verifies that INTERNET and unused transitive permissions (ACCESS_NETWORK_STATE, WAKE_LOCK)
# are explicitly removed in the Android production manifest and absent from release builds.
#
# Usage:
#   sh tool/check_no_internet_permission.sh [MERGED_MANIFEST_PATH]
#
# Exits 0 when permissions are safely guarded/absent, 1 on failure.

set -u

MAIN_MANIFEST="android/app/src/main/AndroidManifest.xml"

if [ ! -f "$MAIN_MANIFEST" ]; then
  echo "Error: $MAIN_MANIFEST not found." >&2
  exit 1
fi

echo "Checking production manifest ($MAIN_MANIFEST) for permission removal declarations..."

check_node_remove() {
  perm="$1"
  # Search for the permission element and verify it has tools:node="remove"
  # Handles multi-line or single-line XML tags.
  if grep -E -A 2 "<uses-permission[^>]*android:name=\"$perm\"" "$MAIN_MANIFEST" | grep -q 'tools:node="remove"'; then
    echo "  [OK] $perm has tools:node=\"remove\""
  elif grep -E -B 2 'tools:node="remove"' "$MAIN_MANIFEST" | grep -q "$perm"; then
    echo "  [OK] $perm has tools:node=\"remove\""
  else
    echo "  [ERROR] $perm is missing tools:node=\"remove\" in $MAIN_MANIFEST" >&2
    return 1
  fi
  return 0
}

FAILED=0

check_node_remove "android.permission.INTERNET" || FAILED=1
check_node_remove "android.permission.ACCESS_NETWORK_STATE" || FAILED=1
check_node_remove "android.permission.WAKE_LOCK" || FAILED=1

if [ "$FAILED" -ne 0 ]; then
  echo "Manifest permission guard check failed in $MAIN_MANIFEST." >&2
  exit 1
fi

# If a merged manifest path is supplied or found, check it
MERGED_MANIFEST=""
if [ "$#" -ge 1 ]; then
  MERGED_MANIFEST="$1"
fi

if [ -n "$MERGED_MANIFEST" ]; then
  if [ -f "$MERGED_MANIFEST" ]; then
    echo "Checking merged manifest ($MERGED_MANIFEST)..."
    for perm in "android.permission.INTERNET" "android.permission.ACCESS_NETWORK_STATE" "android.permission.WAKE_LOCK"; do
      if grep -q "android:name=\"$perm\"" "$MERGED_MANIFEST"; then
        echo "  [ERROR] Prohibited permission found in merged manifest: $perm" >&2
        FAILED=1
      else
        echo "  [OK] Prohibited permission absent from merged manifest: $perm"
      fi
    done
  else
    echo "Warning: Provided merged manifest path '$MERGED_MANIFEST' does not exist; skipping merged check."
  fi
fi

if [ "$FAILED" -ne 0 ]; then
  echo "Merged manifest permission check failed." >&2
  exit 1
fi

echo "All offline permission guards passed."
exit 0
