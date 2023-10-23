#!/bin/bash
#SBATCH --time=24:00:00							# Set walltime
#SBATCH -J SVS									# Name the job as 'MPItest'
#SBATCH --account=CDERID0047
#SBATCH --output=output/logfiles/SVS_%j.out		# Write the standard output to file
###SBATCH --ntasks=16							# Request N tasks
###SBATCH --nodes=1								# Request N nodes
###SBATCH --ntasks-per-node=1					# Request N tasks per node
###SBATCH --cpus-per-task=1						# Number of cores per task
#SBATCH --mem-per-cpu=2G						# Request 2GB RAM per core
#SBATCH --array=1-16

cd $SLURM_SUBMIT_DIR
pwd                         # prints current working directory
date                        # prints the date and time

source /projects/mikem/applications/R-4.4.1/set_env.sh

opioids=("fentanyl" "carfentanil" "fentanyl" "carfentanil" "fentanyl" "carfentanil" "fentanyl" "carfentanil" "fentanyl" "carfentanil" "fentanyl" "carfentanil" "fentanyl" "carfentanil" "fentanyl" "carfentanil")
doses=("1.625" "0.012" "1.625" "0.012" "1.625" "0.012" "1.625" "0.012" "2.965" "0.022" "2.965" "0.022" "2.965" "0.022" "2.965" "0.022")
antagonists=("naloxone" "naloxone" "nalmefene" "nalmefene" "nalmefene" "nalmefene" "nalmefene" "nalmefene" "naloxone" "naloxone" "nalmefene" "nalmefene" "nalmefene" "nalmefene" "nalmefene" "nalmefene")
antagonistAdministrationRoutesAndDoses=("IN4naloxone" "IN4naloxone" "IN3nalmefeneB" "IN3nalmefeneB" "IN3nalmefeneA" "IN3nalmefeneA" "IN3nalmefeneC" "IN3nalmefeneC" "IN4naloxone" "IN4naloxone" "IN3nalmefeneB" "IN3nalmefeneB" "IN3nalmefeneA" "IN3nalmefeneA" "IN3nalmefeneC" "IN3nalmefeneC")

runIndex=$SLURM_ARRAY_TASK_ID-1
opioid=${opioids[runIndex]}
dose=${doses[runIndex]}
antagonist=${antagonists[runIndex]}
antagonistAdministrationRouteAndDose=${antagonistAdministrationRoutesAndDoses[runIndex]}

Rscript simulateVirtualSubject.R  -a "$opioid"   -b "$dose"  -c "$antagonist" -d "$antagonistAdministrationRouteAndDose"	-k "yes"