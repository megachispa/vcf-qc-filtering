#!/bin/bash
#SBATCH --job-name=missingness_filter
#SBATCH --output=missingness_%j.out
#SBATCH --error=missingness_%j.err
#SBATCH --time=02:00:00
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G

set -euo pipefail

source /nfs/home/ebarabanova/miniconda3_new/etc/profile.d/conda.sh
conda activate vcf_clean

# Input VCF (filtered + biallelic SNPs)
VCF=/mnt/tank/scratch/ebarabanova/new_thresholds/geno8_20Filtered_biallelic.vcf.gz

OUTDIR=/mnt/tank/scratch/ebarabanova/missingness_calculations
mkdir -p "$OUTDIR"

echo "Adding missingness annotation (F_MISSING)..."

bcftools +fill-tags "$VCF" -Oz \
    -o "$OUTDIR/vcf_with_missingness.vcf.gz" \
    -- -t F_MISSING

bcftools index "$OUTDIR/vcf_with_missingness.vcf.gz"

echo "Filtering sites with missingness > 0.375 (i.e. >3/8 missing allowed)..."

bcftools view \
    -e 'F_MISSING > 0.375' \
    -Oz \
    -o "$OUTDIR/final_missingness_filtered.vcf.gz" \
    "$OUTDIR/vcf_with_missingness.vcf.gz"

bcftools index "$OUTDIR/final_missingness_filtered.vcf.gz"

echo "Done."
