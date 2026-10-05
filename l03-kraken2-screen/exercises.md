# Exercises — Lesson 03 (run via pixi; DB path from instructor)

1. Screen strainA:
   `pixi run kraken2 --db <DB_PATH> --paired --threads 8 --confidence 0.2 --report results/strainA/kraken2/strainA.kreport results/strainA/trimmed/strainA_R1.trimmed.fq.gz results/strainA/trimmed/strainA_R2.trimmed.fq.gz > results/strainA/kraken2/strainA.kraken2`
   *Check*: `less -S results/strainA/kraken2/strainA.kreport` — what fraction
   of reads is unclassified? Where do the classified reads sit on the tree?

2. Answer before reading further: is the top bacterial family plausibly a
   symbiont/contaminant of an *environmental freshwater isolate*, or does it
   look like index-hopping? How would you tell?

3. Quick domain-level summary for a slide:
   `grep -E "root|R1|U$" results/strainA/kraken2/strainA.kreport | head` and jot
   clade percentages: bacteriophage/bacteria/eukaryota.

4. Repeat for all six strains and record a one-line contamination verdict per
   strain in `results/contamination-summary.md`.
   *Check*: any strain >20% bacterial? If yes, that strain gets a flag before
   lesson 06 (assembly would contaminate the draft).

---

## Quiz (answer in chat; free text)

1. Your kreport says Chlorophyta 96.2% and the line below it (a genus)
   says 91.4%. Why is 91.4 < 96.2, and what does each number *mean*?
2. Kraken2 says "Eukaryota 98%" but never names a species. Give one
   database-side and one biological reason why that happens with green algae.
3. What would a Kraken2 result dominated by a single *Enterobacteriaceae*
   species make you suspect?