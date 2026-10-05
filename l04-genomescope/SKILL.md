---
name: algae-wgs-l04-genomescope
description: 'Lesson 04 of the algae-wgs course: genome-size estimation without assembly — meryl 31-mer counting → GenomeScope2 model fit (size, heterozygosity, coverage, fitted-curve PNG) → unaided coverage arithmetic (bases ÷ estimated size; ≥25x or flag). Exit gate: per-strain histo + fit with goodness-of-fit, coverage arithmetic, archived plots, coverage flags.'
version: 1.0.0
updated: "2026-10-05"
triggers:
  - "estimate my genome size"
  - "genomescope"
  - "meryl count"
  - "coverage math"
  - "lesson 04"
---

# Skill: algae-wgs-l04-genomescope

> Tutorial mode — student types every command; the arithmetic checkpoint is
> done unaided, in chat, before the agent confirms.

## Purpose & scope

Estimate genome size without assembling anything: count how often every
31-mer occurs (**meryl**), fit a k-mer depth-frequency model
(**GenomeScope2**). The histogram shape encodes genome size,
heterozygosity, and repeats — a heterozygous/diploid genome shows a second
peak at lower depth, a homozygous peak at ~2× that depth.

**Coverage arithmetic she must do unaided:** 20–25M PE150 pairs ≈
6–7.5 Gbp per strain (the delivery note's "3–3.7 Gb" was likely post-trim
or a delivery total — this lesson surfaces that discrepancy). ~7 Gbp ÷
~100 Mb expected chlorophyte genome ≈ ~70× coverage — inside
GenomeScope2's working range.

## Procedure (tutorial steps)

Commands verbatim in [exercises.md](exercises.md):

1. `pixi run meryl count k=31 memory=16 threads=8 output …` on trimmed
   pairs → checkpoint: time vs Kraken2, why.
2. `pixi run meryl histogram … > <strain>.histo.txt` → checkpoint: peak
   shape — single sharp ~70× vs two peaks.
3. `pixi run -e genomescope genomescope2 -i …histo.txt -o plots -k 31`
   → checkpoint: size × coverage ≈ sequenced bases? Show the arithmetic.
4. `pixi run seqkit stats -E …trimmed/*.fq.gz` then divide total bases by
   the estimated size → per-strain effective coverage **before** judging
   the fit. Below ~25×: the estimate is unreliable — note which strains.
5. Repeat per strain; archive the fitted plots (Phase-1 slide figures).

## Signature library

Full table: [../TROUBLESHOOTING.md](../TROUBLESHOOTING.md). Highlights:

| Signature | Likely cause | Fix |
|---|---|---|
| meryl OOM / killed | memory= set above free RAM | lower `memory=`, rerun; check `free -g` |
| histogram empty/all-zero | wrong input paths or R-only file passed unmerged | check inputs are the trimmed *pairs* both R1+R2 |
| GenomeScope2 fails to converge | low coverage (<25×) or extreme heterozygosity | check step-4 arithmetic first, then rerun with `-k 21` |
| genomescope missing `R` at runtime | wrong env | run via `pixi run -e genomescope` (its own env) |
| two k-mer peaks at ~35x and ~70x | heterozygous genome | lower peak = heterozygous k-mers, high = homozygous |

## Pitfalls

- Heterozygosity >2% shrinks the usable k-mer peak; the size estimate
  wobbles — record model goodness-of-fit in the results.
- The estimate is of **haploid** genome size; aneuploid or repeat-heavy
  strains will show k-mer size vs assembly-size inflation.

## Exit gate (Go/No-Go)

- [ ] `<strain>.histo.txt` per strain; GenomeScope2 fitted, goodness-of-fit noted
- [ ] Per-strain coverage arithmetic written down (bases ÷ estimated size)
- [ ] GenomeScope2 plots archived for the Phase-1 slide folder
- [ ] Each strain's coverage ≥ ~25× (or a flag on any strain that isn't)

## References

- meryl / genomescope2 / seqkit docs: [../docs-corpus/](../docs-corpus/)

## Handoff

Next: `algae-wgs-l05-marker-genes`. A strain flagged <25× coverage changes
how every later lesson word must be interpreted — carry the flag forward.