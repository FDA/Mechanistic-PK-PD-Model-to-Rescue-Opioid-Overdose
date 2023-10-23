# Scripts to generate the figures and tables of  _Towards Developing Alternative Opioid Antagonists for Treating Community Overdose – A model-based evaluation of important pharmacological attributes_ 
**Anik Chaturbedi, John Mann, Zhihua Li**

Division of Applied Regulatory Science, Office of Clinical Pharmacology, Office of Translational Sciences, Center for Drug Evaluation and Research, Food & Drug Administration, Silver Spring, Maryland, USA

## 1. Brief description of models and parameters
### 1a. Models
Model for simulating **intravenous opioid** overdose and **intranasal naloxone** administration:  _models/modelIN_2Tr1C_

Model for simulating **intravenous opioid** overdose and **intranasal nalmefene** administration:  _models/modelIN_2Tr1C1P_RepeatedDosing_

Model for simulating **transmucosal opioid** overdose and **intranasal naloxone** administration:  _models/model_TM_2Tr1C1P_IN_2Tr1C_

Model for simulating **transmucosal opioid** overdose and **intranasal nalmefene** administration:  _models/model_TM_2Tr1C1P_IN_2Tr1C1P_RepeatedDosing_

In each of these folders  _delaymymod_  files contain the model equations described in detail in [Mann et al.](https://ascpt.onlinelibrary.wiley.com/doi/10.1002/cpt.2696) and other files serve as auxillary files. 

### 1b. Parameters
The parameters for a "typical" subject can be found in  _parameters/optimalParameters_ . 
The opioid (fentanyl and carfentanil) pharmacokinetic and receptor binding parameters are available in  _parameters/optimalParameters/opioid_ .
Pharmacokinetic parameters and receptor binding parameters for IN naloxone and IN nalmefene are provided in  _parameters/optimalParameters/antagonist_ . 
The parameters representing various physiological variables which are used in the physiological and ventilatory component of the model are provided in  _parameters/optimalParameters/physiological/physiologicalParameters_ . 
The pharmacodynamic parameters for a chronic opioid user is given in  _parameters/optimalParameters/subject/chronic_ . 

The corresponding parameters for all of the 2000 subjects in the virtual population are available in  _parameters/populationParameters_ .
The opioid pharmacokinetic and receptor binding parameters are available in  _parameters/populationParameters/opioid_ . 
Similar to the "typical" subject, fentanyl pharmacokinetic parameters are modified to match a longer half-life for carfentanil. 
The pharmacokinetic and receptor binding parameters for IN naloxone and IN nalmefene are available in  _parameters/populationParameters/antagonist_ . 

Additional simulation related parameters used both for simulating the "typical" subject as well as the virtual population are defined in  _input/simulationParameters_ .

### 1c. Clinical data
The data used for plotting are in _data_. 
Note:  _data/nalmefeneCIndividualSubjectData.csv_  and  _data/naloxoneIndividualSubjectData.csv_  were digitized from Figure 2.

## 2. Workflow
### 2a. Pharmacokinetics
#### 2a1. Figure 2 Pharmacokinetics of the various µ-receptor antagonist formulations studied in this work. 
1. run SimulateVirtualPopulationsAntagonistPKOnly.sh (OR simulateVirtualSubject.R)
2. run SimulateVirtualSubjectsAntagonistPKOnly.sh (OR simulateVirtualSubject.R)
2. run PlottingAntagonistPKTimeCourseAndPKParameters.sh (or plottingAntagonistPKTimecourseAndPKParameters.R)

### 2b. IV opioid overdose simulations
#### 2b1. Figure 3 Simulated antagonist induced reversal for various scenarios of opioid overdose with intravenous fentanyl and carfentanil.
1. run SimulateVirtualSubjects.sh (or simulateVirtualSubject.R)
2. run PlotVirtualSubjects.sh

#### 2b2. Figure 4 Immediate antagonist induced recovery in the aftermath of various levels of opioid overdose with intravenous fentanyl and carfentanil in a virtual population.
1. run SimulateVirtualPopulations.sh (or simulateVirtualSubject.R)
2. run CalculatePopulationLevelCAMetrics.sh (or calculatePopulationLevelCAMetric.R)
3. run multipleDoses.R

### 2c. TM opioid overdose simulations
#### 2c1. Figure 5 Simulated prevention of renarcotization induced respiratory depression in a typical subject.
1. run SimulateVirtualSubjectsRenarcotization.sh (OR simulateVirtualSubject.R) 
2. run PlotVirtualSubjectsRenarcotization.sh (OR plottingRenarcotization4Cases.R)

#### 2c2. Figure S2 Plasma concentration of long exposure opioid formulation used here to simulate renarcotization.
1. run MatchOpioidPlasmaConcentration.sh (or simulateVirtualSubject.R followed by  plottingRenarcotizationPlasmaConcentration.R)

#### 2c3. Figure S3 Plasma concentration of the various antagonist formulations studied in this work in a “typical” subject.
1. run SimulateVirtualSubjectsRenarcotization.sh (OR simulateVirtualSubject.R)
2. run PlotVirtualSubjectsRenarcotization.sh (OR plottingRenarcotization4CasesAPC.R)

#### 2c4. Table 1 Minute ventilation with various antagonist formulations (and without any antagonist) at different times after exposure to an opioid with slower absorption.
1. run SimulateVirtualPopulationsRenarcotization.sh (or simulateVirtualSubject.R)
2. run CalculatePopulationLevelMVMetricsRenarcotization.sh (or calculatePopulationLevelMVMetric.R)

#### 2c5. Table S5 Plasma concentration for various antagonist formulations at different times, for the case of long-exposure opioid administration.
1. run SimulateVirtualPopulationsRenarcotization.sh (or simulateVirtualSubject.R)
2. run CalculatePopulationLevelAPCMetricsRenarcotization.sh (or calculatePopulationLevelAPCMetric.R)

## 3. Requirements
These codes were developed in R-4.4.1 and C.
