#!/usr/bin/env bash

set -euo pipefail

trimmomatic PE ${read1} ${read2} ${sample_id}_paired_1.fq.gz  ${sample_id}_unpaired_1.fq.gz ${sample_id}_paired_2.fq.gz ${sample_id}_unpaired_2.fq.gz \
ILLUMINACLIP:$projectDir/data/adapters/All_adapter-PE.fa:2:30:10 LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:20