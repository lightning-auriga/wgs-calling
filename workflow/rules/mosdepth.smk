rule run_mosdepth:
    """
    Use mosdepth to compute base coverage. This is extracted from archival marigold
    behaviors in https://github.com/invitae-internal/marigold-pipes/blob/main/workflow/rules/mosdepth.smk.
    That doc is a mess, but I agree with its internal settings that sacrifice granularity in the
    name of speed; that can always be adjusted later if desired.
    """
    input:
        bam="results/bqsr/{projectid}/{prefix}.bam",
        bai="results/bqsr/{projectid}/{prefix}.bai",
    output:
        assorted_files=expand(
            "results/mosdepth/{{projectid}}/{{prefix}}.{suffix}",
            suffix=[
                "mosdepth.global.dist.txt",
                "mosdepth.summary.txt",
                "mosdepth.region.dist.txt",
                "per-base.bed.gz",
                "regions.bed.gz",
                "thresholds.bed.gz",
                "per-base.bed.gz.csi",
                "regions.bed.gz.csi",
                "thresholds.bed.gz.csi",
            ],
        ),
    benchmark:
        "results/performance_benchmarks/run_mosdepth/{projectid}/{prefix}.tsv"
    params:
        outprefix="results/mosdepth/{projectid}/{prefix}",
        win_size=1000,
        mapq=0,
        T="0,10,20,30",
    conda:
        "../envs/mosdepth.yaml"
    threads: 1
    resources:
        mem_mb="4000",
        qname="small",
    shell:
        "mosdepth --threads {threads} "
        "--by {params.win_size} "
        "--fast-mode "
        "--mapq {params.mapq} "
        "-T {params.T} "
        "{params.outprefix} {input.bam}"