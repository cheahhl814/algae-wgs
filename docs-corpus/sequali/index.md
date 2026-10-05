# Welcome to Sequali\'s documentation!

::: contents
Table of contents
:::

# Introduction

Sequence quality metrics for FASTQ and uBAM files.

Features:

- [MultiQC](https://multiqc.info) support since MultiQC version 1.22.
- Low memory footprint, small install size and fast execution times.
  - Sequali typically needs less than 2 GB of memory and 3-30 minutes runtime when run on 2 cores (the default).
- Informative graphs that allow for judging the quality of a sequence at a quick glance.
- Overrepresentation analysis using 21 bp sequence fragments. Overrepresented sequences are checked against the NCBI univec database.
- Estimate duplication rate using a [fingerprint subsampling technique which is also used in filesystem duplication estimation](https://www.usenix.org/system/files/conference/atc13/atc13-xie.pdf).
- Checks for 6 illumina adapter sequences and 17 nanopore adapter sequences for single read data.
- Determines adapters by overlap analysis for paired read data.
- Insert size metrics for paired read data.
- Per tile quality plots for illumina reads.
- Channel and other plots for nanopore reads.
- FASTQ and unaligned BAM are supported. See \"Supported formats\".
- Reproducible reports without timestamps.

Example reports:

- [GM24385_1.fastq.gz](https://sequali.readthedocs.io/en/latest/GM24385_1.fastq.gz.html); HG002 (Genome In A Bottle) on ultra-long Nanopore Sequencing. ENA accession: [ERR3988483](https://www.ebi.ac.uk/ena/browser/view/ERR3988483).
- [GM24385_1_cut.fastq.gz](https://sequali.readthedocs.io/en/latest/GM24385_1_cut.fastq.gz.html); `GM24385_1.fastq.gz` processed with cutadapt: `cutadapt -o GM24385_1_cut.fastq.gz --cut -64 --cut 64 --minimum-length 500 -Z --max-aer 0.1 GM24385_1.fastq.gz`. The resulting file has 64 bp cut off from both its ends and after that filtered for a minimum length of 500 and a maximum average error rate of 0.1.
- [21C125_R1.fastq.gz](https://sequali.readthedocs.io/en/latest/21C125_R1.fastq.gz.html); Illumina NovaSeq X paired-end sequencing of *Campylobacter jejuni*. ENA accession: [ERR11204024](https://www.ebi.ac.uk/ena/browser/view/ERR11204024).

# Supported formats

\- FASTQ. Only the Sanger variation with a phred offset of 33 and the error rate calculation of 10 \^ (-phred/10) is supported. All sequencers use this format today.

> - Paired end sequencing data is supported.
> - For sequences called by illumina base callers an additional plot with the per tile quality will be provided.
> - For sequences called by guppy additional plots for nanopore specific data will be provided.

- (unaligned) BAM with single reads. Read-pair information is currently ignored.
  - For BAM data as delivered by dorado additional nanopore plots will be provided.
  - For aligned BAM files, secondary and supplementary reads are ignored similar to how `samtools fastq` handles the data.

# Installation

Installation via pip is available with:

    pip install sequali

Sequali is also distributed via bioconda. It can be installed with:

    conda install -c conda-forge -c bioconda sequali

# Quickstart

.. code-block:

    sequali path/to/my.fastq.gz

This will create a report `my.fastq.gz.html` and a json `my.fastq.gz.json` in the current working directory.

To set the directory where the reports are created the `--outdir` flag can be used. This is useful when using \[MultiQC\](<https://github.com/multiqc/multiqc>).

``` 
sequali --out-dir /my/dir/all_sequali_reports my.fastq.gz
```

The html and json filenames can be set separately.

``` 
sequali --html before_qc.html --json before_qc.json my.fastq.gz
sequali --html after_qc.html --json after_qc.json my.cutadapt.fastq.gz
```

Sequali can handle paired-end data.

``` 
sequali /sequencing_data/sample100_R1.fastq.gz /sequencing_data/sample100_R2.fastq.gz
```

Additionally sequali can handle BAM data. Proper pair handling is not yet supported for BAM data, so this is primarily useful for ONT datasets.

``` 
sequali /sequencing_data/sample100_dorado_called_hac_v4.30.bam
```

Sequali by default uses one thread per compressed input file and one thread for the read processing, typically keeping two cores busy. Sequali can also use a single core, which is slower, but typically more efficient for HPC scenarios where multiple files can be run simultaneously. (Below a SLURM example.)

``` 
sbatch -c 1 --time 59 --partition short \
--wrap 'sequali --threads 1 /cluster-scratch/myusername/my.fastq.gz'
```

Using a thread count higher than `2` has no effect. Due to the decompression bottleneck, bringing the full power of multithreading to Sequali has limited utility whilst having a disproportionally high cost in additional code complexity.

For a complete overview of the available command line options check the usage below.

For more information about how the different modules see the [Module option explanations](#module-option-explanations).

# Usage

::: {.argparse module="sequali.__main__" func="argument_parser" prog="sequali"}
:::

# Module option explanations

## Adapter Content Module

The adapter content module searches for adapter stubs that are 12 bp in length. These adapter probes are saved in the default adapter file which has the following structure:

  #Name                            Sequencing Technology   Probe sequence   sequence position
  -------------------------------- ----------------------- ---------------- -------------------
  Illumina Universal Adapter       illumina                AGATCGGAAGAG     end
  Illumina Small RNA 3\' adapter   illumina                TGGAATTCTCGG     end

  : adapter_file.tsv

All empty rows and rows starting with `#` are ignored. The file is tab separated. The columns are as follows:

- Name: The name of the sequence that shows up in the report.
- Sequencing Technology: The name of the technology, currently `illumina`, `nanopore` and `all` are supported. Sequali detects the technology from the file header and only loads the appropriate adapters and adapters with `all`.
- Probe sequence: the sequence to probe for. Can be up to 64 bp in length. Since exact matching is used false postives versus false negatives need to be weighed when considering probe length.
- Sequence position: Whether the adapter occurs at the begin or end. In the resulting adapter graph, counts for this adapter will accumulate towards the begin or end depending on this field.

A new adapter file can be set with the `--adapter-file` flag on the CLI.

## Overrepresented Sequences Module

Determining overrepresented sequences is challenging. One way is to take all the k-mers of each sequence and count all the k-mer occurences. To avoid issues with read orientation the canonical k-mers should be taken[^1]. Storing all kmers and counting them is very compute intensive as a k-mer has to be calculated and stored for every position in the sequence.

Sequali therefore divides a sequence in fragments of length k. Unlike k-mers which are overlapping, this ensures that each part of the sequence is represented by just one fragment. The disadvantage is that these fragments can be caught in different frames, unlikely k-mers which capture all possible frames for length k. This hampers the detection rate.

Since most overrepresented sequences will be adapter and helper sequences and since most of these sequences will be anchored at the beginning and end of the read, this problem is alleviated by capturing the fragments from the ends towards the middle. This means that the first and last fragment will always be the first 21 bp of the beginning and the last 21 bp in the end. As such the adapter sequences will always be sampled in the same frame.

To prevent many common genome repeats from ending up in the report, Sequali limits the amount of sampling inwards to approximately 100 bp. With the default fragment size of 21 bp, this means that 5 fragments are taken from each side.

![This figure shows how fragments are sampled in sequali. The silver elements represent the fragments. Sequence #1 is longer and hence more fragments are sampled. Despite the length differences between sequence #1 and sequence #2 the fragments for the adapter and barcode sequences are the same. In Sequence #1 the fragments sampled from the back end overlap somewhat with sequences from the front end. In sequence #3 the sequence is quite long so the middle is not sampled. This prevents many common genome repeats from ending up in the report.](_static/images/overrepresented_sampling.svg)

For each sequence only unique fragments within the sequence are sampled, to avoid overrepresenting common genomic repeats. unique fragments are then stored and counted in a hash table. When the hash table is full only fragments that are already present will be counted. To diminish the time spent on the module, by default 1 in 8 sequences is analysed.

After the module is run, stored fragments are checked for their counts. If the count exceeds a certain threshold it is considered overrepresented. Sequali does a k-mer analysis of the sequences and compares that with sequences from the NCBI UniVec database to determine possible origins.

The following command line parameters affect this module:

- `--overrepresentation-threshold-fraction`: If count / total exceeds this fraction, the fragment is considered overrepresented.
- `--overrepresentation-min-threshold`: The minimum count to be considered overrepresented.
- `--overrepresentation-max-threshold`: The maximum count to be considered overrepresented. On large libraries with billions of sampled fragments this can be used to force detection for certain counts regardless of threshold.
- `--overrepresentation-max-unique-fragments`: The amount of fragments to store.
- `--overrepresentation-sample-every`: How often a sequence is sampled. Default is every 8 sequences.
- `--overrepresentation-bases-from-start`: the minimum amount of bases to take from the start of the sequence. Default is 100.
- `--overrepresentation-bases-from-end`: the minimum amount of bases to take from the end of the sequence. Default is 100.

## Duplication Estimation Module

Properly evaluating duplication in a reference-free fashion requires an all-to-all alignment of sequences and using a predefined set of criteria to ascertain whether the sequences are duplicates. This is unpractical.

For a practical estimate it is common practice to take a small part of the sequence as a fingerprint and use a hash table to store and count fingerprints. Since the fingerprint is small, sequence errors do not affect it heavily. As such this can provide a reasonable estimate, which is good enough for detecting problematic libraries.

Sequali\'s fingerprints by collecting a small sample from the front and back of the sequence. To avoid adapter sequences, the samples are taken at an offset. If the sequence is small, the offsets are sunk proportionally. If the sequence is smaller than the sample sequence lenghts, its entire length is sampled. Paired sequences are sampled at the beginning of both its sequences without an offset, since adapter sequences for illumina sequences are closer to the end.

![Sequali fingerprinting. Small samples are taken from the front and back of the sequence at an offset. Sequence #1 shows the common situation where the sequence is long. Sequence #2 is smaller than the combined length of the offsets and the samples, so the offsets are shrunk proportionally. Sequence #3 is smaller than the sample length, so its sampled entirely. Sequence #4 is paired, so samples are taken from the beginning of R1 and R2.](_static/images/fingerprint.svg)

The sampled sequences are then combined into one and hashed. The hash seed is determined by the sequence length integer divided by 64. The resulting hash is the fingerprint.

Since not all fingerprints can be counted due to memory constraints, [a hash subsampling technique from the file storage world](https://www.usenix.org/system/files/conference/atc13/atc13-xie.pdf) is used.

This technique first counts all the fingerprints. Then when the hash table is full, a new hash table is created. The already counted fingerprints are inserted but only if the last bit of the hash is `0`. This eliminates on average half of the fingerprints. The fingerprinting and counting is then continued, but only hashes that end in `0` are considered. If the hash table is full again, the process is repeated but now only hashes that end with the last two bits `00` are considered, and so on.

The advantage of this technique is that it subsamples only part of the fingerprints which is good for memory usage. As stated in the paper, unlike subsampling only the fingerprints from the beginning of the file, this technique is much less biased towards unique sequences.

The following command line options affect this module:

- `--duplication-max-stored-fingerprints`: The maximum amount of stored fingerprints. More fingerprints lead to more accurate estimates but also more memory usage.

These options can be used to control how the fingerprint is taken

- `--fingerprint-front-length`.
- `--fingerprint-back-length`. For paired-end sequencing this is the length of the sample from from the beginning for R2.
- `--fingerprint-front-offset`.
- `--fingerprint-back-offset`. For paired-end sequencing this is the offset the sample from the beginning for R2.

# Citation

If you wish to credit Sequali please cite [the Sequali article](https://doi.org/10.1093/bioadv/vbaf010).

# Acknowledgements

\+ [FastQC](https://www.bioinformatics.babraham.ac.uk/projects/fastqc/) for its excellent selection of relevant metrics. For this reason these metrics are also gathered by Sequali. + The matplotlib team for their excellent work on colormaps. Their work was an inspiration for how to present the data and their RdBu colormap is used to represent quality score data. Check their [writings on colormaps](https://matplotlib.org/stable/users/explain/colors/colormaps.html) for a good introduction. + Wouter de Coster for his [excellent post on how to correctly average phred scores](https://gigabaseorgigabyte.wordpress.com/2017/06/26/averaging-basecall-quality-scores-the-right-way/) as well as the idea for using end-anchored plots from [NanoQC](https://github.com/wdecoster/nanoQC). + Marcel Martin for providing very extensive feedback. + Agnès Barnabé for creating a Galaxy wrapper.

# Changelog

## version develop

- Speed up the adapter finder module for non-avx2 targets.

## version 1.0.2

- Test on Python 3.14.
- Fix various reference counting errors.
- Fix issue where a missing `st` tag causes an IndexError.
- Raise a warning on wrongly formatted `pi` tags rather than an error.
- Fix issue where too many secondary and supplementary reads in a row would crash Sequali.
- Fix heap overflow issue caused by a wrong pointer offset.
- Require at least setuptools version 77 for building the package.

## version 1.0.1

- Fix a configuration issue where on later setuptools versions wheels would be compiled without optimization flags, leading to much degraded performance. This only affected PyPI wheels and version 1.0.0 has been yanked from PyPI.

## version 1.0.0

This release addresses part of the received feedback after Sequali\'s publication.

- Python 3.13 support was added.
- Python 3.8 and 3.9 are no longer supported.
- Add an `--images-zip` flag to set a path where a zip with all the images will be created.
- Make reports reproducible by eliminating timestamps.
- Add end-anchored plots, similar to how it is done in [NanoQC](https://github.com/wdecoster/nanoQC).
- Add a plot show how many reads originate from read splitting. This primarily serves to notify the user that chimeric read splitting has already been performed by dorado.
- Add a N50 and N90 statistic to the sequence length distribution report.
- Allow proper judging of aligned BAM files as input data by ignoring any secondary or supplementary alignment records. This is equivalent to running `samtools fastq > input.fastq` on the input data before submitting it to sequali, except that useful tag information is retained.
- Only sample the first 100 bp from the beginning and end of the read by default for the overrepresented sequences analysis. This prevents a lot of false positives from common human genome repeats. The amount of base pairs that are sampled from the beginning and end is user settable with an option to sample everything.
- The code for the adapter counting was refactored and the vectorized algorithm was replaced by an AVX2 version that is used when the CPU supports that instruction set. This is both faster and far less code than the original implementation.
- Extended the README with a few usage examples.

## version 0.12.0

- Properly name percentiles as such in the sequence length distribution rather than using N50 nomenclature which is not correct.
- Fix a bug where BAM files with missing quality sequences were inproperly handled.
- Update internal UniVec database to version from November 21st 2023.

## version 0.11.1

- Fix a memory leak that occurred in Python 3.12 due to a refcounting API change.

## version 0.11.0

- Make figure IDs reproducible across HTML reports.
- Fix a bug where the average phred score per read would be rounded, not floored. This would lead reads with a phred score such as 9.7 to be counted towards the Q\>=10 results.
- Replace some of the hand vectorized code with more generic code that can be automatically be optimized by the compiler. This should make things faster on Windows and ARM64 platforms. This also means results should be consistent across platforms and no longer depend on the presence of vector instructions.

## version 0.10.0

- Make overrepresented sequences table scrollable and smaller so it is easier to skip over when lots of entries are found.
- Overrepresented sequence analysis now only counts unique fragments per read. Fragments that are duplicated inside the read are counted only once. This prevents long stretches of genomic repeats getting higher reported frequencies.
- Speed up sequence identity calculations on AVX2 enabled CPUs by using a reverse-diagonal parallelized version of Smith-Waterman.

## version 0.9.1

- Fix an issue where the insert size metrics module would crash when no adapters where present.

## version 0.9.0

- MultiQC support since MultiQC version 1.22
- Sort modules for paired end reports in the same order as single end reports. For example, the sequence length distributions for read 1 and read 2 are now right after each other.
- Add common human genome repeats and Illumina poly-G dark cycles to the overrepresented sequences database.
- Illumina adapter trimming sequences were added to the contaminants database as these were missing from the UniVec database.
- Sequence identity, rather than kmers matched is shown as a metric for similarity in the overrepresented sequences table.
- Overrepresented sequence classification now uses stable sorting to ensure the classification results are the same on each rerun.
- Overrepresented sequences are now classified using Smith-Waterman alignment and sequence identity.
- Fix an off by one error in the insert size metrics that was triggered for insert sizes larger than 300 bp.

## version 0.8.0

- A citation file was added to the repository.
- Calculate insert sizes and used adapters based on overlap between the read pairs.
- Both reads from paired-end reads are taken into consideration when evaluating the duplication rate.
- Support for paired-end reads added.
- Minor performance improvement by providing a non-temporal cache hint in the QCMetrics module.

## version 0.7.1

- Fix a small visual bug in the report sidebar.
- PyGAL report htmls are now fully HTML5 compliant. HTML5 validation has been made a part of the integration testing.

## version 0.7.0

- Image files can now be saved as SVG files.
- The javascript file for the tooltip highlighting is now embedded in the html file so no internet access is needed for the functionality.
- A sidebar with a table of contents is added to the report for easier navigation.
- Graph fonts are made a little bigger. Graphs now respond to zooming in and out on the web page.
- Enable building on ARM platforms such as M1 macintosh and Aarch64.
- Speedup the overrepresented sequences module by adding an AVX2 k-mer construction algorithm.

## version 0.6.0

- Add links to the documentation in the report.
- Moved documentation to readthedocs and added extensive module documentation.
- Change the `-deduplication-estimate-bits` to a more understandable `--duplication-max-stored-fingerprints`.
- Add a small table that lists how many reads are \>=Q5, \>=Q7 etc. in the per sequence average quality report.
- The progressbar can track progress through more file formats.
- The deduplication fingerprint that is used is now configurable from the command line.
- The deduplication module starts by gathering all sequences rather than half of the sequences. This allows all sequences to be considered using a big enough hash table.

## version 0.5.1

- Fix a bug in the overrepresented sequence sampling where the fragments from the back half of the sequence were incorrectly sampled. Leading to the last fragment being sampled over and over again.

## version 0.5.0

- Base the percentage in the overrepresented sequences section on the number of found fragments divided by the number of sampled sequences. Previously this was based on the number of sampled fragments, which led to very low percentages for long read sequences, whilst also being less intuitive to understand. There were some inconsistencies in the documentation about this that are now fixed.
- Add a new [meta]{.title-ref} section to the JSON report to allow integration with [MultiQC](https://multiqc.info).
- Add all nanopore barcode sequences and native adapters to the contaminants.
- Add native adapters to the adapter search.

## version 0.4.1

- Fixed an issue that caused an off by one error if start and end time of a Nanopore run were at certain intervals.

## version 0.4.0

- Fix bugs that were triggered when empty reads were present on illumina and nanopore platforms.
- Fix a bug that was triggered when a single nucleotide read was present on a nanopore platform.
- Add a `--version` command line flag.
- Add an `--adapter-file` file flag which can be used to set custom adapter files by users.

## version 0.3.0

- Fingerprint using offsets of 64 bases from both ends of the sequence. On nanopore sequencing this prevents taking into account adapter sequences for the duplication estimate. It also prevents taking sequences from the error-prone regions. The fingerprint consists of two 8 bp sequences rather than the two 16 bp sequences that were used before. This made the fingerprint less prone to sequencing errors, especially in long read sequencing technologies. As a result the duplication estimate on nanopore reads should be more accurate.
- Added a small header with information on where to submit bug reports.
- Use different adapter probes for nanopore adapters, such that the probes do occur at some distance from the strand extremities. The start and end of nanopore sequences are prone to errors and this hindered adapter detection.
- Distinguish between top and bottom adapters for the adapter occurrence plot.
- Update pygal to 3.0.4 to prevent installation errors on Python 3.12.
- Fix several divide by 0 errors that occurred on empty reads and empty files.
- Change default fragment length from 31 to 21 which increases the sensitivity of the overrepresented sequences module.

## version 0.2.0

- Fixed a crash that occurred in the illumina header checking code on illumina headers without the comment part.
- `--max-unique-sequences` flag replaced with `--overrepresentation-max-unique-fragments` to be consistent with the report and other flags.
- Lots of formatting improvements were made to the report:
  - The quality distribution plot now use Matplotlib\'s RdBu colormap. Like the old colormap, it goes from red to blue via white, but is much clearer visually.
  - Tables now have zebra-style coloring and mouse-over coloring to clearly distinguish rows.
  - The base content plot now uses a green and blue color scheme for GC and AT bases respectively. Previously it was red and blue.
  - Sans-serif fonts used throughout the report.
  - Explanation paragraphs are now in a smaller font and italic to visually distuingish them from data generated specifically for the sequencing file.
  - Plots are now rendered in sans-serif rather than monospace fonts.
  - Minor formatting, spelling and style issues were fixed.
- The programs CLI help messages have been improved by clearer phrasing, better metavar names and consistent punctuation.
- The reverse complement of the canonical sequence is included in the overrepresented sequences table.
- Make the number of threads configurable on the command line.
- Fix build errors on windows

## version 0.1.0

- In order to get overrepresented sequences across the entire read, reads are cut into fragments of 31 bp which are stored and counted. If the fragment store is full, only already stored sequences are counted. One in eight reads is processed this way.
- Add fingerprint-based deduplication estimation based on [a technique used in filesystem deduplication estimation](https://www.usenix.org/system/files/conference/atc13/atc13-xie.pdf).
- Add a BAM parser to allow reading dorado produced unaligned BAM as well as already aligned BAM files.
- Guess sequencing technology from the file header, so only appropriate adapters can be loaded in the adapter searcher. This improves speed.
- Make an assortment of nanopore adapter probes that make it possible to distuinghish between nannopore adapters despite the nanopore adapters having a lot of shared subsequences.
- Add a module to retrieve nanopore specific information from the header.
- Classify overrepresented sequences by using NCBI\'s UniVec database and an assortment of nanopore adapters, ligation kits and primers.
- Estimate duplication fractions based on counted unique sequences.
- Add a JSON report
- Add a progressbar powered by tqdm.
- Implement a custom parser based on memchr for finding newlines.
- Count overrepresented sequences using a hash table implemented in C.
- Add a per tile sequence quality module.
- Count adapters using a fast shift-AND algorithm.
- Create diverse graphs using pygal based on the count matrix.
- Implement base module using an optimised count matrix.

[^1]: A canonical k-mer is the k-mer that has the lowest sort order compared to itself and its reverse complement. This way the canonical-kmer is always the same regardless if it, or its reverse complement are read. This is useful to identify sequences regardless of orientation.
