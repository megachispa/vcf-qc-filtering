#!/bin/bash
#SBATCH --job-name=genotype_gvcf
#SBATCH --output=genotype_gvcf_%j.out
#SBATCH --error=genotype_gvcf_%j.err
#SBATCH --time=98:00:00
#SBATCH --cpus-per-task=8
#SBATCH --mem=64G

set -e

echo "Starting GenotypeGVCFs..."

# ---- Tools ----
GATK_JAR=/mnt/tank/scratch/ebarabanova/gatk_tools/gatk-package-4.6.1.0-local.jar

# ---- Reference ----
REF=/nfs/home/ebarabanova/bwa_indexed_ref_genome/GCA_034233915.1_ASM3423391v1_genomic.fna

# ---- Working directory ----
WORKDIR=/mnt/tank/scratch/ebarabanova/gatk_output
cd $WORKDIR

# ---- Input / Output ----
INPUT=combined.g.vcf.gz
OUTPUT=genotyped.vcf.gz

# Remove old output if exists
rm -f $OUTPUT $OUTPUT.tbi

# ---- Run GenotypeGVCFs ----
java -Xmx60G -jar $GATK_JAR GenotypeGVCFs \
    -R $REF \
    -V $INPUT \
    -O $OUTPUT

echo "Genotyping finished successfully."
