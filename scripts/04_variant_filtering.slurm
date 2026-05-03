#!/bin/bash

# initialize conda
source /nfs/home/ebarabanova/miniconda3_new/etc/profile.d/conda.sh

# activate your environment
conda activate vcf_clean

#1. Input
VCF=/mnt/tank/scratch/ebarabanova/gatk_output/genotyped.vcf.gz
REF=/nfs/home/ebarabanova/bwa_indexed_ref_genome/GCA_034233915.1_ASM3423391v1_genomic.fna
GATK_JAR=/mnt/tank/scratch/ebarabanova/gatk_tools/gatk-package-4.6.1.0-local.jar

#2. Normalize
echo "Normalizing VCF (splitting multiallelic sites)..."

bcftools norm -m-any $VCF -Oz -o norm.vcf.gz
bcftools index norm.vcf.gz

#3. echo "Selecting SNPs..."

java -Xmx60G -jar $GATK_JAR SelectVariants \
    -R $REF \
    -V norm.vcf.gz \
    -select-type SNP \
    -O snps.vcf.gz

#4. Apply HARD FILTERS (site-level)
echo "Applying site-level filters..."

java -Xmx60G -jar $GATK_JAR VariantFiltration \
    -R $REF \
    -V snps.vcf.gz \
    -filter "QD < 2.0" --filter-name "QD2" \
    -filter "QUAL < 30.0" --filter-name "QUAL30" \
    -filter "SOR > 3.0" --filter-name "SOR3" \
    -filter "FS > 60.0" --filter-name "FS60" \
    -filter "MQ < 40.0" --filter-name "MQ40" \
    -filter "MQRankSum < -12.5" --filter-name "MQRankSum-12.5" \
    -filter "ReadPosRankSum < -8.0" --filter-name "ReadPosRankSum-8" \
    -O snps_filtered.vcf.gz

#5. Keep only pass

echo "Selecting PASS SNPs..."

java -Xmx60G -jar $GATK_JAR SelectVariants \
    -V snps_filtered.vcf.gz \
    --exclude-filtered \
    -O snps_PASS.vcf.gz

#6. Enforce biallelic SNPs
echo "Keeping only biallelic SNPs..."

bcftools view -m2 -M2 -v snps snps_PASS.vcf.gz -Oz -o snps_PASS_biallelic.vcf.gz
bcftools index snps_PASS_biallelic.vcf.gz

bcftools stats snps_PASS_biallelic.vcf.gz > stats_pre_genoFilter.txt

#7. Genotype-level filtering

echo "Applying genotype-level filters (GQ>=20)..."

bcftools filter \
    -e 'FMT/DP<10 || FMT/GQ<20' \
    snps_PASS_biallelic.vcf.gz \
    -Oz -o snps_PASS_geno20Filtered.vcf.gz

bcftools index snps_PASS_geno20Filtered.vcf.gz

echo "Applying genotype-level filters (GQ>=50)..."

bcftools filter \
    -e 'FMT/DP<10 || FMT/GQ<50' \
    snps_PASS_biallelic.vcf.gz \
    -Oz -o snps_PASS_geno50Filtered.vcf.gz

bcftools index snps_PASS_geno50Filtered.vcf.gz

bcftools stats snps_PASS_geno20Filtered.vcf.gz > stats_GQ20.txt
bcftools stats snps_PASS_geno50Filtered.vcf.gz > stats_GQ50.txt
