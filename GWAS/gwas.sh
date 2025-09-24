# =====================================================================
#  GWAS workflow with PLINK + GCTA
#  Goal:
#    1) Convert filtered VCF into PLINK binary format (bed/bim/fam)
#    2) Build GRM (genomic relationship matrix) using GCTA
#    3) Perform GWAS with GCTA-MLMA mixed linear model
#
#  Dependencies:
#    - PLINK
#    - GCTA (gcta64)
#
#  Input files:
#    - 2100list.maf0.05.int0.9.recode.vcf : filtered genotype VCF
#    - 2100bailizhong                     : phenotype file (FID IID PHENO)
#    - 2100pca                            : quantitative covariates (PCs)
# =====================================================================

# --- Step 1: Convert VCF to PLINK binary format
# --output-missing-genotype 0   : set missing calls to "0" (avoids NA codes)
# --double-id                   : duplicate FID=IID for PLINK compatibility
# Output: gwas.bed / gwas.bim / gwas.fam
plink \
  --vcf 2100list.maf0.05.int0.9.recode.vcf \
  --make-bed \
  --output-missing-genotype 0 \
  --double-id \
  --out gwas

# --- Step 2: Build GRM with GCTA
# --autosome : restrict analysis to autosomes
# Output: 2100list.maf0.05.int0.9.recode.grm.* (GRM binary set)
gcta64 \
  --bfile 2100list.maf0.05.int0.9.recode \
  --autosome \
  --make-grm \
  --out 2100list.maf0.05.int0.9.recode

# --- Step 3: Run GWAS with GCTA-MLMA (mixed linear model association)
# Inputs:
#   --bfile   : PLINK binary genotype file
#   --grm     : GRM created in Step 2
#   --pheno   : phenotype file (3 cols: FID IID PHENO)
#   --qcovar  : covariates file (e.g., PCs)
#   --thread-num 4 : parallel computation
# nohup + & ensures background run with logging
nohup gcta64 \
  --mlma \
  --bfile 2100list.maf0.05.int0.9.recode \
  --grm 2100list.maf0.05.int0.9.recode \
  --pheno 2100bailizhong \
  --qcovar 2100pca \
  --out 2100bailizhong \
  --thread-num 4 &

# =====================================================================
# Notes:
#   - Make sure sample IDs (FID IID) match across genotype, phenotype, and covariate files.
#   - Phenotype file: must be space/tab-delimited, with no headers unless specified.
#   - PCA covariates (2100pca) should be formatted as FID IID PC1 PC2 PC3 ...
#   - Adjust --thread-num to match available cores.
#   - Consider MAF/LD pruning before Step 1 if not already done.
# =====================================================================
