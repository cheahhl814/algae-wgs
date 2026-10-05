# docs-corpus · sequali

- **Fetched:** 2026-09-29 (pre-seeded at course authoring, outside the locked env)
- **Source(s):** github.com/rhpvorderman/sequali (README.rst + docs/*.rst) — pandoc-converted per docs-ingest pitfall #16
- **Strategy:** 3 — GitHub clone + RST conversion
- **Captured files:** README.md, index.md, module_options.md
- **Lessons that consume this corpus:** 02/06 (QC reports)
- **Known gaps:** —

## Freshness rule (bioinfo-skill-creator convention)

These captures are upstream `master` at fetch date — they may be *newer*
than the pixi-locked tool version on the workstation. The authoritative
flag list for teaching remains the pinned-version capture:
than the pixi-locked tool version on the workstation. The authoritative
flag list for teaching remains the pinned-version capture:

> Instructor task (on the workstation, after `pixi install --locked`):
> `pixi run [-e env] <tool> --help > sequali/cli-reference.md`

If a flag documented here is absent from the pinned version's `--help`,
the `--help` wins and the drift gets a line in this README.
