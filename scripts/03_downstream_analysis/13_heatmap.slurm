#!/bin/bash
#SBATCH --job-name=shared_roh_heatmap
#SBATCH --output=shared_roh_heatmap_%j.out
#SBATCH --error=shared_roh_heatmap_%j.err
#SBATCH --time=01:00:00
#SBATCH --cpus-per-task=4
#SBATCH --mem=4G

# initialize conda
source /nfs/home/ebarabanova/miniconda3_new/etc/profile.d/conda.sh

# activate your environment
conda activate vcf_clean

WORKDIR=/mnt/tank/scratch/ebarabanova/roh
cd "$WORKDIR"

Rscript /mnt/tank/scratch/ebarabanova/vcf_filtering_qc/elds_deer_genomics/scripts/03_downstream_analysis/heatmap.R
