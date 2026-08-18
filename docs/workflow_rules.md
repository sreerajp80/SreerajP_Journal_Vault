# Workflow Rules — SreerajP Journal Vault

How every change to this repository is made: plan first, get approval, change, then log it. Read
this before you touch a project file. It mirrors the global workflow rules and the rules in
[`../CLAUDE.md`](../CLAUDE.md) and [`../AGENTS.md`](../AGENTS.md), which are the versions AI tools
load automatically.

Read first: [`../CLAUDE.md`](../CLAUDE.md) ·
[`guidelines/flutter_project_engineering_standard.md`](guidelines/flutter_project_engineering_standard.md)
section 21.1.1

---

## 1. Plan before changing

Before editing, creating, or deleting any project file, write a plan to `plans/` at the repository
root.

- **Name:** `yyyymmdd_hhMMss_<short-slug>.md`, using local time. Example:
  `20260818_100606_guidelines-conformance-audit.md`.
- **Must contain:**
  - a `# H1` title,
  - a `**Status:**` line right under the title,
  - the list of files to be changed,
  - what the issue is,
  - the plan for the fix,
  - how the change will be verified.

### Status values

| Value | Meaning |
|---|---|
| `draft` | Being written. Not yet shown to anyone. |
| `approval_pending` | Presented. Waiting for an explicit yes. |
| `in_progress` | Approved. Implementation underway. |
| `completed` | Implemented, and the change log is written. |
| `dropped` | Abandoned. Will not be implemented. |
| `partial_completion` | Some of it was built, the rest was not. |

The normal path is `draft` → `approval_pending` → `in_progress` → `completed`. Keep the line
current as the plan moves — a stale status is worse than no status.

---

## 2. The approval gate

This is a hard stop, not a formality.

- After writing the plan, **stop**. Change nothing except the plan file itself.
- Present the plan and ask, in plain words, for approval.
- Start only on an explicit yes ("yes", "approved", "go ahead"). Silence, a question, a
  clarification, or an ambiguous reply is **not** approval — ask again.
- If the plan changes after feedback, present it again and ask again.
- The only exception is when the user says outright to skip the plan for one specific change. A
  general "go ahead" from an earlier task does not carry forward.

---

## 3. Log after changing

After the work is done, write a change log to `change_log/` at the repository root.

- **Name:** `yyyymmdd_hhMMss_<short-slug>.md`, local time, same slug as its plan where possible.
- **Must say:** what actually changed, which plan it implements, and anything that was planned but
  skipped, with the reason.

A change log describes what happened, not what was intended. If the plan and the result differ,
the log records the difference.

---

## 4. Privacy rule for `plans/`, `change_log/` and `docs/`

These files are committed and may become public. Write them as if a stranger will read them.
Nothing in them should reveal the machine they were written on.

**Use relative repository paths only.** Never an absolute local path — a drive letter, a home
folder, or a `file:///` URI. <!-- allow-abs-path -->

**Never include local system details:** OS user name, computer or host name, network share names,
LAN or internal IP addresses, local server URLs with ports, device serial numbers, or personal
email addresses.

**Never include secrets:** API keys, tokens, passwords, keystore passphrases, credentials, or PII.

| Do not write | Write instead |
|---|---|
| a full drive-letter path to a source file | `lib/main.dart` |
| a path into a home folder's Gradle directory | "the local Gradle home" |
| a `file:///` link to a plan | `../plans/x.md` | <!-- allow-abs-path -->
| a UNC path to a build share | "the shared build folder" |
| an internal IP with a port | "the local dev server" |
| a personal email address | "the release owner" |
| a keystore password | "the keystore password (stored outside the repo)" |

### How it is enforced

`tool/check_absolute_paths.sh` runs as a pre-commit hook through `.githooks/pre-commit`. Turn it
on once per clone:

```sh
git config core.hooksPath .githooks
```

Audit everything tracked at any time:

```sh
sh tool/check_absolute_paths.sh --all
```

Out of scope: `docs/guidelines/` (a submodule, not ours) and source code — the attachment storage
migration test uses invented Windows-style fixture paths on purpose. If a covered file genuinely
needs an absolute path, put `allow-abs-path` in a comment on that line.

---

## 5. Definition of done

A change is finished only when all of these are true.

**Every change:**

- [ ] Architecture boundaries were respected.
- [ ] The change follows Riverpod, the repository's chosen state pattern.
- [ ] Tests were added or updated for changed logic.
- [ ] `flutter analyze` is clean.
- [ ] `flutter test` passes.
- [ ] `dart format --set-exit-if-changed lib test integration_test` exits 0.
- [ ] Every user-visible string added or changed comes from `AppLocalizations`, not a literal.
- [ ] Generated files were regenerated if an annotated source changed.
- [ ] No secrets, build output, or local machine files were staged.
- [ ] The plan and change log were re-read once, purely to check for leaked local details.

**Also, when the change touches build, config, signing, or release behaviour:**

- [ ] The flavor builds were verified.
- [ ] User-facing documentation was updated.

**Also, when the change touches sensitive data:**

- [ ] Data handling was reviewed against [`security.md`](security.md).
- [ ] Logging was reviewed for protected data exposure.
- [ ] Backup, import, export, migration and recovery paths were tested if touched.
- [ ] The affected OWASP checklist items were re-verified.

---

## 6. Communication rule

Always use simple English — in responses, plans, change logs, and code comments. Short sentences,
common words. Explain any jargon you have to use.

---

## 7. Related documents

- [`../CLAUDE.md`](../CLAUDE.md) and [`../AGENTS.md`](../AGENTS.md) — the same rules, auto-loaded
  by AI tools
- [`architecture.md`](architecture.md) — what the app is, and the known gap list
- [`security.md`](security.md) — the security rules a change must not break
- [`release_process.md`](release_process.md) — the release runbook
- [`guidelines/flutter_project_engineering_standard.md`](guidelines/flutter_project_engineering_standard.md)
  — sections 21 to 23, the shared source for these rules
