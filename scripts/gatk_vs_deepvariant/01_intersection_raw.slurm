#!/bin/bash
#SBATCH --job-name=comparison
#SBATCH --output=comparison_%j.out
#SBATCH --error=comparison_%j.err
#SBATCH --time=04:00:00
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G

set -euo pipefail  # safer bash

source /nfs/home/ebarabanova/miniconda3_new/etc/profile.d/conda.sh
conda activate vcf_clean

cp /mnt/tank/scratch/tsizova/vcf/raw/unfiltered_cohort.vcf.gz .

bcftools index -t unfiltered_cohort.vcf.gz

# input files
A=/mnt/tank/scratch/ebarabanova/gatk_output/genotyped.vcf.gz
B=unfiltered_cohort.vcf.gz

OUTDIR=isec_output

# clean previous run (optional but recommended)
rm -rf $OUTDIR
mkdir -p $OUTDIR

echo "Running bcftools isec..."
bcftools isec -p $OUTDIR $A $B

# isec outputs
PRIVATE_A=$OUTDIR/0000.vcf
PRIVATE_B=$OUTDIR/0001.vcf
SHARED=$OUTDIR/0002.vcf

echo "Computing statistics..."

# compute counts
count_A=$(bcftools view -H $A | wc -l)
count_B=$(bcftools view -H $B | wc -l)
count_shared=$(bcftools view -H $SHARED | wc -l)
count_private_A=$(bcftools view -H $PRIVATE_A | wc -l)
count_private_B=$(bcftools view -H $PRIVATE_B | wc -l)

jaccard=$(echo "scale=5; $count_shared / ($count_A + $count_B - $count_shared)" | bc)

private_prop_A=$(echo "scale=5; $count_private_A / $count_A" | bc)
private_prop_B=$(echo "scale=5; $count_private_B / $count_B" | bc)

shared_prop_A=$(echo "scale=5; $count_shared / $count_A" | bc)
shared_prop_B=$(echo "scale=5; $count_shared / $count_B" | bc)

# Ts/Tv ratios
tstv_A=$(bcftools stats $A | grep ^TSTV | awk '{print $5}')
tstv_B=$(bcftools stats $B | grep ^TSTV | awk '{print $5}')
tstv_shared=$(bcftools stats $SHARED | grep ^TSTV | awk '{print $5}')

# output report
REPORT=stats_report.txt

{
echo "VCF comparison report"
echo "====================="
echo "Run date: $(date)"
echo ""
echo "Total variants:"
echo "My dataset (GATK): $count_A"
echo "Classmate dataset (DeepVariant): $count_B"
echo ""
echo "Intersection:"
echo "Shared variants: $count_shared"
echo "Jaccard similarity: $jaccard"
echo ""
echo "Private variants:"
echo "Private to my dataset: $count_private_A"
echo "Private to classmate: $count_private_B"
echo ""
echo "Proportions:"
echo "Private proportion (my): $private_prop_A"
echo "Private proportion (classmate): $private_prop_B"
echo "Shared proportion (my): $shared_prop_A"
echo "Shared proportion (classmate): $shared_prop_B"
echo ""
echo "Ts/Tv ratios:"
echo "My dataset (GATK): $tstv_A"
echo "Classmate dataset (DeepVariant): $tstv_B"
echo "Shared variants: $tstv_shared"
} > $REPORT

echo "Done. Report saved to $REPORT"
