#!/bin/bash
#SBATCH --time=24:00:00							# Set walltime
#SBATCH -J SVPRN								# Name the job as 'MPItest'
#SBATCH --account=CDERID0047
#SBATCH --output=output/logfiles/SVPRN_%j.out	# Write the standard output to file
###SBATCH --ntasks=2001							# Request N tasks
###SBATCH --nodes=1								# Request N nodes
###SBATCH --ntasks-per-node=1					# Request N tasks per node
###SBATCH --cpus-per-task=1						# Number of cores per task
#SBATCH --mem-per-cpu=2G						# Request 2GB RAM per core
#SBATCH --array=1-2001

cd $SLURM_SUBMIT_DIR
pwd                         # prints current working directory
date                        # prints the date and time

source /projects/mikem/applications/R-4.4.1/set_env.sh

#MUST CHANGE simulationTime TO 15*60*60

opioidDosingRoute="transmucosal"
opioidDose=16 #(mg) 
fractionOfBaselineVentilationForAntagonistAdministration=0.6
simulateRenarcotization="yes"

echo $opioidDosingRoute
echo $opioidDose
echo $fractionOfBaselineVentilationForAntagonistAdministration
echo $simulateRenarcotization

#IN 4 mg naloxone======================================================================================================================================================================================
Rscript simulateVirtualSubject.R	-c naloxone		-d IN4naloxone		-b "$opioidDose"	-f "$SLURM_ARRAY_TASK_ID"	-n "$simulateRenarcotization"	-s "$opioidDosingRoute"	-t "$fractionOfBaselineVentilationForAntagonistAdministration"
#======================================================================================================================================================================================IN 4 mg naloxone

#IN 3 mg nalemfene B==============================================================================================================================================================================
Rscript simulateVirtualSubject.R	-c nalmefene	-d IN3nalmefeneB	-b "$opioidDose"	-f "$SLURM_ARRAY_TASK_ID"	-n "$simulateRenarcotization"	-s "$opioidDosingRoute"	-t "$fractionOfBaselineVentilationForAntagonistAdministration"
#==============================================================================================================================================================================IN 3 mg nalemfene B

#IN 3 mg nalemfene A=============================================================================================================================================================================
Rscript simulateVirtualSubject.R	-c nalmefene	-d IN3nalmefeneA	-b "$opioidDose"	-f "$SLURM_ARRAY_TASK_ID"	-n "$simulateRenarcotization"	-s "$opioidDosingRoute"	-t "$fractionOfBaselineVentilationForAntagonistAdministration"
#=============================================================================================================================================================================IN 3 mg nalemfene A

#IN 3 mg nalmefeneC==============================================================================================================================================================================
Rscript simulateVirtualSubject.R	-c nalmefene	-d IN3nalmefeneC	-b "$opioidDose"	-f "$SLURM_ARRAY_TASK_ID"	-n "$simulateRenarcotization"	-s "$opioidDosingRoute"	-t "$fractionOfBaselineVentilationForAntagonistAdministration"
#==============================================================================================================================================================================IN 3 mg nalmefeneC