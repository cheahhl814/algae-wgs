# l02-read-qc

**Read QC: preflight → trim → re-QC**

Part of the `algae-wgs` per-lesson skill set (L02 · beginner-core · ~2.5 h · prerequisite: l01-setup-data-intake).

## What it does

The QC sandwich: sequali measures raw reads, fastp trims (quality window, PE adapter detection for MGI/DNBSEQ data, length filter), sequali re-measures trimmed output, and MultiQC aggregates all six strains. Carries the Raph WSL → Linux troubleshooting drill.

## How to use

Point your agent at this directory (or run the lesson steps via the
herdr-lab runner where a `steps.json` ships with the skill). The
tutorial steps, checkpoint questions, and quiz are in the skill and in
[exercises.md](exercises.md).

## Environment

Skill-local pixi manifest: fastp, sequali, multiqc, bbmap in the default env.

## Links

- Skill definition: [SKILL.md](SKILL.md)
- Lesson exercises: [exercises.md](exercises.md)
- Shared tool docs: [../docs-corpus/](../docs-corpus/)
- Shared signature library: [../TROUBLESHOOTING.md](../TROUBLESHOOTING.md)
- Instructor prerequisites: [../INSTRUCTOR-PRECHECK.md](../INSTRUCTOR-PRECHECK.md)
