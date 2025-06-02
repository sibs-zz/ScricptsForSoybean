#Only part was shown as an example
nohup vcftools --vcf 8917.snp.filter.maf0.01.int0.7.clean.beagle.vcf --weir-fst-pop zhongguo_all_cultivar.list --weir-fst-pop baxi_cultivar.list --out zhongguoallvsbaxi --fst-window-size 100000 --fst-window-step 10000 &

grep -v BIN zhongguoallvsbaxi.windowed.weir.fst|awk '{print $1,$2,$3,$5}' > zhongguoallvsbaxi.windowed.weir.fst.t
python zscore.py zhongguoallvsbaxi.windowed.weir.fst.t zhongguoallvsbaxi.windowed.weir.fst.t.zscore
awk '{if($5>=1.96) print $1,$2,$3}' zhongguoallvsbaxi.windowed.weir.fst.t.zscore  > zhongguoallvsbaxi.windowed.weir.fst.t.zscore.pos
awk '{if($1<10){print "Chr0"$1,$2,$3}else {print "Chr"$1,$2,$3}}' zhongguoallvsbaxi.windowed.weir.fst.t.zscore.pos > zhongguoallvsbaxi.windowed.weir.fst.t.zscore.pos.t
python GetGeneFromGFF.py ZH13.gene.gff zhongguoallvsbaxi.windowed.weir.fst.t.zscore.pos.t zhongguoallvsbaxi.windowed.weir.fst.t.zscore.pos.t.gene
awk '{print $9}' zhongguoallvsbaxi.windowed.weir.fst.t.zscore.pos.t.gene |grep -v attr|sed s/ID=//g|sed s/\;//g |sort -u > zhongguoallvsbaxi.windowed.weir.fst.t.zscore.pos.t.gene.clean
