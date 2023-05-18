IN PROCESS

# Scripts to generate the pharmacodynamic results (figures and tables) of _Intranasal Naloxone Repeat Dosing Strategies: A Randomized Clinical Trial and Simulation Study_ 
Mathematical modeling scripts to generate:
* Figures 3, 4B, and eFigures 1, 2, 3 
* Table 1 and eTable 7

# Authors
FDA DARS mechanistic modeling team

# Workflow
## Generating Figure 3 and eFigure 1
Executing [SimulateVirtualSubjects.sh](SimulateVirtualSubjects.sh) calls [simulateVirtualSubject.R](simulateVirtualSubject.R) and necessary 
model files in [models](https://github.com/FDA/Mechanistic-PK-PD-Model-to-Rescue-Opioid-Overdose/tree/1d837704adb995684fc0ce584260776abf7e40a6/pharmacodynamic%20figures/models), 
model parameters in [input](https://github.com/FDA/Mechanistic-PK-PD-Model-to-Rescue-Opioid-Overdose/tree/1d837704adb995684fc0ce584260776abf7e40a6/pharmacodynamic%20figures/input) and 
function files in [functions](https://github.com/FDA/Mechanistic-PK-PD-Model-to-Rescue-Opioid-Overdose/tree/1d837704adb995684fc0ce584260776abf7e40a6/pharmacodynamic%20figures/functions) to generate Figure 3 and eFigure 1 in **link output folder**.

## Generating Figure 4B, eFigure 2 and eFigure 3
1. Execute [SimulateVirtualPopulationsIN4.sh](https://github.com/FDA/Mechanistic-PK-PD-Model-to-Rescue-Opioid-Overdose/blob/7b1f5754700fc88e406a43e07078b519492768b3/pharmacodynamic%20figures/SimulateVirtualPopulationsIN4.sh) which generates cardiac arrest (CA) outcomes for all subjects in the population with IN 4 mg naloxone administration in **link output folder**.
2. Execute [SimulateVirtualPopulationsIVBoyer.sh](https://github.com/FDA/Mechanistic-PK-PD-Model-to-Rescue-Opioid-Overdose/blob/7b1f5754700fc88e406a43e07078b519492768b3/pharmacodynamic%20figures/SimulateVirtualPopulationsIVBoyer.sh) which generates CA outcomes for all subjects in the population with IV naloxone administration as per the Boyer scheme suggested in **link Boyer et al.** in **link output folder**.
3. Execute [SimulateVirtualPopulationsIVMultipleDoses.sh](https://github.com/FDA/Mechanistic-PK-PD-Model-to-Rescue-Opioid-Overdose/blob/7b1f5754700fc88e406a43e07078b519492768b3/pharmacodynamic%20figures/SimulateVirtualPopulationsIVMultipleDoses.sh) which generates CA outcomes for all subjects in the population with administration of single IV naloxone bolus of varying amount in **link output folder**.
4. Execute [CalculatePopulationLevelCAMetricsIN4.sh](https://github.com/FDA/Mechanistic-PK-PD-Model-to-Rescue-Opioid-Overdose/blob/7b1f5754700fc88e406a43e07078b519492768b3/pharmacodynamic%20figures/CalculatePopulationLevelCAMetricsIN4.sh) which outputs the _percentage of subjects in the population experiencing cardiac arrest_ values with IN 4 mg naloxone administration, to be used in further plotting, in **link output folder**, using the CA outcomes of individual subjects in  **link input folder**.
5. Execute [CalculatePopulationLevelCAMetricsIVBoyer.sh](https://github.com/FDA/Mechanistic-PK-PD-Model-to-Rescue-Opioid-Overdose/blob/7b1f5754700fc88e406a43e07078b519492768b3/pharmacodynamic%20figures/CalculatePopulationLevelCAMetricsIVBoyer.sh)which outputs the _percentage of subjects in the population experiencing cardiac arrest_ values with IV naloxone administration as per the Boyer scheme, to be used in further plotting, in **link output folder**, using the CA outcomes of individual subjects in  **link input folder**.
6. Execute [CalculatePopulationLevelCAMetricsIVMultipleDoses.sh](https://github.com/FDA/Mechanistic-PK-PD-Model-to-Rescue-Opioid-Overdose/blob/7b1f5754700fc88e406a43e07078b519492768b3/pharmacodynamic%20figures/CalculatePopulationLevelCAMetricsIVMultipleDoses.sh) which outputs the _percentage of subjects in the population experiencing cardiac arrest_ values with administration of single IV naloxone bolus of varying amount, to be used in further plotting, in **link output folder**, using the CA outcomes of individual subjects in  **link input folder**.
7. Execute [ForestPlots.sh](https://github.com/FDA/Mechanistic-PK-PD-Model-to-Rescue-Opioid-Overdose/blob/7b1f5754700fc88e406a43e07078b519492768b3/pharmacodynamic%20figures/ForestPlots.sh) which produces the final forest plots in **link output folder**, using the population level CA percentages in folders **link 3 input folders**.

## Generating Table 1 and eTable 7
1. Execute [SimulateVirtualPopulationsIN4.sh](https://github.com/FDA/Mechanistic-PK-PD-Model-to-Rescue-Opioid-Overdose/blob/7b1f5754700fc88e406a43e07078b519492768b3/pharmacodynamic%20figures/SimulateVirtualPopulationsIN4.sh) which generates CA outcomes for all subjects in the population with IN 4 mg naloxone administration in **link output folder**.
2. Execute [CalculatePopulationLevelCAMetricsIN4.sh](https://github.com/FDA/Mechanistic-PK-PD-Model-to-Rescue-Opioid-Overdose/blob/7b1f5754700fc88e406a43e07078b519492768b3/pharmacodynamic%20figures/CalculatePopulationLevelCAMetricsIN4.sh) which outputs the _percentage of subjects in the population experiencing cardiac arrest_ values with IN 4 mg naloxone administration presented in Table 1, in **link output folder**, using the CA outcomes of individual subjects in **link input folder**.
3. Execute [CalculatePopulationLevelRTMetricsIN4.sh](https://github.com/FDA/Mechanistic-PK-PD-Model-to-Rescue-Opioid-Overdose/blob/7b1f5754700fc88e406a43e07078b519492768b3/pharmacodynamic%20figures/CalculatePopulationLevelRTMetricsIN4.sh) which outputs the time below (or above) under various physiological parameters with IN 4 mg naloxone administration, presented in both the tables in **link output folder**, using the same information about individual subjects generated earlier in **link input folder**.

# Requirements
This code was developed with R version 4.0.2 and uses the following packages:
*	deSolve (version 1.30)
*	forestplot
*	ggplot2 (version 3.1.1)
*	grid
*	gridExtra (version 2.2.1)
*	optparse (version 1.4.4)
*	scales



