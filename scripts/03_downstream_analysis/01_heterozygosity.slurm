#!/bin/bash
#SBATCH --job-name=heterozygosity
#SBATCH --output=heterozygosity_%j.out
#SBATCH --error=heterozygosity_%j.err
#SBATCH --time=01:00:00
#SBATCH --cpus-per-task=2
#SBATCH --mem=8G

set -euo pipefail

source /nfs/home/ebarabanova/miniconda3_new/etc/profile.d/conda.sh
conda activate vcf_clean

VCF=/mnt/tank/scratch/ebarabanova/missingness_calculations/final_missingness_filtered.vcf.gz

OUTDIR=/mnt/tank/scratch/ebarabanova/heterozygosity
mkdir -p "$OUTDIR"

echo "Running vcftools heterozygosity calculation..."

vcftools --gzvcf "$VCF" --het --out "$OUTDIR/heterozygosity"

echo "Done."
echo "Output:"
echo "$OUTDIR/heterozygosity.het"
