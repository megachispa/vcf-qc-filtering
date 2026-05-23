#!/bin/bash
#SBATCH --job-name=exact_roh_overlap
#SBATCH --output=exact_roh_overlap_%j.out
#SBATCH --error=exact_roh_overlap_%j.err
#SBATCH --time=01:00:00
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G

source /nfs/home/ebarabanova/miniconda3_new/etc/profile.d/conda.sh
conda activate vcf_clean

WORKDIR=/mnt/tank/scratch/ebarabanova/roh
cd "$WORKDIR"

INPUT=roh_gt1Mb_sorted.bed

# get deer IDs
cut -f4 $INPUT | sort -u > deer_list.txt

# initialize matrix
printf "Deer" > exact_overlap_matrix.tsv

while read d; do
    printf "\t%s" "$d" >> exact_overlap_matrix.tsv
done < deer_list.txt

printf "\n" >> exact_overlap_matrix.tsv

# compute pairwise overlaps
while read d1; do

    printf "%s" "$d1" >> exact_overlap_matrix.tsv

    awk -v id="$d1" '$4==id' $INPUT > tmp1.bed

    while read d2; do

        awk -v id="$d2" '$4==id' $INPUT > tmp2.bed

        overlap=$(bedtools intersect \
            -a tmp1.bed \
            -b tmp2.bed \
            | awk '{
                sum += ($3-$2)
            }
            END{
                print sum/1000000
            }')

        printf "\t%.3f" "${overlap:-0}" >> exact_overlap_matrix.tsv

    done < deer_list.txt

    printf "\n" >> exact_overlap_matrix.tsv

done < deer_list.txt

rm -f tmp1.bed tmp2.bed

