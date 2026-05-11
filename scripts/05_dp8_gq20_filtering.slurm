#!/bin/bash
#SBATCH --job-name=gatk_genotype_filter
#SBATCH --output=gatk_genotype_filter_%j.out
#SBATCH --error=gatk_genotype_filter_%j.err
#SBATCH --time=12:00:00
#SBATCH --cpus-per-task=8
#SBATCH --mem=64G

set -euo pipefail

# Load conda
source /nfs/home/ebarabanova/miniconda3_new/etc/profile.d/conda.sh
conda activate vcf_clean

############################################
# Input VCF (site-level filtered, SNPs)
############################################

VCF="/mnt/tank/scratch/ebarabanova/vcf_filtering_qc/filtered_vcfs/snps_PASS.vcf.gz"

############################################
# Output directory
############################################

OUTDIR="/mnt/tank/scratch/ebarabanova/new_thresholds"
mkdir -p "$OUTDIR"

############################################
# Genotype-level filtering
# DP ≥ 8 AND GQ ≥ 20
############################################

echo "Applying genotype-level filters (DP ≥ 8, GQ ≥ 20)..."

bcftools filter \
    -e 'FMT/DP < 8 || FMT/GQ < 20' \
    -Oz \
    -o "$OUTDIR/geno8_20_filtered.vcf.gz" \
    "$VCF"

bcftools index "$OUTDIR/geno8_20_filtered.vcf.gz"

############################################
# Variant statistics
############################################

bcftools stats \
    "$OUTDIR/geno8_20_filtered.vcf.gz" \
    > "$OUTDIR/stats_geno8_20.txt"

############################################
# Keep only biallelic SNPs
############################################

echo "Keeping only biallelic SNPs..."

bcftools view \
    -m2 -M2 -v snps \
    "$OUTDIR/geno8_20_filtered.vcf.gz" \
    -Oz \
    -o "$OUTDIR/geno8_20_filtered_biallelic.vcf.gz"

bcftools index "$OUTDIR/geno8_20_filtered_biallelic.vcf.gz"

############################################
# Final statistics
############################################

bcftools stats \
    "$OUTDIR/geno8_20_filtered_biallelic.vcf.gz" \
    > "$OUTDIR/stats_geno8_20_biallelic.txt"

echo "Filtering complete."
