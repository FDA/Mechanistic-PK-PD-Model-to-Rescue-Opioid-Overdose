#!/bin/sh
#$ -cwd
#$ -pe thread 1
#$ -j y
#$ -P CDERID0047
#$ -N CPLRTM
#$ -l s_rt=24:00:00
#$ -R y
#$ -l h_vmem=2G
#$ -l h_rt=24:00:00
#$ -t 1-4
#$ -o NULL
source /projects/mikem/applications/R-4.0.2/set_env.sh


#Table 1, eTable 7
opioids=("fentanyl" "fentanyl" "carfentanil" "carfentanil")
doses=("1.625" "2.965" "0.012" "0.02187")

runIndex=$SGE_TASK_ID-1

opioid=${opioids[runIndex]}
dose=${doses[runIndex]}

echo $opioid
echo $dose

Rscript calculatePopulationLevelRTMetric.R  -a "$opioid"   -b "$dose"