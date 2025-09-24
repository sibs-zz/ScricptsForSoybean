# ================================================================
#   Genome-wide FST Scan Pipeline
#   Identify selective sweeps using windowed FST statistics
#   Dependencies: vcftools, awk, grep, sed, sort, python (zscore.py), GetGeneFromGFF.py
# ================================================================

# Step 1 — Calculate windowed FST between two populations
vcftools \
  --vcf input.filtered.vcf \
  --weir-fst-pop popA.list \
  --weir-fst-pop popB.list \
  --out out \
  --fst-window-size 100000 \
  --fst-window-step 10000

# Step 2 — Extract useful columns (CHR, START, END, FST)
grep -v BIN out.windowed.weir.fst \
  | awk '{print $1,$2,$3,$5}' \
  > out.fst.window

# Step 3 — Standardize FST values with Z-scores
python zscore.py out.fst.window out.fst.window.zscore

# Step 4 — Filter windows with Z ≥ 1.96
awk '{if($5>=1.96) print $1,$2,$3}' out.fst.window.zscore \
  > out.fst.window.zscore.pos

# Step 5 — Normalize chromosome IDs for GFF compatibility
awk '{if($1<10){print "Chr0"$1,$2,$3}else {print "Chr"$1,$2,$3}}' \
  out.fst.window.zscore.pos \
  > out.fst.window.zscore.pos.norm

# Step 6 — Map candidate regions to gene models
python GetGeneFromGFF.py reference.gff \
  out.fst.window.zscore.pos.norm \
  out.fst.window.zscore.pos.genes

# Step 7 — Extract a clean list of unique candidate genes
awk '{print $9}' out.fst.window.zscore.pos.genes \
  | grep -v attr \
  | sed 's/ID=//g' \
  | sed 's/;//g' \
  | sort -u \
  > out.fst.window.zscore.pos.genes.clean

# ================================================================
# Final Output: out.fst.window.zscore.pos.genes.clean
#   → Contains non-redundant candidate genes under selection
# ================================================================
