# Exercises — Lesson 05 (run via pixi; REF = instructor's chlorophyte_markers.fasta; bbmap/blast/spades/seqkit are in the default env)

1. Capture marker-bearing reads from strainA:
   `pixi run bbduk.sh in=results/strainA/trimmed/strainA_R1.trimmed.fq.gz,results/strainA/trimmed/strainA_R2.trimmed.fq.gz ref=<REF> k=25 hdist=1 outm=results/strainA/markers/strainA_marker_R1.fq.gz outm2=results/strainA/markers/strainA_marker_R2.fq.gz`
   *Check*: bbduk prints retain % — was it ~0.1–1%? If 0.00%, do NOT proceed to
   step 3; discuss loosening k/hdist first (see TROUBLESHOOTING.md).

2. Mini-assemble the captured fraction:
   `pixi run spades.py -k 21,55 --only-assembler -1 results/strainA/markers/strainA_marker_R1.fq.gz -2 results/strainA/markers/strainA_marker_R2.fq.gz -t 8 -m 16 -o results/strainA/markers/spades_mini`
   *Check*: `grep -c '>' ` the contigs — did you get contigs the length of a
   real 18S (~1.8 kb) or rbcL (~1.4 kb)?

3. Identify:
   `pixi run blastn -query results/strainA/markers/spades_mini/contigs.fasta -subject <REF> -outfmt '6 qseqid sseqid pident length evalue bitscore stitle' -max_target_seqs 5 -num_threads 8 > results/strainA/markers/strainA.marker_hits.tsv`
   *Check*: top hit per contig — which genus does strainA belong to, and at
   what identity?

4. Extract the full-length 18S for the phylogeny:
   `cut -f1 results/strainA/markers/strainA.marker_hits.tsv | sort -u > results/strainA/markers/marker_ids.txt && pixi run seqkit grep -f results/strainA/markers/marker_ids.txt results/strainA/markers/spades_mini/contigs.fasta -o results/strainA/markers/strainA.18S.fa`
   *Check*: sequence length plausible for 18S?

5. Repeat per strain, then (with instructor, optional Phase-1 stretch):
   concatenate 18S+rbcL across strains → `pixi run mafft` → `pixi run iqtree2`
   → the strain tree for her slide deck. *(mafft/iqtree may need adding to
   the default env by the instructor first — consult docs-corpus first.)*

---

## Quiz (answer in chat; free text)

1. Why not BLAST the raw reads directly? What specifically fails?
2. bbduk retained 0.02% of reads. Roughly how many read pairs is that, and
   is that consistent with capturing marker-gene reads from a 100 Mb genome?
3. Your best 18S hit is 97.3% identity to a described species. Write the
   one cautious sentence you'd put on a slide — what can you claim, what not?