plink --vcf 2100list.maf0.05.int0.9.recode.vcf --make-bed --output-missing-genotype 0  --double-id --out gwas
gcta64 --bfile 2100list.maf0.05.int0.9.recode --autosome --make-grm --out 2100list.maf0.05.int0.9.recode
nohup gcta64 --mlma --bfile 2100list.maf0.05.int0.9.recode --grm 2100list.maf0.05.int0.9.recode --pheno 2100bailizhong --out 2100bailizhong --thread-num 4 --qcovar 2100pca &
nohup gcta64 --mlma --bfile 2100list.maf0.05.int0.9.recode --grm 2100list.maf0.05.int0.9.recode --pheno 2100danbaizhihanliang --out 2100danbaizhihanliang --thread-num 4 --qcovar 2100pca &
