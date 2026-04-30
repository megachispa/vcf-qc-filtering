#!/bin/bash

export PATH=/mnt/tank/scratch/ebarabanova/gatk_tools:$PATH

gatk CombineGVCFs \
 -R /nfs/home/ebarabanova/bwa_indexed_ref_genome/GCA_034233915.1_ASM3423391v1_genomic.fna \
 -V /mnt/tank/scratch/ebarabanova/gatk_output/RE113838.g.vcf \
 -V /mnt/tank/scratch/ebarabanova/gatk_output/RE114379.g.vcf \
 -V /mnt/tank/scratch/ebarabanova/gatk_output/RE114623.g.vcf \
 -V /mnt/tank/scratch/ebarabanova/gatk_output/RE115125.g.vcf \
 -V /mnt/tank/scratch/ebarabanova/gatk_output/RE115304.g.vcf \
 -V /mnt/tank/scratch/ebarabanova/gatk_output/RE115445.g.vcf \
 -V /mnt/tank/scratch/ebarabanova/gatk_output/RE115604.g.vcf \
 -V /mnt/tank/scratch/ebarabanova/gatk_output/RE116077.g.vcf \
 -O /mnt/tank/scratch/ebarabanova/gatk_output/combined.g.vcf

# compress + index
bgzip /mnt/tank/scratch/ebarabanova/gatk_output/combined.g.vcf
tabix -p vcf /mnt/tank/scratch/ebarabanova/gatk_output/combined.g.vcf.gz
