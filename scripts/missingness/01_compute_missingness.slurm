#!/bin/bash
#SBATCH --job-name=intersect
#SBATCH --output=intersect_%j.out
#SBATCH --error=intersect_%j.err
#SBATCH --time=04:00:00
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G

set -euo pipefail  

source /nfs/home/ebarabanova/miniconda3_new/etc/profile.d/conda.sh
conda activate vcf_clean

OUTDIR=/mnt/tank/scratch/ebarabanova/missingness_calculations
VCF=/mnt/tank/scratch/ebarabanova/new_thresholds/geno8_20Filtered_biallelic.vcf.gz

mkdir -p "$OUTDIR"

#Adding missingness rates to the vcf file

echo "Adding call rate annotation..."

bcftools +fill-tags $VCF -Oz \
    -o $OUTDIR/snps_with_callrate.vcf.gz \
    -- -t F_MISSING

bcftools index $OUTDIR/snps_with_callrate.vcf.gz

#6. Extract missingness values and write them into a file

bcftools query -f '%F_MISSING\n' $OUTDIR/snps_with_callrate.vcf.gz | \
awk '
{
    total++;

    if ($1 >= 0.8) cat1++;
    else if ($1 >= 0.5) cat2++;
    else if ($1 >= 0.2) cat3++;
    else cat4++;
}
END {
    print "Missingness category\tNumber of SNPs";
    print ">=80%\t", cat1+0;
    print "50–80%\t", cat2+0;
    print "20–50%\t", cat3+0;
    print "0–20%\t", cat4+0;
    print "Total\t", total;
}' > $OUTDIR/missingness_summary.txt
