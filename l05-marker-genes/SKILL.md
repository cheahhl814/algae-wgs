---
name: algae-wgs-l05-marker-genes
description: 'Lesson 05 of the algae-wgs course — the species-ID lesson: BBDuk marker capture (18S/ITS/rbcL/tufA, k=25 hdist=1) → SPAdes mini-assembly of captured reads → blastn against the curated reference for identity-bounded species calls. Exit gate: retain-% logged, defensible top-hit table, 18S extracted for ≥5/6 strains, cautious taxonomic sentences, cross-check vs the lesson-03 screen.'
version: 1.0.0
updated: "2026-10-05"
triggers:
  - "identify my strain with marker genes"
  - "species ID blast"
  - "bbduk capture"
  - "mini assembly"
  - "lesson 05"
---

# Skill: algae-wgs-l05-marker-genes

> Tutorial mode — student types every command; the agent quizzes before
> each stage transition.

## Purpose & scope

Marker genes (18S rRNA, ITS, rbcL, tufA) are a fraction of a percent of a
~100 Mb genome — BLASTing raw reads wastes 99.99% of compute and returns
noise. The professional pattern:

1. **Capture**: `bbduk.sh` seeded with a curated chlorophyte marker
   reference FASTA (`<REF>`; instructor-provided — see
   [INSTRUCTOR-PRECHECK §4](../INSTRUCTOR-PRECHECK.md)); extracts only
   reads bearing k-mer matches.
2. **Mini-assembly**: SPAdes on captured reads alone — tens of MB, minutes
   — reconstructing full-length marker contigs.
3. **Identification**: `blastn` the contigs back against(`<REF>`);
   identity % + species of the top hit is the taxonomic call, with
   identity-bounded wording.

Presentation note: BLAST table + MAFFT + IQ-TREE on 18S/rbcL gives a
**strain phylogeny** — a stronger slide artifact than any table.
(mafft/iqtree2 may need adding to the env first; consult docs-corpus.)

## Procedure (tutorial steps)

Commands verbatim in [exercises.md](exercises.md):

1. Capture strainA (`bbduk.sh in=<R1>,<R2> ref=<REF> k=25 hdist=1 outm=… outm2=…`)
   → checkpoint: retain % ~0.1–1%? If **0.00%**, do NOT proceed to step 3 —
   loosen k/hdist one notch first (see signature library).
2. Mini-assemble (`spades.py -k 21,55 --only-assembler -m 16`)
   → checkpoint: contigs ~18S (1.8 kb) or rbcL (1.4 kb) length?
3. Identify (`blastn -outfmt '6 qseqid sseqid pident length evalue bitscore stitle' -max_target_seqs 5`)
   → checkpoint: which genus, at what identity?
4. Extract full-length 18S (`seqkit grep` on hit IDs).
5. Repeat per strain; optional instructor stretch → MAFFT + IQ-TREE.

## Signature library

Full table: [../TROUBLESHOOTING.md](../TROUBLESHOOTING.md). Highlights:

| Signature | Likely cause | Fix |
|---|---|---|
| bbduk retain % = 0.00% | capture too strict (k=25/hdist=1) | loosen one notch (hdist=2 or k=23) and retry before blaming biology |
| mini contigs all <500 bp | too few captured reads | loosen capture; verify marker REF fasta non-empty |
| blastn returns nothing | query/subject DB mismatch or strand | try `-strand both`; check REF contents (`grep '>' <REF>`) |
| top hit identity ~84-90% to wrong kingdom | reference contamination or wrong subject DB | inspect stitle column; cross-check vs lesson 03 kreport genus |
| mafft/iqtree not found | tools not in env (optional stretch) | instructor adds them; never pip-install ad hoc |

## Pitfalls

- Capture k-mer size (k=25, hdist=1) trades sensitivity vs specificity —
  a missing marker usually means capture was too strict, not that the gene
  is absent; loosen one notch and retry.
- rbcL/tufA are plastid genes — if plastid signal vanishes in capture,
  check the strain's QC/k-mer profile before blaming biology.
- BLAST identity ≥99% ≈ same species territory for 18S; ~95–98% may be a
  new species in a poorly sampled genus — phrase slide text accordingly.

## Exit gate (Go/No-Go)

- [ ] Per strain: bbduk retain-% logged, `marker_hits.tsv` with a defensible top-hit table
- [ ] `<strain>.18S.fa` extracted for ≥5/6 strains (missing ones have a written hypothesis)
- [ ] One cautious per-strain taxonomic sentence drafted (identity-bounded wording)
- [ ] Marker identity cross-checked against lesson 03's genus-level screen — agreement or an explained gap

## References

- bbmap (BBDuk) / blast / spades / seqkit docs: [../docs-corpus/](../docs-corpus/)

## Handoff

Next: `algae-wgs-l06-assembly` (Phase 2 — long-running jobs). The marker
table must exist before the assembly narrative is drafted, so the slide
story (identify → assemble → quantify) holds together.