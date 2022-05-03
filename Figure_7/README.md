# Instructions to Generate Cardiac Arrest Data from Opioid Overdose Simulation


# Requirements
This code was developed with R version 3.6 and uses the following packages:

* optparse (version 1.4.4)
* ggplot2 (version 3.1.1)
* deSolve (version 1.10-5)
* gridExtra (version 2.2.1)
* FME (version 1.3.6.1)

The model is designed to be run in a linux environment with a high performance computing cluster (HPC) using the Sun Grid Enginer (SGE) batch queuing system. In this system shell scripts are submitted with the command qsub 'shell_script_name.sh'


# Opioid Model Preparation
The full opioid model can be found in: [OpioidModel](https://github.com/FDA/Mechanistic-PK-PD-Model-to-Rescue-Opiod-Overdose/blob/main/Figure_7/models/modelWithSimpleVentilatoryCollapse_IM/delaymymod.c)

This model combines the in vitro binding parameters for fentanyl derivatives and naloxone with the pharmacokinetic, physiological, and pharmacodynamic model components to simulate opioid overdose and subsequent cardiac arrest or rescue.

# Running the Code

## Simulating Overdose and Response

To run the code first compile the opioid model: delaymymod.c from the [model folder](https://github.com/FDA/Mechanistic-PK-PD-Model-to-Rescue-Opiod-Overdose/tree/main/Figure_7/models/modelWithSimpleVentilatoryCollapse_IM)
with the command:  R CMD SHILB delaymymod.c

The four shell scripts:
[Simulate_Overdose_Rmodel_LC.sh](https://github.com/FDA/Mechanistic-PK-PD-Model-to-Rescue-Opiod-Overdose/blob/main/Figure_7/Simulate_Overdose_Rmodel_LC.sh)
[Simulate_Overdose_Rmodel_HC.sh](https://github.com/FDA/Mechanistic-PK-PD-Model-to-Rescue-Opiod-Overdose/blob/main/Figure_7/Simulate_Overdose_Rmodel_HC.sh)
[Simulate_Overdose_Rmodel_LF.sh](https://github.com/FDA/Mechanistic-PK-PD-Model-to-Rescue-Opiod-Overdose/blob/main/Figure_7/Simulate_Overdose_Rmodel_LF.sh)
[Simulate_Overdose_Rmodel_HF.sh](https://github.com/FDA/Mechanistic-PK-PD-Model-to-Rescue-Opiod-Overdose/blob/main/Figure_7/Simulate_Overdose_Rmodel_HF.sh)

simulate opioid overdose scenarios in response to both generic IM naloxone (2mg/2ml) and the EVZIO IM Autoinjector (2mg/0.4ml) for a virtual population of 2000 patients and the best estimate (optimal fitted parameters) patient for the low dose carfentanil, high carfentanil, low fentanyl and high fentanyl dose respectively by calling [simulateToGetOD_IM.R](https://github.com/FDA/Mechanistic-PK-PD-Model-to-Rescue-Opiod-Overdose/blob/main/Figure_7/simulateToGetOD_IM.R). 

Each script can be run from the terminal using the qsub command followed by the script name as such:
* qsub Simulate_Overdose_Rmodel_LC.sh

Each of the four shelll scripts calls 4002 jobs (2001 for each naloxone administration) to be run simultaneously on the HPC generating two separate population data sets.

After running the four scripts there will 8 output folders of the format: 

Review_naloxone_formulation_x_conc_y_ligand_z_patient_chronic 

where x is the naloxone antagonist (either generic or EVZIO)
	y is the opioid concentration (2 carfentanil doses and 2 fentanyl doses)
	z is the opioid ligand (either carfentanil or fentanyl) 

These files include the data for incidence of cardiac arrest and rescue times for key physiological metrics (Arterial O2, Brain O2 Arterial CO2 etc…)for all 2001 simulations per folder 

## Interpreting the simulation outputs 

After generating these output files run: 

[CA_RS.sh](https://github.com/FDA/Mechanistic-PK-PD-Model-to-Rescue-Opiod-Overdose/blob/main/Figure_7/CA_RS.sh)

which calls [Randome_population_calcu_CA_Dose.R](https://github.com/FDA/Mechanistic-PK-PD-Model-to-Rescue-Opiod-Overdose/blob/main/Figure_7/Randome_population_calcu_CA_Dose.R) for each of the 8 scenarios corresponding to the different opioids, doses, and naloxone formulations and calculates the total Cardiac arrest percentage and mean rescue times. This also resamples the total population space to generate median and 95% CI of the cardiac arrest percentage 


## Generating the Manuscript Figure 

After running CA_RS.sh run [Plot_Combined_Generic_EVZIO2mg.R](https://github.com/FDA/Mechanistic-PK-PD-Model-to-Rescue-Opiod-Overdose/blob/main/Figure_7/plot_combine_2mg_AND_EVZIO/Plot_Combined_Generic_EVZIO2mg.R) to combine the optimal patient time course data with the population level Cardiac Arrest results to generate Figure 7 of the mechanistic model manuscript. 

