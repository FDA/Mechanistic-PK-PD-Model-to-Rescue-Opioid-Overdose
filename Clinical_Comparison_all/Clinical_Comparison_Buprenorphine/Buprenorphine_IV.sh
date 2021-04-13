#!/bin/sh
#$ -cwd
#$ -pe thread 8
#$ -j y
#$ -P CDERID0047
#$ -N Buprenorphine_IV
#$ -l s_rt=24:00:00
#$ -R y
#$ -l h_rt=24:00:00
#$ -t 1
#$ -o logfiles


Rscript Clinical_Comparison_Buprenorphine_IV_Naloxone_IV.R  >& logfiles/"$JOB_NAME".o"$JOB_ID"."$SGE_TASK_ID"

