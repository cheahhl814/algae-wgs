---
name: algae-wgs-l01-setup-data-intake
description: 'Lesson 01 of the algae-wgs course: verify a locked pixi workspace, take sequencing data in, and prove its integrity with md5. Tutorial mode — the student types every command (environment lockfile, version audit, project skeleton, pen-drive intake with checksums, rehearsal copy). No bioinformatics tools of its own; uses the repo-root pixi manifest. Exit gate: offline locked install passes, per-tool version table, md5 all-OK, six strain dirs, rehearsal copy exists.'
version: 1.0.0
updated: "2026-10-05"
triggers:
  - "set up the algae WGS project"
  - "verify the pixi workspace"
  - "data intake md5"
  - "lesson 01"
---

# Skill: algae-wgs-l01-setup-data-intake

> Tutorial mode. The agent drives step by step in a side pane: the student
> types every command. Deliver this lesson, don't perform it.

## Purpose & scope

Reproducibility starts before any analysis, on three fronts:

1. **A locked environment.** One `pixi.toml` manifest plus a solved
   `pixi.lock` pinning every tool from conda-forge/bioconda to exact
   versions. The lockfile is what makes "it worked at the meeting" mean the
   same thing next month. No `conda activate`, no ad-hoc pip — every tool
   runs through `pixi run`.
2. **Directory layout convention:**

   ```
   algal-wgs/
   ├── data/raw/<strain>_R{1,2}.fq.gz
   ├── results/<strain>/{qc,kraken2,genomescope,markers,assembly}/
   ├── logs/
   └── pixi.toml + pixi.lock        (committed — NEVER edited without re-locking)
   ```

3. **Provenance check.** `md5sum` fingerprints each file; one flipped bit in
   a ~7 GB FASTQ changes the hash. Matching the facility's checksums
   exonerates transfer and storage — any later failure is analysis-side.

## Inputs

| Input | Source | Required |
|---|---|---|
| project tree `~/algal-wgs` with the repo-root `pixi.toml`/`pixi.lock` | instructor setup | yes |
| pen drive: 6 strains × R1/R2 `.fq.gz` + `md5.txt` | facility | yes |
| real strain names (replace strainA…strainF; one is *Raph*) | instructor | yes |

## Procedure (tutorial steps)

The step list, checkpoint questions, and quiz live in
[exercises.md](exercises.md); if your runner supports it, the
herdr-lab `steps.json` drives acceptance automatically. Sequence:

1. `cd ~/algal-wgs && pixi install --locked && pixi install --locked --offline`
   — discuss why the offline re-install passing proves cache completeness.
2. Version audit into `results/tools-versions.txt` (`pixi list`, then
   `pixi run <tool> --version` per tool) — this table becomes the methods
   paragraph backbone in lesson 07.
3. Project skeleton: `mkdir -p data/raw logs` and
   `results/<strain>/{qc,kraken2,genomescope,markers,assembly}` per real strain.
4. Pen-drive intake (copy, do not move; never write back into `data/raw/`).
5. `cd data/raw && md5sum -c md5.txt` — interpret `OK` vs `FAILED`.
6. Rehearsal copy `cp -a ~/algal-wgs ~/algal-wgs-rehearsal`.

## Signature library

Shared lessons-wide signature table: [../TROUBLESHOOTING.md](../TROUBLESHOOTING.md).
Rows most relevant here:

| Signature | Likely cause | Fix |
|---|---|---|
| `pixi install` fails mid-download | flaky network | retry; `--offline` only after a full success |
| `md5sum: ... FAILED` on exactly one file | transfer truncation OR wrong md5.txt pairing | `md5sum <file>` re-run; compare size `ls -lh` |
| command not found after `pixi run` | tool in a feature env, not default | `pixi run -e <env> <tool>` |
| fish: `$?` behaves oddly | pane default shell is fish | `bash --login` inside the pane |

## Pitfalls

- Fish shells are the pane default: run analyses from bash (`bash --login`)
  so scripts and `$?` behave as documented.
- Never write back into `data/raw/` — it is the immutable reference point.
- Editing `pixi.toml` without re-validating the lockfile aborts every later
  lesson.

## Exit gate (Go/No-Go)

- [ ] `pixi install --locked --offline` passes
- [ ] `results/tools-versions.txt` lists tool → version for every tool
- [ ] `md5sum -c md5.txt` all OK (or a discrepancy note + follow-up plan)
- [ ] Six strain directories exist under `results/`
- [ ] Rehearsal copy `~/algal-wgs-rehearsal` exists

## Handoff

Next skill: `algae-wgs-l02-read-qc` (needs trimmed-capable env + verified
intake). Failure anywhere: fix on the instructor side; do not proceed with
an unverified environment.