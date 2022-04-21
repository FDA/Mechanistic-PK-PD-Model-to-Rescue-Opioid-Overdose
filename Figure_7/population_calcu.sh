#!/bin/sh
#$ -cwd
#$ -pe thread 1
#$ -j y
#$ -P CDERID0047
#$ -N Simulate
#$ -l s_rt=24:00:00
#$ -R y
#$ -l h_vmem=2G
#$ -l h_rt=24:00:00
#$ -t 1
#$ -o NULL


Rscript population_calcu_CA_Dose.R -t "$SGE_TASK_ID" >& logfiles/"$JOB_NAME".o1"$JOB_ID"."$SGE_TASK_ID".txt