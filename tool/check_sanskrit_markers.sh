#!/usr/bin/env bash
# Sanskrit quality gate (engineering standard §8.5.1).
#
# Fails when a Hindi marker appears in the Sanskrit ARB file, in
# assets/config/app_config.json, or in any Sanskrit asset file (*_sa.*).
# Sanskrit and Hindi share the Devanagari script, so Hindi text looks like
# Sanskrit to anyone who does not read it; these tokens are reliable giveaways.
#
# A smoke test, not a proof: passing means no obvious Hindi marker, not that the
# Sanskrit is good. A fluent reader still reviews new terms.
#
# Uses PCRE (-P) with lookarounds so standalone copulas and words are not
# confused with Sanskrit roots (स्थाप्यताम्, स्थानम्) or indeclinables (यथा, तथा,
# कथा). Word edges: whitespace, quotes, brackets, punctuation, the daṇḍa, XML or
# HTML tag edges (< >), and Markdown marks (* _ ` # | : ; ~ -).
#
# Run from the repository root:  sh tool/check_sanskrit_markers.sh
set -eu

cd "$(dirname "$0")/.."

PATTERN='(?<=[\s"'\''([{<>।,*_`#|:;~-]|^)(?:था|थे|थी|हो|है|हैं|हूं|और)(?=[\s"'\''\)\]}<>।,.\?!*_`#|:;~-]|$)|करें|करना|करके|रहा|रही|रहे|गया|गयी|चाहिए|नहीं|लेकिन|क्या|आपका|आपकी|आपके|हमारा|मेरा|कृपया|सेटिंग्स|ऐप|\x{093C}|[\x{0958}-\x{095F}]'

FILES=$(find . -path ./build -prune -o -path ./.dart_tool -prune -o -path ./docs -prune -o -type f \( \
    -name 'app_sa.arb' -o \
    -path './assets/*_sa.*' -o \
    -path './assets/config/app_config.json' \) -print)

if [ -z "$FILES" ]; then
  echo 'No Sanskrit files found — every app ships lib/l10n/app_sa.arb.'
  exit 1
fi

# Self-test: the pattern must still catch a Hindi copula in ARB/JSON, XML and
# Markdown text. A broken pattern would otherwise pass everything silently.
for sample in '"greeting": "है"' '<b>है</b>' 'यह **है**' 'यह `है`' 'वह *था*'; do
  if ! printf '%s\n' "$sample" | LC_ALL=C.UTF-8 grep -qP "$PATTERN"; then
    echo "Sanskrit check self-test failed on: $sample"
    exit 1
  fi
done
# ...and must not flag real Sanskrit.
for sample in 'स्थाप्यताम्' 'यथा तथा कथा' 'न कोऽपि दत्तांशः प्राप्तः' 'सस्नेहं निर्मितम् {heart} भारततः'; do
  if printf '%s\n' "$sample" | LC_ALL=C.UTF-8 grep -qP "$PATTERN"; then
    echo "Sanskrit check self-test flagged valid Sanskrit: $sample"
    exit 1
  fi
done

# shellcheck disable=SC2086
if LC_ALL=C.UTF-8 grep -nP "$PATTERN" $FILES; then
  echo 'Hindi markers found in Sanskrit text (engineering standard §8.5).'
  exit 1
fi

echo "Sanskrit marker check passed:" $FILES
exit 0
