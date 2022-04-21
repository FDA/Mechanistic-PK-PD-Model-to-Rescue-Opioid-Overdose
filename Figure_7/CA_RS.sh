#!/bin/sh
#$ -cwd
#$ -pe thread 1
#$ -j y
#$ -P CDERID0047
#$ -N Random_Sampling
#$ -l s_rt=4:00:00
#$ -R y
#$ -l h_vmem=8G
#$ -l h_rt=4:00:00
#$ -t 1-8
#$ -o NULL


#source /projects/mikem/applications/R-4.0.2/set_env.sh

Rscript Randome_population_calcu_CA_Dose.R -t "$SGE_TASK_ID" #>& logfiles/"$JOB_NAME".o3"$JOB_ID"."$SGE_TASK_ID".txt
