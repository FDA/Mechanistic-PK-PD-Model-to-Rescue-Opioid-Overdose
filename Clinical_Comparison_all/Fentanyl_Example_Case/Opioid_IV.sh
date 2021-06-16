#!/bin/sh
#$ -cwd
#$ -pe thread 2
#$ -j y
#$ -P CDERID0047
#$ -N Clincal_Compare
#$ -R y
#$ -l h_rt=5:00:00
#$ -l h_vmem=8G
#$ -t 1        #num. drugs(28) x WORKERPERDRUG(1000)
#$ -o /dev/null
ERR=$(((SGE_TASK_ID)))

PATIENT_CASE=(Naive)

IDX=$((SGE_TASK_ID-1))
PATIENT=${PATIENT_CASE[IDX]}

Rscript Opioid_IV_Fentanyl_Naloxone.R -p "$PATIENT"  >& logfiles/"$JOB_NAME"."$PATIENT".o"$JOB_ID"."$SGE_TASK_ID".txt

