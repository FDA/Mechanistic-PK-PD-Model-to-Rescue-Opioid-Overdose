
# Prediction of remifentanil clinical data
This code performs the prediction of clinical ventilation depression in response to bolus remifentanil administration as described in Barbenco et al using the mechanistic PKPD model of opioid induced repiratory depression. Model inputs are the remifentanil receptor binding kinetics parameterized through in-vitro binding assays, the pharmacokinetic parameters for remifentanil (Barbenco et al.) and the PD parameters governing ventilation. These inputs are used to simulate respiratory depression in response to mu receptor occupancy by remifentanil. The primary model output is percent of baseline ventilation.

# Running the code 
This code uses the following R packages: deSolve (version 1.14), ggplot2 (version 2.2.0), gridExtra (version 2.2.1)

Rscript IV_opioid.R 

Remifentanil PKPD parameters as well as Clinical data can be found in (Clinical_data/). Figures are automatically saved in (figs/)