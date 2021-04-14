# load modules
shell.prefix("module load gcc/5.5.0; module load R;")
# configurations
#configfile: "config/config.yaml"
niter=100
rule build_sim:
    input:
       snps = "ss_sims/{cohort}/snp_list.pruned.0.3.txt",
       sum_stats = "/work-zfs/abattle4/lab_data/UKBB/GWAS_Neale/highly_heritable_traits_2/unzipped/21001_irnt.gwas.imputed_v3.both_sexes.tsv"
    output:
        #directory("ss_sims/{cohort}/{trait}/)
        expand("ss_sims/{{cohort}}/{{trait}}/sumstat_sim_{i}.tsv", i = list(range(1,niter + 1)))
    params:
        "ss_sims/{cohort}/{trait}/"
    shell:
        """
        Rscript src/buildSims.R {input.sum_stats} {input.snps} 100 {output} 1
        """

rule calc_prs:
    input:
        ss = "ss_sims/{cohort}/{trait}/sumstat_sim_{i}.tsv",
        snps = "ss_sims/{cohort}/snp_list.pruned.0.3.txt"
    output:
        "prs_runs/{cohort}/{trait}/{trait}.sim_run{i}/full_prs.scores.tsv"
    params:
        source_dir = "/work-zfs/abattle4/ashton/prs_dev/analysis_results/MESA_race1/bmi_mesa_plink2",
        out_suff = "prs_runs/{cohort}/{trait}/{trait}.sim_run{i}/"

    shell:
        """
        ml python/3.7-anaconda
        mkdir -p prs_runs/{wildcards.cohort}/{wildcards.trait}/{wildcards.trait}.sim_run{wildcards.i}
        python /work-zfs/abattle4/ashton/prs_dev/prs_tools/calc_prs.py  -snps {params.source_dir}/new_plink  -ss {input.ss} -o {params.out_suff} -pv 2 --ss_format DEFAULT --preprocessing_done --prefiltered_ss --no_na --select_vars {input.snps} --inverted_snp_encoding --reset_ids --plink_snp_matrix {params.source_dir}/mat_form_tmp --keep_matrix
        """
