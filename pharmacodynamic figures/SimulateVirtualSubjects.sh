#!/bin/sh
#$ -cwd
#$ -pe thread 1
#$ -j y
#$ -P CDERID0047
#$ -N SVS
#$ -l s_rt=12:00:00
#$ -R y
#$ -l h_vmem=2G
#$ -l h_rt=24:00:00
#$ -t 1
#$ -o NULL
source /projects/mikem/applications/R-4.0.2/set_env.sh


#Figure 3
Rscript simulateVirtualSubject.R -a "fentanyl"      -b "2.965"      -d "IN4" -e "chronic" -f 2001 -j 60 -k "yes"

#eFigure 1A
Rscript simulateVirtualSubject.R -a "fentanyl"      -b "1.625"      -d "IN4" -e "chronic" -f 2001 -j 60 -k "yes"

#eFigure 1B
Rscript simulateVirtualSubject.R -a "carfentanil"   -b "0.012"      -d "IN4" -e "chronic" -f 2001 -j 60 -k "yes"

#eFigure 1C
Rscript simulateVirtualSubject.R -a "carfentanil"   -b "0.02187"    -d "IN4" -e "chronic" -f 2001 -j 60 -k "yes"