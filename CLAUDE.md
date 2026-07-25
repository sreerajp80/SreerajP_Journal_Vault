# SreerajP Journal Vault — project rules

## Follow the shared Flutter guidelines

This app follows the shared Flutter guidelines listed in [`docs/GUIDELINES_MANIFEST.md`](docs/GUIDELINES_MANIFEST.md).
Read that manifest first. It lists every guideline document and where to find it.

The documents live in a Git submodule at `docs/guidelines/`, cloned from
<https://github.com/sreerajp80/Flutter_Guidelines>.

## Applicability profiles in force — all three

Declared 2026-07-25 in [`docs/architecture.md`](docs/architecture.md) section 1, which is the
authoritative record.

| Profile | Why it applies |
|---|---|
| `Core Baseline` | Mandatory for every Flutter app. |
| `Production App Extension` | Built to a release standard — production-ready milestones, release sign-off gates, `dev`/`prod` flavors. |
| `Sensitive Data Extension` | AES-256-GCM encrypted attachments, Keystore-held secrets, PIN and biometric lock, encrypted sync, private diary content. |

So `release_process.md` and `security.md` are **required** for this app, not optional, along with
the Production and Sensitive Data sections of the engineering standard.

Known gaps against these rules are listed in `docs/architecture.md` section 21. Read that before
starting release or security work — release builds are currently signed with debug keys.

### Local copy wins

If a guideline document has also been copied into this app's own `docs/` folder, **the local copy
wins** for this app. Use the `docs/guidelines/` copy only when there is no local copy. This is the
manifest's own rule — it lets one app override a shared document without changing the shared repo.

### Start here

- New work on structure or conventions — `docs/guidelines/guideline.md` and
  `docs/guidelines/flutter_project_engineering_standard.md`.
- If a document looks dense, open its plain-English explainer under `docs/guidelines/docs/` first.

## Working with the submodule

- After a fresh clone of this repo, run `git submodule update --init --recursive` to fill
  `docs/guidelines/`.
- To pull newer guidelines: `git submodule update --remote docs/guidelines`, then commit the
  updated submodule pointer.
- Do not edit files inside `docs/guidelines/`. That is a separate repository. Change them there,
  or make a local override copy in `docs/` as described above.
