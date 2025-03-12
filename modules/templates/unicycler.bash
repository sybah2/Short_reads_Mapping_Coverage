#!/usr/bin/env bash

set -euo pipefail

unicycler --min_fasta_length 500 -1 ${reads[0]}  -2 ${reads[1]} -o ${sample_id}


#cp ${sample_id}/assembly.fasta ${sample_id}.fasta

awk -v f="$sample_id" '/^>/{print ">"f"." ++i; next}{print}' < ${sample_id}/assembly.fasta > ${sample_id}.fasta