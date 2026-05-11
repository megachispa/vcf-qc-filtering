#!/bin/bash
#SBATCH --job-name=multiqc_vcf
#SBATCH --output=multiqc_%j.out
#SBATCH --error=multiqc_%j.err
#SBATCH --time=00:30:00
#SBATCH --cpus-per-task=2
#SBATCH --mem=4G

# activate environment
source /nfs/home/ebarabanova/miniconda3_new/etc/profile.d/conda.sh
conda activate vcf_clean

IN_DIR=/mnt/tank/scratch/ebarabanova/vcf_filtering_qc/multiqc_input
OUT_DIR=/mnt/tank/scratch/ebarabanova/vcf_filtering_qc/multiqc_report

mkdir -p "$OUT_DIR"

multiqc "$IN_DIR" \
    -o "$OUT_DIR" \
    -c /mnt/tank/scratch/ebarabanova/vcf_filtering_qc/vcf-qc-filtering/multiqc_config.yaml \
    --filename vcf_filtering_multiqc.html

echo "Done. Report written to: $OUT_DIR"
