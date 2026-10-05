# Exercises — Lesson 06 (run via pixi inside `tmux`; spades is in the default env)

1. Check resources FIRST:
   `free -g && nproc` — how much RAM is actually free? Decide with the
   instructor how many strains can run concurrently.

2. Start a tmux session so the job survives disconnects:
   `tmux new -s spadesA` then run:
   `pixi run spades.py --isolate -1 results/strainA/trimmed/strainA_R1.trimmed.fq.gz -2 results/strainA/trimmed/strainA_R2.trimmed.fq.gz -t 16 -m 60 -o results/strainA/assembly/spades_out 2>&1 | tee logs/strainA.spades.log`
   Detach with `Ctrl-b d`. *Check*: reattach (`tmux a -t spadesA`) — which
   k is SPAdes on right now?

3. While it runs, interpret log lines: find the "Assembling" stage lines in
   the log (`grep -n "Assembling" logs/strainA.spades.log`). What does the
   increasing k ladder do to the contiguity it reports?

4. On completion: `bash -c 'tail -5 logs/strainA.spades.log'` — confirm
   "Thank you for using SPAdes!". Then:
   `cp results/strainA/assembly/spades_out/contigs.fasta results/strainA/assembly/strainA.contigs.fasta`
   and `pixi run seqkit stats results/strainA/assembly/strainA.contigs.fasta` — how many contigs, and what is the longest?

5. Queue the next strain in the same tmux pane (serial, per instructor's
   concurrency decision), and draft your results-section sentence about
   expected fragmentation of short-read-only assemblies.

---

## Quiz (answer in chat; free text)

1. Why does RAM, not thread count, usually cap how many SPAdes runs you can
   run simultaneously — and where does `-m 60` come from on a 64 GB box?
2. Why run a multi-hour job inside tmux rather than a plain terminal?
   What happens to a foreground SPAdes run if your SSH/PC dies?
3. Your assembly finished in 20 minutes with 3,000 contigs mostly <500 bp.
   Which upstream lesson's numbers would you check first, and what?