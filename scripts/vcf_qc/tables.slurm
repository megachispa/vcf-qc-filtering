#!/bin/bash
#SBATCH --job-name=qc_tables
#SBATCH --output=qc_tables_%j.out
#SBATCH --error=qc_tables_%j.err
#SBATCH --time=00:30:00
#SBATCH --cpus-per-task=1
#SBATCH --mem=4G

INDIR=/mnt/tank/scratch/ebarabanova/vcf_filtering_qc/qc_outputs
cd "$INDIR"

############################
# 1. FILTERING CORRECTNESS
############################

echo -e "Dataset\tFILTER_status\tSNP_count" > filtering_correctness_final.tsv

echo -e "Raw VCF\t.\t$(awk '$1=="snps.vcf.gz"{print $2}' qc_summary.txt)" >> filtering_correctness_final.tsv
echo -e "Site filtered\tPASS\t$(awk '$1=="snps_PASS.vcf.gz"{print $2}' qc_summary.txt)" >> filtering_correctness_final.tsv
echo -e "GQ20\tPASS\t$(awk '$1=="geno20Filtered.vcf.gz"{print $2}' qc_summary.txt)" >> filtering_correctness_final.tsv
echo -e "GQ50\tPASS\t$(awk '$1=="geno50Filtered.vcf.gz"{print $2}' qc_summary.txt)" >> filtering_correctness_final.tsv


############################
# 2. PER-SAMPLE COVERAGE (DP)
############################

echo -e "Sample\tRaw_DP\tPASS_DP\tGQ20_DP\tGQ50_DP" > per_sample_DP_final.tsv
paste \
  snps.vcf.gz.per_sample_DP.txt \
  snps_PASS.vcf.gz.per_sample_DP.txt \
  geno20Filtered.vcf.gz.per_sample_DP.txt \
  geno50Filtered.vcf.gz.per_sample_DP.txt \
| awk '{print $1"\t"$2"\t"$4"\t"$6"\t"$8}' \
>> per_sample_DP_final.tsv


############################
# 3. SNPs PER SAMPLE
############################

echo -e "Sample\tRaw_SNPs\tPASS_SNPs\tGQ20_SNPs\tGQ50_SNPs" > per_sample_SNPs_final.tsv

# extract ONLY sample + SNP count (column 3 and 4)
awk '$1=="PSC"{print $3,$4}' snps.vcf.gz.PSC.txt > raw.snp
awk '$1=="PSC"{print $3,$4}' snps_PASS.vcf.gz.PSC.txt > pass.snp
awk '$1=="PSC"{print $3,$4}' geno20Filtered.vcf.gz.PSC.txt > gq20.snp
awk '$1=="PSC"{print $3,$4}' geno50Filtered.vcf.gz.PSC.txt > gq50.snp

# paste clean files (same logic as DP)
paste raw.snp pass.snp gq20.snp gq50.snp \
| awk '{print $1"\t"$2"\t"$4"\t"$6"\t"$8}' \
>> per_sample_SNPs_final.tsv

echo "DONE"
