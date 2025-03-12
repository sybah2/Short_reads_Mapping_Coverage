#!/usr/bin/env bash

set -euo pipefail

bwa mem ${reference} ${reads[0]} ${reads[1]} > ${sample_id}.sam

samtools view -Sb ${sample_id}.sam > temp.bam

samtools sort temp.bam -o ${sample_id}.bam


samtools view -b ${sample_id}.bam | genomeCoverageBed -bga -ibam stdin > graph.txt


