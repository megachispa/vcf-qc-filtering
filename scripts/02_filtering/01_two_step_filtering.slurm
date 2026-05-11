#!/bin/bash
#SBATCH --job-name=variant_filtering
#SBATCH --output=filtering_%j.out
#SBATCH --error=filtering_%j.err
#SBATCH --time=12:00:00
#SBATCH --cpus-per-task=8
#SBATCH --mem=64G


# initialize conda
source /nfs/home/ebarabanova/miniconda3_new/etc/profile.d/conda.sh

# activate your environment
conda activate vcf_clean

#1. Input
VCF=/mnt/tank/scratch/ebarabanova/gatk_output/genotyped.vcf.gz
REF=/nfs/home/ebarabanova/bwa_indexed_ref_genome/GCA_034233915.1_ASM3423391v1_genomic.fna
GATK_JAR=/mnt/tank/scratch/ebarabanova/gatk_tools/gatk-package-4.6.1.0-local.jar

#2.Output
OUTDIR=/mnt/tank/scratch/ebarabanova/vcf_filtering_qc/filtered_vcfs
mkdir -p $OUTDIR

#3. Selecting SNPs
echo "Selecting SNPs..."

java -Xmx60G -jar $GATK_JAR SelectVariants \
    -R $REF \
    -V $VCF \
    -select-type SNP \
    -O $OUTDIR/snps.vcf.gz

bcftools index $OUTDIR/snps.vcf.gz

#4. Apply HARD FILTERS (site-level)
echo "Applying site-level filters..."

java -Xmx60G -jar $GATK_JAR VariantFiltration \
    -R $REF \
    -V $OUTDIR/snps.vcf.gz \
    -filter "QD < 2.0" --filter-name "QD2" \
    -filter "QUAL < 30.0" --filter-name "QUAL30" \
    -filter "SOR > 3.0" --filter-name "SOR3" \
    -filter "FS > 60.0" --filter-name "FS60" \
    -filter "MQ < 40.0" --filter-name "MQ40" \
    -filter "MQRankSum < -12.5" --filter-name "MQRankSum-12.5" \
    -filter "ReadPosRankSum < -8.0" --filter-name "ReadPosRankSum-8" \
    -O $OUTDIR/snps_filtered.vcf.gz

bcftools index $OUTDIR/snps_filtered.vcf.gz

#5. Keep only pass

echo "Selecting PASS SNPs..."

java -Xmx60G -jar $GATK_JAR SelectVariants \
    -V $OUTDIR/snps_filtered.vcf.gz \
    --exclude-filtered \
    -O $OUTDIR/snps_PASS.vcf.gz

bcftools index $OUTDIR/snps_PASS.vcf.gz

#6. Stats pre-genotype-level filtering

bcftools stats $OUTDIR/snps_PASS.vcf.gz > $OUTDIR/stats_pre_genoFilter.txt

#7. Genotype-level filtering

echo "Applying genotype-level filters (GQ>=20)..."

bcftools filter \
    -e 'FMT/DP<10 || FMT/GQ<20' \
    $OUTDIR/snps_PASS.vcf.gz \
    -Oz -o $OUTDIR/geno20Filtered.vcf.gz

bcftools index $OUTDIR/geno20Filtered.vcf.gz

echo "Applying genotype-level filters (GQ>=50)..."

bcftools filter \
    -e 'FMT/DP<10 || FMT/GQ<50' \
    $OUTDIR/snps_PASS.vcf.gz \
    -Oz -o $OUTDIR/geno50Filtered.vcf.gz

bcftools index $OUTDIR/geno50Filtered.vcf.gz

bcftools stats $OUTDIR/geno20Filtered.vcf.gz > $OUTDIR/stats_GQ20.txt
bcftools stats $OUTDIR/geno50Filtered.vcf.gz > $OUTDIR/stats_GQ50.txt


#8. Enforce biallelic SNPs
echo "Keeping only biallelic SNPs..."


bcftools view -m2 -M2 -v snps \
    $OUTDIR/geno20Filtered.vcf.gz \
    -Oz -o $OUTDIR/geno20Filtered_biallelic.vcf.gz

bcftools index $OUTDIR/geno20Filtered_biallelic.vcf.gz


bcftools view -m2 -M2 -v snps \
    $OUTDIR/geno50Filtered.vcf.gz \
    -Oz -o $OUTDIR/geno50Filtered_biallelic.vcf.gz

bcftools index $OUTDIR/geno50Filtered_biallelic.vcf.gz


bcftools stats $OUTDIR/geno20Filtered_biallelic.vcf.gz > $OUTDIR/stats_GQ20_biallelic.txt
bcftools stats $OUTDIR/geno50Filtered_biallelic.vcf.gz > $OUTDIR/stats_GQ50_biallelic.txt
