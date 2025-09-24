# =====================================================================
#  Variant annotation workflow using ANNOVAR
#  Goal:
#    1) Prepare reference gene annotation (GFF → GFF3 → refGene format)
#    2) Extract mRNA reference sequences
#    3) Convert VCF variants to ANNOVAR input
#    4) Run ANNOVAR gene-based annotation
#
#  Requirements:
#    - gffread (https://github.com/gpertea/gffread)
#    - UCSC gff3ToGenePred (http://hgdownload.soe.ucsc.edu/admin/exe/)
#    - ANNOVAR (https://annovar.openbioinformatics.org)
#    - Custom genome FASTA (ZH13.v2.fasta) and annotation GFF (ZH13.gene.gff)
# =====================================================================

# --- Step 1: Convert GFF to GFF3 ---
# Some tools require strict GFF3 format.
gffread ZH13.gene.gff -o ZH13.gene.gff3

# --- Step 2: Convert GFF3 to refGene format ---
# Generate UCSC GenePred-style annotation file using attribute "attr" as gene name.
gff3ToGenePred -geneNameAttr=attr ZH13.gene.gff3 ZH13_refGene.txt

# --- Step 3: Clean FASTA sequence headers ---
# Remove the prefix "ZH13." from chromosome names for consistency.
sed -i 's/ZH13.//g' ZH13.v2.fasta

# --- Step 4: Extract mRNA reference sequences ---
# Use a custom Perl script provided by ANNOVAR package.
perl ../retrieve_seq_from_fasta.pl \
     --format refGene \
     --seqfile ZH13.v2.fasta \
     ZH13_refGene.txt \
     --out ZH13_refGeneMrna.fa

# --- Step 5: Convert VCF to ANNOVAR input format ---
# Keep only essential fields: chr, start, end, ref, alt.
# Format chromosomes consistently: Chr01..Chr20 instead of numeric.
grep -v "#" ../../vcf/8917.snp.filter.vcf \
  | awk '{print $1,$2,$2,$4,$5}' \
  | awk '{if($1<10){print "Chr0"$1,$2,$3,$4,$5}else{print "Chr"$1,$2,$3,$4,$5}}' \
  | sed 's/ /\t/g' > annovar.avinput

# --- Step 6: Run ANNOVAR gene-based annotation ---
# Apply gene-based annotations using prepared refGene database.
perl table_annovar.pl annovar.avinput ZH13_db/ \
     -buildver ZH13 \
     -outfile SNPanno \
     -protocol refGene \
     -operation g

# =====================================================================
# Outputs:
#   - ZH13_refGene.txt         : GenePred format annotation
#   - ZH13_refGeneMrna.fa      : Reference mRNA sequences
#   - annovar.avinput          : ANNOVAR input file
#   - SNPanno.*                : Annotated SNP results (e.g. SNPanno.refGene)
#
# Notes:
#   - Ensure ZH13_db/ contains properly formatted refGene database
#     (ZH13_refGene.txt, ZH13_refGeneMrna.fa, and index files).
#   - Adjust attribute field (-geneNameAttr) if your GFF differs.
#   - For additional annotations (e.g., conserved elements, functional predictions),
#     add more protocols in table_annovar.pl.
# =====================================================================
