# Snakemake workflow: WGS Pipeline

This workflow is intended to be the R&D space for the PMGRC WGS analysis pipeline. It will first support existing functionality from variously [marigold](https://github.com/invitae-internal/marigold-pipes), [nextflow-pipelines](https://github.com/invitae-internal/nextflow-pipelines), and the descendants of `nextflow-pipelines` after splitting out into individual repositories. When that back compatibility is complete, additional features will be sandboxed and tested here.

New global targets should be added in `workflow/Snakefile`. Content in `workflow/Snakefile` and the snakefiles in `workflow/rules` should be specifically _rules_; python infrastructure should be composed as subroutines under `lib/` and constructed in such a manner as to be testable with [pytest](https://docs.pytest.org/en/7.2.x/). Rules can call embedded scripts (in python or R/Rmd) from `workflow/scripts`; again, these should be constructed to be testable with pytest or [testthat](https://testthat.r-lib.org/).

## Authors

* Lightning Auriga (@lightning.auriga)

## Usage

### Step 1: Obtain a copy of this workflow

1. Clone this repository to your local system, into the place where you want to perform the data analysis.
```
    git clone git@gitlab.com:lightning.auriga1/wgs-pipeline.git
```

Note that this requires local git ssh key configuration; see [here](https://docs.gitlab.com/ee/user/ssh.html) for instructions as required.

### Step 2: Configure workflow

Configure the workflow according to your needs via editing the files in the `config/` folder. Adjust `config.yaml` to configure the workflow execution, and `manifest.tsv` to specify your sample setup.

The following settings are recognized in `config/config.yaml`. Note that each reference data option below exists under an arbitrary tag denoting desired reference genome build. This tag is completely arbitrary and will be used to recognize the requested build for the current pipeline run.

- `manifest`: relative path to run manifest
- `multiqc-config`: relative path to configuration settings for post-alignment multiQC report
- `genome-build`: requested genome reference build to use for this analysis run. this should match the tags used in the reference data blocks below.
- `references`: human genome reference data applicable to multiple tools
  - `fasta`: human sequence fasta file
  - note that the other bwa-style index files attached to this fasta used to be imported by the nextflow workflow. however, presumably by accident,
    these annotation files were getting pulled from various different directories in a way that suggested that they might be delinked from their
	source fasta. in reality, the source reference fastas were probably the same; but to avoid any difficulties downstream, now only the fasta
	itself is pulled in from remote, and the index files are regenerated. this also substantially cleans up the configuration.
- `dnascope`: reference data files specific to [Sentieon DNAscope](https://support.sentieon.com/manual/DNAscope_usage/dnascope/)
  - `model`: DNAscope model file
  - `dbsnp-vcf-gz`: dbSNP backend vcf.gz file
  - `dbsnp-vcf-gz-tbi`: tbi format index file for above vcf
- `verifybamid2`: reference data files specific to [VerifyBamID2](https://github.com/Griffan/VerifyBamID)
  - `db-V`: filename for assorted Verify annotation files
  - `db-UD`: filename for assorted Verify annotation files
  - `db-mu`: filename for assorted Verify annotation files
  - `db-bed`: filename for assorted Verify annotation files
- `octopus`: reference data files specific to [octopus](https://github.com/luntergroup/octopus)
  - `forest-model`: forest model annotation file for `--forest-model`
  - `error-model`: error model annotation file for `--sequence-error-model`
  - `skip-regions`: region annotation for `--skip-regions-file`


The following columns are expected in the run manifest, by default at `config/manifest.tsv`:
- thing
- otherthing

### Step 3: Install Snakemake

Install Snakemake using [conda](https://conda.io/projects/conda/en/latest/user-guide/install/index.html):

    conda create -c bioconda -c conda-forge -n snakemake snakemake

For installation details, see the [instructions in the Snakemake documentation](https://snakemake.readthedocs.io/en/stable/getting_started/installation.html).

### Step 4: Execute workflow

Activate the conda environment:

    conda activate snakemake

Test your configuration by performing a dry-run via

    snakemake --use-conda -n

Execute the workflow locally via

    snakemake --use-conda --cores $N

using `$N` cores or run it in a cluster environment via

    snakemake --use-conda --cluster qsub --jobs 100

See the [Snakemake documentation](https://snakemake.readthedocs.io/en/stable/executable.html) for further details.

### Step 5: Investigate results

TBD; the only current targeted output is multiqc output in `results/multiqc`.

### Step 6: Commit changes

Whenever you change something, don't forget to commit the changes back to your github copy of the repository:

    git commit -a
    git push

### Step 7: Obtain updates from upstream

Whenever you want to synchronize your workflow copy with new developments from upstream, do the following.

1. Once, register the upstream repository in your local copy: `git remote add -f upstream git@gitlab.com:lightning.auriga1/wgs-pipeline.git` or `upstream https://gitlab.com/lightning.auriga1/wgs-pipeline.git` if you do not have setup ssh keys.
2. Update the upstream version: `git fetch upstream`.
3. Create a diff with the current version: `git diff HEAD upstream/master workflow > upstream-changes.diff`.
4. Investigate the changes: `vim upstream-changes.diff`.
5. Apply the modified diff via: `git apply upstream-changes.diff`.
6. Carefully check whether you need to update the config files: `git diff HEAD upstream/master config`. If so, do it manually, and only where necessary, since you would otherwise likely overwrite your settings and samples.


### Step 8: Contribute back

In case you have also changed or added steps, please consider contributing them back to the original repository. This project follows git flow; feature branches off of dev are welcome.

1. [Clone](https://docs.gitlab.com/ee/gitlab-basics/start-using-git.html) the fork to your local system, to a different place than where you ran your analysis.
2. Check out a branch off of dev:
```
git fetch
git checkout dev
git checkout -b your-new-branch
```
3. Make whatever changes best please you to your feature branch.
4. Commit and push your changes to your branch.
5. Create a [merge request](https://docs.gitlab.com/ee/user/project/merge_requests/) against dev.

## Testing

Testing infrastructure for embedded python and R scripts is installed under `lib/` and `workflow/scripts/`. Additional testing
coverage for the Snakemake infrastructure itself should be added once the workflow is more mature ([see here](https://github.com/lightning.auriga/snakemake-unit-tests)).
