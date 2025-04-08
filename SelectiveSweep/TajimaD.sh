ls *.list|while read id;do echo vcftools --vcf 8917.snp.filter.maf0.01.int0.7.clean.beagle.vcf --keep $id --TajimaD 100000 --out $id ;done
