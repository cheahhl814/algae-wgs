# l06-assembly

**Draft genome assembly (SPAdes --isolate)**

Part of the `algae-wgs` per-lesson skill set (L06 · advanced · 4–8 h per strain · prerequisite: l04-genomescope).

## What it does

The long-running-job lesson: SPAdes --isolate (k-ladder 21→33→55→77) launched inside tmux with explicit RAM budgeting (free -g before each run), log interpretation while waiting, and post-run seqkit stats on the draft contigs.

## How to use

Point your agent at this directory (or run the lesson steps via the
herdr-lab runner where a `steps.json` ships with the skill). The
tutorial steps, checkpoint questions, and quiz are in the skill and in
[exercises.md](exercises.md).

## Environment

Skill-local pixi manifest: spades, seqkit.

## Links

- Skill definition: [SKILL.md](SKILL.md)
- Lesson exercises: [exercises.md](exercises.md)
- Shared tool docs: [../docs-corpus/](../docs-corpus/)
- Shared signature library: [../TROUBLESHOOTING.md](../TROUBLESHOOTING.md)
- Instructor prerequisites: [../INSTRUCTOR-PRECHECK.md](../INSTRUCTOR-PRECHECK.md)
