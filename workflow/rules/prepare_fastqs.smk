rule sort_input_bam:
    """
    For input files provided as pre-aligned bams: the expectation is that these
    bams will be aligned to the wrong genome, and need to be converted into fastqs
    in preparation for re-alignment. As a preliminary requirement, sort the bam.
    """
    input:
        lambda wildcards: tc.locate_input_bam(wildcards, manifest),
    output:
        temp("results/input_bams/{projectid}/{subjectid}.sorted.bam"),
    params:
        sort_m=int(config_resources["samtools"]["memory"])
        / (2 * int(config_resources["samtools"]["threads"])),
    conda:
        "../envs/samtools.yaml" if not use_containers else None
    container:
        "{}/samtools.sif".format(apptainer_images) if use_containers else None
    threads: config_resources["samtools"]["threads"]
    resources:
        mem_mb=config_resources["samtools"]["memory"],
        qname=rc.select_queue(config_resources["samtools"]["queue"], config_resources["queues"]),
    shell:
        "samtools sort -@ {threads} -m {params.sort_m} -n -o {output} {input}"


checkpoint input_bam_sample_lanes:
    """
    For input files provided as pre-aligned bams: the expectation is that these
    bams will be aligned to the wrong genome, and need to be converted into fastqs
    in preparation for re-alignment. To determine the expected files after splitting
    by lane, sniff the bam for read names and determine which lanes are reportedly present.
    """
    input:
        "results/input_bams/{projectid}/{sampleid}.sorted.bam",
    output:
        temp("results/fastqs_from_bam/{projectid}/{sampleid}_expected-lanes.tsv"),
    benchmark:
        "results/performance_benchmarks/input_bam_sample_lanes/{projectid}/{sampleid}.tsv"
    conda:
        "../envs/samtools.yaml" if not use_containers else None
    container:
        "{}/samtools.sif".format(apptainer_images) if use_containers else None
    threads: 1
    resources:
        mem_mb=1000,
        qname=rc.select_queue(config_resources["samtools"]["queue"], config_resources["queues"]),
    shell:
        'samtools view -@ 1 {input} | cut -f 4 -d ":" | head -n 100000 | sort | uniq > {output}'


rule input_bam_to_split_fastq:
    """
    For input files provided as pre-aligned bams: the expectation is that these
    bams will be aligned to the wrong genome, and need to be converted into fastqs
    in preparation for re-alignment. After sorting the bam, convert it to fastq,
    split by lane, bgzip compressed.
    """
    input:
        "results/input_bams/{projectid}/{sampleid}.sorted.bam",
    output:
        "results/fastqs_from_bam/{projectid}/{sampleid}_L00{lane}_{readgroup}_001.fastq.gz",
    benchmark:
        "results/performance_benchmarks/input_bam_to_split_fastq/{projectid}/{sampleid}_L00{lane}_{readgroup}.tsv"
    params:
        off_target_read_flag=lambda wildcards: 3 - int(wildcards.readgroup.strip("R")),
    conda:
        "../envs/samtools.yaml" if not use_containers else None
    container:
        "{}/samtools.sif".format(apptainer_images) if use_containers else None
    threads: config_resources["samtools"]["threads"]
    resources:
        mem_mb=config_resources["samtools"]["memory"],
        qname=rc.select_queue(config_resources["samtools"]["queue"], config_resources["queues"]),
    shell:
        "samtools fastq -@ {threads} -s /dev/null -{params.off_target_read_flag} /dev/null -0 /dev/null -n {input} | "
        "awk 'BEGIN {{FS = \":\"}} {{lane = $4 ; print ; for (i = 1 ; i <= 3 ; i++) {{getline ; print}}}}' | "
        "bgzip -c > {output}"


checkpoint input_fastq_sample_lanes:
    """
    For input files provided as combined fastqs: the expectation is that these
    fastqs will need to be split into per-lane fastqs for both improved performance
    and finer-grained QC. To determine the expected files after splitting
    by lane, sniff the fastq for read names and determine which lanes are reportedly present.
    """
    input:
        lambda wildcards: manifest.query(
            'projectid == "{}" and sampleid == "{}"'.format(
                wildcards.projectid, wildcards.sampleid
            )
        )[wildcards.readgroup.lower()].to_list()[0],
    output:
        temp("results/fastqs_from_fastq/{projectid}/{sampleid}_{readgroup}_expected-lanes.tsv"),
    benchmark:
        "results/performance_benchmarks/input_fastq_sample_lanes/{projectid}/{sampleid}_{readgroup}.tsv"
    threads: 1
    resources:
        mem_mb=1000,
        qname=rc.select_queue("small", config_resources["queues"]),
    shell:
        "gunzip -c {input} | awk 'NF > 1 {{print $1}}' | cut -f 4 -d ':' | sort | uniq > {output}"


rule input_fastq_to_split_fastq:
    """
    For input files provided as pre-aligned bams: the expectation is that these
    bams will be aligned to the wrong genome, and need to be converted into fastqs
    in preparation for re-alignment. After sorting the bam, convert it to fastq,
    split by lane, bgzip compressed.
    """
    input:
        lambda wildcards: manifest.query(
            'projectid == "{}" and sampleid == "{}"'.format(
                wildcards.projectid, wildcards.sampleid
            )
        )[wildcards.readgroup.lower()].to_list()[0],
    output:
        "results/fastqs_from_fastq/{projectid}/{sampleid}_L00{lane}_{readgroup}_001.fastq.gz",
    benchmark:
        "results/performance_benchmarks/input_fastq_to_split_fastq/{projectid}/{sampleid}_L00{lane}_{readgroup}.tsv"
    conda:
        "../envs/bcftools.yaml" if not use_containers else None
    container:
        "{}/bcftools.sif".format(apptainer_images) if use_containers else None
    threads: 1
    resources:
        mem_mb=1000,
        qname=rc.select_queue("small", config_resources["queues"]),
    shell:
        "gunzip -c {input} | "
        "awk 'BEGIN {{FS = \":\"}} {{lane = $4 ; print ; for (i = 1 ; i <= 3 ; i++) {{getline ; print}}}}' | "
        "bgzip -c > {output}"
