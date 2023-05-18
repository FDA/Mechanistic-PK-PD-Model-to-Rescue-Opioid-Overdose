#!/bin/sh
#$ -cwd
#$ -pe thread 1
#$ -j y
#$ -P CDERID0047
#$ -N ForPlot
#$ -l s_rt=24:00:00
#$ -R y
#$ -l h_vmem=4G
#$ -l h_rt=24:00:00
#$ -t 1
#$ -o NULL
source /projects/mikem/applications/R-4.0.2/set_env.sh

#Figure 4B
Rscript forestplotDoseVariation.R -a fentanyl

#eFigure 2
Rscript forestplotDoseVariation.R -a carfentanil

#eFigure 3A
Rscript forestplotDelayVariation.R -a fentanyl

#eFigure 3B
Rscript forestplotDelayVariation.R -a carfentanil
