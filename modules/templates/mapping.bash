#!/usr/bin/env bash

set -euo pipefail

bwa mem ${reference} ${read1} ${read2} > ${sample_id}.sam

samtools view -Sb ${sample_id}.sam > temp.bam

samtools sort temp.bam -o ${sample_id}.bam


samtools view -b ${sample_id}.bam | genomeCoverageBed -d -ibam stdin > ${sample_id}.txt


