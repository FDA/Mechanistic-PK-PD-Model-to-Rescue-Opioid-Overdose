#!/bin/sh
#$ -cwd
#$ -pe thread 1
#$ -j y
#$ -P CDERID0047
#$ -N SVP
#$ -l s_rt=24:00:00
#$ -R y
#$ -l h_vmem=2G
#$ -l h_rt=24:00:00
#$ -t 1-2001
#$ -o NULL
source /projects/mikem/applications/R-4.0.2/set_env.sh


#Figure #
#1.625 mg fentanyl
Rscript simulateVirtualSubject.R -a "fentanyl"      -b "1.625"     -d "IVBoyer" -e "chronic" -f "$SGE_TASK_ID" -j 30
Rscript simulateVirtualSubject.R -a "fentanyl"      -b "1.625"     -d "IVBoyer" -e "chronic" -f "$SGE_TASK_ID" -j 60
Rscript simulateVirtualSubject.R -a "fentanyl"      -b "1.625"     -d "IVBoyer" -e "chronic" -f "$SGE_TASK_ID" -j 180
Rscript simulateVirtualSubject.R -a "fentanyl"      -b "1.625"     -d "IVBoyer" -e "chronic" -f "$SGE_TASK_ID" -j 300
Rscript simulateVirtualSubject.R -a "fentanyl"      -b "1.625"     -d "IVBoyer" -e "chronic" -f "$SGE_TASK_ID" -j 600

#2.965 mg fentanyl
Rscript simulateVirtualSubject.R -a "fentanyl"      -b "2.965"     -d "IVBoyer" -e "chronic" -f "$SGE_TASK_ID" -j 30
Rscript simulateVirtualSubject.R -a "fentanyl"      -b "2.965"     -d "IVBoyer" -e "chronic" -f "$SGE_TASK_ID" -j 60
Rscript simulateVirtualSubject.R -a "fentanyl"      -b "2.965"     -d "IVBoyer" -e "chronic" -f "$SGE_TASK_ID" -j 180
Rscript simulateVirtualSubject.R -a "fentanyl"      -b "2.965"     -d "IVBoyer" -e "chronic" -f "$SGE_TASK_ID" -j 300
Rscript simulateVirtualSubject.R -a "fentanyl"      -b "2.965"     -d "IVBoyer" -e "chronic" -f "$SGE_TASK_ID" -j 600

#0.012 mg carfentanil
Rscript simulateVirtualSubject.R -a "carfentanil"      -b "0.012"     -d "IVBoyer" -e "chronic" -f "$SGE_TASK_ID" -j 30
Rscript simulateVirtualSubject.R -a "carfentanil"      -b "0.012"     -d "IVBoyer" -e "chronic" -f "$SGE_TASK_ID" -j 60
Rscript simulateVirtualSubject.R -a "carfentanil"      -b "0.012"     -d "IVBoyer" -e "chronic" -f "$SGE_TASK_ID" -j 180
Rscript simulateVirtualSubject.R -a "carfentanil"      -b "0.012"     -d "IVBoyer" -e "chronic" -f "$SGE_TASK_ID" -j 300
Rscript simulateVirtualSubject.R -a "carfentanil"      -b "0.012"     -d "IVBoyer" -e "chronic" -f "$SGE_TASK_ID" -j 600

#0.02187 mg carfentanil
Rscript simulateVirtualSubject.R -a "carfentanil"      -b "0.02187"     -d "IVBoyer" -e "chronic" -f "$SGE_TASK_ID" -j 30
Rscript simulateVirtualSubject.R -a "carfentanil"      -b "0.02187"     -d "IVBoyer" -e "chronic" -f "$SGE_TASK_ID" -j 60
Rscript simulateVirtualSubject.R -a "carfentanil"      -b "0.02187"     -d "IVBoyer" -e "chronic" -f "$SGE_TASK_ID" -j 180
Rscript simulateVirtualSubject.R -a "carfentanil"      -b "0.02187"     -d "IVBoyer" -e "chronic" -f "$SGE_TASK_ID" -j 300
Rscript simulateVirtualSubject.R -a "carfentanil"      -b "0.02187"     -d "IVBoyer" -e "chronic" -f "$SGE_TASK_ID" -j 600