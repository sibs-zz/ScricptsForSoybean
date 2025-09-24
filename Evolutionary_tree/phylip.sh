# =====================================================================
#  Phylogenetic tree workflow
#  Goal:
#    1) Compute pairwise genetic distances with PLINK (1 − IBS)
#    2) Convert to PHYLIP format
#    3) Build a Neighbor-Joining tree with PHYLIP
#    4) Visualize the Newick tree in iTOL (Interactive Tree Of Life)
#
#  Dependencies:
#    - PLINK 1.9/2.0 (plink)
#    - Perl (for phylip_pre.pl converter)
#    - PHYLIP (neighbor)
#    - iTOL (web visualization; upload Newick file)
#
#  Inputs:
#    - 8917.prune.prune.in.*  : PLINK bed/bim/fam (LD-pruned recommended)
#
#  Outputs:
#    - 8917.distance.mdist / .mdist.id : PLINK distance matrix + IDs
#    - 8917.distance.phy               : PHYLIP-formatted distance matrix
#    - outtree                         : Newick tree (rename to .nwk for iTOL)
# =====================================================================

# --- Step 1: Pairwise genetic distance (1 − IBS) with PLINK
# --maf 0.05 filters rare SNPs; adjust as needed
# --distance square '1-ibs' produces a full square matrix
plink \
  --bfile 8917.prune.prune.in \
  --maf 0.05 \
  --noweb \
  --distance square '1-ibs' \
  --out 8917.distance

# Generated files:
#   8917.distance.mdist     : distance matrix
#   8917.distance.mdist.id  : sample IDs (FID IID)

# --- Step 2: Convert PLINK distance matrix to PHYLIP format
# phylip_pre.pl should read *.mdist.id and *.mdist and write a PHYLIP file
perl phylip_pre.pl \
  8917.distance.mdist.id \
  8917.distance.mdist \
  > 8917.distance.phy

# --- Step 3: Build Neighbor-Joining tree with PHYLIP (non-interactive)
# PHYLIP "neighbor" is interactive by default; feed filename + confirm overwrite.
# Depending on your PHYLIP build, the prompts may differ slightly.
# The following works for most installations:
printf "8917.distance.phy\nY\n" | phylip neighbor

# Outputs:
#   outfile  : PHYLIP textual report
#   outtree  : Newick tree (rename for clarity)
mv outtree 8917.neighbor.nwk

# --- Step 4: Visualize in iTOL (https://itol.embl.de)
# Upload 8917.neighbor.nwk to iTOL and customize labels/colors as needed.

# =====================================================================
# Notes:
#   - Ensure sample order and IDs are consistent across steps; iTOL can read
#     a separate metadata table (sample → group/color) for annotation.
#   - If PHYLIP prompts differ, run `phylip neighbor` once interactively to
#     confirm the exact sequence of inputs, then script via printf accordingly.
#   - Alternatives: fastme (NJ/ME), rapidnj, or R (ape::nj) can also build NJ trees.
#   - For large cohorts, consider distance thinning or PC-based clustering first.
# =====================================================================
