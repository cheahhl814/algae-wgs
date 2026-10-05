# l05-marker-genes

**Marker genes: capture → mini-assembly → BLAST**

Part of the `algae-wgs` per-lesson skill set (L05 · intermediate · ~2.5 h · prerequisite: l03-kraken2-screen, l04-genomescope).

## What it does

The species-ID lesson: BBDuk captures 18S/ITS/rbcL/tufA reads out of the trimmed set, SPAdes mini-assembles them into full-length contigs, and blastn ranks hits against the curated reference for identity-bounded species calls. Optional stretch: MAFFT + IQ-TREE strain phylogeny.

## How to use

Point your agent at this directory (or run the lesson steps via the
herdr-lab runner where a `steps.json` ships with the skill). The
tutorial steps, checkpoint questions, and quiz are in the skill and in
[exercises.md](exercises.md).

## Environment

Skill-local pixi manifest: bbmap, blast, spades, seqkit (all in the default env).

## Links

- Skill definition: [SKILL.md](SKILL.md)
- Lesson exercises: [exercises.md](exercises.md)
- Shared tool docs: [../docs-corpus/](../docs-corpus/)
- Shared signature library: [../TROUBLESHOOTING.md](../TROUBLESHOOTING.md)
- Instructor prerequisites: [../INSTRUCTOR-PRECHECK.md](../INSTRUCTOR-PRECHECK.md)
