# =====================================================================
#  ADMIXTURE + pophelper visualization workflow
#  Goal:
#    1) Run ADMIXTURE for a range of K with cross-validation (CV)
#    2) Collect CV errors and pick the best K
#    3) Visualize Q matrices in R using pophelper / pophelperShiny
#
#  Requirements:
#    - ADMIXTURE (https://dalexander.github.io/admixture/)
#    - PLINK bed/bim/fam: 8917.snp.filter.bed/.bim/.fam
#    - Optional: cpulimit (to cap CPU), GNU coreutils, grep, awk, sed
#    - R packages: pophelper, pophelperShiny (install inside R)
# =====================================================================

# --- Step 1: Run ADMIXTURE across K values (example K=3..7), 4 threads, with CV ---
# Note: ADMIXTURE prints CV error to stderr; we capture both stdout+stderr to logs.
for K in 3 4 5 6 7; do
  echo "[INFO] Running ADMIXTURE for K=${K}"
  # Remove cpulimit if you don't need CPU capping; adjust -j threads as needed.
  cpulimit -l 400 -- admixture --cv 8917.snp.filter.bed ${K} -j4 > admixture_K${K}.log 2>&1
done

# This generates:
#   8917.snp.filter.${K}.Q   : Q matrix (individual ancestry proportions)
#   8917.snp.filter.${K}.P   : P matrix (allele frequencies per cluster)
#   admixture_K${K}.log      : log with CV error line

# --- Step 2: Parse CV errors from logs and choose best K ---
# Extract lines like: "CV error (K=5): 0.51234"
grep -H "CV error" admixture_K*.log \
  | sed -E 's/.*K=([0-9]+)\)\:\s*([0-9.]+)/\1\t\2/' \
  | sort -k1,1n > admixture_cv_errors.tsv

echo -e "#K\tCV_error"
cat admixture_cv_errors.tsv

# Optionally pick K with the minimum CV error:
bestK=$(awk 'NR==1{min=$2;k=$1} NR>1{if($2<min){min=$2;k=$1}} END{print k}' admixture_cv_errors.tsv)
echo "[INFO] Best K by CV error = ${bestK}"

# --- Step 3: Prepare files for pophelper visualization ---
# Place all *.Q files and a sample order/label file (optional) in a directory.
mkdir -p admixture_Q && cp 8917.snp.filter.*.Q admixture_Q/

# =====================================================================
#  R SECTION (run the following lines inside an R session)
#  - Visualize Q matrices using pophelper / pophelperShiny
# =====================================================================

# R code starts here (copy into R):
# ------------------------------------------------------------
# install.packages("pophelper")           # if not installed
# if (!requireNamespace("remotes", quietly=TRUE)) install.packages("remotes")
# remotes::install_github("royfrancis/pophelperShiny")  # pophelperShiny

# library(pophelper)
# library(pophelperShiny)

# # Point to the directory with Q files
# qdir <- "admixture_Q"

# # Read all Q files (supports ADMIXTURE output)
# qlist <- pophelper::readQ(files=list.files(qdir, pattern="*.Q$", full.names=TRUE))

# # Summarize CV errors (from the TSV parsed above)
# cv <- read.table("admixture_cv_errors.tsv", header=FALSE, sep="\t",
#                  col.names=c("K","CVerror"))
# print(cv)

# # Basic barplots of Q matrices for a chosen K (e.g., bestK)
# # Identify the file for bestK:
# qfile <- sprintf("8917.snp.filter.%s.Q", as.character(cv$K[which.min(cv$CVerror)]))
# qpath <- file.path(qdir, qfile)
# qlist_best <- pophelper::readQ(files=qpath)

# # Plot and save as PDF
# pdf("admixture_barplot_bestK.pdf", width=10, height=4)
# pophelper::plotQ(qlist_best, sortind="all", showsp=TRUE, grplab=NULL,
#                  imgoutput="pdf", exportplot=FALSE, splab=TRUE)
# dev.off()

# # Launch interactive app (explore multiple K interactively)
# # This opens a browser UI where you can reorder samples, export figures, etc.
# pophelperShiny::runPophelper(qdir=qdir)
# ------------------------------------------------------------

# =====================================================================
# Notes:
#   - Ensure sample order is consistent across K if you want comparable barplots.
#     You can provide a group label file to plotQ via 'grplab' for colored strata.
#   - ADMIXTURE can be sensitive to LD; consider SNP pruning beforehand.
#   - For reproducibility, document ADMIXTURE version and random seed (use --seed).
#   - pophelper accepts CLUMPP/STRUCTURE/BAPS formats as well; see ?readQ.
# =====================================================================
