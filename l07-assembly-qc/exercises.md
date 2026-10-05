# Exercises — Lesson 07 (run via pixi; quast and busco have dedicated envs from lesson 01)

1. QUAST on strainA:
   `pixi run -e quast quast.py -o results/strainA/quast -t 8 -m 500 results/strainA/assembly/strainA.contigs.fasta`
   *Check*: `cat results/strainA/quast/report.tsv` — total length vs the
   GenomeScope2 size from lesson 04: what fraction of the estimated genome
   did you assemble? Is the gap repeats/contam, or coverage?

2. Interpret before running the next: write one sentence per metric —
   contigs, N50, largest contig — as you would word it on a slide.

3. BUSCO on strainA:
   `pixi run -e busco busco -i results/strainA/assembly/strainA.contigs.fasta -o strainA_busco -m genome -l viridiplantae_odb10 -c 8 --out_path results/strainA/busco`
   *Check*: read the short_summary file — Complete% vs Duplicated%. What
   does high Duplicated% tell you given each strain's heterozygosity from
   lesson 04?

4. Compare all six: run QUAST on every assembly at once,
   `pixi run -e quast quast.py -o results/quast_all -t 8 -m 500 results/*/assembly/*.contigs.fasta`
   — the combined report table IS the Phase-2 slide table.

5. Reconcile: for each strain write `size estimate (L04) vs assembly (L07)`
   and one hypothesis for any >15% discrepancy.

6. **Methods paragraph & results pack (course close-out)**: open
   `results/tools-versions.txt` from lesson 01 and write the methods section —
   every tool with name, exact version (from the locked env), and the
   parameter values you used in these lessons; note the Kraken2 DB build
   date and BUSCO lineage. Copy the six GenomeScope plots and the
   `results/quast_all` table into a Phase-2 slide folder.
   *Check*: could a stranger re-run your analysis from this paragraph alone?
   What is missing if not?

---

## Quiz (answer in chat; free text)

1. StrainB: N50 = 2 kb, largest contig = 180 kb. Is that contradictory?
   Explain each metric in one line.
2. BUSCO reports C:92% (S:70, D:22), F:3%, M:5%. What does the Duplicated%
   likely reflect here, and which earlier lesson number gave you the clue?
3. Why must Complete% always be interpreted relative to the lineage you
   chose — what would change if you swapped to a chlorophyte-specific set?
4. Why does the methods paragraph cite the *locked environment* versions
   rather than "latest versions" — what breaks otherwise?