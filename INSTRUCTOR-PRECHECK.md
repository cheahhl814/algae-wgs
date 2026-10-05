# INSTRUCTOR-PRECHECK.md — before the first student session

Condensed from the source course's INSTRUCTOR-SETUP §1–§9. Every item
must exist on the workstation before L01, because lesson 01 hands the
environment to the student verified and locked.

## 1. Pixi lock + install

The repo root `pixi.toml` (12 tools) is the full-course manifest; lesson
skills each carry their own subset manifest. On the workstation:

```bash
cd <repo>
pixi lock                     # solve root manifest
pixi install --locked
pixi install --locked --offline   # proves the cache is complete
```

Repeat per lesson dir whose skill is scheduled next (each has its own
`pixi.toml`; e.g. `cd l02-read-qc && pixi lock && pixi install --locked`).

## 2. Kraken2 database — Standard-8

The screen uses the **Standard-8** capped build (contamination screen
fit; 7.5 GB index keeps assembly RAM free). Verified index page:
`https://benlangmead.github.io/aws-indexes/k2`. Download the Standard-8
tarball, verify its MD5, and record build date + MD5 — lesson 03's exit
gate requires them in `results/db-provenance.txt`. Escalation path to
full Standard exists for strains > 20% bacterial.

## 3. BUSCO lineage

Download the `viridiplantae_odb10` lineage (`busco --download_path /
`busco --download viridiplantae_odb10`) before lesson 07. Lesson 04/05
identifications may justify a narrower chlorophyte lineage — check the
updated lineage list then.

## 4. Marker reference FASTA

`refs/chlorophyte_markers.fasta` — curated 18S/ITS/rbcL/tufA references
for BBDuk capture (lesson 05). It does **not** ship in this repo
(assemble from your curated set); lesson 05's capture step takes its
path as `<REF>`.

## 5. Battle-test before first session

Run the shared harness (`battle-test/battle_test.sh`) in order:

1. **Tier A** — structural: anytime.
2. **Tier B** — functional rehearsal: after `pixi lock`.
3. **Tier C** — Kraken2 chain: only after the Standard-8 download.

Gate for scheduling the first student session: **zero FAIL, every WARN
named with an owner.** Failed signature lines get promoted into
`TROUBLESHOOTING.md`.

## 6. Known placeholders you must replace

- Real six strain IDs (one is *Raph*) in lesson commands and
  `results/<strain>/…` layout.
- Workstation RAM check (`free -g`) before lesson 06's `-m 60` default.