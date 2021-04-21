# Simulation of buprenorphine clinical studies. 
This code combines the receptor binding model with PK models for buprenorphine and naloxone to simulate a clinical ventilation study. IV buprenorphine is described by a 3-compartment model whereas IV naloxone is described by a 2-compartment model. These models are combined with a linear transduction model linking fraction of buprenorphine-bound receptor to ventilation to simulate respiratory depression following buprenorphine administration and reversal of depression after naloxone administration. The primary model output is percent of baseline ventilation.

# Running the code 
This code uses the following R packages: This code uses the following R packages: deSolve (version 1.14), ggplot2 (version 2.2.0), FME (version 1.3.5)

Rscript Clinical_Comparison_Buprenorphine_IV_Naloxone_IV.R

This script requires clinical ventilation data as well as PKPD parameters for both buprenorphine and naloxone which can be found in (Data/). Figures are automatically saved in (figs/)

