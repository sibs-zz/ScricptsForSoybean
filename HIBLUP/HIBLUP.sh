# =====================================================================
#  HiBLUP + GCTA workflow
#  Goal:
#    1) Build additive & dominance relationship matrices (XRM) with HiBLUP
#    2) Run single-trait genomic prediction (mixed model) with covariates
#    3) Prepare phenotype for downstream association
#    4) Run GCTA-MLMA GWAS with GRM and covariates
#
#  Dependencies:
#    - HiBLUP (hiblup)
#    - GCTA (gcta64)
#    - PLINK binary set for genotype inputs (*.bed/bim/fam)
#
#  Folder layout (example):
#    data/
#      ├── 8105.990w.*           # PLINK bed/bim/fam for training set
#      ├── 8105pheno             # phenotype table (tab-delimited)
#      ├── 8105pca               # quantitative covariates (PCs)
#      ├── 8105pop               # population class file (categorical)
#      ├── order                 # sample order file (one ID per line)
#      └── 2100list              # sample list to keep for GWAS
#    gwas/
#      ├── gwas.*                # PLINK bed/bim/fam for GWAS set
#      └── gwas.grm.*            # GCTA GRM (optional; or build on the fly)
# =====================================================================

# --- Step 1: Build additive (GA) and dominance (GD) XRM with HiBLUP
# Input: PLINK bfile for the training panel
# Output: 8105.990w.gs.GA (additive) and 8105.990w.gs.GD (dominance)
./hiblup \
  --make-xrm \
  --bfile ../8105.990w \
  --add \
  --dom \
  --out 8105.990w.gs

# --- Step 2: Single-trait mixed model with covariates and population class
# Inputs:
#   --pheno 8105pheno       : phenotype table (FID IID ... PHENOcol ...)
#   --pheno-pos 5           : phenotype column index (1-based)
#   --qcovar 2,3,4          : quantitative covariate columns (e.g., PCs)
#   --pop-class ../8105pop  : population structure (categorical)
#   --xrm GA,GD             : relationship matrices built above
# Output:
#   2100zongdanbaiyouzhi.*  : prediction / random effects / solutions
hiblup \
  --single-trait \
  --pheno 8105pheno \
  --pheno-pos 5 \
  --qcovar 2,3,4 \
  --pop-class ../8105pop \
  --xrm ../8105.990w.gs.GA,../8105.990w.gs.GD \
  --add \
  --dom \
  --threads 8 \
  --out 2100zongdanbaiyouzhi

# --- Step 3: Build a phenotype file from HiBLUP random effects (example)
# Assumes 2100zongdanbaiyouzhi.rand contains per-sample additive+dominance effects
# "order" holds sample IDs in the desired order (one per line).
# Output: three-column PHENO (FID IID PHENO) for GCTA
cat order \
  | while read id; do grep -w "$id" 2100zongdanbaiyouzhi.rand; done \
  | awk '{print $1, $1, $2+$3}' \
  > 2100zongdanbaiyouzhi.rand.pheno

# --- Step 4: GCTA MLMA (GWAS) using GRM + covariates on a target subset
# Inputs:
#   --bfile ../../gwas                 : PLINK GWAS genotype
#   --grm ../../gwas                   : GRM for GWAS panel (precomputed)
#   --keep ../2100list                 : subset of samples to analyze
#   --pheno *.pheno                    : three-column phenotype (FID IID PHENO)
#   --qcovar ../8105pca                : quantitative covariates (e.g., PCs)
# Output:
#   2100zongdanbaiyouzhi.rand.pheno.* : MLMA results
gcta64 \
  --mlma \
  --bfile ../../gwas \
  --grm ../../gwas \
  --keep ../2100list \
  --pheno 2100zongdanbaiyouzhi.rand.pheno \
  --qcovar ../8105pca \
  --out 2100zongdanbaiyouzhi.rand.pheno \
  --thread-num 4

# =====================================================================
# Notes:
#   - Ensure FID/IID match across all files (PLINK, pheno, covariates, lists).
#   - In Step 2, adjust --pheno-pos and --qcovar to the actual column indices.
#   - If you do not have a precomputed GRM for GWAS, create it with:
#       gcta64 --bfile ../../gwas --make-grm --autosome --out ../../gwas
#   - Consider alternative models in HiBLUP (e.g., epistasis) if needed.
#   - For very large cohorts, parallelize and use sufficient memory.
# =====================================================================
