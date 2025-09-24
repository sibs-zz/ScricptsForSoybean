# =====================================================================
#  Haplotype Construction Workflow (Example Gene: E2)
#  Goal: Extract a target genomic region from soybean VCFs,
#        perform genotype imputation/phasing, and generate haplotypes.
#
#  Input:
#    - soybean.8917.Chr*.vcf.gz   : chromosome-level VCF files
#    - header                     : VCF header file (required for valid VCF formatting)
#    - haplo.py                   : custom Python script for haplotype analysis
#
#  Output:
#    - E2.vcf                     : extracted VCF region for gene E2
#    - E2_beagle.vcf.gz           : phased/imputed VCF after BEAGLE
#    - Haplotypes (from haplo.py) : haplotype statistics and sample grouping
#
#  Dependencies:
#    - tabix (htslib)
#    - beagle (genotype phasing)
#    - Python (with pysam, custom haplo.py)
# =====================================================================

# --- Step 1: Extract the target genomic region for gene E2 (Chr10:47816233–47837846)
ls ../../vcf/soybean.8917.Chr*vcf.gz | while read id; do
    tabix $id Chr10:47816233-47837846
done | sort -n -k2 > tmp

# --- Step 2: Reconstruct a valid VCF by combining header + extracted region
cat header tmp > E2.vcf

# --- Step 3: Run BEAGLE for genotype imputation and phasing
beagle gt=E2.vcf nthreads=4 out=E2_beagle

# --- Step 4: Index the BEAGLE output VCF
tabix -p vcf E2_beagle.vcf.gz

# --- Step 5: Generate haplotype information using custom Python script
python haplo.py E2_beagle.vcf.gz

# =====================================================================
# Notes:
#   - Replace genomic coordinates (Chr10:47816233-47837846) with the
#     target region of any gene of interest.
#   - Ensure "header" file contains the proper VCF header lines.
#   - Adjust `nthreads` parameter in BEAGLE to match available CPU cores.
#   - haplo.py will output unique haplotypes and their sample composition.
# =====================================================================
