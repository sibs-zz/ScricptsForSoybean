sh vcf2treemix.sh heidou_990w.recode.vcf 3780.clust 
#Run a repetition as an example
FILE="heidou_990w.recode"
for i in {1..15}
do
         treemix -i ${FILE}.treemix.frq.gz -m $i -o ${FILE}.$i.rep1 -bootstrap 100 -k 10000 -noss > treemix_${i}_log &
done
