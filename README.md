

# Translational Model to Assess the Impact of Opioid Overdose and Naloxone Dosing on Respiratory Depression and Cardiac Arrest

R code to utilize mechanistic PK-PD model of opioid overdose for simulation of overdose scenarios and cardiac arrest

# Authors

John Mann, Mohammadreza Samieegohar, Xiaomei Han, Anik Chaturbedi, Farzad Ahmadi, Zhihua Li

# Requirements

This code was developed with R version 3.6.0 and uses the following packages:
*	optparse (version 1.4.4)
*	ggplot2 (version 3.1.1)
*	deSolve (version 1.10-5)
*	gridExtra (version 2.2.1)
*	FME (version 1.3.6.1)

# Binding Parameters 

Binding parameters (Kon, Koff and n) for naloxone and the opioid ligands can be found in their corresponding folder in [Ligand_Data/](https://github.com/FDA/Mechanistic-PK-PD-Model-to-Rescue-Opiod-Overdose/tree/main/Ligand_Data). 

## Fentanyl
Fentanyl optimal binding parameters can be found here: [Fentanyl](https://github.com/FDA/Mechanistic-PK-PD-Model-to-Rescue-Opiod-Overdose/blob/main/Ligand_Data/Fentanyl_A_parameters/Fentanyl_A_pars.txt). The full probability distribution of parameters estimated through uncertainty quantification for Fentanyl can be found in [boot_pars.csv](https://github.com/FDA/Mechanistic-PK-PD-Model-to-Rescue-Opiod-Overdose/blob/main/Ligand_Data/Fentanyl_A_parameters/boot_pars.csv)

[Fentanyl_parms](https://github.com/FDA/Mechanistic-PK-PD-Model-to-Rescue-Opiod-Overdose/blob/main/Ligand_Data/Fentanyl_A_parameters/parmsFentanyl.R) contains the full set of binding and PK parameters necessary for simulating opioid overdose and subsequent rescue using intramuscular naloxone for the optimal scenario. 

## Carfentanil

Carfentanil optimal binding parameters can be found here: [Carfentanil](https://github.com/FDA/Mechanistic-PK-PD-Model-to-Rescue-Opiod-Overdose/blob/main/Ligand_Data/Carfentanil_parameters/CARFENTANIL_pars.txt). The full probability distribution of parameters estimated through uncertainty quantification for Carfentanil can be found in [boot_pars.csv](https://github.com/FDA/Mechanistic-PK-PD-Model-to-Rescue-Opiod-Overdose/blob/main/Ligand_Data/Carfentanil_parameters/boot_pars.csv) 

Carfentanil PK parameters utilized fentanyl parameters as a baseline and were modified to match the long half-life (~45 minutes) seen in clinical studies [4]

## Naloxone 
Naloxone optimal binding parameters can be found here: [Naloxone](https://github.com/FDA/Mechanistic-PK-PD-Model-to-Rescue-Opiod-Overdose/blob/main/Ligand_Data/NALOXONE/NALOXONE_pars.txt). While the full probability distribution of parameters estimated through uncertainty quantification for Naloxone can be found in [boot_pars.csv](https://github.com/FDA/Mechanistic-PK-PD-Model-to-Rescue-Opiod-Overdose/blob/main/Ligand_Data/NALOXONE/boot_pars.csv)
 


# Generating Opioid Overdose and Rescue Figures


# Receptor Binding Model
In developing the mu receptor binding model, association and dissociation assays were conducted for each of the 9 opioid agonists and naloxone.  The binding model uses the following ordinary differential equation (ODE) to describe the system: 

dRL/dt=K<sub>on</sub>* L<sup>n</sup>*R-K<sub>off</sub>*RL (1)


where L, R, and RL are free ligands (opioids or naloxone), free (unoccupied) mu receptors, and ligand-occupied receptors, respectively. K<sub>on</sub>, K<sub>off</sub>, and n are the association rate, dissociation rate, and the slope of the dose-effect relationship, respectively. The concentration of receptors is represented as fractions of the total receptor R_total. Assuming R_total is 1, it follows that R = 1 – RL, and, as such, no ODE is needed for the amount (fraction) of free receptor R. There is also no ODE for the ligand L, a simplification necessary to use fraction of receptors rather than real units for receptors in the ODE system, which is a requirement for virtual patients simulations [1]. Such a simplification assumes  there is minimal change of the free ligand concentration due to binding, which was supported by the observation that even at the lowest ligand concentration, only ~5% ligand was lost due to binding to mu receptors in our experimental systems (data not shown). 

The parameters were estimated by fitting the model to the time course of association and dissociation data. Single point estimation of each parameter was obtained by fitting to the mean values of experimental data. The variability in experimental data and uncertainty in parameter estimation were captured and quantified by a boot strapping strategy developed earlier [2]. This resulted in 2000 parameter sets that describe the joint distribution of Kon, Koff, and n based on experimental data.

# Pharmacokinetic Models

Compartmental pharmacokinetic (PK) models for fentanyl [3] and carfentanil were used in this study. Briefly, a three-compartment was used to describe the time course of plasma concentration after an intravenous bolus injection of fentanyl and carfentanil. A biophase equilibrium model was used to characterize the transfer of ligands from the plasma to the effective compartment. 

For the PK of naloxone following intramuscular (IM) administration, plasma concentration profiles after a 2 mg IM naloxone dose as documented in the FDA labels [5,6], were used to construct a IM PK model for formulations of 2mg/2ml and 2mg/0.4ml naloxone. A transit compartment model with two transition compartments, 1 central and 1 peripheral compartment was used to describe the delay between the tissue and plasma concentration profile. 
 The following system of ODEs was used to characterize the system.


dT1/dt=K<sub>tr</sub>*D*F*e<sup>(-K<sub>tr</sub>*t)</sup>-K<sub>tr</sub>*T1 (2)

dT2/dt=K<sub>tr</sub>*T1-K<sub>in</sub>*T2 (3)

dP/dt=K<sub>in</sub>/V*T2-CL/V*P+CL<sub>i</sub>/V*P2-CL<sub>i</sub>/V*P  (4)

dP2/dt=CL<sub>i</sub>/V2*P-CL<sub>i</sub>/V2*P2  (5)






Here D, T1, T2, P and P2 are the initial dose of IM naloxone, and drug concentrations in the 1st transit, the 2nd transit, the central compartment, and the peripheral compartment, respectively. F, K<sub>tr</sub>, K<sub>in</sub>, CL, CL<sub>i</sub> V and V2 are the bioavailability, transit rate, absorption rate, clearance, intercompartmental clearance, central volume of distribution, and peripheral volume of distribution respectively. The following optimal values were used based on model fitting: (insert optimal parameters)

# Physiological Models

The physiological component combines gas oxygen and carbon dioxide storage, metabolism, and exchange, as well as ventilatory control and blood flow control. It was implemented primarily based on the work of Magosso, Ursino and colleagues [7-9] with a few modifications to better recapitulate clinical data. These include:

* Preventing the combined ventilatory drives from being zero to better match hyperoxic and normocapnic scenarios

* Reproducing ventilation responses to hypoxia under hypercapnia and normocapnia

* Matching changes in cerebral blood flow due to changes in carbon dioxide partial pressure

* Allowing prolonged hypoxia to result in decreased cardiac output and eventual cardiac arrest.   	

# Pharmacodynamic Models

For the pharmacodynamic (PD) component, similar to Ursino and Magosso model [7], we assume opioids binding to the opioid receptor can reduce all 3 ventilatory drives: 
* the peripheral chemoreflex
*  the central chemoreflex
*  the wakefulness drive (basal respiratory activities)

The original Magosso and Ursino model assumes a dose-response relationship between fentanyl plasma concentration and the degree of reduction in these drives [6]. To make this PD relationship more generally applicable, in our model, the reduction in these drives (relative to the baseline values) was assumed to be CAR<sup>P</sup>, where CAR is the fraction of opioid receptors bound by opioids and P is a scaling parameter (P1 for the wakefulness drive and P3 for both the central and peripheral chemoreflex drive). Of note, both the fractional ventilatory drive and CAR are values between 0 and 1. Parameters P1 and P3 were estimated through various clinical studies of fentanyl effects on ventilation, both for healthy opioid naïve volunteers and chronic opioid users [3, 10], who are assumed to have different P1 and P3 parameters. In addition, to account for the hysteresis between drug (opioid or naloxone) plasma concentrations and PD effects, we assume there is an effect compartment within which drug concentrations are equilibrated with the plasma compartment with a rate k1. For fentanyl, k1 was estimated from clinical data along with P1 and P3. For naloxone, k1 was estimated from a clinical study investigating naloxone-mediated reversal of opioid-induced respiratory depression [11]. For carfentanil, we assume an arbitrarily large k1 due to the lack of clinical data and to not underestimate its potency.


# Simulate Opioid Overdose and Rescue (Figure 7) 

For a full description of the Figure 7 simulation procedures see: [Simulation_Readme](https://github.com/FDA/Mechanistic-PK-PD-Model-to-Rescue-Opiod-Overdose/blob/main/Figure_7/README.md).

The complete overdose simulation model combines all submodels including: the receptor binding model, the pharmacokinetic model, the physiological submodel, and the pharmacodynamic model to estimate the outcomes of opioid overdose scenarios in the absence and presence of different intramuscular naloxone formualations. 

Overdose scenarios were based on real world fatal overdose data of approximately 500 fatal fentanyl overdose cases. The postmortem fentanyl distribution from this data set has a mean and standard deviation of 9.96 and 9.27 ng.ml respectively [12]. We used the mean (9.96 ng/mL) and one standard deviation above the mean (84.1% percentile; 19.3 ng/mL) of this fatal fentanyl overdose range and estimated the corresponding intravenous dose to be 1.63 ("medium dose") and 2.97 mg ("high dose"), respectively. This estimation assumed that significant postmortem fentanyl redistribution would not occur within this time window [13] For carfentanil we utilized a dose equivalence strategy to calculate its corresponding medium and high dose scenarios. In this strategy, the minimum dose required to induce cardiac arrest was calculated for both fentanyl and carfentanil. The ratio of the minimum cardiac arrest dose for carfentanil relative to that for fentanyl was multiplied by the medium and high fentanyl doses to derive the corresponding overdose scenarios for carfentanil. The calculated median and high overdose scenarios for carfentanil IV is 0.012 and 0.022 mg, respectively.  

In overdose scenarios we used both the typical patient (optimal parameters referenced above) and the patient populations in the simulations. For receptor binding parameters the uncertainty was captured in a joint distribution approximated by 2000 sets of parameters (see the section Receptor Binding above). For PK of fentanyl, we randomly sampled 2000 values for each parameter based on the published mean and standard deviation of fentanyl population PK model [3] assuming a log-normal distribution. For carfentanil, the mean PK parameters were estimated based on the limited human PK data avaialable, and the standard deviation across the population (inter-subject variability) was assumed to be the same as fentanyl. For naloxone products (Generic: IM 2 mg/2 mL, EVZIO: 2 mg/0.4 mL), we randomly sampled 2000 values of each PK parameter based on the population mean and standard deviation estimated through Bayesian Hierarchical Modeling. The primary outout of interest is the cardiac arrest percentage [Figure 7D](https://github.com/FDA/Mechanistic-PK-PD-Model-to-Rescue-Opiod-Overdose/blob/main/Figure_7/plot_combine_2mg_AND_EVZIO/results/Manuscript_Figure_7.pdf). We also captured the timecourse of several endpoints of interest including minute ventilation (Figure 7A), arterial partial pressure of oxygen (Figure 7B), and total cardiac output (Figure 7C). The values shown for these additional endpoints in Figure 7 are for the typical patient.


## References

1.	Yassen, A., et al., Mechanism-based PK/PD modeling of the respiratory depressant effect of buprenorphine and fentanyl in healthy volunteers. Clin Pharmacol Ther, 2007. 81(1): p. 50-8.
2.	Chang, K.C., et al., Uncertainty Quantification Reveals the Importance of Data Variability and Experimental Design Considerations for in Silico Proarrhythmia Risk Assessment. Frontiers in Physiology, 2017. 8(917).
3.	Algera, M.H., et al., Tolerance to Opioid-Induced Respiratory Depression in Chronic High-Dose Opioid Users: A Model-Based Comparison With Opioid-Naive Individuals. Clin Pharmacol Ther, 2020.
4.	Minkowski, C.P., et al., Differential response to IV carfentanil in chronic cocaine users and healthy controls. Addict Biol, 2012. 17(1): p. 149-55.
5.	US FDA label for naloxone hydrochloride injection 1988; Available from: https://dailymed.nlm.nih.gov/dailymed/fda/fdaDrugXsl.cfm?setid=236349ef-2cb5-47ca-a3a5-99534c3a4996&type=display.
6.	USFDA. Label for EVZIO Auto-Injector for intramuscular or subcutaneous use, 2 mg. 2016; Available from: https://www.accessdata.fda.gov/drugsatfda_docs/label/2016/209862lbl.pdf.
7. Magosso, E., M. Ursino, and J.H. van Oostrom, Opioid-induced respiratory depression: a mathematical model for fentanyl. IEEE Trans Biomed Eng, 2004. 51(7): p. 1115-28.
8.	Ursino, M., E. Magosso, and G. Avanzolini, An integrated model of the human ventilatory control system: the response to hypercapnia. Clin Physiol, 2001. 21(4): p. 447-64.
9.	Ursino, M., E. Magosso, and G. Avanzolini, An integrated model of the human ventilatory control system: the response to hypoxia. Clin Physiol, 2001. 21(4): p. 465-77.
10.	Stoeckel, H., et al., Plasma fentanyl concentrations and the occurrence of respiratory depression in volunteers. Br J Anaesth, 1982. 54(10): p. 1087-95.
11.	Yassen, A., et al., Mechanism-based pharmacokinetic-pharmacodynamic modelling of the reversal of buprenorphine-induced respiratory depression by naloxone : a study in healthy volunteers. Clin Pharmacokinet, 2007. 46(11): p. 965-80.
12.	NDEWS. Unintentional Fentanyl Overdoses in New Hampshire: An NDEWS HotSpot Analysis. 2017; Available from: https://ndews.org/wordpress/files/2020/07/ndews-hotspot-unintentional-fentanyl-overdoses-in-new-hampshire-final-09-11-17.pdf
13.	Brockbals, L., et al., Time-Dependent Postmortem Redistribution of Opioids in Blood and Alternative Matrices. J Anal Toxicol, 2018. 42(6): p. 365-374.
