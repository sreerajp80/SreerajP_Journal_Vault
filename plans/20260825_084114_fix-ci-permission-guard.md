# Fix CI failure: permission guard is out of date after Wi-Fi P2P sync

**Status:** completed

**Date:** 2026-08-25

---

## 1. The issue

The CI job **"Guard offline and unused permissions"** fails on `master` (run "Updates #2"):

```
[ERROR] android.permission.INTERNET is missing tools:node="remove" in android/app/src/main/AndroidManifest.xml
[ERROR] android.permission.ACCESS_NETWORK_STATE is missing tools:node="remove" in android/app/src/main/AndroidManifest.xml
[OK] android.permission.WAKE_LOCK has tools:node="remove"
```

This is not a bug in the manifest. It is a stale check.

- On 2026-08-23 the guard `tool/check_no_internet_permission.sh` was added. At that time the app
  was fully offline, so the script demanded that `INTERNET`, `ACCESS_NETWORK_STATE` and
  `WAKE_LOCK` all carry `tools:node="remove"`.
- On 2026-08-24 the **Peer-to-Peer Encrypted Wi-Fi Sync** feature was added
  (`change_log/20260824_120500_wifi_p2p_sync.md`). It deliberately declares `INTERNET` and
  `ACCESS_NETWORK_STATE` in the production manifest so the app can bind a **local TCP socket** on
  the same Wi-Fi network. The Dart test `test/core/security/manifest_permission_guard_test.dart`
  was updated to match, but the shell guard used by CI was not.

So the shell script and the Dart test now demand opposite things, and CI is red.

A second, related problem: several documents still say the app has no `INTERNET` permission and
no network use at all. That is no longer true, and it should be corrected so a reader (or a
future agent) is not misled.

## 2. Files to change

| File | Change |
|------|--------|
| `tool/check_no_internet_permission.sh` | Rewrite the policy it enforces (see below) |
| `.github/workflows/ci.yml` | Rename the job/step wording to match the new policy |
| `docs/security.md` | Correct the permission table, the "In transit" note, the A5.3 hardening note, and gap item 10 |
| `CLAUDE.md` | Correct the connectivity row, hard rule 1, and the security rule about `INTERNET` |
| `AGENTS.md` | Same three corrections, kept in step with `CLAUDE.md` |
| `change_log/20260825_<time>_fix-ci-permission-guard.md` | New change log after implementation |

No app source (`lib/`), no manifest, and no test file is changed. Behaviour of the app does not
change.

## 3. The fix

### 3.1 `tool/check_no_internet_permission.sh`

Keep the file name and the CI wiring, but change what it enforces so it protects the property the
app actually has now: **local-network-only sync, no unused permissions, no HTTP client.**

New rules for `android/app/src/main/AndroidManifest.xml`:

1. `android.permission.WAKE_LOCK` **must** still carry `tools:node="remove"`. (Unchanged.)
2. `android.permission.INTERNET` and `android.permission.ACCESS_NETWORK_STATE` **must be present
   and must NOT carry `tools:node="remove"`** — they are required by Wi-Fi Sync. Flag it as an
   error if either is missing, so nobody removes them by accident and silently breaks sync.
3. A **deny list** of network permissions that must never appear at all:
   `ACCESS_WIFI_STATE`, `CHANGE_WIFI_STATE`, `ACCESS_COARSE_LOCATION`, `ACCESS_FINE_LOCATION`,
   `ACCESS_BACKGROUND_LOCATION`, `RECEIVE_BOOT_COMPLETED`, `FOREGROUND_SERVICE`.
   (If a future feature genuinely needs one, it is added to the allow list on purpose, with a
   plan — which is the point of the guard.)
4. Keep the existing `pubspec.yaml` spirit of the offline rule by adding a check that no known
   HTTP/cloud client package appears in `pubspec.yaml` dependencies: `http`, `dio`,
   `firebase_core`, `cloud_firestore`, `supabase_flutter`, `googleapis`, `connectivity_plus`.
   This keeps a real "no cloud" guarantee in CI even though `INTERNET` is now allowed.

The optional merged-manifest argument is kept, but its check is inverted for the two sync
permissions: `WAKE_LOCK` and every deny-listed permission must be **absent** from the merged
manifest; `INTERNET` and `ACCESS_NETWORK_STATE` are expected to be present.

Exit code stays 0 on pass, 1 on any failure, so `.github/workflows/ci.yml` needs no logic change.

### 3.2 `.github/workflows/ci.yml`

Rename the job display name from "Guard offline and unused permissions" to
"Guard permissions and no-cloud dependencies", and the step to "Check manifest permission policy".
Cosmetic only — the run command is unchanged.

### 3.3 Documentation corrections

`docs/security.md`:

- Permission table: change the `INTERNET` and `ACCESS_NETWORK_STATE` rows from "Removed" to
  "Declared — required by local Wi-Fi Sync (local TCP socket only)", with the impact-if-denied
  column saying Wi-Fi Sync is unavailable and the rest of the app works.
- "In transit" section: replace "Network use: **none**" with an accurate description — no cloud,
  no server, no HTTP client; the only traffic is a direct device-to-device TCP socket on the
  user's own LAN, sealed with AES-256-GCM using a PBKDF2 session key from a pairing code.
- The "Hardened 2026-08-23 (A5.3)" note: add a follow-up line dated 2026-08-24 saying the policy
  changed with Wi-Fi Sync, and what the guard checks now.
- Gap item 10: keep the history, add that `INTERNET` / `ACCESS_NETWORK_STATE` were deliberately
  re-added on 2026-08-24 for Wi-Fi Sync.
- M5 (Insecure Communication) row in the OWASP table: restate it as local-socket-only with
  authenticated encryption, instead of "no network traffic".

`CLAUDE.md` and `AGENTS.md` (identical edits in both):

- Connectivity row: "No cloud, no server, no HTTP client. `INTERNET` and `ACCESS_NETWORK_STATE`
  are declared only so Wi-Fi Sync can open a direct device-to-device socket on the local network."
- Hard rule 1: change "The app never asks for `INTERNET`" to "No cloud, no analytics, no crash
  reporter, no HTTP client. `INTERNET` exists only for local-network Wi-Fi Sync — do not use it
  for anything that leaves the local network."
- Security rule "Never add `INTERNET`": change to "Never add a permission that widens network
  reach beyond the local network, and never add an HTTP or cloud client."

## 4. Verification

1. `sh tool/check_no_internet_permission.sh` passes locally.
2. Temporarily removing `INTERNET` from the manifest makes it fail (guard proves it works), then
   restore.
3. `flutter analyze` — clean.
4. `flutter test` — all pass (the Dart manifest guard test already matches the new policy).
5. `sh tool/check_absolute_paths.sh --all` — passes, so the privacy CI job stays green.

## 5. Out of scope

- No change to the manifest, the sync feature, or any `lib/` code.
- The release-signing gap (`docs/architecture.md` section 21) is untouched.
