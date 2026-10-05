# Exercises — Lesson 02 (run via pixi from `~/algal-wgs`; fastp/sequali/multiqc live in the default env)

1. Raw QC on strainA:
   `pixi run sequali -t 8 data/raw/strainA_R1.fq.gz data/raw/strainA_R2.fq.gz -o sequali_raw results/strainA/qc_raw/strainA.html`
   *Check*: open the HTML — what % of bases are ≥Q30? Is there adapter signal?

2. Trim strainA:
   `pixi run fastp -i data/raw/strainA_R1.fq.gz -I data/raw/strainA_R2.fq.gz -o results/strainA/trimmed/strainA_R1.trimmed.fq.gz -O results/strainA/trimmed/strainA_R2.trimmed.fq.gz --qualified_quality_phred 20 --length_required 50 --detect_adapter_for_pe --thread 8 --html results/strainA/qc/fastp.strainA.html --json results/strainA/qc/fastp.strainA.json`
   *Check*: the fastp report's "after filtering" read count — how many reads
   survived, and is that consistent with what you saw in step 1?

3. Re-QC trimmed reads (same as step 1, changed inputs):
   `pixi run sequali -t 8 results/strainA/trimmed/strainA_R1.trimmed.fq.gz results/strainA/trimmed/strainA_R2.trimmed.fq.gz -o sequali_trimmed results/strainA/qc_trimmed/strainA.html`
   *Check*: compare Q30 and length distribution with the raw report. What improved, what shortened?

4. **Raph troubleshooting** (no trimming yet):
   `pixi run sequali -t 8 data/raw/Raph_R1.fq.gz data/raw/Raph_R2.fq.gz -o sequali_raw results/Raph/qc_raw/Raph.html`
   *Check*: did this crash — and if not, what does that already imply about
   your WSL fault hypothesis? Then run the fastp step 2 command with strain=Raph.

5. Aggregate everything so far:
   `pixi run multiqc results/ --force -o results/multiqc`
   *Check*: one report, six strains visible.

Repeat steps 1–3 for the remaining four strains (you can pair this with
reading the next lesson while jobs run).

---

## Quiz (answer in chat; free text)

1. Why run QC twice (before AND after trimming)? What would you be unable to
   claim if you only did it once?
2. Raph's fastp exited with "Segmentation fault" on your PC but is fine on
   the Linux workstation. Where does the evidence point — file or machine —
   and what one further test would settle it?
3. fastp reports ~30M reads surviving from ~45M raw. Name one acceptable
   reason and one red-flag reason for that ratio.