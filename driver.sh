#!/bin/bash

ml gcc/5.5.0
ml R

SNPS="ss_sims/MESA/snp_list.pruned.0.3.txt"
#BMI
#SS="/work-zfs/abattle4/lab_data/UKBB/GWAS_Neale/highly_heritable_traits_2/unzipped/21001_irnt.gwas.imputed_v3.both_sexes.tsv"
#OUT="ss_sims/MESA/BMI/"
#Rscript src/buildSims.R $SS $SNPS 100 $OUT 0
#LDL
#SS="/work-zfs/abattle4/lab_data/UKBB/GWAS_Neale/30780_irnt.gwas.imputed_v3.both_sexes.tsv"
#OUT="ss_sims/MESA/LDL/"
#Rscript src/buildSims.R $SS $SNPS 100 $OUT 0

#HDL
SS="/work-zfs/abattle4/lab_data/UKBB/GWAS_Neale/30760_irnt.gwas.imputed_v3.both_sexes.tsv"
OUT="ss_sims/MESA/HDL/"
Rscript src/buildSims.R $SS $SNPS 100 $OUT 1

