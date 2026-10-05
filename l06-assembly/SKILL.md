---
name: algae-wgs-l06-assembly
description: 'Lesson 06 of the algae-wgs course: draft genome assembly with SPAdes --isolate — the long-running-job lesson (de Bruijn k-ladder 21→33→55→77, tmux/nohup management, RAM budgeting, log interpretation). Exit gate: contigs per strain, log files, memory budget verified, contig counts + longest contig jotted, fragmentation caveat drafted.'
version: 1.0.0
updated: "2026-10-05"
triggers:
  - "assemble my algae genome"
  - "spades isolate"
  - "run a long assembly job"
  - "lesson 06"
---

# Skill: algae-wgs-l06-assembly

> Tutorial mode — the course's long-running-job lesson; jobs run in tmux
> with the agent monitoring pane tails, not babysitting.

## Purpose & scope

SPAdes builds a de Bruijn graph from k-mers at a ladder of k values
(21→33→55→77) and resolves it into contigs. `--isolate` mode is the
short-read single-isolate optimizer (skips error-correction sensitivity
checks designed for metagenomes) — appropriate because lessons 03–05
already vetted the strains as single-organism isolates.

The real subject is **running a 4–8 h job**: launch inside `tmux`, log it,
monitor via log tails and exit codes — the exact skill to overlap assembly
runs with other lab work.

## Procedure (tutorial steps)

Commands verbatim in [exercises.md](exercises.md):

1. Resources FIRST: `free -g && nproc` — decide concurrency with the
   instructor against total RAM (two concurrent SPAdes runs share the
   budget).
2. `tmux new -s spadesA` → `pixi run spades.py --isolate -1 <R1> -2 <R2>
   -t 16 -m 60 -o … 2>&1 | tee logs/strainA.spades.log`; detach `Ctrl-b d`;
   reattach to check which k SPAdes is on.
3. While it runs, interpret log lines (`grep -n "Assembling" …`) — what the
   rising k ladder does to contiguity.
4. On completion confirm `Thank you for using SPAdes!` in the log tail;
   copy `contigs.fasta` to `results/<strain>/assembly/<strain>.contigs.fasta`;
   `pixi run seqkit stats` → contig count, longest.
5. Queue the next strain (serial, per the concurrency decision); draft the
   fragmentation caveat sentence for the slides.

## Signature library

Full table: [../TROUBLESHOOTING.md](../TROUBLESHOOTING.md). Highlights:

| Signature | Likely cause | Fix |
|---|---|---|
| SPAdes killed (no stderr trace) | OOM — `-m 60` exceeded free RAM | check `free -g`, lower `-m` or run serially |
| `Assertion failed` at error correction | raw or damaged input reads | confirm trimmed pairs from lesson 02; never assemble raw reads |
| assembly "finished" in 20 min with 3,000 tiny contigs | upstream QC failure | go back to lesson 02 numbers, not to SPAdes flags |
| contigs full of 200-bp fragments | upstream failure, not assembly | never "fix" assembly problems at the assembly step |
| job dies when SSH drops | run outside tmux | always `tmux new -s <name>` first |
| no `Thank you for using SPAdes!` | crashed mid-k | read `spades.log` tail; rerun the failing stage |

## Pitfalls

- Memory is the budget, not CPU: `-m 60` assumes ~64 GB free; verify with
  `free -g` and coordinate concurrent runs against total RAM.
- A contigs FASTA full of 200-bp fragments means something upstream failed —
  never treat it as an assembly-step problem; go back to QC.
- Never assemble raw reads — trimmed reads only (lesson 02 outputs).

## Exit gate (Go/No-Go)

- [ ] `results/<strain>/assembly/<strain>.contigs.fasta` per strain + log files under `logs/`
- [ ] Memory budget verified before each run (`free -g`), concurrency decision respected
- [ ] Contig counts + longest contig jotted per strain (QUAST quantifies next)
- [ ] The fragmentation caveat sentence exists in draft form for the slides

## References

- spades / seqkit docs: [../docs-corpus/](../docs-corpus/)

## Handoff

Next: `algae-wgs-l07-assembly-qc` — QUAST + BUSCO quantify what lesson 06
produced; that reconciliation closes the course.