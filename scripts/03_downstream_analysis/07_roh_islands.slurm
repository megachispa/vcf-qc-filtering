#!/bin/bash
#SBATCH --job-name=roh_islands
#SBATCH --output=roh_islands_%j.out
#SBATCH --error=roh_islands_%j.err
#SBATCH --time=01:00:00
#SBATCH --cpus-per-task=4
#SBATCH --mem=32G


# Activate conda
source /nfs/home/ebarabanova/miniconda3_new/etc/profile.d/conda.sh
conda activate vcf_clean

which bedtools
bedtools --version

WORKDIR=/mnt/tank/scratch/ebarabanova/roh
cd "$WORKDIR"

########################################
# 1. Extract ROHs ≥1 Mb from PLINK .hom
########################################

awk 'NR>1 && $9>=1000 {
print $4"\t"$7"\t"$8"\t"$2
}' deer_roh.hom > roh_gt1Mb.bed

########################################
# 2. Sort coordinates
########################################

sort -k1,1 -k2,2n roh_gt1Mb.bed > roh_gt1Mb_sorted.bed

########################################
# 3. Prepare genome file
########################################

cut -f1,2 ~/bwa_indexed_ref_genome/GCA_034233915.1_ASM3423391v1_genomic.fna.fai > genome.txt

########################################
# 4. Create 50 kb genome windows
########################################

bedtools makewindows \
-g genome.txt \
-w 50000 \
> genome_windows.bed

########################################
# 5. Count ROHs overlapping each window
########################################

bedtools intersect \
-a genome_windows.bed \
-b roh_gt1Mb_sorted.bed \
-c \
> roh_window_counts.txt

########################################
# 6. Convert counts to frequencies
########################################

awk '{
print $1"\t"$2"\t"$3"\t"$4"\t"$4/8
}' roh_window_counts.txt > roh_window_freq.txt

########################################
# 7. Identify ROH islands
########################################

awk '$5>=0.375' roh_window_freq.txt > roh_islands.bed

########################################
# 8. Merge adjacent windows
########################################

sort -k1,1 -k2,2n roh_islands.bed > roh_islands_sorted.bed

bedtools merge \
-i roh_islands_sorted.bed \
-c 5 \
-o mean \
> roh_islands_merged.bed

########################################
# 9. Calculate island length
########################################

awk '{
print $1"\t"$2"\t"$3"\t"$4"\t"($3-$2)/1000000
}' roh_islands_merged.bed > roh_islands_final.txt

echo "ROH island detection complete."
