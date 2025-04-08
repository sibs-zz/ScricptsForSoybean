#Run a year group as an example
cat meiguo_cultivar.list |awk '{print $1,"A"}'  > before1960.pop
cat before1960.list |awk '{print $1,"B"}'  >>  before1960.pop
cat zhongguo_soja.list |awk '{print $1,"C"}'  >> before1960.pop
cat outgroup.list |awk '{print $1,"D"}'  >> before1960.pop
python ABBABABAwindows.py -g merge.beagle.geno.gz -f phased -o before1960.pop.csv -w 100000 -m 100 -s 100000 -P1 A -P2 B -P3 C -O D -T 4  --popsFile before1960.pop
sed s/,/\\t/g 1960-1980.pop.csv |awk '{print $1,$2,$9,$10}'|grep -v ld |awk '{if($3<0){print $1"_"$2,$1,$2,"0"} else {print $1"_"$2,$1,$2,$4}}'|awk '{if($4>1){print $1,$2,$3,"0"}else{print $1,$2,$3,$4}}' |awk '{if($4<0){print $1,$2,$3,"0"}else{print $1,$2,$3,$4}}'> 1960-1980.pop.csv.fd
