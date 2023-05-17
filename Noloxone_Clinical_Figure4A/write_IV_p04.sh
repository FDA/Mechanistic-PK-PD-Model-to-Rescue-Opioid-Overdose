#!/bin/sh
#$ -cwd
#$ -pe thread 8
#$ -j y
#$ -P CDERID0047
#$ -N write
#$ -l s_rt=4:00:00
#$ -R y
#$ -l h_vmem=12G
#$ -l h_rt=4:00:00
#$ -t 1
#$ -o NULL

source /projects/mikem/applications/R-4.0.2/set_env.sh

Rscript Write_Avg_IV_p04mg.R

