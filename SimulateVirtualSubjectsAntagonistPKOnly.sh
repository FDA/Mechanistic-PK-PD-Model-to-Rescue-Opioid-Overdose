#!/bin/bash
#SBATCH --time=24:00:00							# Set walltime
#SBATCH -J SVSAPKO								# Name the job as 'MPItest'
#SBATCH --account=CDERID0047
#SBATCH --output=output/logfiles/SVSAPKO_%j.out	# Write the standard output to file
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

#IN 4 mg naloxone=================================================================================================
Rscript simulateVirtualSubject.R	-b "0"	-c "naloxone"	-d "IN4naloxone"				-k "noButOnlyAntagonistPK"
#=================================================================================================IN 4 mg naloxone

#IN 3 mg nalemfene B=========================================================================================
Rscript simulateVirtualSubject.R	-b "0"	-c "nalmefene"	-d "IN3nalmefeneB"		-k "noButOnlyAntagonistPK"
#=========================================================================================IN 3 mg nalemfene B

#IN 3 mg nalemfene A========================================================================================
Rscript simulateVirtualSubject.R	-b "0"	-c "nalmefene"	-d "IN3nalmefeneA"	-k "noButOnlyAntagonistPK"
#========================================================================================IN 3 mg nalemfene A

#IN 3 mg nalmefeneC=========================================================================================
Rscript simulateVirtualSubject.R	-b "0"	-c "nalmefene"	-d "IN3nalmefeneC"				-k "noButOnlyAntagonistPK"
#=========================================================================================IN 3 mg nalmefeneC