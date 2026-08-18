#!/bin/sh
#
# Blocks absolute local paths from entering the plans, change logs and docs.
#
# Those files may end up public. An absolute path tells the reader which drives
# and folders exist on a developer's machine, so they must use relative
# repository paths only.
#
# Usage:
#   tool/check_absolute_paths.sh --all          scan every tracked file in scope
#   tool/check_absolute_paths.sh FILE [FILE..]  scan the named files
#
# Exits 0 when clean, 1 when something was found, 2 on bad usage.
#
# To allow a genuine absolute path on one line, put the text
# "allow-abs-path" in a comment on that same line.

set -u

# Each alternative below is deliberately anchored so it does not fire on
# ordinary text. See the notes for why the anchors are there.
#
#   1. A lone drive letter followed by a separator. The leading boundary stops
#      it matching the "s:/" inside "https://".
#   2. A local file URI.
#   3. A Unix or macOS home folder, at a path boundary. The boundary stops it
#      matching "lib/features/home/presentation/...".
#   4. A Windows environment path.
PATTERN='(^|[^A-Za-z0-9_.-])[A-Za-z]:[\\/]'
PATTERN="$PATTERN"'|file:///'
PATTERN="$PATTERN"'|(^|[^A-Za-z0-9_.-])/(Users|home)/[A-Za-z0-9_.-]'
PATTERN="$PATTERN"'|%(USERPROFILE|HOMEPATH|APPDATA|LOCALAPPDATA|HOMEDRIVE)%'

# Which files this guard covers.
#
# docs/guidelines/ is a separate Git submodule that this project must not edit,
# and its own text names drive-letter paths as bad examples inside the rule.
#
# Source files are out of scope on purpose: the attachment storage migration
# test legitimately uses invented Windows-style fixture paths as test data, and
# a guard that cries wolf is a guard people switch off.
in_scope() {
  case "$1" in
    docs/guidelines/*) return 1 ;;
    plans/*|change_log/*|docs/*) return 0 ;;
    */*) return 1 ;;
    *.md) return 0 ;;
    *) return 1 ;;
  esac
}

if [ "$#" -eq 0 ]; then
  echo "usage: $0 --all | FILE [FILE...]" >&2
  exit 2
fi

report=$(mktemp) || exit 2
# shellcheck disable=SC2064
trap "rm -f '$report'" EXIT INT TERM

scan_one() {
  file="$1"
  in_scope "$file" || return 0
  [ -f "$file" ] || return 0

  # -I skips binary files. Lines carrying the escape marker are dropped.
  grep -nIE "$PATTERN" "$file" 2>/dev/null \
    | grep -v 'allow-abs-path' \
    | while IFS= read -r hit; do
        printf '%s:%s\n' "$file" "$hit"
      done >> "$report"
}

if [ "$1" = "--all" ]; then
  git ls-files | while IFS= read -r file; do
    scan_one "$file"
  done
else
  for file in "$@"; do
    scan_one "$file"
  done
fi

if [ -s "$report" ]; then
  echo "Absolute local paths found. Use relative repository paths instead." >&2
  echo >&2
  sed 's/^/  /' "$report" >&2
  echo >&2
  echo "Fix the lines above, or add \"allow-abs-path\" in a comment on a line" >&2
  echo "that genuinely needs an absolute path." >&2
  exit 1
fi

exit 0
