# =====================================================================
#  fd statistic calculation workflow (ABBA-BABA framework)
#  Goal:
#    1) Define population groups (P1, P2, P3, Outgroup)
#    2) Run ABBABABAwindows.py to compute ABBA-BABA statistics
#    3) Convert outputs and calculate fd values
#
#  Requirements:
#    - Python script: ABBABABAwindows.py (https://github.com/simonhmartin/genomics_general)
#    - Beagle genotype file: merge.beagle.geno.gz
#    - Population lists: meiguo_cultivar.list, before1960.list,
#                        zhongguo_soja.list, outgroup.list
# =====================================================================

# --- Step 1: Prepare population assignment file ---
# Assign individuals to populations A, B, C, D
#   A = American cultivars
#   B = Chinese cultivars before 1960
#   C = Chinese wild soybean (soja)
#   D = Outgroup
cat meiguo_cultivar.list | awk '{print $1,"A"}'  > before1960.pop
cat before1960.list      | awk '{print $1,"B"}' >> before1960.pop
cat zhongguo_soja.list   | awk '{print $1,"C"}' >> before1960.pop
cat outgroup.list        | awk '{print $1,"D"}' >> before1960.pop

# --- Step 2: Run ABBA-BABA analysis ---
# Sliding window test (100 kb windows, step 100 kb, min 100 sites).
# Outputs results as before1960.pop.csv.
python ABBABABAwindows.py \
    -g merge.beagle.geno.gz \
    -f phased \
    -o before1960.pop.csv \
    -w 100000 \
    -m 100 \
    -s 100000 \
    -P1 A -P2 B -P3 C -O D \
    -T 4 \
    --popsFile before1960.pop

# --- Step 3: Post-process results to calculate fd ---
# Convert CSV to tab-delimited, extract necessary columns:
#   col1=chrom, col2=position, col9=D-statistic, col10=fd
# Replace invalid or extreme values with "0" for stability.
sed 's/,/\t/g' 1960-1980.pop.csv \
  | awk '{print $1,$2,$9,$10}' \
  | grep -v ld \
  | awk '{if($3<0){print $1"_"$2,$1,$2,"0"} else {print $1"_"$2,$1,$2,$4}}' \
  | awk '{if($4>1){print $1,$2,$3,"0"}else{print $1,$2,$3,$4}}' \
  | awk '{if($4<0){print $1,$2,$3,"0"}else{print $1,$2,$3,$4}}' \
  > 1960-1980.pop.csv.fd

# =====================================================================
# Outputs:
#   - before1960.pop          : population assignment file
#   - before1960.pop.csv      : ABBA-BABA window statistics
#   - 1960-1980.pop.csv.fd    : fd statistic values (filtered and cleaned)
#
# Notes:
#   - fd is a normalized statistic for introgression analysis.
#   - Replace file names (before1960 / 1960-1980) as needed for other groups.
#   - Adjust window size and step depending on genome coverage and SNP density.
# =====================================================================
