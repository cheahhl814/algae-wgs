# docs-corpus · busco

- **Fetched:** 2026-09-29 (pre-seeded at course authoring, outside the locked env)
- **Source(s):** gitlab.com/ezlab/busco (README)
- **Strategy:** 3 — GitLab clone
- **Captured files:** README.md
- **Lessons that consume this corpus:** 07 (-l lineage, -c)
- **Known gaps:** full userguide is at busco.ezlab.org — workstation fetch pending

## Freshness rule (bioinfo-skill-creator convention)

These captures are upstream `master` at fetch date — they may be *newer*
than the pixi-locked tool version on the workstation. The authoritative
flag list for teaching remains the pinned-version capture:
than the pixi-locked tool version on the workstation. The authoritative
flag list for teaching remains the pinned-version capture:

> Instructor task (on the workstation, after `pixi install --locked`):
> `pixi run [-e env] <tool> --help > busco/cli-reference.md`

If a flag documented here is absent from the pinned version's `--help`,
the `--help` wins and the drift gets a line in this README.

## 2026-10-05 capture addendum

- **Captured:** `github-readme.md` — gitlab.com/ezlab/busco (README, master, 2026-10-05 capture)
- **Gap remaining:** no pinned-version `cli-reference.md` (authoritative --help capture) — instructor workstation task (INSTRUCTOR-SETUP §5).
