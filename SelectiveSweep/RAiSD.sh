# =====================================================================
#  RAiSD-based selective sweep detection
#  Goal: run RAiSD for a given population, merge replicate outputs,
#        standardize RAiSD scores (Z-scores), identify outlier regions,
#        and map them to annotated genes.
#
#  Dependencies:
#    - RAiSD (https://github.com/alachins/raisd)
#    - awk, grep, sed, sort
#    - python (zscore.py)      # standardization of RAiSD scores
#    - GetGeneFromGFF.py       # interval → gene overlap (user script)
#
#  Inputs:
#    - input.filtered.vcf       # cohort VCF (biallelic SNPs, QC’d)
#    - population.list          # sample IDs for one population
#    - reference.gff            # gene annotation file (GFF/GFF3)
#
#  Outputs (main):
#    - RAiSD_Report.all.zscore.pos.genes.clean   # candidate genes
# =====================================================================

# --- Step 1: run RAiSD
./raisd-master/bin/release/RAiSD \
  -n population_name \
  -I input.filtered.vcf \
  -R -A 0.95 \
  -S population.list \
  -f

# This generates multiple RAiSD report files:
#   RAiSD_Report.population_name.1
#   RAiSD_Report.population_name.2
#   ...
#   RAiSD_Report.population_name.N

# --- Step 2: extract key columns from each replicate and merge into one file
# Columns used: $2 = coordinate1, $3 = coordinate2, $7 = RAiSD score (μ statistic)
# Each replicate is prefixed with its replicate number.
for i in {1..20}; do
  awk '{printf "%.3f %.3f %.3f\n", $2,$3,$7}' RAiSD_Report.population_name.$i \
    | awk -v rep=$i '{print rep, $0}' >> RAiSD_Report.population_name.all
done

# --- Step 3: Z-score standardization of RAiSD scores
python zscore.py \
  RAiSD_Report.population_name.all \
  RAiSD_Report.population_name.all.zscore

# --- Step 4: call outlier regions based on Z threshold (e.g., Z ≥ 1.96)
awk '{if($5>=1.96) print $1, $2, $3}' \
  RAiSD_Report.population_name.all.zscore \
  > RAiSD_Report.population_name.all.zscore.pos

# --- Step 5: normalize chromosome labels (e.g., Chr01, Chr02)
awk '{if($1<10){print "Chr0"$1, $2, $3} else {print "Chr"$1, $2, $3}}' \
  RAiSD_Report.population_name.all.zscore.pos \
  > RAiSD_Report.population_name.all.zscore.pos.norm

# --- Step 6: map outlier regions to genes and extract non-redundant IDs
python GetGeneFromGFF.py reference.gff \
  RAiSD_Report.population_name.all.zscore.pos.norm \
  RAiSD_Report.population_name.all.zscore.pos.genes

awk '{print $9}' RAiSD_Report.population_name.all.zscore.pos.genes \
  | grep -v attr \
  | sed 's/ID=//g' \
  | sed 's/;//g' \
  | sort -u \
  > RAiSD_Report.population_name.all.zscore.pos.genes.clean

# =====================================================================
# Final deliverable:
#   RAiSD_Report.population_name.all.zscore.pos.genes.clean
#     → Non-redundant candidate genes from RAiSD sweep signals
#
# Tips:
#   - Adjust replicate range {1..N} depending on how many output files RAiSD generated.
#   - RAiSD μ statistic is sensitive to sample size; interpret cautiously.
#   - Ensure VCF and GFF annotations are aligned to the same genome build.
#   - Use HPC/parallelization for large datasets to accelerate processing.
# =====================================================================
