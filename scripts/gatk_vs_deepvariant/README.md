GATK vs DeepVariant VCF Comparison Pipeline

This module contains scripts for comparative analysis of variant call sets generated using two independent variant calling pipelines:
* Genome Analysis Toolkit (GATK)
* DeepVariant
The goal of this workflow is to evaluate concordance between pipelines and quantify shared and caller-specific variants before and after filtering.

Workflow Overview

The comparison is performed using bcftools isec and includes:
1. Raw VCF intersection Baseline concordance prior to any filtering.
2. Filtered VCF intersection Datasets after site-level and genotype-level filtering, SNPs only, biallelic subsets.
3. Intersection after missingness filtering Sites with high proportions of missing genotypes (e.g., F_MISSING > 0.375) removed.
  4. Intersection of the GATK-generated VCF with adjusted filtering parameters versus DeepVariant filtered VCF
       The final comparison uses the optimized GATK dataset selected for downstream population genetic analyses.

 Metrics Computed
For each comparison stage, the scripts calculate:
* Total variant counts
* Shared variants
* Private variants
* Jaccard similarity index
* Proportions of shared/private variants
* Transition/transversion (Ts/Tv) ratios
