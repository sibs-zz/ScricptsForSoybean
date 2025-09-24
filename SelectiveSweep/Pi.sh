# =====================================================================
#  π-ratio–based selective sweep detection
#  Goal: compute windowed nucleotide diversity (π) per population,
#        align common windows, derive π ratio (popA/popB), standardize
#        with Z-scores, call outlier windows, and map to genes.
#
#  Dependencies:
#    - vcftools, awk, grep, sed, sort, paste, comm
#    - python (zscore.py)      # same interface as in FST workflow
#    - GetGeneFromGFF.py       # interval → gene overlap (user script)
#
#  Inputs:
#    - input.filtered.vcf        # cohort VCF (biallelic SNPs, QC’d)
#    - *.list                    # one sample ID per line (population files)
#    - reference.gff             # gene annotation (GFF/GFF3)
#
#  Outputs (main):
#    - popA_vs_popB.piratio.in.zscore.pos.genes.clean  # candidate genes
# =====================================================================

# --- Step 0: (optional) create a batch script to run windowed π for many groups
# Each *.list is a population list. Adjust window/step sizes as needed.
ls *.list | while read plist; do
  echo "nohup vcftools --vcf input.filtered.vcf \
    --keep ${plist} \
    --window-pi 100000 \
    --window-pi-step 100000 \
    --out ${plist%.list} &"
done > run_pi.sh

# Execute the batch if desired:
# bash run_pi.sh
# Wait until you have files like: popA.windowed.pi, popB.windowed.pi

# --- Step 1: define two populations (edit these to your actual filenames)
popA=popA.windowed.pi
popB=popB.windowed.pi

# --- Step 2: build window keys (CHR_START_END) and find common windows
grep -v BIN "$popA" | awk '{print $1"_"$2"_"$3}' | sort > A.keys
grep -v BIN "$popB" | awk '{print $1"_"$2"_"$3}' | sort > B.keys
comm -12 A.keys B.keys > common.keys

# --- Step 3: tag original π tables with window keys for joining
awk '{print $1"_"$2"_"$3, $0}' "$popA" > A.tag
awk '{print $1"_"$2"_"$3, $0}' "$popB" > B.tag

# --- Step 4: extract rows for common windows (order follows common.keys)
# Note: Using while+grep is simple and readable for moderate files.
#       For very large files, consider join after sorting by key.
while read k; do grep -w "$k" A.tag; done < common.keys > A.common
while read k; do grep -w "$k" B.tag; done < common.keys > B.common

# --- Step 5: paste A and B tables, compute π ratio (A/B), keep core columns
# Assumption: In VCFtools windowed.pi, π is typically column 4 (PI).
# The paste result concatenates A.common and B.common lines side by side.
paste A.common B.common \
  | awk '{print $2, $3, $4, $6, $12, $6/$12}' \
  > popA_vs_popB.piratio    # CHR START END PI_A PI_B PIratio

# --- Step 6: sort and keep minimal table for Z-scoring
grep -v BIN popA_vs_popB.piratio \
  | sort -k1,1n -k2,2n \
  | awk '{print $1, $2, $3, $6}' \
  > popA_vs_popB.piratio.in   # CHR START END PIratio

# --- Step 7: Z-score standardization (adds column 5 = Z)
python zscore.py popA_vs_popB.piratio.in popA_vs_popB.piratio.in.zscore

# --- Step 8: call outlier windows by Z threshold (e.g., Z ≥ 1.96)
awk '{if($5>=1.96) print $1, $2, $3}' \
  popA_vs_popB.piratio.in.zscore \
  > popA_vs_popB.piratio.in.zscore.pos

# --- Step 9: normalize chromosome labels (optional; match your GFF naming)
awk '{if($1<10){print "Chr0"$1, $2, $3} else {print "Chr"$1, $2, $3}}' \
  popA_vs_popB.piratio.in.zscore.pos \
  > popA_vs_popB.piratio.in.zscore.pos.norm

# --- Step 10: map outlier windows to genes and extract unique IDs
python GetGeneFromGFF.py reference.gff \
  popA_vs_popB.piratio.in.zscore.pos.norm \
  popA_vs_popB.piratio.in.zscore.pos.genes

awk '{print $9}' popA_vs_popB.piratio.in.zscore.pos.genes \
  | grep -v attr \
  | sed 's/ID=//g' \
  | sed 's/;//g' \
  | sort -u \
  > popA_vs_popB.piratio.in.zscore.pos.genes.clean

# =====================================================================
# Final deliverable:
#   popA_vs_popB.piratio.in.zscore.pos.genes.clean
#     → Non-redundant candidate genes from π-ratio outlier windows
#
# Tips:
#   - Use identical window/step for both populations; align on common windows.
#   - Ensure VCF and GFF share the same reference build and contig naming.
#   - For very large cohorts, replace grep loops with sorted joins and run on HPC.
#   - Record software versions and all parameters for reproducibility.
# =====================================================================
