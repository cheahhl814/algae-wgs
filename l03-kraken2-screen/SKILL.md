---
name: algae-wgs-l03-kraken2-screen
description: 'Lesson 03 of the algae-wgs course: taxonomic screening with Kraken2 (Standard-8 DB) for contamination, not species ID — exact k-mer LCA classification read via clade-stepped kreport. Thresholds (~0-10% bacterial normal; >20% flags the strain for lesson 06). Exit gate: kreport per strain, contamination-summary.md, >20% flags, DB provenance recorded.'
version: 1.0.0
updated: "2026-10-05"
triggers:
  - "screen for contamination"
  - "kraken2 screen"
  - "taxonomy of my algae reads"
  - "lesson 03"
---

# Skill: algae-wgs-l03-kraken2-screen

> Tutorial mode — student types every command.

## Purpose & scope

Kraken2 assigns every k-mer in every read to a taxonomic node by exact
k-mer lookup against a database, then classifies each read at the lowest
common ancestor of its k-mer assignments. You read the clade-stepped
percentage table (`.kreport`).

**The honest interpretation lesson:** green algae are underrepresented in
the standard Kraken2 DB — chlorophytes resolve only to Chlorophyta/genus
level, never species. This screen is for *contamination* (bacteria, other
eukaryotes, blanks). Species ID comes from marker-gene BLAST in lesson 05.

## Inputs

| Input | Source | Required |
|---|---|---|
| Kraken2 **Standard-8** DB path (`<DB_PATH>`) | instructor ([INSTRUCTOR-PRECHECK](../INSTRUCTOR-PRECHECK.md) §2) | yes |
| trimmed pairs from lesson 02 | student tree | yes |

## Procedure (tutorial steps)

Commands verbatim in [exercises.md](exercises.md):

1. Screen strainA (`kraken2 --db <DB_PATH> --paired --threads 8 --confidence 0.2 --report …`)
   → checkpoint: unclassified fraction; where classified reads sit on the tree.
2. Reason about the top bacterial family: plausible symbiont/contaminant of
   an environmental freshwater isolate, or index-hopping? How would you tell?
3. Domain-level slide summary (grep the kreport; clade %: bacteria / eukaryota / U).
4. Repeat for all six strains → `results/contamination-summary.md`,
   one-line verdict per strain.

## Signature library

Full table: [../TROUBLESHOOTING.md](../TROUBLESHOOTING.md). Highlights:

| Signature | Likely cause | Fix |
|---|---|---|
| kraken2 fails with DB missing/not found | wrong `<DB_PATH>` or incomplete extract | `kraken2-inspect --db <DB_PATH> | head` to health-check; re-extract |
| 100% unclassified on real reads | wrong DB scope (e.g. min-db used) | confirm build is Standard-8, not a custom mini build |
| 100% classified random control | DB contamination or wrong control file | run the null control from battle-test Tier C |
| kreport percentages seem inconsistent | reading clade % as node % | % is clade-inclusive — subtree total, not the node's own |
| k2 database hash flag mismatch | DB built with different version | rebuild or upgrade kraken2 to match DB version |

## Pitfalls

- Standard-8 on purpose: 7.5 GB index keeps lesson-06 RAM free; escalation
  to full Standard only for strains > 20% bacterial.
- A % on a report line is **clade-inclusive** (subtree total), not the
  node's own count — the classic beginner error.

## Interpretation bands

- ~0–10% bacterial in a fresh algal isolate: normal.
- >30% bacterial: investigate before proceeding.
- Any strain >20% bacterial: flag before lesson 06.

## Exit gate (Go/No-Go)

- [ ] `.kreport` for all six strains under `results/<strain>/kraken2/`
- [ ] `results/contamination-summary.md` — one-line verdict per strain
- [ ] Strains >20% bacterial flagged with follow-up note (feeds lesson 06)
- [ ] DB build date + MD5 in `results/db-provenance.txt`

## References

- kraken2 / seqkit docs: [../docs-corpus/](../docs-corpus/)

## Handoff

Next: `algae-wgs-l04-genomescope` (uses trimmed pairs + coverage math).
A contaminant-dominated assembly outcome is prevented here, not in lesson 06.