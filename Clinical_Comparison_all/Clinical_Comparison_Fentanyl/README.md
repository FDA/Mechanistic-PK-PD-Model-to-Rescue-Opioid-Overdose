# Simulation of fentanyl clinical studies. 
This code combines the receptor binding model with PK models for fentanyl to simulate a clinical ventilation study for naive and chronic fentanyl users. IV fentanyl is described 
by a 3-compartment model. These models are combined with a mechanistic model linking fraction of fentanyl-bound receptor to ventilation to simulate respiratory depression 
following repeat IV fentanyl administration. The primary model output is percent of baseline ventilation.

# Running the code 
**Rscript IV_opioid.R -p "patient_case"**

When running the script for simulation of fentanyl clinical studies select the desired patient case using the parser. For instance for simulating chronic fentanyl users: Rscript 
IV_opiod.R - p "Chronic". Fentanyl PKPD parameters required for the script are found in (Clinical_data/) and study data for naive and chronic users are found in 
(paper_digitized/). Ventilation figures for both chronic and naive users are saved automatically in (figs/)

This code uses the following R packages: This code uses the following R packages: deSolve (version 1.14), ggplot2 (version 2.2.0) optparse (version 1.4.4), gridExtra (version 
2.2.1)
