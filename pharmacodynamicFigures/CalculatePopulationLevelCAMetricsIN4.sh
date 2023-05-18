#!/bin/sh
#$ -cwd
#$ -pe thread 1
#$ -j y
#$ -P CDERID0047
#$ -N CPLCAM
#$ -l s_rt=24:00:00
#$ -R y
#$ -l h_vmem=2G
#$ -l h_rt=24:00:00
#$ -t 1-20
#$ -o NULL
source /projects/mikem/applications/R-4.0.2/set_env.sh


#Table 1
opioids=("fentanyl" "fentanyl" "fentanyl" "fentanyl" "fentanyl" "fentanyl" "fentanyl" "fentanyl" "fentanyl" "fentanyl" "carfentanil" "carfentanil" "carfentanil" "carfentanil" "carfentanil" "carfentanil" "carfentanil" "carfentanil" "carfentanil" "carfentanil")
doses=("1.625" "1.625" "1.625" "1.625" "1.625" "2.965" "2.965" "2.965" "2.965" "2.965" "0.012" "0.012" "0.012" "0.012" "0.012" "0.02187" "0.02187" "0.02187" "0.02187" "0.02187")
delays=("30" "60" "180" "300" "600" "30" "60" "180" "300" "600" "30" "60" "180" "300" "600" "30" "60" "180" "300" "600" "30" "60" "180" "300" "600")

runIndex=$SGE_TASK_ID-1

opioid=${opioids[runIndex]}
dose=${doses[runIndex]}
delay=${delays[runIndex]}
b="_"
delayString="$b$delay$b"

echo $opioid
echo $dose
echo $delayString

Rscript calculatePopulationLevelCAMetric.R  -a "$opioid"   -b "$dose"  -d "IN4" -j "$delayString"