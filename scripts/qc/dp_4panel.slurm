#!/bin/bash
#SBATCH --job-name=dp_4panel
#SBATCH --output=dp_4panel_%j.out
#SBATCH --error=dp_4panel_%j.err
#SBATCH --time=01:00:00
#SBATCH --cpus-per-task=2
#SBATCH --mem=8G

# activate conda
source /nfs/home/ebarabanova/miniconda3_new/etc/profile.d/conda.sh
conda activate qc_plotting

WORKDIR=/mnt/tank/scratch/ebarabanova/vcf_filtering_qc/qc_outputs

cd "$WORKDIR"

python3 <<EOF
import pandas as pd
import matplotlib.pyplot as plt

# ----------------------------
# Function: load DP histogram
# ----------------------------
def load_dp(file):
    df = pd.read_csv(file, sep=r"\s+", header=None, names=["count", "dp"])
    df = df[df["dp"] < 200]
    return df

# ----------------------------
# Files
# ----------------------------
raw = load_dp("snps.vcf.gz.DP.hist.txt")
after_hard = load_dp("snps_PASS.vcf.gz.DP.hist.txt")
gq20 = load_dp("geno20Filtered.vcf.gz.DP.hist.txt")
gq50 = load_dp("geno50Filtered.vcf.gz.DP.hist.txt")

# common bins
bins = range(0, 200, 5)

# ----------------------------
# Plot
# ----------------------------
fig, axes = plt.subplots(1, 4, figsize=(20, 5), sharex=True)

# ----------------------------
# Panel A: Raw
# ----------------------------
axes[0].hist(raw["dp"], bins=bins, weights=raw["count"])
axes[0].set_title("Raw VCF")
axes[0].set_xlabel("DP")
axes[0].set_ylabel("Variant count")

# ----------------------------

# Panel B: After hard filters
# ----------------------------
axes[1].hist(after_hard["dp"], bins=bins, weights=after_hard["count"])
axes[1].set_title("After site-level filters")
axes[1].set_xlabel("DP")
axes[1].set_ylabel("Variant count")

# ----------------------------

# Panel C: GQ20
# ----------------------------
axes[2].hist(gq20["dp"], bins=bins, weights=gq20["count"])
axes[2].set_title("GQ ≥ 20")
axes[2].set_xlabel("DP")

# ----------------------------
# Panel D: GQ50
# ----------------------------
axes[3].hist(gq50["dp"], bins=bins, weights=gq50["count"])
axes[3].set_title("GQ ≥ 50")
axes[3].set_xlabel("DP")

# ----------------------------
# Final styling
# ----------------------------
plt.suptitle("Depth (DP) distribution before and after filtering", fontsize=14)
plt.tight_layout()

plt.savefig("DP_4panel.png", dpi=300)
EOF
