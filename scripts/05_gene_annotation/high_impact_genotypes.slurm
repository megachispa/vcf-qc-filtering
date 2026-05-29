#!/bin/bash
#SBATCH --job-name=highimpact_table
#SBATCH --output=highimpact_table_%j.out
#SBATCH --error=highimpact_table_%j.err
#SBATCH --time=01:00:00
#SBATCH --cpus-per-task=2
#SBATCH --mem=8G

set -euo pipefail

source /nfs/home/ebarabanova/miniconda3_new/etc/profile.d/conda.sh
conda activate vcf_clean

WORKDIR=/mnt/tank/scratch/ebarabanova/var_in_genes
cd "$WORKDIR" || exit 1

VCF="high_impact.vcf"
MAP="gene_id_to_name.tsv"

echo "1. Extract sample names"
bcftools query -l "$VCF" > samples.txt

echo "2. Extract variant + annotation + genotypes"
bcftools query \
-f '%CHROM\t%POS\t%REF\t%ALT\t%INFO/ANN\n' \
"$VCF" > tmp.tsv

echo "3. Build genotype matrix"
bcftools query \
-f '[\t%GT]\n' \
"$VCF" > gt.tsv

echo "4. Build header"
{
  printf "CHROM\tPOS\tREF\tALT\tANN\t"
  paste -sd '\t' samples.txt
} > header.txt

echo "5. Combine table"
paste tmp.tsv gt.tsv > body.tsv
cat header.txt body.tsv > high_impact_genotypes_raw.tsv

echo "6. Map gene IDs → gene names (clean extraction)"
awk -F'\t' 'NR==FNR {a[$1]=$2; next}
{
  gene=$5
  split(gene, arr, "|")
  gid=arr[4]   # SnpEff ANN field layout (gene is 4th in ANN split)
  if (gid in a) gene_name=a[gid]
  else gene_name=gid

  print $0 "\t" gene_name
}' "$MAP" high_impact_genotypes_raw.tsv > high_impact_genotypes_named.tsv

echo "DONE"
echo "Output:"
echo " - high_impact_genotypes_named.tsv"
