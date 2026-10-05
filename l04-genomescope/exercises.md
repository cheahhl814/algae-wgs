# Exercises — Lesson 04 (run via pixi; per strain)

1. Count 31-mers (meryl is in the default env):
   `pixi run meryl count k=31 memory=16 threads=8 output results/strainA/genomescope/kmers results/strainA/trimmed/strainA_R1.trimmed.fq.gz results/strainA/trimmed/strainA_R2.trimmed.fq.gz`
   *Check*: how long did this take vs the Kraken2 run — why the difference?

2. Build the histogram:
   `pixi run meryl histogram results/strainA/genomescope/kmers > results/strainA/genomescope/strainA.histo.txt`
   *Check*: `head` the histogram — most k-mers occur how many times? What
   does a sharp single peak at ~70 suggest vs two peaks?

3. Fit the model (GenomeScope2 is R-based, hence its own env):
   `pixi run -e genomescope genomescope2 -i results/strainA/genomescope/strainA.histo.txt -o results/strainA/genomescope/plots -k 31`
   *Check*: read the summary.txt — estimated genome size, coverage,
   heterozygosity. Does size×coverage ≈ the bases you actually sequenced?
   Show the arithmetic.

4. Compute per-strain effective coverage BEFORE judging the fit:
   `pixi run seqkit stats -E results/strainA/trimmed/*.fq.gz` → divide total bases by
   the GenomeScope2 genome size. Below ~25× the estimate is unreliable —
   note which strains that applies to, if any.

5. Repeat 1–4 for all strains; keep each GenomeScope2 plot (they are the
   Phase-1 slide figures).

---

## Quiz (answer in chat; free text)

1. Your reads total 7.0 Gbp and GenomeScope2 estimates a 140 Mb genome.
   What is your coverage, and in one sentence, is that adequate — for what?
2. The histogram shows two peaks at ~35× and ~70×. What genome property does
   that pattern indicate, and which peak is which?
3. Why k=31? Name one thing that would mislead you if k were much smaller.