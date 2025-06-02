#Only part was shown as an example
./raisd-master/bin/release/RAiSD -n baxi_cultivar_990w.list -I 8917.snp.filter.maf0.01.int0.7.clean.beagle.vcf -R -A 0.95 -S baxi_cultivar.list -f

awk '{printf "%.3f %.3f %.3f\n", $2,$3,$7}' RAiSD_Report.baxi_cultivar_990w.list.1 |awk '{print 1,$0}' > RAiSD_Report.baxi_cultivar_990w.list.all
awk '{printf "%.3f %.3f %.3f\n", $2,$3,$7}' RAiSD_Report.baxi_cultivar_990w.list.2 |awk '{print 2,$0}' >> RAiSD_Report.baxi_cultivar_990w.list.all
awk '{printf "%.3f %.3f %.3f\n", $2,$3,$7}' RAiSD_Report.baxi_cultivar_990w.list.3 |awk '{print 3,$0}' >> RAiSD_Report.baxi_cultivar_990w.list.all
awk '{printf "%.3f %.3f %.3f\n", $2,$3,$7}' RAiSD_Report.baxi_cultivar_990w.list.4 |awk '{print 4,$0}' >> RAiSD_Report.baxi_cultivar_990w.list.all
awk '{printf "%.3f %.3f %.3f\n", $2,$3,$7}' RAiSD_Report.baxi_cultivar_990w.list.5 |awk '{print 5,$0}' >> RAiSD_Report.baxi_cultivar_990w.list.all
awk '{printf "%.3f %.3f %.3f\n", $2,$3,$7}' RAiSD_Report.baxi_cultivar_990w.list.6 |awk '{print 6,$0}' >> RAiSD_Report.baxi_cultivar_990w.list.all
awk '{printf "%.3f %.3f %.3f\n", $2,$3,$7}' RAiSD_Report.baxi_cultivar_990w.list.7 |awk '{print 7,$0}' >> RAiSD_Report.baxi_cultivar_990w.list.all
awk '{printf "%.3f %.3f %.3f\n", $2,$3,$7}' RAiSD_Report.baxi_cultivar_990w.list.8 |awk '{print 8,$0}' >> RAiSD_Report.baxi_cultivar_990w.list.all
awk '{printf "%.3f %.3f %.3f\n", $2,$3,$7}' RAiSD_Report.baxi_cultivar_990w.list.9 |awk '{print 9,$0}' >> RAiSD_Report.baxi_cultivar_990w.list.all
awk '{printf "%.3f %.3f %.3f\n", $2,$3,$7}' RAiSD_Report.baxi_cultivar_990w.list.10 |awk '{print 10,$0}' >> RAiSD_Report.baxi_cultivar_990w.list.all
awk '{printf "%.3f %.3f %.3f\n", $2,$3,$7}' RAiSD_Report.baxi_cultivar_990w.list.11 |awk '{print 11,$0}' >> RAiSD_Report.baxi_cultivar_990w.list.all
awk '{printf "%.3f %.3f %.3f\n", $2,$3,$7}' RAiSD_Report.baxi_cultivar_990w.list.12 |awk '{print 12,$0}' >> RAiSD_Report.baxi_cultivar_990w.list.all
awk '{printf "%.3f %.3f %.3f\n", $2,$3,$7}' RAiSD_Report.baxi_cultivar_990w.list.13 |awk '{print 13,$0}' >> RAiSD_Report.baxi_cultivar_990w.list.all
awk '{printf "%.3f %.3f %.3f\n", $2,$3,$7}' RAiSD_Report.baxi_cultivar_990w.list.14 |awk '{print 14,$0}' >> RAiSD_Report.baxi_cultivar_990w.list.all
awk '{printf "%.3f %.3f %.3f\n", $2,$3,$7}' RAiSD_Report.baxi_cultivar_990w.list.15 |awk '{print 15,$0}' >> RAiSD_Report.baxi_cultivar_990w.list.all
awk '{printf "%.3f %.3f %.3f\n", $2,$3,$7}' RAiSD_Report.baxi_cultivar_990w.list.16 |awk '{print 16,$0}' >> RAiSD_Report.baxi_cultivar_990w.list.all
awk '{printf "%.3f %.3f %.3f\n", $2,$3,$7}' RAiSD_Report.baxi_cultivar_990w.list.17 |awk '{print 17,$0}' >> RAiSD_Report.baxi_cultivar_990w.list.all
awk '{printf "%.3f %.3f %.3f\n", $2,$3,$7}' RAiSD_Report.baxi_cultivar_990w.list.18 |awk '{print 18,$0}' >> RAiSD_Report.baxi_cultivar_990w.list.all
awk '{printf "%.3f %.3f %.3f\n", $2,$3,$7}' RAiSD_Report.baxi_cultivar_990w.list.19 |awk '{print 19,$0}' >> RAiSD_Report.baxi_cultivar_990w.list.all
awk '{printf "%.3f %.3f %.3f\n", $2,$3,$7}' RAiSD_Report.baxi_cultivar_990w.list.20 |awk '{print 20,$0}' >> RAiSD_Report.baxi_cultivar_990w.list.all

python zscore.py RAiSD_Report.baxi_cultivar_990w.list.all RAiSD_Report.baxi_cultivar_990w.list.all.zscore
awk '{if($5>=1.96) print $1,$2,$3}' RAiSD_Report.baxi_cultivar_990w.list.all.zscore > RAiSD_Report.baxi_cultivar_990w.list.all.zscore.pos
awk '{if($1<10){print "Chr0"$1,$2,$3}else {print "Chr"$1,$2,$3}}' RAiSD_Report.baxi_cultivar_990w.list.all.zscore.pos > RAiSD_Report.baxi_cultivar_990w.list.all.zscore.pos.t
python GetGeneFromGFF.py ZH13.gene.gff RAiSD_Report.baxi_cultivar_990w.list.all.zscore.pos.t RAiSD_Report.baxi_cultivar_990w.list.all.zscore.pos.t.gene
awk '{print $9}' RAiSD_Report.baxi_cultivar_990w.list.all.zscore.pos.t.gene |grep -v attr|sed s/ID=//g|sed s/\;//g |sort -u > RAiSD_Report.baxi_cultivar_990w.list.all.zscore.pos.t.gene.clean
