# VCF QC and Filtering Pipeline

## Overview

This project performs variant calling quality control (QC) and filtering on whole-genome sequencing data. The pipeline starts from raw BAM files and produces high-confidence SNP datasets through a combination of GATK and bcftools filtering steps.

---

## Workflow

### 1. Raw variant generation
- GATK HaplotypeCaller used to generate per-sample GVCF files
- GVCFs combined using GATK CombineGVCFs
- Joint genotyping performed to produce a raw VCF dataset

### 2. Variant filtering
- Site-level hard filtering using GATK VariantFiltration
- Removal of low-quality and multiallelic sites
- Retention of PASS-only biallelic SNPs

### 3. Genotype-level filtering
- Filtering based on:
  - Depth (DP < 10 removed)
  - Genotype quality (GQ < 20 or GQ < 50 removed)
- Two filtered datasets generated:
  - GQ20 dataset (moderate stringency)
  - GQ50 dataset (high stringency)

---

## Quality control analysis

The following QC metrics were computed:

- SNP counts per sample
- Mean genotype depth (DP)
- FILTER field composition
- Depth distribution across variants

---

## Key outputs

- Raw VCF (joint genotyped)
- GQ20 filtered VCF
- GQ50 filtered VCF
- QC summary tables
- Per-sample DP estimates
- DP distribution plots


