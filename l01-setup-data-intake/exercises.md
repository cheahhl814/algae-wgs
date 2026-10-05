# Exercises — Lesson 01

The toolchain is already locked and installed by the instructor (`pixi.toml`
+ `pixi.lock` in the course root) — locking fastp/spades/BUSCO by hand is an
advanced exercise, not the way to start. Your job in this lesson: verify the
environment, take the data in, and prove its integrity.

Type each command in the side pane yourself. Before running, say out loud
what you expect to see. After each step, answer the checkpoint in chat.

1. Verify the workspace:
   `cd ~/algal-wgs && pixi install --locked && pixi install --locked --offline`
   *Check*: why does the offline re-install *also* passing prove something
   about the cache, and why does that matter on an air-gapped HPC node?

2. Version audit (the preflight habit — this output becomes provenance):
   `pixi list | tee first-run.env.txt` then, per tool:
   `pixi run fastp --version; pixi run sequali --version; pixi run seqkit version; pixi run kraken2 --version; pixi run -e busco busco --version`
   *Check*: do the reported versions match what `pixi list` shows? Write the
   table into `results/tools-versions.txt`.

3. Create the project skeleton:
   `mkdir -p data/raw logs && mkdir -p results/{strainA,strainB,strainC,strainD,strainE,strainF}/{qc,kraken2,genomescope,markers,assembly}`
   (Replace strain names with the real six — one of them is *Raph*.)
   *Check*: `ls results` — do you see six strain directories?

4. Copy the data off the pen drive:
   `cp /path/to/pendrive/*.fq.gz data/raw/ && cp /path/to/pendrive/md5.txt data/raw/`
   *Check*: `ls -lh data/raw` — are all 12 files (6 × R1+R2) present? Given
   ~20–25M read pairs per strain, roughly what size per file do you expect?

5. Verify integrity:
   `cd data/raw && md5sum -c md5.txt`
   *Check*: does every line end in `OK`? If one says `FAILED`, what are the
   two different causes (see TROUBLESHOOTING.md), and why does a failure not
   immediately mean the facility copy is bad?

6. Make a scratch copy for a dry run:
   `cp -a ~/algal-wgs ~/algal-wgs-rehearsal`
   *Why*: mistakes in the rehearsal copy cost nothing; the real tree stays
   clean until lesson 06.

---

## Quiz (answer in chat; free text)

1. What does a committed `pixi.lock` guarantee that "the tools are installed"
   does not — and why does that matter when we hand analysis over between
   machines or agents?
2. A md5sum check prints `FAILED` for `strainF_R2.fq.gz`. Name two different
   causes and the next command you'd run for each.
3. Why keep `data/raw/` read-only once intake is verified? What habit does
   that enforce about every later lesson?
4. Why is `pixi global install fastp` the WRONG move for this project — and
   when is `pixi global` the right tool instead?