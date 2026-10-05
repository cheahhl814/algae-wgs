# l07-assembly-qc

**Assembly QC: QUAST stats & BUSCO completeness**

Part of the `algae-wgs` per-lesson skill set (L07 · intermediate · ~1.5 h · prerequisite: l06-assembly).

## What it does

Two lenses on each draft assembly: QUAST (continuity: contigs, N50, total length) and BUSCO (completeness: viridiplantae_odb10 Complete/Duplicated/Fragmented). Closes the course with the size-estimate reconciliation table, the methods paragraph from the lesson-01 version audit, and the results pack.

## How to use

Point your agent at this directory (or run the lesson steps via the
herdr-lab runner where a `steps.json` ships with the skill). The
tutorial steps, checkpoint questions, and quiz are in the skill and in
[exercises.md](exercises.md).

## Environment

Skill-local pixi manifest: quast (own env), busco 5.7.* (own env), multiqc.

## Links

- Skill definition: [SKILL.md](SKILL.md)
- Lesson exercises: [exercises.md](exercises.md)
- Shared tool docs: [../docs-corpus/](../docs-corpus/)
- Shared signature library: [../TROUBLESHOOTING.md](../TROUBLESHOOTING.md)
- Instructor prerequisites: [../INSTRUCTOR-PRECHECK.md](../INSTRUCTOR-PRECHECK.md)
