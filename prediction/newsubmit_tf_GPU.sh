#!/bin/sh
#$ -S /bin/bash
#$ -P CDERID0047
#$ -cwd
#$ -j y
#$ -l gpus=1                    # 1 GPU required (per thread!)
#$ -l ncores=1                    
#$ -N LSTM_New
#$ -o LOGS/
#$ -l h_rt=48:00:00
#$ -l h_vmem=100G

echo "==== start of job $JOB_NAME ($JOB_ID) at: " `date` " on host " `hostname`
echo

echo check for gpu: nvidia-smi output:
nvidia-smi
echo

# Get start of job information
START_TIME=`date +%s`

/home/lizhi/setup/anaconda3/bin/python simpleblock_mirrormodel_prediction.py


# Get end of job information
EXIT_STATUS=$?
END_TIME=`date +%s`
