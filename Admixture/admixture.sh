cpulimit -l 400 -- admixture --cv 8917.snp.filter.bed 3 -j4 >> log.txt
cpulimit -l 400 -- admixture --cv 8917.snp.filter.bed 4 -j4 >> log.txt
cpulimit -l 400 -- admixture --cv 8917.snp.filter.bed 5 -j4 >> log.txt
cpulimit -l 400 -- admixture --cv 8917.snp.filter.bed 6 -j4 >> log.txt
cpulimit -l 400 -- admixture --cv 8917.snp.filter.bed 7 -j4 >> log.txt
#load library for use in R
#library(pophelperShiny)
#launch app
#runPophelper()
