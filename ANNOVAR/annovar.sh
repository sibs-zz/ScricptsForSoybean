gffread ZH13.gene.gff -o ZH13.gene.gff3
gff3ToGenePred -geneNameAttr=attr ZH13.gene.gff3 ZH13_refGene.txt
sed -i s/ZH13.//g ZH13.v2.fasta
perl ../retrieve_seq_from_fasta.pl --format refGene --seqfile ZH13.v2.fasta ZH13_refGene.txt --out ZH13_refGeneMrna.fa
grep -v \# ../../vcf/8917.snp.filter.vcf |awk '{print $1,$2,$2,$4,$5}'|awk '{if($1<10){print "Chr0"$1,$2,$3,$4,$5}else{print "Chr"$1,$2,$3,$4,$5}}'|sed s/\\s/\\t/g > annovar.avinput
perl table_annovar.pl annovar.avinput ZH13_db/ -buildver ZH13 -outfile SNPanno -protocol refGene -operation g
