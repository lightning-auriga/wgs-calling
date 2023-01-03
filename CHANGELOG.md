# Changelog

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.3.0] - Ensemble SV Calling

### Added

- support for [delly](https://github.com/dellytools/delly)
- support for [lumpy](https://github.com/arq5x/lumpy-sv)
  - lumpy's own repo recommends using [smoove](https://github.com/brentp/smoove) to actually run lumpy, and so that's recapitulated here
- support for [svaba](https://github.com/walaj/svaba)
- ensemble SV calling
  - variants are still merged with svdb, but additional filters are applied to select out subsets of variants based on how many/which callers detected them
- methods summary and version reporting
  - once the workflow instance's conda environments have been installed, for example after the run is complete, run `snakemake -j1 summarize_methods`
    to emit a report in `results/reports` that summarizes:
	- the bioinformatic methodology deployed in your installed version of the workflow
	- the best available git description of your installed pipeline version
	- the version data of all pertinent packages installed from conda
	- descriptions of the most prominent user configuration settings and commentary on the impact of important settings therein
- gvcf generation by DeepVariant

### Changed

- [TIDDIT](https://github.com/SciLifeLab/TIDDIT) is no longer pinned to <3
- due to TIDDIT update, manual conversion of `TDUP` variants is no longer relevant,
  as these were harmonized away to standardized SV types between <3 and current
- duplicates are now removed, instead of just marked
- sites with FILTER=PASS but GT=./. are now removed before ensemble calling
  - impacts TIDDIT and delly
- alignment multiqc report points to fastqc results from merged-by-lane fastqs
  - in response to user feedback; draft fix for an outstanding issue with the alignment multiqc report

### Removed

- inexplicable old change of TIDDIT output DUP variants to INS

## [0.2.0] - DeepVariant

First support for DeepVariant.

### Added

- support for DeepVariant
  - specify with `config/config.yaml` `snv-caller: deepvariant`
- automatically record performance benchmark data
  - stored under `results/performance_benchmarks`
- optionally create performance benchmark report for review during optimization
  - the report is not created by default, and requires substantially more work
    before it's really ready for primetime
  - to create the report, run `snakemake -j1 --use-conda performance_benchmarks`

### Fixed

- many, many changes to resource allocation, to compensate for the fact that the original
  settings were based on random cloud pipeline allocations that did not actually inspect or
  enforce their own usage. the result is some extremely chunky rules, but much more accurate
  representations of the footprints of the rules
- alignment multiQC report more closely matches format of legacy, and also is prettier than before
- random, assorted bugfixes to various foolishness from the rapid initial implementation. note
  that SV steps are _still_ completely untested and should be considered dubious at best

## Deprecated

- Octopus. the project is orphaned, and the runs themselves are unstable and unreliable. I'm
  not fully removing it for the time being,
  but it's on notice. I'll do some testing outside of this workflow
  to see if I can find a path to even remotely trusting its output

## [0.1.0] - 2022-11-28

Integration of initial implementation branch, so that default has things of interest for casual viewing.
The initial high-burden test of the implementation is still running, so rapid and immediate changes
are anticipated.

### Added

- legacy support for fastQC, fastp.
- legacy support for bwa-mem2 for alignment.
- legacy support for markdups.
- legacy support for aligned read QC (mostly picard).
- legacy support for octopus.
- legacy support for tiddit, manta SV calling.
- legacy support for duphold.
- legacy support for merging tiddit/manta output.
- test coverage for all snakemake lambda functions (under `lib/`).
- test coverage for all added internal python scripts (under `workflow/scripts/`).

### Changed

- `bwa-mem2` is pulled from conda, which currently pulls v2.2.1. the docker image
  from the legacy workflow has pulled from an untagged feature branch. this is bad.
- markdups switched from `samtools markdup` to `gatk MarkDuplicates` (i.e. picard).
- `octopus` is orphaned, and the available versions are of questionable desirability.




### Deprecated

- `fastp` emits output fastqs with adapters trimmed, but these trimmed fastqs were not passed to `bwa-mem2` in legacy.
  this behavior should no longer be the default, but can be turned back on with the corresponding config/behaviors setting.

### Removed

- some filters on the tiddit output in particular were undocumented and are at the least temporarily removed,
  until such time as I can confirm what they were intended to do.

### Fixed

- `duphold` is actually being applied now. previously, it was only, and somewhat wonkily,
  being applied to tiddit.


[//]: # [Unreleased]

[//]: # (- Added)
[//]: # (- Changed)
[//]: # (- Deprecated)
[//]: # (- Removed)
[//]: # (- Fixed)
[//]: # (- Security)