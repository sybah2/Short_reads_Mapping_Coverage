#!/usr/bin/env bash

set -euo pipefail

mkdir "${sample_id}_fastqc_out"
fastqc -o "${sample_id}_fastqc_out" ${read1} ${read2} --extract