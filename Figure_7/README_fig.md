# Instructions to Generate Cardiac Arrest Data from Opioid Overdose Simulation


#Requirements
This code was developed with R version 3.3 and uses the following packages:

optparse (version 1.4.4)
ggplot2 (version 2.2.0)
deSolve (version 1.14)
gridExtra (version 2.2.1)
FME (version 1.3.5)

#Opioid Model Preparation
The full opioid model can be found in: [OpioidModel](https://github.com/FDA/Mechanistic-PK-PD-Model-to-Rescue-Opiod-Overdose/Figure_7/models/modelWithSimpleVentilatoryCollapse_IM/delaymymod.c)

This model combines the in vitro binding parameters for fentanyl derivatives and naloxone with the pharmacokinetic, physiological, and pharmacodynamic model components to simulate opioid overdose and subsequent cardiac arrest or rescue.

#Running the Code

To run the code first compile the opioid model: delaymymod.c form the model folder: models/modelWithSimpleVentilatoryCollapse_IM/
by running R CMD SHILB delaymymod.c

The four shell scripts:
Simulate_Overdose_Rmodel_LC.sh
Simulate_Overdose_Rmodel_HC.sh
Simulate_Overdose_Rmodel_LF.sh
Simulate_Overdose_Rmodel_HF.sh

simulate opioid overdose scenarios in response to both generic (2mg/2ml) IM naloxone and EVZIO (2mg/0.4ml) IM naloxone for a virtual population of 2000 patients and the best estimate (optimal fitted parameters) patient for the low dose carfentanil, high carfentanil, low fentanyl and high fentanyl dose respectively. 

After running the four scripts there will 8 output folders of the format: 

Review_naloxone_formulation_x_conc_y_ligand_z_patient_chronic 

where x is the naloxone antagonist (either generic or EVZIO)
	y is the opioid concentration (2 carfentanil doses and 2 fentanyl doses)
	z is the opioid ligand (either carfentanil or fentanyl) 

These files include the data for incidence of cardiac arrest and rescue times for key physiological metrics (Arterial O2, Brain O2 Arterial CO2 etc…)for all 2001 simulations per folder 

After generating these output files run: 

population_calcu.sh 

which calls population_calcu_CA for each of the 8 scenarios corresponding to the different opioids, doses, and naloxone formulations and calculated the total Cardiac arrest percentage and mean rescue times. 

Running CA_RS.sh calls Randome_population_calcu_CA_Dose.R for the same 8 scenarios also producing Cardiac arrest percentage and rescue data but also resamples the total population space to generate median and 95% CI of the cardiac arrest percentage. 


After running CA_RS.sh run Plot_Combined_Generic_EVZIO2mg.R from
/plot_combine_2mg_AND_EVZIO/ to combine the optimal patient time course data with the population level Cardiac Arrest results to generate Figure 7 of the mechanistic model manuscript. 

