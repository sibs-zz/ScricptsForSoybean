# =====================================================================
#  XP-CLR selective sweep detection
#  Goal: run XP-CLR across all chromosomes, merge outputs, standardize
#        scores (Z-scores), identify outlier regions, and map them to genes.
#
#  Dependencies:
#    - XP-CLR (https://reich.hms.harvard.edu/software)
#    - awk, grep, sed, sort
#    - python (zscore.py)      # standardization of XP-CLR scores
#    - GetGeneFromGFF.py       # interval → gene overlap (user script)
#
#  Inputs:
#    - input.filtered.vcf          # cohort VCF (biallelic SNPs, QC’d)
#    - populationA.list            # sample IDs for population A
#    - populationB.list            # sample IDs for population B
#    - reference.gff               # gene annotation file (GFF/GFF3)
#
#  Outputs (main):
#    - xpclr_results.genes.clean   # candidate genes under selection
# =====================================================================

# --- Step 1: run XP-CLR for each chromosome
for chr in {1..20}; do
  xpclr \
    --out popA_vs_popB_chr${chr} \
    -Sa populationA.list \
    -Sb populationB.list \
    --input input.filtered.vcf \
    --chr ${chr} \
    --ld 0.95 \
    --maxsnps 1000 \
    --size 100000 \
    --step 100000
done

# --- Step 2: merge results from all chromosomes
# keep header from chr1, remove xpclr labels and append others
head -1 popA_vs_popB_chr1 > xpclr_results_all
for chr in {1..20}; do
  grep -v xpclr popA_vs_popB_chr${chr} >> xpclr_results_all
done

# --- Step 3: extract required columns for Z-score input
# using col2, col3, col4 (coordinates) and col12 (XP-CLR score)
awk '{print $2,$3,$4,$12}' xpclr_results_all \
  | grep -v xpclr \
  | awk '{if(NF==4)print}' \
  > xpclr_results_all.t

# --- Step 4: Z-score standardization of XP-CLR scores
python zscore.py \
  xpclr_results_all.t \
  xpclr_results_all.t.zscore

# --- Step 5: call outlier regions based on Z threshold (e.g., Z ≥ 1.96)
awk '{if($5>=1.96) print $1,$2,$3}' \
  xpclr_results_all.t.zscore \
  > xpclr_results_all.t.zscore.pos

# --- Step 6: normalize chromosome labels (e.g., Chr01, Chr02)
awk '{if($1<10){print "Chr0"$1,$2,$3}else {print "Chr"$1,$2,$3}}' \
  xpclr_results_all.t.zscore.pos \
  > xpclr_results_all.t.zscore.pos.norm

# --- Step 7: map outlier regions to genes and extract non-redundant IDs
python GetGeneFromGFF.py reference.gff \
  xpclr_results_all.t.zscore.pos.norm \
  xpclr_results_all.t.zscore.pos.genes

awk '{print $9}' xpclr_results_all.t.zscore.pos.genes \
  | grep -v attr \
  | sed 's/ID=//g' \
  | sed 's/;//g' \
  | sort -u \
  > xpclr_results_all.t.zscore.pos.genes.clean

# =====================================================================
# Final deliverable:
#   xpclr_results_all.t.zscore.pos.genes.clean
#     → Non-redundant candidate genes from XP-CLR selective sweep signals
#
# Tips:
#   - Ensure chromosome IDs in VCF match XP-CLR expectation (e.g., 1..20).
#   - LD threshold (--ld), window size (--size), and step size (--step)
#     may be tuned for population-specific resolution.
#   - Interpret XP-CLR scores cautiously; consider integrating with
#     additional selection scans (e.g., Fst, π ratio, RAiSD).
# =====================================================================
