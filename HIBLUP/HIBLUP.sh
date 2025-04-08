./hiblup --make-xrm --bfile ../8105.990w --add --dom --out 8105.990w.gs
hiblup --single-trait --pheno 8105pheno --pheno-pos 5 --qcovar 2,3,4 --pop-class ../8105pop --xrm ../8105.990w.gs.GA,../8105.990w.gs.GD --add --dom --threads 8 --out 2100zongdanbaiyouzhi
cat order |while read id;do grep -w $id 2100zongdanbaiyouzhi.rand ;done |awk '{print $1,$1,$2+$3}' > 2100zongdanbaiyouzhi.rand.pheno
gcta64 --mlma --bfile ../../gwas --grm ../../gwas --keep ../2100list --pheno 2100zongdanbaiyouzhi.rand.pheno --out 2100zongdanbaiyouzhi.rand.pheno --thread-num 4 --qcovar ../8105pca
