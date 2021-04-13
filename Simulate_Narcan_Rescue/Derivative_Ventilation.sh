#!/bin/sh
#$ -cwd
#$ -pe thread 8
#$ -j y
#$ -P CDERID0047
#$ -N Ventilation
#$ -l s_rt=24:00:00
#$ -R y
#$ -l h_rt=24:00:00
#$ -t 1
#$ -o logfiles


#DRUGNAMES=(Fentanyl_A Carfentanil)
DRUGNAMES=(Fentanyl_A) 
#MolarMass=(336.4 394.52)
MolarMass=(336.4)

IDX=$((SGE_TASK_ID-1))
DRUG=${DRUGNAMES[IDX]}
Mmass=${MolarMass[IDX]}


Rscript simulate_Ventilation_NARCAN.R -d "$DRUG" -m "$Mmass" >& logfiles/"$JOB_NAME".o"$JOB_ID"."$SGE_TASK_ID"


