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
function files in [functions](https://github.com/FDA/Mechanistic-PK-PD-Model-to-Rescue-Opioid-Overdose/tree/1d837704adb995684fc0ce584260776abf7e40a6/pharmacodynamic%20figures/functions) to generate figures 3 and eFigure 1 in **link output folder**

## Generating Figure 4B, eFigure 2 and eFigure 3
1. Execute [SimulateVirtualPopulationsIN4.sh](https://github.com/FDA/Mechanistic-PK-PD-Model-to-Rescue-Opioid-Overdose/blob/7b1f5754700fc88e406a43e07078b519492768b3/pharmacodynamic%20figures/SimulateVirtualPopulationsIN4.sh) which generates CA outcomes for all subjects in the population in **link output folder**
2. Execute [SimulateVirtualPopulationsIVBoyer.sh](https://github.com/FDA/Mechanistic-PK-PD-Model-to-Rescue-Opioid-Overdose/blob/7b1f5754700fc88e406a43e07078b519492768b3/pharmacodynamic%20figures/SimulateVirtualPopulationsIVBoyer.sh) which generates CA outcomes for all subjects in the population in **link output folder**
3. Execute [SimulateVirtualPopulationsIVMultipleDoses.sh](https://github.com/FDA/Mechanistic-PK-PD-Model-to-Rescue-Opioid-Overdose/blob/7b1f5754700fc88e406a43e07078b519492768b3/pharmacodynamic%20figures/SimulateVirtualPopulationsIVMultipleDoses.sh) which generates CA outcomes for all subjects in the population in **link output folder**
4. Execute [CalculatePopulationLevelCAMetricsIN4.sh](https://github.com/FDA/Mechanistic-PK-PD-Model-to-Rescue-Opioid-Overdose/blob/7b1f5754700fc88e406a43e07078b519492768b3/pharmacodynamic%20figures/CalculatePopulationLevelCAMetricsIN4.sh) which outputs the _percentage of subjects in the population experiencing cardiac arrest_ values presented in the table 1 in **link output folder**
5. Execute [CalculatePopulationLevelCAMetricsIVBoyer.sh](https://github.com/FDA/Mechanistic-PK-PD-Model-to-Rescue-Opioid-Overdose/blob/7b1f5754700fc88e406a43e07078b519492768b3/pharmacodynamic%20figures/CalculatePopulationLevelCAMetricsIVBoyer.sh) which outputs the _percentage of subjects in the population experiencing cardiac arrest_ values presented in the table 1 in **link output folder**
6. Execute [CalculatePopulationLevelCAMetricsIVMultipleDoses.sh](https://github.com/FDA/Mechanistic-PK-PD-Model-to-Rescue-Opioid-Overdose/blob/7b1f5754700fc88e406a43e07078b519492768b3/pharmacodynamic%20figures/CalculatePopulationLevelCAMetricsIVMultipleDoses.sh) which outputs the _percentage of subjects in the population experiencing cardiac arrest_ values presented in the table 1 in **link output folder**
7. Execute [ForestPlots.sh](https://github.com/FDA/Mechanistic-PK-PD-Model-to-Rescue-Opioid-Overdose/blob/7b1f5754700fc88e406a43e07078b519492768b3/pharmacodynamic%20figures/ForestPlots.sh) which outputs the _percentage of subjects in the population experiencing cardiac arrest_ values presented in the table 1 in **link output folder**

## Generating Table 1 and eTable 7
1. Execute [SimulateVirtualPopulationsIN4.sh](https://github.com/FDA/Mechanistic-PK-PD-Model-to-Rescue-Opioid-Overdose/blob/7b1f5754700fc88e406a43e07078b519492768b3/pharmacodynamic%20figures/SimulateVirtualPopulationsIN4.sh) which generates CA outcomes for all subjects in the population in **link output folder**
2. Execute [CalculatePopulationLevelCAMetricsIN4.sh](https://github.com/FDA/Mechanistic-PK-PD-Model-to-Rescue-Opioid-Overdose/blob/7b1f5754700fc88e406a43e07078b519492768b3/pharmacodynamic%20figures/CalculatePopulationLevelCAMetricsIN4.sh) which outputs the _percentage of subjects in the population experiencing cardiac arrest_ values presented in the table 1 in **link output folder**
3. Execute [CalculatePopulationLevelRTMetricsIN4.sh](https://github.com/FDA/Mechanistic-PK-PD-Model-to-Rescue-Opioid-Overdose/blob/7b1f5754700fc88e406a43e07078b519492768b3/pharmacodynamic%20figures/CalculatePopulationLevelRTMetricsIN4.sh) which outputs the time below (or above) under various physiological parameters values presented in the tables in **link output folder**

# Requirements
This code was developed with R version 4.0.2 and uses the following packages:
*	deSolve (version 1.30)
*	dplyr
*	forestplot
*	ggplot2 (version 3.1.1)
*	grid
*	gridExtra (version 2.2.1)
*	optparse (version 1.4.4)
*	scales



