# l04-genomescope

**Genome-size estimation & coverage math (meryl → GenomeScope2)**

Part of the `algae-wgs` per-lesson skill set (L04 · intermediate · ~1.5 h · prerequisite: l01-setup-data-intake).

## What it does

Counts 31-mers with meryl, fits the GenomeScope2 depth-frequency model (size, heterozygosity, coverage + fitted-curve PNG), and requires the unaided coverage arithmetic: bases ÷ estimated size ≥ ~25x or the strain gets flagged.

## How to use

Point your agent at this directory (or run the lesson steps via the
herdr-lab runner where a `steps.json` ships with the skill). The
tutorial steps, checkpoint questions, and quiz are in the skill and in
[exercises.md](exercises.md).

## Environment

Skill-local pixi manifest: meryl, genomescope2 (R-based, its own env), seqkit.

## Links

- Skill definition: [SKILL.md](SKILL.md)
- Lesson exercises: [exercises.md](exercises.md)
- Shared tool docs: [../docs-corpus/](../docs-corpus/)
- Shared signature library: [../TROUBLESHOOTING.md](../TROUBLESHOOTING.md)
- Instructor prerequisites: [../INSTRUCTOR-PRECHECK.md](../INSTRUCTOR-PRECHECK.md)
