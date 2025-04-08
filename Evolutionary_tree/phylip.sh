plink --bfile 8917.prune.prune.in --maf 0.05 --noweb --distance square '1-ibs' --out 8917.distance
perl phylip_pre.pl 8917.distance.mdist.id 8917.distance.mdist > 8917.distance.phy
phylip neighbor
#Further visualization on the iTOL website
