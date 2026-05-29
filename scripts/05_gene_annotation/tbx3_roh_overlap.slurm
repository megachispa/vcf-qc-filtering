#!/bin/bash
#SBATCH --job-name=TBX3_ROH_overlap
#SBATCH --output=TBX3_ROH_overlap_%j.out
#SBATCH --error=TBX3_ROH_overlap_%j.err
#SBATCH --time=01:00:00
#SBATCH --cpus-per-task=2
#SBATCH --mem=4G

set -euo pipefail

# initialize conda
source /nfs/home/ebarabanova/miniconda3_new/etc/profile.d/conda.sh

# activate your environment
conda activate vcf_clean

WORKDIR=/mnt/tank/scratch/ebarabanova/var_in_genes
cd "$WORKDIR" || exit 1


echo "Step 1: create TBX3 BED file (variant position)"

printf "JACCHN010000208.1\t37869792\t37869793\tTBX3\n" > tbx3.bed


echo "Step 2: intersect TBX3 with ROH segments"

bedtools intersect \
    -a tbx3.bed \
    -b /mnt/tank/scratch/ebarabanova/roh/roh_gt1Mb_sorted.bed \
    -wa -wb > tbx3_roh_hits.tsv



