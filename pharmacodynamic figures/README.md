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

## Generating Figure 4B
## Generating Table 1
## Generating eFigure 1
## Generating eFigure 2
## Generating eFigure 3
## Generating eTable 7

# Requirements
This code was developed with R version 3.6.0 and uses the following packages:
*	deSolve (version 1.10-5)
*	dplyr
*	forestplot
*	ggplot2 (version 3.1.1)
*	grid
*	gridExtra (version 2.2.1)
*	optparse (version 1.4.4)
*	scales



