#!/bin/bash
#SBATCH --time=24:00:00							# Set walltime
#SBATCH -J PVSRN								# Name the job as 'MPItest'
#SBATCH --account=CDERID0047
#SBATCH --output=output/logfiles/PVSRN_%j.out	# Write the standard output to file
###SBATCH --ntasks=1							# Request N tasks
###SBATCH --nodes=1								# Request N nodes
###SBATCH --ntasks-per-node=1					# Request N tasks per node
###SBATCH --cpus-per-task=1						# Number of cores per task
#SBATCH --mem-per-cpu=2G						# Request 2GB RAM per core
#SBATCH --array=1

cd $SLURM_SUBMIT_DIR
pwd                         # prints current working directory
date                        # prints the date and time

source /projects/mikem/applications/R-4.4.1/set_env.sh

opioidDosingRoute="transmucosal"
opioidDose=16 #(mg) 
fractionOfBaselineVentilationForAntagonistAdministration=0.6

echo $opioidDosingRoute
echo $opioidDose
echo $fractionOfBaselineVentilationForAntagonistAdministration

Rscript plottingRenarcotization4Cases.R -b "$opioidDose" -s "$opioidDosingRoute" -t "$fractionOfBaselineVentilationForAntagonistAdministration"
Rscript plottingRenarcotization4CasesAPC.R -b "$opioidDose" -s "$opioidDosingRoute" -t "$fractionOfBaselineVentilationForAntagonistAdministration"