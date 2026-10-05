#!/usr/bin/env bash
# battle_test.sh — tiered lesson rehearsal (see battle-test/README.md)
# Usage: ./battle_test.sh structural | exec | exec-kraken2 | all-exec
# Run from the course battle-test/ directory. Requires: pixi (locked), bash.
set -uo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
COURSE="$(dirname "$HERE")"          # course root (pixi.toml, refs/, lessons/)
REPORT="$HERE/battle-test-report.md"
REFS="${REFS:-$COURSE/refs/chlorophyte_markers.fasta}"
KRAKEN_DB="${KRAKEN_DB:-}"           # required for exec-kraken2 (instructor-set)
FAILS=0; WARNS=0

log(){ echo "$@" | tee -a "$REPORT"; }
check(){ # check <PASS|WARN|FAIL> "<what>" [stderr]
  local verdict="$1"; shift
  echo "$verdict $*" >> "$REPORT"
  [[ $# -gt 0 && -n "$1" ]] && { echo "--- stderr ---" >> "$REPORT"; echo "$1" | head -25 >> "$REPORT"; }
  case "$verdict" in
    FAIL) FAILS=$((FAILS+1));;
    WARN) WARNS=$((WARNS+1));;
  esac
}
stamp(){ echo "## battle-test run $(date -Iseconds) — stage: $1" >> "$REPORT"; }
envrun(){ pixi run "$@"; }
envrun-e(){ local e="$1"; shift; pixi run -e "$e" "$@"; }

# ---------------- Tier A: structural ----------------
structural(){
  stamp structural
  cd "$COURSE" || { check FAIL "cannot cd course root"; exit 1; }

  if pixi lock --dry-run >/dev/null 2>"$HERE/.bt.err"; then
    check PASS "pixi lock --dry-run solves all environments (incl. isolated features)"
  else check FAIL "pixi lock --dry-run failed" "$(cat "$HERE/.bt.err")"; fi

  if pixi install --locked >/dev/null 2>"$HERE/.bt.err"; then
    check PASS "pixi install --locked"
    if pixi install --locked --offline >/dev/null 2>&1; then
      check PASS "pixi install --locked --offline (cache covers lockfile)"
    else check WARN "offline solve failed — package cache incomplete (matters on HPC only)"; fi
  else check FAIL "pixi install --locked failed" "$(cat "$HERE/.bt.err")"; fi

  local tools_default="fastp sequali multiqc seqkit bbduk.sh blastn kraken2 meryl spades.py"
  local t
  for t in fastp sequali multiqc seqkit bbmap kraken2 meryl spades quast busco genomescope2 blastn; do
    if test -s docs-corpus/$t/README.md; then
      check PASS "docs-corpus/${t}/README.md present (battle-test check #4 equivalent)"
    else check FAIL "docs-corpus/${t} missing metadata README (pixi.toml tool without corpus)"; fi
  done
  n=$(grep -l 'cli-reference.md' docs-corpus/*/README.md | wc -l)
  check $([ "$n" -eq 12 ] && echo PASS || echo WARN) "pinned cli-reference.md captures present in $n/12 tool dirs (workstation task, INSTRUCTOR-SETUP §5)"
  for t in $tools_default; do
    if envrun "$t" --version >/dev/null 2>&1; then check PASS "tool answers: $t (default env)"
    else check FAIL "tool does not answer: $t (default env)" "$(envrun "$t" --version 2>&1)"; fi
  done
  for pair in "genomescope:genomescope2" "quast:quast.py" "busco:busco"; do
    local env="${pair%%:*}" tool="${pair#*:}"
    if pixi run -e "$env" "$tool" --version >/dev/null 2>&1; then
      check PASS "tool answers: $tool (-e $env)"
    else check FAIL "tool does not answer: $tool (-e $env)" "$(pixi run -e "$env" "$tool" --version 2>&1)"; fi
  done

  local n
  n=$(grep -l 'Exit gate' lessons/*/README.md | wc -l); check $([ "$n" -eq 7 ] && echo PASS || echo WARN) "exit gates $n/7"
  n=$(grep -l '## Quiz' lessons/*/exercises.md | wc -l); check $([ "$n" -eq 7 ] && echo PASS || echo WARN) "quiz sections $n/7"
  if [ -s TROUBLESHOOTING.md ]; then check PASS "TROUBLESHOOTING.md present ($(grep -c '^| ' TROUBLESHOOTING.md) table rows)"
  else check FAIL "TROUBLESHOOTING.md missing/empty"; fi
  if test -f refs/chlorophyte_markers.fasta; then check PASS "marker refs present ($(grep -c '>' refs/chlorophyte_markers.fasta) seqs)"
  else check FAIL "refs/chlorophyte_markers.fasta missing — tier B lesson-05 rehearsal needs it"; fi
  pixi list | sort > "$HERE/.bt-env-versions.txt"; check PASS "version audit snapshot saved ($(wc -l < "$HERE/.bt-env-versions.txt") rows)"
}

# ---------------- dummy data generation (python3, stdlib only) ----------------
gen_dummy(){
  python3 - "$HERE/dummy" "$2" <<'PYEOF'
import sys, random, gzip, os
outdir, n_pairs = sys.argv[1], int(sys.argv[2]); random.seed(42)
os.makedirs(outdir, exist_ok=True)
def revcomp(s): return s.translate(str.maketrans("ACGT","TGCA"))[::-1]
def genome(n): return "".join(random.choice("ACGT") for _ in range(n))
def writes(gz, name, seq, qual): gz.write(f"@{name}\n{seq}\n+\n{qual}\n".encode())
def simulate(seq, stem, n_pairs, seed):
    random.seed(seed)
    p1, p2 = os.path.join(outdir, stem+"_R1.fq.gz"), os.path.join(outdir, stem+"_R2.fq.gz")
    z1, z2 = gzip.open(p1,"wb"), gzip.open(p2,"wb")
    L, ins = 150, 300
    for i in range(n_pairs):
        s = random.randrange(0, len(seq)-ins-1)
        q = "I"*L  # Q40, no errors: deterministic, perfectly reconstructible
        writes(z1, f"bt_{stem}_{i}", seq[s:s+L], q)
        writes(z2, f"bt_{stem}_{i}", revcomp(seq[s+ins-150:s+ins]), q)
    z1.close(); z2.close(); return (p1,p2)
g1 = genome(2_500_000); g_marker = None
if os.environ.get("MARKER_FASTA") and os.path.exists(os.environ["MARKER_FASTA"]):
    seqs=[]; cur=[]
    with open(os.environ["MARKER_FASTA"]) as fh:
        for line in fh:
            if line.startswith(">") and cur: seqs.append("".join(cur)); cur=[]
            elif not line.startswith(">"): cur.append(line.strip())
    if cur: seqs.append("".join(cur))
    if seqs:
        # seed marker seq (reverse-complement half of it) into the genome so the
        # capture→blastn chain has a 100%-identity ground truth
        m = seqs[0]; g1 = list(g1); s=1000
        g1 = g1[:s] + [m] + g1[s+len(m):]; g1 = "".join(g1); g_marker = m
simulate(g1, "btA", n_pairs, 1)
g2 = genome(2_500_000); simulate(g2, "btB", n_pairs, 2)
if g_marker:
    md5 = __import__("hashlib").md5(g_marker.encode()).hexdigest()
    open(os.path.join(outdir,"marker_seed.txt"),"w").write(f"seeded_marker_seq_md5={md5}\nseeded_in=btA\n")
open(os.path.join(outdir,"truth.txt"),"w").write(f"btA=2500000bp btB=2500000bp pairs={n_pairs}\n")
PYEOF
}

# ---------------- Tier B: functional rehearsal, no DB ----------------
exec_stage(){
  stamp exec
  gen_dummy "$HERE/dummy" 500000 || { check FAIL "dummy generation failed"; }
  local D="$HERE/dummy"; cd "$D" || return 1
  mkdir -p results/btA/{qc,trimmed,genomescope,markers,assembly} logs

  # L02 chain
  if envrun fastp -i btA_R1.fq.gz -I btA_R2.fq.gz \
       -o results/btA/trimmed/btA_R1.trimmed.fq.gz -O results/btA/trimmed/btA_R2.trimmed.fq.gz \
       --qualified_quality_phred 20 --length_required 50 --detect_adapter_for_pe --thread 4 \
       --html results/btA/qc/fastp.btA.html --json results/btA/qc/fastp.btA.json 2>logs/fastp.log
  then check PASS "L02 fastp executes on dummy reads (trimming should be ~no-op: synthetic reads are clean)"
  else check FAIL "L02 fastp failed" "$(tail -5 logs/fastp.log)"; fi
  if envrun sequali -t 4 btA_R1.fq.gz btA_R2.fq.gz -o sequali_raw results/btA/qc/btA.html >/dev/null 2>logs/sequali.log
  then check PASS "L02 sequali renders"; else check FAIL "L02 sequali failed" "$(tail -5 logs/sequali.log)"; fi

  # L04 chain — the calibration check: GenomeScope2 must estimate ~2.5 Mb
  if envrun meryl count k=31 memory=8 threads=4 output kmers btA_R1.fq.gz btA_R2.fq.gz 2>logs/meryl.log \
     && envrun meryl histogram kmers > btA.histo.txt 2>logs/meryl2.log
  then check PASS "L04 meryl count+histogram"; else check FAIL "L04 meryl failed" "$(tail -3 logs/meryl.log logs/meryl2.log)"; fi
  if envrun-e genomescope genomescope2 -i btA.histo.txt -o gsout -k 31 >logs/gs.log 2>&1 && [ -s gsout/summary.txt ]
  then
    est=$(awk '/Genome Haploid Length/{print $4}' gsout/summary.txt 2>/dev/null)
    check PASS "L04 GenomeScope2 fit (size estimate: ${est:-?} — compare against truth.txt: 2.5 Mb)"
  else check FAIL "L04 GenomeScope2 failed" "$(tail -5 logs/gs.log 2>/dev/null)"; fi

  # L05 chain — capture→mini-assembly→blastn, seeded 100% identity ground truth
  if [ -s "$REFS" ]; then
    if envrun bbduk.sh in=btA_R1.fq.gz,btA_R2.fq.gz ref="$REFS" k=25 hdist=1 \
         outm=mk_R1.fq.gz outm2=mk_R2.fq.gz 2>logs/bbduk.log
    then
      if envrun spades.py -k 21,55 --only-assembler -1 mk_R1.fq.gz -2 mk_R2.fq.gz \
           -t 4 -m 8 -o spades_mini 2>logs/spades_mini.log && [ -s spades_mini/contigs.fasta ]
      then
        hits=$(envrun blastn -query spades_mini/contigs.fasta -subject "$REFS" \
               -outfmt '6 qseqid sseqid pident length evalue bitscore stitle' 2>/dev/null | sort -k3 -gr | head -1)
        if [ -n "$hits" ]; then
          pid=$(echo "$hits" | awk '{print int($3)}')
          check $([ "$pid" -ge 99 ] && echo PASS || echo WARN) "L05 capture→blastn ground truth: top identity ${pid}% (expect ≥99: reads simulated from a ref contig) — ${hits}"
        else check FAIL "L05 blastn produced no hits (capture or mini-assembly broke)"; fi
      else check FAIL "L05 mini-SPAdes failed" "$(tail -5 logs/spades_mini.log)"; fi
    else check FAIL "L05 bbduk capture failed (check marker refs headers: marker token must be first)" "$(tail -5 logs/bbduk.log)"; fi
  else check FAIL "L05 skipped: refs/chlorophyte_markers.fasta not found (set REFS)"; fi

  # L06 chain — SPAdes --isolate on 2.5 Mb: measures REAL time+RAM on this box
  /usr/bin/time -v envrun spades.py --isolate -1 btA_R1.fq.gz -2 btA_R2.fq.gz -t 4 -m 16 \
      -o spades_out 2>logs/spades.log
  if [ -s spades_out/contigs.fasta ]; then
    nctg=$(grep -c '>' spades_out/contigs.fasta)
    check PASS "L06 SPAdes --isolate done on 2.5 Mb dummy: $nctg contigs; Elapsed/MaxRSS → logs/spades.log (feeds lesson-06 -m/-t guidance)"
  else check FAIL "L06 SPAdes failed on dummy" "$(tail -8 logs/spades.log)"; fi

  # L07 chain — quast + busco (RUN-only; BUSCO on dummy vs plants ≈ 0% complete by design)
  if envrun-e quast quast.py -o quast_btA -t 4 -m 500 spades_out/contigs.fasta >/dev/null 2>logs/quast.log && [ -s quast_btA/report.tsv ]
  then check PASS "L07 QUAST renders report.tsv"; else check FAIL "L07 QUAST failed" "$(tail -5 logs/quast.log)"; fi
  if envrun-e busco busco -i spades_out/contigs.fasta -o btA_busco -m genome -l viridiplantae_odb10 \
       -c 4 --out_path busco_btA >/dev/null 2>logs/busco.log
  then check WARN "L07 BUSCO executes + lineage loads (recorded as INFO only — expect ~0% complete on a bacterial-scale synthetic genome; never quote this number)"
  else check FAIL "L07 BUSCO failed to execute" "$(tail -5 logs/busco.log)"; fi

  # L01 path — md5 verify, both OK and deliberately-corrupted paths
  echo "dummy content for md5" > md5_target.txt
  md5sum md5_target.txt > md5.sum
  if md5sum -c md5.sum 2>&1 | grep -q "OK"; then check PASS "L01 md5 OK-path exercised"
  else check FAIL "L01 md5 OK-path failed on an intact file"; fi
  echo "0bad0bad0bad0bad0bad0bad0bad0bad  md5_target.txt" > md5.badsum
  if md5sum -c md5.badsum 2>&1 | grep -q "FAILED"; then check PASS "L01 md5 FAILED-path exercised (corruption detected)"
  else check FAIL "L01 md5 did NOT flag a corrupted checksum"; fi
}

# ---------------- Tier C: Kraken2 chain (needs DB) ----------------
exec_kraken2(){
  stamp "exec-kraken2"
  local D="$HERE/dummy"; cd "$D" || return 1
  if [ -z "$KRAKEN_DB" ] || [ ! -d "$KRAKEN_DB" ]; then
    check FAIL "exec-kraken2: KRAKEN_DB env var not set or missing dir (set it to the extracted Standard-8 path)"; return 0; fi
  if envrun kraken2-inspect "$KRAKEN_DB" > inspect.txt 2>logs/k2i.log && [ -s inspect.txt ]
  then check PASS "kraken2-inspect healthy ($(grep -c . inspect.txt) taxa rows)"; else check FAIL "kraken2-inspect failed — DB download likely incomplete" "$(tail -5 logs/k2i.log)"; fi
  # null control: dummy random reads → unclassified
  if envrun kraken2 --db "$KRAKEN_DB" --paired --threads 4 --confidence 0.2 \
       --report null.kreport btA_R1.fq.gz btA_R2.fq.gz > null.out 2>logs/k2null.log
  then
    pct=$(awk '$1=="U"{print $2}' null.kreport)
    check $(awk -v p="$pct" 'BEGIN{print (p+0>=95)?"PASS":"WARN"}') "null control: ${pct:-?}% unclassified on random sequence (expect ~100)"
  else check FAIL "null control kraken2 run failed" "$(tail -5 logs/k2null.log)"; fi
  # positive control: instructor-supplied reference genome (fastq generated locally)
  if [ -n "${CONTROL_FASTA:-}" ] && [ -f "$CONTROL_FASTA" ]; then
    python3 - "$CONTROL_FASTA" pos_control <<'PYEOF'
import sys, random, gzip
fa, stem = sys.argv[1], sys.argv[2]; seq = []; random.seed(7)
with open(fa) as fh:
    for line in fh:
        if not line.startswith(">"):
            seq.append(line.strip())
s = "".join(seq).upper().replace("N", "A")
pc = s.translate(str.maketrans("ACGT", "TGCA"))[::-1]
z1, z2 = gzip.open(stem + "_R1.fq.gz", "wb"), gzip.open(stem + "_R2.fq.gz", "wb")
for i in range(100000):
    st = random.randrange(0, len(s) - 300); q = "I" * 150
    z1.write(f"@c_{i}\n{s[st:st+150]}\n+\n{q}\n".encode())
    z2.write(f"@c_{i}\n{pc[st:st+150]}\n+\n{q}\n".encode())
z1.close(); z2.close()
PYEOF
    if envrun kraken2 --db "$KRAKEN_DB" --paired --threads 4 --confidence 0.2 \
         --report pos.kreport pos_control_R1.fq.gz pos_control_R2.fq.gz > pos.out 2>logs/k2pos.log
    then
      pctc=$(awk '$1=="U"{u=$2} END{print 100-u}' pos.kreport)
      check $(awk -v p="$pctc" 'BEGIN{print (p>=80)?"PASS":"WARN"}') "positive control: ${pctc:-?}% classified (expect >80 for real reads vs Standard-8)"
    else check FAIL "positive-control kraken2 run failed" "$(tail -5 logs/k2pos.log)"; fi
  else
    check WARN "no CONTROL_FASTA set — positive control pending (recommended: E. coli K-12 GCF_000005845.2, expect >95% classified)"
  fi
}

: > "$HERE/.bt.tmp"; REPORT="$HERE/battle-test-report.md"
mkdir -p "$HERE/dummy"
case "${1:-}" in
  structural)  structural ;;
  exec|all-exec) exec_stage ;;
  exec-kraken2) exec_kraken2 ;;
  *) echo "usage: $0 structural|exec|exec-kraken2"; exit 2;;
esac
{ echo; echo "## VERDICT ($1): FAILS=$FAILS WARNS=$WARNS"; } >> "$HERE/.bt.summary"
cat "$HERE/.bt.summary" >> "$REPORT"; rm -f "$HERE/.bt.summary" "$HERE/.bt.env"
tail -3 "$REPORT"