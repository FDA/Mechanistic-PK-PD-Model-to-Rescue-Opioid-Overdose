# Simulation of fentanyl clinical studies. 
This code combines the receptor binding model with PK models for fentanyl to simulate a clinical ventilation study for naive and chronic fentanyl users. For this example only naive user parameters are included. IV fentanyl is described 
by a 3-compartment model. These models are combined with a mechanistic model linking fraction of fentanyl-bound receptor to ventilation to simulate respiratory depression 
following repeat IV fentanyl administration and demonstrate naloxone's ability to reverse this depression. The primary model output is percent of baseline ventilation.

#Running the code

**Rscript Opioid_IV_Fentanyl_Naloxone.R -p "patient_case"**

For the example case: run Rscript Opioid_IV_Fentanyl_Naloxone.R -p "Naive". Fentanyl PKPD parameters required for the script are found in [Fentanyl_PK](https://github.com/FDA/Mechanistic-PK-PD-Model-to-Rescue-Opiod-Overdose/Clinical_Comparison_all/Fentanyl_Example_Case/Clinical_data/fentanylPK.csv) and study data for naive users can be found in [Naive](https://github.com/FDA/Mechanistic-PK-PD-Model-to-Rescue-Opiod-Overdose/blob/main/Clinical_Comparison_all/Fentanyl_Example_Case/paper_digitized/A_Naive.csv). The combined ventilation figures for naive users given fentanyl alone and fentanyl followed by naloxone can be found in [Figs](https://github.com/FDA/Mechanistic-PK-PD-Model-to-Rescue-Opiod-Overdose/tree/main/Clinical_Comparison_all/Fentanyl_Example_Case/figs)

This code uses the following R packages: deSolve (version 1.10), ggplot2 (version 2.2.0) optparse (version 1.4.4), gridExtra (version 
2.2.1), colorspace (version 1.3)
