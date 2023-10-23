#!/bin/bash
#SBATCH --time=24:00:00							# Set walltime
#SBATCH -J MOPC									# Name the job as 'MPItest'
#SBATCH --account=CDERID0047
#SBATCH --output=output/logfiles/MOPC_%j.out	# Write the standard output to file
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
opioidDose=1.6 #(mg)
fractionOfBaselineVentilationForAntagonistAdministration=1
antagonist="nalmefene"
antagonistAdministrationRouteAndDose="IN3nalmefeneB"

runIndex=$SLURM_ARRAY_TASK_ID-1

echo $opioidDosingRoute
echo $opioidDose
echo $fractionOfBaselineVentilationForAntagonistAdministration
echo $antagonist
echo $antagonistAdministrationRouteAndDose

#matching opioid infusion plasma concentration=================================================================================================================================================================
Rscript simulateVirtualSubject.R -b "$opioidDose" -c "$antagonist" -d "$antagonistAdministrationRouteAndDose" -k yes -n yes -s "$opioidDosingRoute" -t "$fractionOfBaselineVentilationForAntagonistAdministration"

Rscript plottingRenarcotizationPlasmaConcentration.R -b "$opioidDose" -s "$opioidDosingRoute" -t "$fractionOfBaselineVentilationForAntagonistAdministration"
#=================================================================================================================================================================matching opioid infusion plasma concentration