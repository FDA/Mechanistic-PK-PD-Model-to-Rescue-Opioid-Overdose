#!/bin/bash
#SBATCH --time=24:00:00								# Set walltime
#SBATCH -J CPLMVMRN									# Name the job as 'MPItest'
#SBATCH --account=CDERID0047
#SBATCH --output=output/logfiles/CPLMVMRN_%j.out	# Write the standard output to file
###SBATCH --ntasks=5								# Request N tasks
###SBATCH --nodes=1									# Request N nodes
###SBATCH --ntasks-per-node=1						# Request N tasks per node
###SBATCH --cpus-per-task=1							# Number of cores per task
#SBATCH --mem-per-cpu=16G							# Request 2GB RAM per core
#SBATCH --array=1-5

cd $SLURM_SUBMIT_DIR
pwd                         # prints current working directory
date                        # prints the date and time

source /projects/mikem/applications/R-4.4.1/set_env.sh

opioidDosingRoute="transmucosal"
opioidDose=16 #(mg) 
fractionOfBaselineVentilationForAntagonistAdministration=0.6
simulateRenarcotization="yes"
PercentCI=50
inputDate=""
typicalSubjectInputDate=""
antagonists=("naloxone" "nalmefene" "nalmefene" "nalmefene" "nalmefene")
antagonistAdministrationRoutesAndDoses=("IN4naloxone" "IN3nalmefeneB" "IN3nalmefeneA" "IN3nalmefeneC" "OpioidOnly")

runIndex=$SLURM_ARRAY_TASK_ID-1
antagonist=${antagonists[runIndex]}
antagonistAdministrationRouteAndDose=${antagonistAdministrationRoutesAndDoses[runIndex]}

echo $antagonist
echo $antagonistAdministrationRouteAndDose

Rscript calculatePopulationLevelMVMetric.R -b "$opioidDose" -c "$antagonist" -d "$antagonistAdministrationRouteAndDose"	-r "$inputDate"	-s "$simulateRenarcotization" -t "$PercentCI" -u "$typicalSubjectInputDate" -v "$opioidDosingRoute" -w "$fractionOfBaselineVentilationForAntagonistAdministration"