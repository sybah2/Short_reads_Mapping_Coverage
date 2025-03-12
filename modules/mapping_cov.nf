#!/usr/bin/env nextflow
nextflow.enable.dsl=2


process fastqQulity {

    //publishDir "${params.result}/QC", mode: 'copy'   
 
    input:
    tuple val(sample_id), file(read1), file(read2)

    output:
    path("${sample_id}_fastqc_out")

    script:
    template 'fastqc.bash'
}

process multiqc {

    publishDir "${params.result}/multiqc", mode: 'copy'
    input:
    path(qc_files)

    output:
    path("*multiqc*")

    script:
    """
    multiqc ${qc_files}
    """

}

process quast_multiqc {

    publishDir "${params.result}/quast_multiqc", mode: 'copy'
    input:
    path(qc_files)

    output:
    path("*multiqc*")

    script:
    """
    multiqc ${qc_files}
    """

}

process trimming {
    
    publishDir "${params.result}/Trimmed_read", mode: 'copy' 
    input:
    tuple val(sample_id), file(read1), file(read2)

    output:
    tuple val("${sample_id}"), path("${sample_id}_paired*.fq.gz"), emit: trimmed_fastqs


    script:
    template 'trimming.bash'

}

process index {

    input:
    path reference

    output:
    path("${reference}*"), emit: index


    script:
    template 'index.bash'
}

process mapping {
    
    publishDir "${params.result}/bams", pattern: "${sample_id}*", mode: 'copy' 
    input:
    path(index)
    path reference
    tuple val(sample_id), path(reads)

    output:
    path("${sample_id}.bam"), emit: trimmed_fastqs

    script:
    template 'mapping.bash'

}

workflow mapping_cov {
    
    take:
    samples

    main:
    
    qc = fastqQulity(samples)

    multiqc(qc.collect())

    trimmed_reads = trimming(samples)

    index = index(params.reference)

    bams = mapping(index.index, params.reference, trimmed_reads.trimmed_fastqs)

}
