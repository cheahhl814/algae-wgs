# algae-wgs

Seven learn-by-doing skills that walk a student through a freshwater
green-algae whole-genome sequencing (WGS) project end to end — from a
locked pixi environment and md5-verified data intake (L01) through read
QC (L02), taxonomic screening (L03), genome sizing (L04), marker-gene
species ID (L05), SPAdes assembly (L06), and QUAST/BUSCO assembly QC
(L07).

One shared private repo, one skill per lesson — each skill is
self-contained and independent, and all lesson skills share the
`docs-corpus/`, `battle-test/`, and `TROUBLESHOOTING.md` assets at the
repo root.

## Contents

| Skill | Focus | Tools |
|---|---|---|
| [l01-setup-data-intake](l01-setup-data-intake/) | Locked pixi env, layout, md5 intake | pixi (uses the root manifest) |
| [l02-read-qc](l02-read-qc/) | QC sandwich: measure → trim → re-measure | fastp, sequali, multiqc, bbmap |
| [l03-kraken2-screen](l03-kraken2-screen/) | Contamination screen (Standard-8 DB) | kraken2, seqkit |
| [l04-genomescope](l04-genomescope/) | Genome size + coverage math | meryl, genomescope2, seqkit |
| [l05-marker-genes](l05-marker-genes/) | Capture → mini-assembly → BLAST species ID | bbmap, blast, spades, seqkit |
| [l06-assembly](l06-assembly/) | SPAdes `--isolate` long-run management | spades, seqkit |
| [l07-assembly-qc](l07-assembly-qc/) | QUAST continuity + BUSCO completeness | quast, busco, multiqc |

> [!NOTE]
> Each lesson runs the student's own `~/algal-wgs` project tree with
> `pixi run` — the skills teach the reasoning and guard the gates, the
> student types every command.

## 🚀 Installation

Any single agent that runs one of these skills needs `pixi` on PATH:

```bash
curl -fsSL https://pixi.sh/install.sh | bash
```

Clone this repo, `cd <clone>`, and point your agent at the lesson dir.
No install into any personal-agent skills directory is required — this
tree is deliberately self-contained.

## 💡 Usage

Natural-language triggers (each lesson skill registers its own):
"set up the algae WGS project", "run read QC on my algae reads",
"screen for contamination", "estimate my genome size", "identify my
strain with marker genes", "assemble my algae genome", "QC my assembly".

Manual phases per lesson skill:

```bash
cd l02-read-qc
pixi lock && pixi install --locked --offline   # env from that skill's pixi.toml
pixi run update-check                          # self-check vs repo origin
```

Instructor pre-session prerequisites (Kraken2 DB, marker reference
FASTA, RAM budget) are in [INSTRUCTOR-PRECHECK.md](INSTRUCTOR-PRECHECK.md).

## 🔬 Pipeline overview

```
L01 env + intake → L02 read QC ─→ L03 kraken2 screen
                    │                │
                    └→ L04 genomescope ─→ L05 marker genes
                              │
                              └→ L06 SPAdes assembly → L07 QUAST/BUSCO QC
```

Phases: **Phase 1** (L01–L05) feeds the first presentation deadline;
**Phase 2** (L06–L07) closes the course with the methods paragraph and
results pack.

## 🧰 Tools

twelve tools total, from conda-forge/bioconda, pinned in each skill's
`pixi.toml` and co-solve-verified at preflight — `busco` is pinned
`5.7.*`. Full-course joint environment preserved at the repo-root
`pixi.toml` (as in the source course).

## 🔄 Update check

Every skill tree version-diffs itself against the repo origin:

```bash
cd <lesson-skill-dir> && pixi run update-check
```

Verdict legend: `UP-TO-DATE` (0) · `LOCAL-AHEAD` (0) · `BEHIND-BY-N` (1) ·
`OFFLINE` (2) · `NO-ORIGIN` (2).

## 📁 Repository layout

```
algae-wgs/
├── README.md            ← this file
├── INSTRUCTOR-PRECHECK.md
├── course.yaml          ← lesson sequence (herdr-lab course.v1)
├── pixi.toml            ← full-course joint env (12 tools, 3 feature envs)
├── docs-corpus/         ← offline tool docs, 12 tools, shared by all skills
├── battle-test/         ← 3-tier harness validating the lesson toolchains
├── TROUBLESHOOTING.md   ← 19-row failure-signature library
├── bin/skill-update-check.py
├── test-data/           ← deterministic fixtures for smoke tests
└── l0{1..7}-…/<skill>/  ← one skill per lesson (SKILL.md + pixi.toml + exercises assets)
```

## 🔒 Hard guarantees

- Every tool version was verified via `pixi search` (conda-forge +
  bioconda) at preflight; every lesson-level manifest co-solves by real
  `pixi lock --dry-run`.
- `data/raw/` is immutable once intake verifies; all commands write into
  `results/` or `logs/`.
- No student command writes outside the project tree.
- The Kraken2 screen is a contamination screen, never a species claim —
  species IDs come from marker BLAST with identity-bounded wording.

## Provenance

Derived from the `algal-wgs-course` teaching scaffold (rev 3,
2026-09-29); conversion to per-lesson skills followed the
bioinfo-skill-creator AiX-BIO convention (preflight → build →
battle-test) with documented user overrides: skills ship in this
private standalone repo instead of a personal-agent skills directory.
License: unspecified (private repo).

## License

Private; all rights reserved by the repo owner.