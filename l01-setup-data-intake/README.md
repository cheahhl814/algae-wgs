# l01-setup-data-intake

**Environment (pixi), data intake & md5 verification**

Part of the `algae-wgs` per-lesson skill set (L01 · beginner · ~2 h · prerequisite: (none — course entry point)).

## What it does

Verifies the locked pixi workspace (install --locked and --offline), audits every tool version into results/tools-versions.txt, builds the data/raw + results layout, takes the pen-drive data in, and proves integrity with md5sum -c. No bioinformatics tools of its own.

## How to use

Point your agent at this directory (or run the lesson steps via the
herdr-lab runner where a `steps.json` ships with the skill). The
tutorial steps, checkpoint questions, and quiz are in the skill and in
[exercises.md](exercises.md).

## Environment

Root pixi workspace only (pixi install --locked + --offline). Lesson-local pixi.toml exists for parity but carries no bio tools.

## Links

- Skill definition: [SKILL.md](SKILL.md)
- Lesson exercises: [exercises.md](exercises.md)
- Shared tool docs: [../docs-corpus/](../docs-corpus/)
- Shared signature library: [../TROUBLESHOOTING.md](../TROUBLESHOOTING.md)
- Instructor prerequisites: [../INSTRUCTOR-PRECHECK.md](../INSTRUCTOR-PRECHECK.md)
