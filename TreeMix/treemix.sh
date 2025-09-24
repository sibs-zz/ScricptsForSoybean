# =====================================================================
#  TreeMix analysis pipeline
#  Goal: convert VCF to TreeMix input, run TreeMix with multiple
#        migration edges, and generate log files for inspection.
#
#  Dependencies:
#    - vcf2treemix.sh      # custom script to convert VCF → TreeMix format
#    - TreeMix             # https://bitbucket.org/nygcresearch/treemix
#
#  Inputs:
#    - input.vcf                 # genotype VCF file
#    - cluster.file               # population assignment file
#
#  Outputs (per run):
#    - *.rep1                     # TreeMix output directories for each m
#    - treemix_*_log              # log files for each run
# =====================================================================

# --- Step 1: convert VCF to TreeMix format
# Usage: sh vcf2treemix.sh <vcf> <cluster.file>
sh vcf2treemix.sh BS.vcf 3780.clust

# --- Step 2: run TreeMix with increasing migration events (m = 1..15)
# bootstrap replicates = 100, block size = 10,000, no sample size correction
FILE="BS"

for i in {1..15}; do
  treemix \
    -i ${FILE}.treemix.frq.gz \
    -m $i \
    -o ${FILE}.${i}.rep1 \
    -bootstrap 100 \
    -k 10000 \
    -noss \
    > treemix_${i}_log &
done

# =====================================================================
# Notes:
#   - "cluster.file" should define sample-to-population mapping
#     required by vcf2treemix.sh.
#   - The number of migration edges (-m) controls network complexity:
#       * m = 0 produces a bifurcating tree
#       * higher m values allow for admixture edges
#   - "-bootstrap 100" ensures robustness assessment via resampling.
#   - Check treemix_*_log files for convergence and error messages.
#   - Results (*.rep1) can be visualized with TreeMix plotting utilities.
# =====================================================================
