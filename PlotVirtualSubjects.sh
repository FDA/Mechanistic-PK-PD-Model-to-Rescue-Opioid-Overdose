#!/bin/bash
#SBATCH --time=24:00:00						# Set walltime
#SBATCH -J PVS								# Name the job as 'MPItest'
#SBATCH --account=CDERID0047
#SBATCH --output=output/logfiles/PVS_%j.out	# Write the standard output to file
###SBATCH --ntasks=4						# Request N tasks
###SBATCH --nodes=1							# Request N nodes
###SBATCH --ntasks-per-node=1				# Request N tasks per node
###SBATCH --cpus-per-task=1					# Number of cores per task
#SBATCH --mem-per-cpu=2G					# Request 2GB RAM per core
#SBATCH --array=1-4

cd $SLURM_SUBMIT_DIR
pwd                         # prints current working directory
date                        # prints the date and time

source /projects/mikem/applications/R-4.4.1/set_env.sh

opioids=("fentanyl" "carfentanil" "fentanyl" "carfentanil")
doses=("1.625" "0.012" "2.965" "0.022")
inputDate=""

runIndex=$SLURM_ARRAY_TASK_ID-1
opioid=${opioids[runIndex]}
dose=${doses[runIndex]}

Rscript plottingVirtualSubject4Cases.R  -a "$opioid"   -b "$dose"	-r "$inputDate" -s "MV"
Rscript plottingVirtualSubject4Cases.R  -a "$opioid"   -b "$dose"	-r "$inputDate" -s "AOS"
Rscript plottingVirtualSubject4Cases.R  -a "$opioid"   -b "$dose"	-r "$inputDate" -s "BOPP"
Rscript plottingVirtualSubject4Cases.R  -a "$opioid"   -b "$dose"	-r "$inputDate" -s "CO"