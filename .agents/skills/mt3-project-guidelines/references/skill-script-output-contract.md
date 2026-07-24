# MT3 Skill Script Output Contract

Use this contract for any repo-local Codex skill script placed under `.agents/skills/*/scripts/`.

Shared runtime helper:

- Prefer dot-sourcing `.agents/skills/mt3-project-guidelines/scripts/skill-script-helpers.ps1`
- Do not duplicate `Resolve-RepoRootPath`, `Read-TextFileSmart`, `Get-CommandSource`, `Get-ExistingPath`, or `Write-Result` across scripts unless there is a task-specific reason

Required runtime structure:

- Add `[CmdletBinding()]` at the top.
- Enable `Set-StrictMode -Version Latest`.
- Set `$ErrorActionPreference = "Stop"`.
- Use the shared `Write-Result` helper to print the final contract.
- Return `exit 1` only for `FAIL`; return `exit 0` for `PASS` and `WARN`.

Required output fields:

- `STATUS: PASS|WARN|FAIL`
- `SKILL: <skill-name>`
- `SUMMARY: <one-line outcome>`
- `DETAIL: <repeatable detail lines>`
- `NEXT: <next action or verification>`

Optional machine-readable extension:

- Support `-Json` for scripts that will be chained by other governance or repair steps.
- When `-Json` is present, emit one JSON object with:
  - `status`
  - `skill`
  - `summary`
  - `next`
  - `details`
  - `data`
- Keep the default behavior text-first so existing manual workflows remain stable.
- Keep the top-level JSON shape stable; put domain-specific fields under `data`.
- See [skill-script-json-schema.md](skill-script-json-schema.md) for the shared JSON schema and naming guidance.

Recommended script shape:

1. Resolve `RepoRoot` or `ProjectRoot`.
2. Collect facts into `details`, `warnings`, and `failures`.
3. Compute a single final `status`.
4. Emit only one final result block through `Write-Result`.

Do not:

- Print ad-hoc success banners before the final result block.
- Mix multiple incompatible output styles in one script.
- Exit early without returning the contract fields.
- Copy-paste the same helper functions into every script when the shared helper already covers them.

Current governance:

- `.claude/scripts/audit_codex_skills.ps1` treats missing contract fields as audit errors.
- `.claude/scripts/audit_codex_skills.ps1` also records how many repo-local skill scripts are JSON-capable.
- `.claude/scripts/audit_codex_skills.ps1` also tracks whether repo-local skill entry scripts import the shared helper.
- [skill-script-template.ps1.txt](../assets/skill-script-template.ps1.txt) is the preferred starting point for new repo-local skill scripts.
