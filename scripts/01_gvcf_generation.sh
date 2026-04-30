#!/bin/bash

# GVCF generation using GATK HaplotypeCaller

export PATH=/mnt/tank/scratch/ebarabanova/gatk_tools:$PATH

gatk --java-options "-Xmx4G" HaplotypeCaller \
 -R /nfs/home/ebarabanova/bwa_indexed_ref_genome/GCA_034233915.1_ASM3423391v1_genomic.fna \
 -I /mnt/tank/scratch/ebarabanova/marked_duplicates/RE114379.marked_duplicates.bam \
 -O /mnt/tank/scratch/ebarabanova/gatk_output/RE114379.g.vcf \
 -ERC GVCF
