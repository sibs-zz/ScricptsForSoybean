# =====================================================================
#  PCA pipeline with PLINK + GCTA
#  Goal: LD-prune variants → build binary PLINK files → compute GRM →
#        run PCA to obtain top principal components.
#
#  Dependencies:
#    - PLINK 1.9/2.0 (plink)
#    - GCTA (gcta64)  https://yanglab.westlake.edu.cn/software/gcta/
#
#  Inputs:
#    - input VCF: 8917.snp.filter.vcf   # filtered, biallelic SNPs recommended
#
#  Outputs:
#    - 8917.prune.prune.in              # list of SNPs kept after LD pruning
#    - 8917.prune.*                     # PLINK bed/bim/fam for pruned SNPs
#    - 8917.prune.grm.*                 # GCTA GRM (binary format)
#    - 8917.eigenval / 8917.eigenvec    # PCA eigenvalues / eigenvectors
# =====================================================================

# --- Step 1: LD pruning (window=50 SNPs, step=10 SNPs, r^2 threshold=0.2)
# Produces two lists: *.prune.in (kept SNPs) and *.prune.out (removed SNPs)
plink \
  --vcf 8917.snp.filter.vcf \
  --indep-pairwise 50 10 0.2 \
  --out 8917.prune \
  --double-id

# --- Step 2: Create PLINK binary set using only pruned SNPs
# Keeps only SNPs in 8917.prune.prune.in; outputs bed/bim/fam
plink \
  --vcf 8917.snp.filter.vcf \
  --make-bed \
  --extract 8917.prune.prune.in \
  --out 8917.prune.prune.in \
  --double-id

# --- Step 3: Build the Genetic Relationship Matrix (GRM) with GCTA
# Uses autosomal SNPs only; output prefix 8917.prune.grm.*
gcta64 \
  --bfile 8917.prune.prune.in \
  --make-grm \
  --autosome \
  --out 8917.prune

# --- Step 4: Principal Component Analysis (top 10 PCs)
# Reads the GRM and outputs eigenvalues/eigenvectors
gcta64 \
  --grm 8917.prune \
  --pca 10 \
  --out 8917

# =====================================================================
# Notes:
#   - Ensure sample IDs are consistent; --double-id sets FID=IID from VCF IDs.
#   - Consider additional variant filters before pruning (e.g., MAF, geno, mind).
#   - LD thresholds (50 10 0.2) are typical defaults; tune per dataset.
#   - For very large cohorts, use PLINK2 (--pca approx) as an alternative.
#   - Downstream plotting: use 8917.eigenvec (columns: FID IID PC1 PC2 ...)
# =====================================================================
