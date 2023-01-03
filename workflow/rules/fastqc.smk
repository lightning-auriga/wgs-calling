rule run_fastqc_pretrimming:
    """
    Run fastQC on a paired end library, before trimming
    """
    input:
        r1="results/fastqs/{projectid}/{prefix}_R1_{suffix}.fastq.gz",
        r2="results/fastqs/{projectid}/{prefix}_R2_{suffix}.fastq.gz",
    output:
        r1_zip="results/fastqc/{projectid}/{prefix}_R1_{suffix}_fastqc.zip",
        r2_zip="results/fastqc/{projectid}/{prefix}_R2_{suffix}_fastqc.zip",
        r1_html="results/fastqc/{projectid}/{prefix}_R1_{suffix}_fastqc.html",
        r2_html="results/fastqc/{projectid}/{prefix}_R2_{suffix}_fastqc.html",
    benchmark:
        "results/performance_benchmarks/fastqc/{projectid}/{prefix}_{suffix}_fastqc.tsv"
    params:
        outdir="results/fastqc/{projectid}",
    conda:
        "../envs/fastqc.yaml"
    threads: 4
    resources:
        mem_mb="8000",
        qname="small",
    shell:
        "mkdir -p {params.outdir} && fastqc --threads {threads} {input.r1} {input.r2} --outdir {params.outdir}"


rule run_fastqc_posttrimming:
    """
    Run fastQC on a paired end library, after trimming
    """
    input:
        r1="results/fastp/{projectid}/{sampleid}_{lane}_R1_fastp.fastq.gz",
        r2="results/fastp/{projectid}/{sampleid}_{lane}_R2_fastp.fastq.gz",
    output:
        r1_zip="results/fastqc_posttrimming/{projectid}/{sampleid}_{lane}_R1_fastp_fastqc.zip",
        r2_zip="results/fastqc_posttrimming/{projectid}/{sampleid}_{lane}_R2_fastp_fastqc.zip",
        r1_html="results/fastqc_posttrimming/{projectid}/{sampleid}_{lane}_R1_fastp_fastqc.html",
        r2_html="results/fastqc_posttrimming/{projectid}/{sampleid}_{lane}_R2_fastp_fastqc.html",
    benchmark:
        "results/performance_benchmarks/fastqc_posttrimming/{projectid}/{sampleid}_{lane}_fastp_fastqc.tsv"
    params:
        outdir="results/fastqc_posttrimming/{projectid}",
    conda:
        "../envs/fastqc.yaml"
    threads: 4
    resources:
        mem_mb="8000",
        qname="small",
    shell:
        "mkdir -p {params.outdir} && fastqc --threads {threads} {input.r1} {input.r2} --outdir {params.outdir}"


use rule run_fastqc_pretrimming as run_fastqc_pretrimming_combined with:
    input:
        r1="results/fastqs_combined/pretrimming/{projectid}/{sampleid}_R1.fastq.gz",
        r2="results/fastqs_combined/pretrimming/{projectid}/{sampleid}_R2.fastq.gz",
    output:
        r1_zip="results/fastqc_combined/{projectid}/{sampleid}_R1_fastqc.zip",
        r2_zip="results/fastqc_combined/{projectid}/{sampleid}_R2_fastqc.zip",
        r1_html="results/fastqc_combined/{projectid}/{sampleid}_R1_fastqc.html",
        r2_html="results/fastqc_combined/{projectid}/{sampleid}_R2_fastqc.html",
    benchmark:
        "results/performance_benchmarks/fastqc_combined/{projectid}/{sampleid}_fastqc.tsv"
    params:
        outdir="results/fastqc_combined/{projectid}",


use rule run_fastqc_posttrimming as run_fastqc_posttrimming_combined with:
    input:
        r1="results/fastqs_combined/posttrimming/{projectid}/{sampleid}_R1.fastq.gz",
        r2="results/fastqs_combined/posttrimming/{projectid}/{sampleid}_R2.fastq.gz",
    output:
        r1_zip="results/fastqc_posttrimming_combined/{projectid}/{sampleid}_R1_fastqc.zip",
        r2_zip="results/fastqc_posttrimming_combined/{projectid}/{sampleid}_R2_fastqc.zip",
        r1_html="results/fastqc_posttrimming_combined/{projectid}/{sampleid}_R1_fastqc.html",
        r2_html="results/fastqc_posttrimming_combined/{projectid}/{sampleid}_R2_fastqc.html",
    benchmark:
        "results/performance_benchmarks/fastqc_posttrimming_combined/{projectid}/{sampleid}_fastqc.tsv"
    params:
        outdir="results/fastqc_posttrimming_combined/{projectid}",