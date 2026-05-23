#!/bin/bash
#SBATCH --job-name=stacked_plot.slurm
#SBATCH --output=stacked_plot_%j.out
#SBATCH --error=stacked_plot_%j.err
#SBATCH --time=00:30:00
#SBATCH --cpus-per-task=1
#SBATCH --mem=4G

# Activate conda
source /nfs/home/ebarabanova/miniconda3_new/etc/profile.d/conda.sh
conda activate vcf_clean

# Go to working directory
cd /mnt/tank/scratch/ebarabanova/roh

# Run R script
Rscript /mnt/tank/scratch/ebarabanova/vcf_filtering_qc/elds_deer_genomics/scripts/03_downstream_analysis/plot_largest_island.R
