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

process spades_assembly {

    publishDir "${params.result}/Fasta", mode: 'copy', pattern: "*.fasta"
    publishDir "${params.result}/Assembly", mode: 'copy', pattern: "${sample_id}"
    
    input:
    tuple val(sample_id), path(reads)

    output:
    path("${sample_id}"), emit: assemblies
    tuple val("${sample_id}"), path("${sample_id}.fasta"), emit: fasta
    path("${sample_id}.fasta"), emit: mlst_fasta
    val(sample_id), emit: sample_id
    path(reads), emit: reads

    script:
    template 'spades.bash'
    
}

process unicycler_assembly {

    publishDir "${params.result}/Fasta", mode: 'copy', pattern: "*.fasta"
    publishDir "${params.result}/Assembly", mode: 'copy', pattern: "${sample_id}"
    
    input:
    tuple val(sample_id), path(reads)

    output:
    path("${sample_id}"), emit: assemblies
    tuple val("${sample_id}"), path("${sample_id}.fasta"), emit: fasta
    path("${sample_id}.fasta"), emit: mlst_fasta
    val(sample_id), emit: sample_id
    path(reads), emit: reads

    script:
    template 'unicycler.bash'
    
}

process index {

    input:
    path(reference)
    path(reads)

    output:
    path("${reference}*"), emit: index
    path(reads), emit: reads
    path(reference), emit: reference


    script:
    template 'index.bash'
}

process mapping {
    
    publishDir "${params.result}/Bams", pattern: "${sample_id}*", mode: 'copy'
    publishDir "${params.result}/BedGraph", pattern: "*txt", mode: 'copy'

    input:
    path(index)
    path(reference)
    path(reads)

    output:
    path("${sample_id}.bam"), emit: trimmed_fastqs
    path("*.txt")

    script:
    sample_id = reference.getSimpleName()
    template 'mapping.bash'

}

workflow mapping_cov {
    
    take:
    samples

    main:
    
    qc = fastqQulity(samples)

    multiqc(qc.collect())

    trimmed_reads = trimming(samples)


    if (params.assembler == 'spades') {
        assemblies = spades_assembly(trimmed_reads.trimmed_fastqs)
    }
    else if (params.assembler == 'unicycler') {
        assemblies = unicycler_assembly(trimmed_reads.trimmed_fastqs)
    }

    index = index(assemblies.mlst_fasta, assemblies.reads)
    bams = mapping(index.index, index.reference, index.reads)

}
