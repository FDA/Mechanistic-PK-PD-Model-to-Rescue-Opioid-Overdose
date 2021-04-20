# Mechanistic-PK-PD-Model-to-Rescue-Opiod-Overdose

R code used to validate Mechansitic PK-PD Model of Opioid Overdose through simulation of clinical ventilation trials

# Authors

John Mann, Mohammadreza Samieegohar, Xiaomei Han, Anik Chaturbedi, Zhihua Li

# Requirements

This code was developed with R version 3.3 and uses the following packages:

* optparse (version 1.4.4)
* ggplot2 (version 2.2.0)
* deSolve (version 1.14)
* gridExtra (version 2.2.1)

# Clinical Comparison

Clinical_Comparison_all/ contains code to validate the PK-PD model of opioid induced respiratory depression through clinical prediction. Clinical comparisons were conducted with naive and chronic fentanyl exposure (Clinical_Comparison_Fentanyl/), remifentanil (Clinical_Comparison_Remifentanil/) and buprenorphine with naloxone induced ventilation recovery (Clinical_Comparison_Buprenorphine/)

# Ligand Data

Ligand_data/ contains the PKPD parameters used to simulate overdose of fentanyl, carfentanil and remifentanil and subsequent reversal with naloxone. 
