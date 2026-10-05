# docs-corpus · kraken2

- **Fetched:** 2026-09-29 (pre-seeded at course authoring, outside the locked env)
- **Source(s):** github.com/DerrickWood/kraken2 (docs/MANUAL.markdown)
- **Strategy:** 3 — GitHub clone
- **Captured files:** MANUAL.md, README.md
- **Lessons that consume this corpus:** 03 (reports, confidence, DB)
- **Known gaps:** DB is External: see INSTRUCTOR-SETUP §2 (Standard-8)

## Freshness rule (bioinfo-skill-creator convention)

These captures are upstream `master` at fetch date — they may be *newer*
than the pixi-locked tool version on the workstation. The authoritative
flag list for teaching remains the pinned-version capture:
than the pixi-locked tool version on the workstation. The authoritative
flag list for teaching remains the pinned-version capture:

> Instructor task (on the workstation, after `pixi install --locked`):
> `pixi run [-e env] <tool> --help > kraken2/cli-reference.md`

If a flag documented here is absent from the pinned version's `--help`,
the `--help` wins and the drift gets a line in this README.
