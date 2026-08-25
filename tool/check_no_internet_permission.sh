#!/bin/sh
#
# Guards the Android permission policy and the no-cloud dependency rule.
#
# History: until 2026-08-23 the app was fully offline and this script demanded that
# INTERNET and ACCESS_NETWORK_STATE be stripped with tools:node="remove". The Wi-Fi Sync
# feature (2026-08-24) needs both to open a direct device-to-device TCP socket on the
# user's own LAN, so the policy changed. There is still no cloud, no server and no HTTP
# client, and this script is what keeps it that way.
#
# What it enforces:
#   1. WAKE_LOCK is stripped with tools:node="remove".
#   2. INTERNET and ACCESS_NETWORK_STATE are declared and NOT stripped (Wi-Fi Sync needs
#      them; removing them would silently break sync).
#   3. No deny-listed permission (wider network reach, location, boot, background service)
#      appears at all.
#   4. No HTTP or cloud client package appears in pubspec.yaml dependencies.
#
# Usage:
#   sh tool/check_no_internet_permission.sh [MERGED_MANIFEST_PATH]
#
# Exits 0 when every rule holds, 1 on any failure.

set -u

MAIN_MANIFEST="android/app/src/main/AndroidManifest.xml"
PUBSPEC="pubspec.yaml"

# Permissions that must be present and must NOT be stripped.
REQUIRED_PERMS="android.permission.INTERNET android.permission.ACCESS_NETWORK_STATE"

# Permissions that arrive transitively and must be stripped.
REMOVED_PERMS="android.permission.WAKE_LOCK"

# Permissions that must never appear. Adding one needs a plan and a deliberate edit here.
DENIED_PERMS="android.permission.ACCESS_WIFI_STATE
android.permission.CHANGE_WIFI_STATE
android.permission.ACCESS_COARSE_LOCATION
android.permission.ACCESS_FINE_LOCATION
android.permission.ACCESS_BACKGROUND_LOCATION
android.permission.RECEIVE_BOOT_COMPLETED
android.permission.FOREGROUND_SERVICE"

# Package names that would pull in cloud or HTTP traffic.
BLOCKED_PACKAGES="http dio firebase_core cloud_firestore supabase_flutter googleapis connectivity_plus"

if [ ! -f "$MAIN_MANIFEST" ]; then
  echo "Error: $MAIN_MANIFEST not found." >&2
  exit 1
fi

FAILED=0

echo "Checking production manifest ($MAIN_MANIFEST) against the permission policy..."

# Prints the whole <uses-permission ... /> element that declares "$1", on one line.
# awk is used because the element is often split across several lines in the manifest.
perm_block() {
  awk -v want="$1" '
    /<uses-permission/ { inside = 1; buf = "" }
    inside { buf = buf " " $0 }
    inside && /\/>|<\/uses-permission>/ {
      inside = 0
      if (buf ~ ("android:name=\"" want "\"")) print buf
      buf = ""
    }
  ' "$MAIN_MANIFEST"
}

# Rule 1: transitive permissions that must be stripped.
for perm in $REMOVED_PERMS; do
  if perm_block "$perm" | grep -q 'tools:node="remove"'; then
    echo "  [OK] $perm has tools:node=\"remove\""
  else
    echo "  [ERROR] $perm is missing tools:node=\"remove\" in $MAIN_MANIFEST" >&2
    FAILED=1
  fi
done

# Rule 2: permissions Wi-Fi Sync needs. Present, and not stripped.
for perm in $REQUIRED_PERMS; do
  block=$(perm_block "$perm")
  if [ -z "$block" ]; then
    echo "  [ERROR] $perm is not declared in $MAIN_MANIFEST; Wi-Fi Sync needs it" >&2
    FAILED=1
  elif echo "$block" | grep -q 'tools:node="remove"'; then
    echo "  [ERROR] $perm is stripped with tools:node=\"remove\"; that breaks Wi-Fi Sync" >&2
    FAILED=1
  else
    echo "  [OK] $perm is declared for local Wi-Fi Sync"
  fi
done

# Rule 3: permissions that must never appear.
for perm in $DENIED_PERMS; do
  if grep -q "android:name=\"$perm\"" "$MAIN_MANIFEST"; then
    echo "  [ERROR] Deny-listed permission found in $MAIN_MANIFEST: $perm" >&2
    FAILED=1
  fi
done
echo "  [OK] No deny-listed permission is declared"

if [ "$FAILED" -ne 0 ]; then
  echo "Manifest permission policy check failed in $MAIN_MANIFEST." >&2
  exit 1
fi

# Rule 4: no HTTP or cloud client in the dependency list.
if [ -f "$PUBSPEC" ]; then
  echo "Checking $PUBSPEC for blocked network packages..."
  for pkg in $BLOCKED_PACKAGES; do
    # Match a top-level dependency key only: two-space indent, package name, colon.
    if grep -E -q "^  $pkg:" "$PUBSPEC"; then
      echo "  [ERROR] Blocked package found in $PUBSPEC: $pkg" >&2
      FAILED=1
    fi
  done
  if [ "$FAILED" -eq 0 ]; then
    echo "  [OK] No HTTP or cloud client package is declared"
  fi
else
  echo "Warning: $PUBSPEC not found; skipping dependency check."
fi

if [ "$FAILED" -ne 0 ]; then
  echo "Dependency check failed." >&2
  exit 1
fi

# Optional: check a merged manifest when its path is supplied.
MERGED_MANIFEST=""
if [ "$#" -ge 1 ]; then
  MERGED_MANIFEST="$1"
fi

if [ -n "$MERGED_MANIFEST" ]; then
  if [ -f "$MERGED_MANIFEST" ]; then
    echo "Checking merged manifest ($MERGED_MANIFEST)..."
    for perm in $REMOVED_PERMS $DENIED_PERMS; do
      if grep -q "android:name=\"$perm\"" "$MERGED_MANIFEST"; then
        echo "  [ERROR] Prohibited permission found in merged manifest: $perm" >&2
        FAILED=1
      else
        echo "  [OK] Prohibited permission absent from merged manifest: $perm"
      fi
    done
    for perm in $REQUIRED_PERMS; do
      if grep -q "android:name=\"$perm\"" "$MERGED_MANIFEST"; then
        echo "  [OK] Required permission present in merged manifest: $perm"
      else
        echo "  [ERROR] Required permission missing from merged manifest: $perm" >&2
        FAILED=1
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

echo "All permission and dependency guards passed."
exit 0
