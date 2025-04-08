#Show a gene as an example
ls ../../vcf/soybean.8917.Chr*vcf.gz|while read id;do tabix $id Chr10:47816233-47837846;done |sort -n -k2 > tmp
cat header tmp > E2.vcf
beagle gt=E2.vcf nthreads=4 out=E2_beagle
tabix -p vcf E2_beagle.vcf.gz
python haplo.py E2_beagle.vcf.gz
