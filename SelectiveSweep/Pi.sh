ls *list|while read id;do echo nohup vcftools --vcf 8917.snp.filter.maf0.01.int0.7.clean.beagle.vcf --keep $id --window-pi 100000 --window-pi-step 100000 --out $id \&;done  > run.sh

grep -v BIN soja_list.windowed.pi | awk '{print $1"_"$2"_"$3}'|sort > 1
grep -v BIN heidoulist.windowed.pi | awk '{print $1"_"$2"_"$3}'|sort > 2
comm -12 1 2 > com.pos
cat soja_list.windowed.pi |awk '{print $1"_"$2"_"$3,$0}' > 1
cat heidoulist.windowed.pi |awk '{print $1"_"$2"_"$3,$0}' > 2
cat com.pos|while read id;do grep -w $id 1;done > 11
cat com.pos|while read id;do grep -w $id 2;done > 22
paste 11 22|awk '{print $2,$3,$4,$6,$12,$6/$12}' > soja_vs_heidou.piratio
grep -v BIN soja_vs_heidou.piratio |sort  -k1,1n -k2,2n |awk '{print $1,$2,$3,$6}' > soja_vs_heidou.piratio.in
python zscore.py soja_vs_heidou.piratio.in soja_vs_heidou.piratio.in.zscore
awk '{if($5>=1.645) print $1,$2,$3}' soja_vs_heidou.piratio.in.zscore > soja_vs_heidou.piratio.in.zscore.pos
awk '{if($1<10){print "Chr0"$1,$2,$3}else {print "Chr"$1,$2,$3}}' soja_vs_heidou.piratio.in.zscore.pos > soja_vs_heidou.piratio.in.zscore.pos.t
python GetGeneFromGFF.py ZH13.gene.gff soja_vs_heidou.piratio.in.zscore.pos.t soja_vs_heidou.piratio.in.zscore.pos.t.gene
awk '{print $9}' soja_vs_heidou.piratio.in.zscore.pos.t.gene |grep -v attr|sed s/ID=//g|sed s/\;//g |sort -u > soja_vs_heidou.piratio.in.zscore.pos.t.gene.clean
