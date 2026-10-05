# Course signature library — algal-wgs-course

Adapted from the bioinfo-skill-creator convention: map `stderr/stdout signature
→ likely cause → suggested fix`. The coach consults this before diagnosing; a
miss here routes to the tool's docs-corpus capture (see INSTRUCTOR-SETUP §5).
Verbatim errors only — the signature match depends on exact wording.

| Lesson | Signature | Likely cause | Fix |
|---|---|---|---|
| 01 | `md5sum: FAILED open or read` | wrong filename/path (renamed strains) | regenerate checksum list with `md5sum <files> > md5.txt`, re-run `-c` |
| 01 | `md5sum: XXX: FAILED` | corrupted transfer | re-copy the file, re-verify; only then suspect the facility copy |
| 01 | `pixi install` → `error: lock file does not match manifest` | pixi.toml edited without re-locking | instructor re-runs `pixi lock`; never `--lock-bypass` |
| 01 | `pixi: command not found` | PATH after install | restart terminal / source profile; never `pip install pixi` |
| 02 | fastp `Empty paired-end file` (after severe trimming) | adapter detection too aggressive on low-quality data | report Q-profiles; revisit `--qualified_quality_phred` with instructor |
| 02 | `Segmentation fault` on fastp (only on student's WSL PC) | Windows/WSL I/O layer, not the file | rerun on native Linux; the decisive evidence is where it passes |
| 02 | multiqc `No analysis results found` | ran from wrong cwd / empty results/ | check `pwd` and directory tree; MultiQC scans the given path |
| 03 | kraken2 `Error reading database directory` | DB path wrong / index files missing | confirm path with instructor; `kraken2-inspect <DB> | head` to smoke-test |
| 03 | kraken2 OOM (killed) | standard DB needs ~10–20 GB RAM | run on the workstation, not a laptop; check `free -g` first |
| 04 | GenomeScope2 fit warning / low goodness-of-fit | heterozygosity too high for k=31 | record and report — do NOT force a different k alone; consult instructor |
| 04 | meryl `memory` error on workstation | `memory=16` exceeds free RAM | lower memory parameter; check `free -g` |
| 05 | bbduk retains 0.00% reads | capture too strict (k=25/hdist=1), or marker absent from refs | loosen one notch; first confirm a control strain captures |
| 05 | blastn: no hits | mini-assembly too fragmented, or wrong marker in query set | check contig lengths; retry with relaxed capture; check ref FASTA headers |
| 05 | seqkit grep: `no id matches` | marker_ids.txt empty or headers mismatched | inspect `marker_ids.txt`; `grep '>'` the contigs FASTA |
| 06 | SPAdes `Error in thread ...: bad_alloc` | RAM over budget | lower `-m`; confirm with `free -g`; reduce concurrent runs |
| 06 | SPAdes finishes fast with tiny contigs | wrong inputs (raw not trimmed) | compare input checksums with lesson-02 outputs |
| 07 | `quast.py: invalid choice` / import error | quast env not isolated | run via `pixi run -e quast` |
| 07 | BUSCO `Missing lineage dataset` | lineage not downloaded on this machine | instructor runs the download; never fetch mid-lesson |

Housekeeping signatures (any lesson):
- `No space left on device` → `df -h .` before blaming the tool; assemblies and DBs are the usual hogs.
- `Read-only file system` → you are on the pen drive; copy data into the project root first (lesson 01).
- Fish-only issue: `$?` empty → panes run fish; use bash for analysis (`bash --login`) per lesson 01 setup.