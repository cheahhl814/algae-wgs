# l03-kraken2-screen

**Taxonomic screening with Kraken2 (contamination)**

Part of the `algae-wgs` per-lesson skill set (L03 · intermediate · ~1.5 h · prerequisite: l02-read-qc).

## What it does

Screens all six strains against the Kraken2 Standard-8 DB for contamination, reads clade-stepped kreport percentages honestly, and writes a per-strain contamination verdict; flags any strain >20% bacterial before assembly.

## How to use

Point your agent at this directory (or run the lesson steps via the
herdr-lab runner where a `steps.json` ships with the skill). The
tutorial steps, checkpoint questions, and quiz are in the skill and in
[exercises.md](exercises.md).

## Environment

Skill-local pixi manifest: kraken2, seqkit. Kraken2 DB path comes from INSTRUCTOR-PRECHECK §2.

## Links

- Skill definition: [SKILL.md](SKILL.md)
- Lesson exercises: [exercises.md](exercises.md)
- Shared tool docs: [../docs-corpus/](../docs-corpus/)
- Shared signature library: [../TROUBLESHOOTING.md](../TROUBLESHOOTING.md)
- Instructor prerequisites: [../INSTRUCTOR-PRECHECK.md](../INSTRUCTOR-PRECHECK.md)
