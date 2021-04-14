#Quick script to sample from the effect size distributions
#args1: the summary stats
#args2: the snps to process (preclumped and pre-selected, etc)
#args3: the number of samplings to do
#args 4: the output director
#args 5: the plot dist check ,0 or 1
#Chekc github
if(FALSE)
{
  
  SS="/work-zfs/abattle4/lab_data/UKBB/GWAS_Neale/highly_heritable_traits_2/unzipped/21001_irnt.gwas.imputed_v3.both_sexes.tsv"
  SNPS="/work-zfs/abattle4/ashton/prs_dev/scratch/error_bounds_2/ss_sims/MESA/snp_list.pruned.0.3.txt"
  OUT="/work-zfs/abattle4/ashton/prs_dev/scratch/error_bounds_2/ss_sims/MESA/BMI/"
  args <-c (SS, SNPS, 100, OUT)
}
pacman::p_load(data.table, tidyr, dplyr, readr, ggplot2, magrittr, vroom)
args = commandArgs(trailingOnly=TRUE)
print("Reading in full summary stats...")

#all_snps <- fread(args[1]) #The full summary stats

all_snps <- vroom(args[1], delim = '\t')

#try with vroom, allegedly much faster
snp_list <- scan(args[2], what = character()) #the screened snps
n_runs <- as.numeric(args[3])
outdir <- as.character(args[4])
keep <- all_snps[all_snps$variant %in% snp_list,]
rm(all_snps)
print("Currently only accepting continuous phenotyhpes.")

sampleNorm <- function(row)
{
  t <- rnorm(n_runs, mean = as.numeric(row[12]), sd = as.numeric(row[13])) #For some reason had this on the wrong thing....
  return(t)
}

sampleWrite <- function(beta,snps, ref, alt, pval, n)
{
  #n is sim number  
  t <- data.frame("ID" = snps, "REF" =ref , "ALT" = alt, "beta" = beta, "pval" =pval )
  write_tsv(t, file = paste0(outdir,"sumstat_sim_", n, ".tsv"))
}
keep <- separate(keep, col = variant, into = c("chr", "pos", "REF", "ALT"),sep = ":", remove = FALSE)
out <- apply(keep, 1, sampleNorm)
print("Writing out the samples...")
sapply(1:nrow(out), function(x) sampleWrite(out[x,], keep$variant, keep$REF, keep$ALT, keep$pval, x))

#sanity test
if(args[5] == 1)
{
   means <- colSums(out)/100
  diffs <- means - keep$beta
  png(paste0(outdir, "/error_check.png"))
  plot(diffs, xlab = "SNP", ylab = "Beta^hat - mean(sample betas)")
  abline(h = 0, col = "red")    
  dev.off()
}
