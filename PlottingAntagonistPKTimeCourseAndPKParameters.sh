#!/bin/bash
#SBATCH --time=24:00:00								# Set walltime
#SBATCH -J PAPKTCPKP								# Name the job as 'MPItest'
#SBATCH --account=CDERID0047
#SBATCH --output=output/logfiles/PAPKTCPKP_%j.out	# Write the standard output to file
###SBATCH --ntasks=4								# Request N tasks
###SBATCH --nodes=1									# Request N nodes
###SBATCH --ntasks-per-node=1						# Request N tasks per node
###SBATCH --cpus-per-task=1							# Number of cores per task
#SBATCH --mem-per-cpu=16G							# Request 2GB RAM per core
#SBATCH --array=1-4

cd $SLURM_SUBMIT_DIR
pwd                         # prints current working directory
date                        # prints the date and time

source /projects/mikem/applications/R-4.4.1/set_env.sh

antagonists=("naloxone" "nalmefene" "nalmefene" "nalmefene")
antagonistAdministrationRoutesAndDoses=("IN4naloxone" "IN3nalmefeneB" "IN3nalmefeneA" "IN3nalmefeneC")
PercentCIs=("95" "95" "95" "95")
PlotForRenarcotizations=("no" "no" "no" "no")

inputDate=""
typicalSubjectInputDate=""
runIndex=$SLURM_ARRAY_TASK_ID-1
antagonist=${antagonists[runIndex]}
antagonistAdministrationRouteAndDose=${antagonistAdministrationRoutesAndDoses[runIndex]}
PercentCI=${PercentCIs[runIndex]}
PlotForRenarcotization=${PlotForRenarcotizations[runIndex]}

echo $antagonist
echo $antagonistAdministrationRouteAndDose
echo $PercentCI
echo $PlotForRenarcotization

Rscript plottingAntagonistPKTimeCourseAndPKParameters.R	-b "0"	-c "$antagonist"	-d "$antagonistAdministrationRouteAndDose"	-n "$PlotForRenarcotization" -r "$inputDate"	-s "$PercentCI"	-t "$typicalSubjectInputDate"