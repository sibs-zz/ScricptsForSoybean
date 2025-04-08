plink --vcf 8917.snp.filter.vcf --indep-pairwise 50 10 0.2 --out 8917.prune --double-id
plink --vcf 8917.snp.filter.vcf --make-bed --extract 8917.prune.prune.in --out 8917.prune.prune.in --double-id
gcta64 --bfile 8917.prune.prune.in --make-grm --autosome --out 8917.prune
gcta64 --grm 8917.prune --pca 10 --out 8917
