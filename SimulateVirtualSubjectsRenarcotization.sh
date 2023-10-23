#!/bin/bash
#SBATCH --time=24:00:00							# Set walltime
#SBATCH -J SVSRN								# Name the job as 'MPItest'
#SBATCH --account=CDERID0047
#SBATCH --output=output/logfiles/SVSRN_%j.out	# Write the standard output to file
###SBATCH --ntasks=14							# Request N tasks
###SBATCH --nodes=1								# Request N nodes
###SBATCH --ntasks-per-node=1					# Request N tasks per node
###SBATCH --cpus-per-task=1						# Number of cores per task
#SBATCH --mem-per-cpu=8G						# Request 2GB RAM per core
#SBATCH --array=1-4

cd $SLURM_SUBMIT_DIR
pwd                         # prints current working directory
date                        # prints the date and time

source /projects/mikem/applications/R-4.4.1/set_env.sh

opioidDosingRoute="transmucosal"
opioidDose=16 #(mg) 
fractionOfBaselineVentilationForAntagonistAdministration=0.6
antagonists=("nalmefene" "nalmefene" "nalmefene" "naloxone")
antagonistAdministrationRoutesAndDoses=("IN3nalmefeneB" "IN3nalmefeneA" "IN3nalmefeneC" "IN4naloxone")

runIndex=$SLURM_ARRAY_TASK_ID-1
antagonist=${antagonists[runIndex]}
antagonistAdministrationRouteAndDose=${antagonistAdministrationRoutesAndDoses[runIndex]}

echo $opioidDosingRoute
echo $opioidDose
echo $fractionOfBaselineVentilationForAntagonistAdministration
echo $antagonist
echo $antagonistAdministrationRouteAndDose

#nalmefene paper===============================================================================================================================================================================================
Rscript simulateVirtualSubject.R -b "$opioidDose" -c "$antagonist" -d "$antagonistAdministrationRouteAndDose" -k yes -n yes -s "$opioidDosingRoute" -t "$fractionOfBaselineVentilationForAntagonistAdministration"
#===============================================================================================================================================================================================nalmefene paper