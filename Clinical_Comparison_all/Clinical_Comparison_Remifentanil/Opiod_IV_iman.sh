#!/bin/sh
#$ -cwd
#$ -pe thread 1
#$ -j y
#$ -P CDERID0047
#$ -N Chronic
#$ -R y
#$ -l h_rt=5:00:00
#$ -l h_vmem=8G
#$ -t 1        #num. drugs(28) x WORKERPERDRUG(1000)
#$ -o /dev/null
ERR=$(((SGE_TASK_ID)))

Rscript IV_opiod.R  >& logfiles/"$JOB_NAME".o"$JOB_ID"."$SGE_TASK_ID".txt

