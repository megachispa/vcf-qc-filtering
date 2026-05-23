#!/bin/bash
#SBATCH --job-name=largest_island_rohs
#SBATCH --output=largest_island_rohs_%j.out
#SBATCH --error=largest_island_rohs_%j.err
#SBATCH --time=01:00:00
#SBATCH --cpus-per-task=4
#SBATCH --mem=32G

WORKDIR=/mnt/tank/scratch/ebarabanova/roh
cd "$WORKDIR"

largest=$(sort -k5,5nr roh_islands_final.txt | head -n1)

scaffold=$(echo "$largest" | awk '{print $1}')
start=$(echo "$largest" | awk '{print $2}')
end=$(echo "$largest" | awk '{print $3}')

echo "Largest ROH island:"
echo "$largest"

# Extract overlapping ROHs

awk -v scaf="$scaffold" -v s="$start" -v e="$end" '
$1==scaf &&
$3>=s &&
$2<=e
' roh_gt1Mb_sorted.bed > largest_island_rohs.txt

echo "Extracted overlapping ROHs:"
wc -l largest_island_rohs.txt
