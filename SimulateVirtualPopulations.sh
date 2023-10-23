#!/bin/bash
#SBATCH --time=24:00:00							# Set walltime
#SBATCH -J SVP									# Name the job as 'MPItest'
#SBATCH --account=CDERID0047
#SBATCH --output=output/logfiles/SVP_%j.out		# Write the standard output to file
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

###chronic adults
##medium doses===================================================================================================================
#IN 4 mg naloxone================================================================================================================
Rscript simulateVirtualSubject.R    -a "fentanyl"       -b "1.625"  -c "naloxone"   -d "IN4naloxone"				-f "$SLURM_ARRAY_TASK_ID"
Rscript simulateVirtualSubject.R    -a "carfentanil"    -b "0.012"  -c "naloxone"   -d "IN4naloxone"				-f "$SLURM_ARRAY_TASK_ID"
#================================================================================================================IN 4 mg naloxone

#IN 3 mg nalemfene B========================================================================================================
Rscript simulateVirtualSubject.R   -a "fentanyl"       -b "1.625"   -c "nalmefene"  -d "IN3nalmefeneB"		-f "$SLURM_ARRAY_TASK_ID"
Rscript simulateVirtualSubject.R   -a "carfentanil"    -b "0.012"   -c "nalmefene"  -d "IN3nalmefeneB"		-f "$SLURM_ARRAY_TASK_ID"
#========================================================================================================IN 3 mg nalemfene B

#IN 3 mg nalemfene A=======================================================================================================
Rscript simulateVirtualSubject.R   -a "fentanyl"       -b "1.625"   -c "nalmefene"  -d "IN3nalmefeneA"	-f "$SLURM_ARRAY_TASK_ID"
Rscript simulateVirtualSubject.R   -a "carfentanil"    -b "0.012"   -c "nalmefene"  -d "IN3nalmefeneA"	-f "$SLURM_ARRAY_TASK_ID"
#=======================================================================================================IN 3 mg nalemfene A

#IN 3 mg nalmefene C========================================================================================================
Rscript simulateVirtualSubject.R   -a "fentanyl"       -b "1.625"   -c "nalmefene"  -d "IN3nalmefeneC"				-f "$SLURM_ARRAY_TASK_ID"
Rscript simulateVirtualSubject.R   -a "carfentanil"    -b "0.012"   -c "nalmefene"  -d "IN3nalmefeneC"				-f "$SLURM_ARRAY_TASK_ID"
#========================================================================================================IN 3 mg nalmefene C
##===================================================================================================================Medium doses

##high doses=====================================================================================================================
#IN 4 mg naloxone================================================================================================================
Rscript simulateVirtualSubject.R   -a "fentanyl"       -b "2.965"   -c "naloxone"   -d "IN4naloxone"				-f "$SLURM_ARRAY_TASK_ID"
Rscript simulateVirtualSubject.R   -a "carfentanil"    -b "0.022"   -c "naloxone"   -d "IN4naloxone"				-f "$SLURM_ARRAY_TASK_ID"
#================================================================================================================IN 4 mg naloxone

#IN 3 mg nalemfene B========================================================================================================
Rscript simulateVirtualSubject.R   -a "fentanyl"       -b "2.965"   -c "nalmefene"  -d "IN3nalmefeneB"		-f "$SLURM_ARRAY_TASK_ID"
Rscript simulateVirtualSubject.R   -a "carfentanil"    -b "0.022"   -c "nalmefene"  -d "IN3nalmefeneB"		-f "$SLURM_ARRAY_TASK_ID"
#========================================================================================================IN 3 mg nalemfene B

#IN 3 mg nalemfene A=======================================================================================================
Rscript simulateVirtualSubject.R   -a "fentanyl"       -b "2.965"   -c "nalmefene"  -d "IN3nalmefeneA"	-f "$SLURM_ARRAY_TASK_ID"
Rscript simulateVirtualSubject.R   -a "carfentanil"    -b "0.022"   -c "nalmefene"  -d "IN3nalmefeneA"	-f "$SLURM_ARRAY_TASK_ID"
#=======================================================================================================IN 3 mg nalemfene A

#IN 3 mg nalmefene C========================================================================================================
Rscript simulateVirtualSubject.R   -a "fentanyl"       -b "2.965"   -c "nalmefene"  -d "IN3nalmefeneC"				-f "$SLURM_ARRAY_TASK_ID"
Rscript simulateVirtualSubject.R   -a "carfentanil"    -b "0.022"   -c "nalmefene"  -d "IN3nalmefeneC"				-f "$SLURM_ARRAY_TASK_ID"
#========================================================================================================IN 3 mg nalmefene C
##=====================================================================================================================high doses