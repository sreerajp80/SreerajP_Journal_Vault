# Change Log: Fix CI permission guard after Wi-Fi P2P sync

**Date:** 2026-08-25
**Plan Reference:** `plans/20260825_084114_fix-ci-permission-guard.md`
**Author:** AI Agent

---

## 1. Overview

The CI job "Guard offline and unused permissions" was failing on `master`. It was not a manifest
bug — the check was out of date.

`tool/check_no_internet_permission.sh` was written on 2026-08-23, when the app was fully offline,
so it demanded that `INTERNET`, `ACCESS_NETWORK_STATE` and `WAKE_LOCK` all carry
`tools:node="remove"`. The Wi-Fi Sync feature added on 2026-08-24
(`change_log/20260824_120500_wifi_p2p_sync.md`) deliberately declares `INTERNET` and
`ACCESS_NETWORK_STATE` so the app can bind a local TCP socket. The Dart test was updated to match;
the shell guard was not. The two then demanded opposite things.

This change updates the guard to the real policy, and corrects the documents that still claimed
the app had no network permission at all.

---

## 2. Changes

### A. `tool/check_no_internet_permission.sh` — rewritten

Same file name, same CI wiring, same exit codes. It now enforces:

1. `WAKE_LOCK` must still be stripped with `tools:node="remove"`.
2. `INTERNET` and `ACCESS_NETWORK_STATE` must be **present and not stripped**. Removing either is
   now an error, so nobody breaks Wi-Fi Sync by accident.
3. A deny list of permissions that must never appear: `ACCESS_WIFI_STATE`, `CHANGE_WIFI_STATE`,
   `ACCESS_COARSE_LOCATION`, `ACCESS_FINE_LOCATION`, `ACCESS_BACKGROUND_LOCATION`,
   `RECEIVE_BOOT_COMPLETED`, `FOREGROUND_SERVICE`.
4. **New:** no HTTP or cloud client package in `pubspec.yaml` — `http`, `dio`, `firebase_core`,
   `cloud_firestore`, `supabase_flutter`, `googleapis`, `connectivity_plus`. This keeps a real
   "no cloud" guarantee in CI now that `INTERNET` itself is allowed.

The permission element is now parsed with a small `awk` block instead of `grep -A/-B` line
windows, so a `<uses-permission>` tag split across several lines is read as one whole element.
The old line-window approach gave false results on the multi-line `WAKE_LOCK` tag.

The optional merged-manifest argument is kept. For that manifest, `WAKE_LOCK` and every
deny-listed permission must be absent, while `INTERNET` and `ACCESS_NETWORK_STATE` must be
present.

### B. `.github/workflows/ci.yml` — wording only

- Job name: "Guard offline and unused permissions" → "Guard permissions and no-cloud dependencies".
- Step name: "Check manifest permission removals" → "Check manifest permission policy".

The command it runs is unchanged.

### C. `docs/security.md` — corrections

- Permission table: `INTERNET` and `ACCESS_NETWORK_STATE` rows changed from "Removed" to
  "Declared", with the reason and the impact if denied (Wi-Fi Sync unavailable, rest of app works).
- Added a "Policy changed 2026-08-24 (Wi-Fi Sync)" note under the A5.3 hardening note, describing
  what the guard checks now.
- "In transit" section rewritten. It used to say "Network use: none" and that the sync module had
  no transport. It now separates **cloud/server/third-party use: none** from **local network use:
  Wi-Fi Sync only**, and describes the pairing code, PBKDF2 session key, AES-256-GCM sealing,
  bounded reader caps, and the single-client challenge lock.
- OWASP M5 row restated as local-socket-only with authenticated encryption.
- Gap item 10 keeps its history and records that the two permissions were re-added on purpose.

### D. `CLAUDE.md` and `AGENTS.md` — identical corrections

- Connectivity row now says: no cloud, no server, no HTTP client; `INTERNET` and
  `ACCESS_NETWORK_STATE` exist only for the local-network sync socket.
- Hard rule 1 renamed from "Fully offline" to "No cloud", stating that `INTERNET` must never be
  used for anything leaving the local network.
- Security rule "Never add `INTERNET`" replaced with "never widen network reach beyond the local
  network, and never add an HTTP or cloud client".

---

## 3. Verification

- `sh tool/check_no_internet_permission.sh` → passes.
- Negative tests, each confirmed to fail the guard, then reverted:
  - `INTERNET` deleted from the manifest → error.
  - `INTERNET` given `tools:node="remove"` → error.
  - `ACCESS_FINE_LOCATION` added to the manifest → error.
  - `dio` added to `pubspec.yaml` → error.
- `sh tool/check_absolute_paths.sh --all` → passes (exit 0).
- `flutter analyze` → "No issues found!".
- `flutter test` → all 776 tests pass.

---

## 4. Not changed

No manifest, no `lib/` source, no test file. App behaviour is unchanged. The release-signing gap
in `docs/architecture.md` section 21 is untouched.
