#!/bin/bash
#SBATCH --job-name=froh
#SBATCH --output=froh_%j.out
#SBATCH --error=froh_%j.err
#SBATCH --time=00:30:00
#SBATCH --cpus-per-task=1
#SBATCH --mem=4G

set -euo pipefail

WORKDIR=/mnt/tank/scratch/ebarabanova/roh
cd "$WORKDIR"

# 1. CALCULATE GENOME SIZE (Mb)

REFERENCE=/nfs/home/ebarabanova/bwa_indexed_ref_genome/GCA_034233915.1_ASM3423391v1_genomic.fna.fai

GENOME_MB=$(awk '{sum+=$2} END {print sum/1000000}' "$REFERENCE")

echo "Genome size: ${GENOME_MB} Mb"

# 2. CALCULATE FROH (>1 Mb only)

(

echo -e "Individual\tROH_gt1Mb\tFROH_gt1Mb"

awk -v G="$GENOME_MB" '

NR>1{

ind=$2

# convert kb -> Mb
roh_mb=$9/1000

# keep only ROH >=1 Mb
if(roh_mb >= 1){

sum[ind]+=roh_mb
}
}

END{

for(ind in sum){

froh=sum[ind]/G

printf "%s\t%.3f\t%.5f\n",
ind, sum[ind], froh
}
}
' deer_roh.hom | sort -k2,2nr

) > froh_gt1Mb.txt
