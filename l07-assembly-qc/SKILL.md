---
name: algae-wgs-l07-assembly-qc
description: 'Lesson 07 of the algae-wgs course: assembly QC through two lenses — QUAST continuity (contigs/N50/total length) and BUSCO completeness (viridiplantae_odb10; Complete/Duplicated/Fragmented) — plus the size-estimate-vs-assembly reconciliation and the course-closing methods paragraph + results pack. Exit gate: per-strain QUAST tsv, six-assembly comparison, BUSCO per strain, reconciliation table, methods paragraph, results pack.'
version: 1.0.0
updated: "2026-10-05"
triggers:
  - "QC my assembly"
  - "quast busco"
  - "write the methods paragraph"
  - "assembly metrics"
  - "lesson 07"
---

# Skill: algae-wgs-l07-assembly-qc

> Tutorial mode — this lesson closes the course; its results pack feeds the
> final slides directly.

## Purpose & scope

Two complementary lenses on a draft assembly:

- **QUAST** = *continuity*: contig count, N50, total length, largest
  contig — how **fragmented** the assembly is.
- **BUSCO** = *completeness*: single-copy orthologs from the
  `viridiplantae_odb10` lineage — Complete% = fraction of the expected core
  set recovered; Duplicated% flags assembly duplication (high
  heterozygosity often shows this).

The honest-reporting habit: short-read-only assemblies of a ~100 Mb genome
typically produce hundreds to thousands of contigs with modest N50 — QUAST
quantifies it and the slide states it rather than hiding it.

## Procedure (tutorial steps)

Commands verbatim in [exercises.md](exercises.md):

1. QUAST strainA (`pixi run -e quast quast.py -o results/strainA/quast -t 8 -m 500 <contigs>`)
   → checkpoint: fraction of the lesson-04 estimated genome actually assembled.
2. Interpret before running the next: one slide-quality sentence per metric
   (contigs, N50, largest contig).
3. BUSCO strainA (`pixi run -e busco busco -i <contigs> -m genome -l viridiplantae_odb10 -c 8`)
   → checkpoint: Complete% vs Duplicated% vs lesson-04 heterozygosity.
4. Compare all six: one QUAST run over `results/*/assembly/*.contigs.fasta`
   → `results/quast_all` is the Phase-2 slide table.
5. Reconcile: per strain, `size estimate (L04) vs assembly (L07)` +
   one hypothesis for any >15% discrepancy.
6. **Methods paragraph & results pack**: from lesson 01's
   `results/tools-versions.txt` — every tool, exact version (locked env),
   parameter values; Kraken2 DB build date + BUSCO lineage; copy GenomeScope
   plots + `quast_all` table + marker table into the Phase-2 slide folder.
   Checkpoint: could a stranger re-run the analysis from this paragraph alone?

## Signature library

Full table: [../TROUBLESHOOTING.md](../TROUBLESHOOTING.md). Highlights:

| Signature | Likely cause | Fix |
|---|---|---|
| BUSCO ~0% complete on a small test input | expected on bacterial-scale fixtures — BUSCO run-only in Tier B | never quote Tier-B BUSCO numbers |
| BUSCO fails: missing lineage | lineage not downloaded | [INSTRUCTOR-PRECHECK §3](../INSTRUCTOR-PRECHECK.md); rerun after download |
| quast.py missing R libs at runtime | wrong env | run via `pixi run -e quast` (its own env) |
| N50 quoted as "largest contig" | metric confusion | N50 is a median — quote contig count + N50 + largest together |
| assembly far below GenomeScope2 size (>15% gap) | repeats/contam/coverage gap | use the reconciliation step's hypothesis, don't hide it |

## Pitfalls

- BUSCO `-l` lineage choice drives the denominator — `viridiplantae_odb10`
  is broad; after lessons 03/05 identify the class and consult the updated
  lineage list.
- N50 is a median, not a maximum — quote contig count + N50 + largest
  contig together, never N50 alone.

## Exit gate (Go/No-Go)

- [ ] Per-strain QUAST `report.tsv`; six-assembly comparison at `results/quast_all/`
- [ ] BUSCO complete/duplicated per strain, lineage name recorded
- [ ] Size-estimate-vs-assembly reconciliation table (per-strain hypotheses)
- [ ] Methods paragraph written from the lesson-01 version audit (tool, exact version, parameters)
- [ ] Results pack assembled: GenomeScope plots + quast_all table + marker table + methods paragraph

## References

- quast / busco / multiqc docs: [../docs-corpus/](../docs-corpus/)

## Handoff

Course complete after this lesson's results pack. Re-run any earlier skill
for a new strain; the methods paragraph templates scale per added strain.