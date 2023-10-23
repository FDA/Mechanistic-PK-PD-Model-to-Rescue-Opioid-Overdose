To generate Figure 4A:

First run 5 scripts using following commands:

qsub write_IN_4.sh
qsub write_IN_8.sh
qsub write_IV_2.sh
qsub write_IV_p5.sh
qsub write_IV_2.sh

It will generate 5 output files in the directory "results"
Avg_IN_4mg.csv
Avg_IN_8mg.csv
Avg_IV_2mg.csv
Avg_IV_p5mg.csv
Avg_IV_p04mg.csv

After generating these output files run Figure4A.R to generate the figure.

