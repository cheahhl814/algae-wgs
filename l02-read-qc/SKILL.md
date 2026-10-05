---
name: algae-wgs-l02-read-qc
description: 'Lesson 02 of the algae-wgs course: the QC sandwich — sequali measure of raw reads → fastp trim (quality window, adapter for MGI/DNBSEQ, length filter) → sequali re-measure → MultiQC aggregation across all six strains. Includes the Raph WSL troubleshooting drill (crash elsewhere = environment fault). Exit gate: raw+trimmed sequali HTML + fastp report, six-strain MultiQC, verbatim-verified file exoneration, per-strain trimmed read counts.'
version: 1.0.0
updated: "2026-10-05"
triggers:
  - "run read QC on my algae reads"
  - "trim adapters"
  - "multiqc report"
  - "lesson 02"
---

# Skill: algae-wgs-l02-read-qc

> Tutorial mode — student types every command; drives the process, and
> accepts checkpoint answers in chat before moving on.

## Purpose & scope

The QC sandwich: measure the raw reads **before** touching them (so you know
what you started with), trim, then measure again (so you know what trimming
actually did). Skipping either half makes trimming unaccountable.

Tools: **sequali** (modern all-in-one QC report), **fastp** (quality sliding
window, PE adapter detection via overlap, length filter), **MultiQC**
(aggregation). Commands: [exercises.md](exercises.md) (steps 1–5 + quiz;
herdr-lab runner: [steps.json](steps.json)).

This lesson also carries the **Raph troubleshooting** drill: her fastp
crashed on Windows/WSL with I/O faults and segfaults while the other five
strains trimmed fine. The Linux-native rerun is the decisive test — works ⇒
environment fault; fails reproducibly ⇒ look at the file.

## Environment

```bash
cd l02-read-qc && pixi lock && pixi install --locked
pixi run <tool> …    # fastp, sequali, multiqc, bbmap in the default env
```

## Procedure (tutorial steps)

1. Raw QC strainA (sequali, both mates, `-o sequali_raw`) → checkpoint: Q30%,
   adapter signal.
2. Trim strainA (fastp:
   `--qualified_quality_phred 20 --length_required 50 --detect_adapter_for_pe --thread 8`)
   → checkpoint: after-filtering read count vs step 1.
3. Re-QC trimmed reads → checkpoint: what improved, what shortened.
4. **Raph drill**: sequali raw on Raph, then the fastp step with strain=Raph
   — file exoneration or environment fault, verbatim evidence.
5. `pixi run multiqc results/ --force -o results/multiqc` → checkpoint: one
   report, six strains visible.
6. Repeat 1–3 for the remaining four strains; record per-strain trimmed
   counts (lesson 04 consumes them).

## Signature library

Full table: [../TROUBLESHOOTING.md](../TROUBLESHOOTING.md). Highlights:

| Signature | Likely cause | Fix |
|---|---|---|
| fastp `Segmentation fault` on one machine only | environment fault (WSL/IO) | rerun on Linux-native station; only then suspect the file |
| sequali crash on open | truncated gz (flip from transfer) | `gzip -t <file>`; re-transfer if failed |
| adapter >30% signal after PE detect | MGI/DNBSEQ adapter set — `--detect_adapter_for_pe` missing | add the flag; do not use Illumina adapters by hand |
| reads shrink to <50 bp en masse | too-aggressive length filter vs data quality | check `--length_required` vs sequali length distribution |
| MultiQC sees fewer than N samples | report filenames lack expected patterns | check `-o` output dirs spelled per-convention |

## Pitfalls

- `--detect_adapter_for_pe` matters for MGI/DNBSEQ data — adapter sequence
  is *not* Illumina-identical.
- Never judge a strain from QC alone — check insert-size/length distribution
  shifts after trimming.

## Exit gate (Go/No-Go)

- [ ] Raw + trimmed sequali HTML for strainA and Raph, plus fastp HTML/JSON
- [ ] `results/multiqc/qc_report.html` shows all six strains
- [ ] Verbatim-verified: Raph trimmed clean on Linux → file exonerated
- [ ] Per-strain trimmed read count noted (feeds lesson 04)

## References

- sequali / fastp / multiqc / bbmap docs:
  [../docs-corpus/](../docs-corpus/) (`docs-corpus/<tool>/`)

## Handoff

Next skill: `algae-wgs-l03-kraken2-screen`. Failure at the sandwich's raw
step with a truncated gz → route back to lesson 01's intake gate.