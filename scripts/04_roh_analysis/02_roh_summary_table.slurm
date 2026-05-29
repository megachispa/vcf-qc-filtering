#!/bin/bash
#SBATCH --job-name=roh_summary_table
#SBATCH --output=roh_summary_%j.out
#SBATCH --error=roh_summary_%j.err
#SBATCH --time=01:00:00
#SBATCH --cpus-per-task=2
#SBATCH --mem=8G

set -euo pipefail

WORKDIR=/mnt/tank/scratch/ebarabanova/roh
cd "$WORKDIR"

awk '
BEGIN{
print "Individual\tClass\tLength"
}

NR>1{
ind=$2
len=$9 / 1000

if(len < 1) class="<1Mb"
else if(len < 2) class="1-2Mb"
else if(len < 4) class="2-4Mb"
else class="4-8Mb"

sum[ind SUBSEP class] += len
}

END{
for(k in sum){
split(k,a,SUBSEP)
printf "%s\t%s\t%.3f\n", a[1], a[2], sum[k]
}
}
' deer_roh.hom > roh_summary_table.txt
