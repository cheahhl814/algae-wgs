# battle-test/ — lesson rehearsal harness (bioinfo-skill-creator Phase 4, course-scale)

The lessons define **exit gates**; this directory answers "do the lessons
actually pass them". Two tiers, mirroring the battle-test philosophy
(structural always, execution opt-in):

## Tier A — structural (run FIRST, no DB, no dummy data, ~5 min)

`./battle_test.sh structural`

- `pixi lock --dry-run` parses every environment (feature isolation included)
- `pixi install --locked` (and `--locked --offline` proves cache coverage)
- per-env `--version` audit: every tool in every env answers
- structural greps: exit gates 7/7, quiz sections 7/7, no conda residue,
  TROUBLESHOOTING.md present and non-empty
- writes `battle-test-report.md` (verdict per check: PASS/WARN/FAIL)

Gate: **zero FAIL** to schedule lesson 01. WARNs must have a named owner.

## Tier B — functional rehearsal (dummy data, no Kraken2 DB needed, ~30 min)

`./battle_test.sh exec`

Generates a synthetic dataset (`dummy/` — random-sequence genomes, PE150,
500k pairs each → ~60x on a 2.5 Mb genome — deliberately meaningless
biologically, perfectly deterministic) and runs the lesson chains on it,
recording outputs **verbatim**:

| Lesson | Rehearsed on dummy data | Expected result |
|---|---|---|
| 02 | fastp + sequali on dummy reads | trimming is a no-op (clean synthetic reads); report must render |
| 04 | meryl histogram → GenomeScope2 fit | single sharp peak; size estimate ≈ generated genome size (this is the calibration check!) |
| 05 | bbduk capture from a marker-carrier genome → mini-SPAdes → blastn | top-hit identity 100% to the seeded reference — proves the capture→BLAST chain end-to-end |
| 06 | **SPAdes --isolate on a 2.5 Mb dummy genome** | near-perfect assembly in minutes — this measures REAL runtime + RAM on THIS workstation (the lesson-06 assumptions come from here, not from theory) |
| 07 | quast + busco on the dummy assembly | quast table renders; **BUSCO is RUN-only** — expect ~0% complete (bacterial-scale dummy genome vs viridiplantae lineage). A "PASS" here means "the command executes and the lineage loads", not a completeness claim — record it as such |
| 01 | md5sum -c on dummy md5 | exercises the verification path incl. one deliberately corrupted file (expect FAILED line) |

Also records verbatim error variants where deterministic (e.g. Kraken2 with
a wrong DB path) — these become confirmed entries in `TROUBLESHOOTING.md`
(replacing the predicted signatures, per the honesty rule).

## Tier C — Kraken2 chain (ONLY after the Standard-8 download, ~10 min)

`./battle_test.sh exec-kraken2`

- `kraken2-inspect <DB> | head` — DB healthy, build provenance copied into the report
- **Positive control**: real reads (e.g. simulated from the E. coli K-12
  reference genome) against the DB → expect >95% family-level classified —
  proves the DB + tool end-to-end
- **Null control**: dummy random-sequence reads → expect ~100% unclassified

Gate: both controls behave → lesson 03 is safe to schedule. This is THE
reason to battle-test before her first session — a DB download that looks
complete but misses index files fails exactly here.

## Scheduling vs reality (answers "do we test after the DB download?")

- Tier A: immediately, before anything else.
- Tier B: immediately after `pixi lock` (doesn't need the DB).
- Tier C: immediately after the DB download — and only Tier C waits for it.
- Do NOT test all lessons serially after the DB: only Kraken2 is DB-bound;
  everything else tests earlier and buys troubleshooting time before Monday.

## Report format (per bioinfo-skill-creator battle-test)

`battle-test-report.md` — one line per check: `PASS|WARN|FAIL <what>` +
verbatim stderr for every FAIL. Verdicts: ≥0 FAIL and ≤1 WARN per tier =
PASS-WITH-WARNINGS acceptable; any FAIL = fix before the student's first
session. Reports are run artifacts: timestamped, never edited afterwards.