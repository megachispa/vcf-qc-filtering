#!/bin/bash
#SBATCH --job-name=private
#SBATCH --output=private_%j.out
#SBATCH --error=private_%j.err
#SBATCH --time=02:00:00
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G

cd /mnt/tank/scratch/ebarabanova/heterozygosity

# Activate conda environment
source /nfs/home/ebarabanova/miniconda3_new/etc/profile.d/conda.sh
conda activate vcf_clean

VCF=/mnt/tank/scratch/ebarabanova/missingness_calculations/final_missingness_filtered.vcf.gz

# STRICT PRIVATE ALLELES (singletons)
# Alleles found in only ONE individual
# Keep only sites with no missing data (all 8 individuals genotyped)
# Then identify singletons

vcftools --gzvcf $VCF \
    --max-missing 1.0 \
    --recode --stdout | \
vcftools --vcf - \
    --singletons \
    --out strict_private_alleles

# Count per individual, sort by count and save to a file
# Column 5 contains the individual ID (skip header line with tail -n +2)

tail -n +2 strict_private_alleles.singletons | awk '$3=="S"' \
| cut -f5 | sort | uniq -c | sort -rn > strict_private_counts.txt

# Get total number of private alleles
TOTAL_STRICT=$(tail -n +2 strict_private_alleles.singletons | awk '$3=="S"' | wc -l)

echo "$TOTAL_STRICT" > total_strict.txt

