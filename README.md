# Mechanistic-PK-PD-Model-to-Rescue-Opioid-Overdose Version 1.0

R code used to validate mechanistic PK-PD model of opioid overdose through simulation of clinical trials

# Authors

John Mann, Mohammadreza Samieegohar, Xiaomei Han, Anik Chaturbedi, Zhihua Li

# Requirements

This code was developed with R version 3.3 and uses the following packages:
*	optparse (version 1.4.4)
*	ggplot2 (version 2.2.0)
*	deSolve (version 1.14)
*	gridExtra (version 2.2.1)
*	FME (version 1.3.5)

# Binding Parameters 

Binding parameters (Kon, Koff and n) for naloxone, the opioid ligands used in clinical simulations, and carfentanil can be found in their corresponding folder in [Ligand_Data/](https://github.com/FDA/Mechanistic-PK-PD-Model-to-Rescue-Opiod-Overdose/tree/main/Ligand_Data). 

## Fentanyl
Fentanyl optimal binding parameters can be found here: [Fentanyl](https://github.com/FDA/Mechanistic-PK-PD-Model-to-Rescue-Opiod-Overdose/blob/main/Ligand_Data/Fentanyl_A_parameters/Fentanyl_A_pars.txt). The full probability distribution of parameters estimated through uncertainty quantification  for Fentanyl can be found in [boot_pars.csv](https://github.com/FDA/Mechanistic-PK-PD-Model-to-Rescue-Opiod-Overdose/blob/main/Ligand_Data/Fentanyl_A_parameters/boot_pars.csv)

[Fentanyl_parms](https://github.com/FDA/Mechanistic-PK-PD-Model-to-Rescue-Opiod-Overdose/blob/main/Ligand_Data/Fentanyl_A_parameters/parmsAlgera2020.R) contains the full set of binding and PK parameters necessary for simulating opioid overdose and subsequent rescue using intranasal naloxone for the optimal scenario. 

## Carfentanil

Carfentanil optimal binding parameters can be found here: [Carfentanil](https://github.com/FDA/Mechanistic-PK-PD-Model-to-Rescue-Opiod-Overdose/blob/main/Ligand_Data/Carfentanil_parameters/CARFENTANIL_pars.txt). The full probability distribution of parameters estimated through uncertainty quantification  for Carfentanil can be found in [boot_pars.csv](https://github.com/FDA/Mechanistic-PK-PD-Model-to-Rescue-Opiod-Overdose/blob/main/Ligand_Data/Carfentanil_parameters/boot_pars.csv) 

## Naloxone 
Naloxone optimal binding parameters can be found here: [Naloxone](https://github.com/FDA/Mechanistic-PK-PD-Model-to-Rescue-Opiod-Overdose/blob/main/Ligand_Data/NALOXONE/NALOXONE_pars.txt). While the full probability distribution of parameters estimated through uncertainty quantification  for Naloxone can be found in [boot_pars.csv](https://github.com/FDA/Mechanistic-PK-PD-Model-to-Rescue-Opiod-Overdose/blob/main/Ligand_Data/NALOXONE/boot_pars.csv)
 


# Generating Clinical Simulation and Comparison Figures

## Buprenorphine Clinical Simulation

Code to be released. 
## Fentanyl Clinical Simulations

Code to be released.

# Receptor Binding Model
In developing the mu receptor binding model, association and dissociation assays were conducted for each of the 9 opioid agonists and naloxone.  The binding model uses the following ordinary differential equation (ODE) to describe the system: 

![image](https://user-images.githubusercontent.com/76440648/116600098-eb6ad380-a8f6-11eb-977d-70269713ee13.png)


where L, R, and RL are free ligands (opioids or naloxone), free (unoccupied) mu receptors, and ligand-occupied receptors, respectively. Kon, Koff, and n are the binding rate, unbinding rate, and the slope of the dose-effect relationship, respectively. The concentration of receptors is represented as fractions of the total receptor R_total. Assuming R_total is 1, it follows that R = 1 – RL, and, as such, no ODE is needed for the amount (fraction) of free receptor R. There is also no ODE for the ligand L, a simplification necessary to use fraction of receptors rather than real units for receptors in the ODE system, which is a requirement for virtual patients simulations [1]. Such a simplification assumes  there is minimal change of the free ligand concentration due to binding, which was supported by the observation that even at the lowest ligand concentration, only ~5% ligand was lost due to binding to mu receptors in our experimental systems (data not shown). 

The parameters were estimated by fitting the model to the time course of association and dissociation data. Single point estimation of each parameter was obtained by fitting to the mean values of experimental data. The variability in experimental data and uncertainty in parameter estimation were captured and quantified by a boot strapping strategy developed earlier [2]. This resulted in 2000 parameter sets that describe the joint distribution of Kon, Koff, and n based on experimental data.

# Pharmacokinetic Models

Compartmental pharmacokinetic (PK) models for fentanyl [3] and buprenorphine [1] were used in this study. Briefly, a three-compartment was used to describe the time course of plasma concentration after an intravenous bolus  injection of buprenorphine and fentanyl. A biophase equilibrium model was used to characterize the transfer of ligands from the plasma to the effective compartment. A two-compartment model developed by Yassen et al. [4] was used to describe the PK of naloxone following continuous intravenous infusion.

For the PK of naloxone following nasal administration, plasma concentration profiles after a 4 mg intranasal (IN) naloxone hydrochloride dose in a single nostril and two 4 mg IN doses (1 per nostril administered approximately at the same time), as documented in the FDA label [5], were used to construct a nasal PK model. A transit compartment model with two transition compartments was used to describe the delay between the nasal spray and plasma concentration profile. The following system of ODEs was used to characterize the system.


![image](https://user-images.githubusercontent.com/76440648/116604307-ef4d2480-a8fb-11eb-973d-129b5a32bbd5.png)



![image](https://user-images.githubusercontent.com/76440648/116600849-c75bc200-a8f7-11eb-8323-6c4aa5999ee2.png)



![image](https://user-images.githubusercontent.com/76440648/116746214-21c55300-a9ca-11eb-9e4f-e5ef707f7b5d.png)






Here D, T1, T2, and N are the initial dose of nasal spray, and drug concentrations  in the 1st transit, the 2nd transit, and the central compartment, respectively. F, Ktr, Kin, CL and V are the bioavailability, transit rate, absorption rate, clearance, and volume of distribution, respectively. The following values were used based on model fitting: F = 0.6349, Ktr = 0.004741 s-1, Kin = 0.0001775 s-1, CL = 89 ml/s, V = 3224 ml. In line with the FDA label, the 3rd dose is administered into the same nostril as the 1st dose, and the 4th dose the 2nd. A 15% reduction in bioavailability for the 3rd and 4th doses was applied to account for likely loss of drug (e.g. overflow) and/or reduced absorption due to repeat dosing in the same nostril.

For the PK of naloxone following intramuscular injection, a model with 2 transition, 1 central, and 1 peripheral (N2) compartments was adopted.


![image](https://user-images.githubusercontent.com/76440648/116601362-6d0f3100-a8f8-11eb-9163-47251a7fedcf.png)



![image](https://user-images.githubusercontent.com/76440648/140965429-b5175186-66dc-4a5f-8289-e5207558c61f.png)




![image](https://user-images.githubusercontent.com/76440648/116746305-47eaf300-a9ca-11eb-8d35-97dbfe47033d.png)





![image](https://user-images.githubusercontent.com/76440648/116746401-6e109300-a9ca-11eb-834a-90daac2ffdec.png)





Here absorption-related parameters F, Ktr, and Kin depend on each formulation so are different among IM products: the 2 mg/0.4 mL, 0.4 mg/0.4 mL, and 2 mg/2 mL formulations have values 0.7371/0.5169/0.4226 for F, 0.007599/0.005563/0.002946 s-1 for Ktr, and 0.007603/109.5/110.8 s-1 for Kin, respectively. The other parameters, CL and V (clearance and volume distribution for the central compartment), as well as CLi and V2 (inter-compartment clearance and volume distribution for the peripheral compartment), are considered to be the same for all IM formulations and take the values 36.03 mL/s (CL), 135.4 L (V), 138.3 mL/s (CLi) and 140.3 L (V2), respectively.

# Simulate Clinical Studies for Fentanyl and Buprenorphine

The receptor binding model was combined with PK models for opioids and/or naloxone to simulate clinical ventilation studies for buprenorphine [4] and fentanyl [3]. The fentanyl and buprenorphine PK models after IV bolus injection were described by 3-compartment models [3, 4] with following equations.


![image](https://user-images.githubusercontent.com/76440648/116604209-d2185600-a8fb-11eb-94e7-ba1dc9091989.png)



![image](https://user-images.githubusercontent.com/76440648/116603638-253dd900-a8fb-11eb-964a-64b609324ce1.png)



![image](https://user-images.githubusercontent.com/76440648/116604366-04c24e80-a8fc-11eb-9f5b-ff5eec969274.png)




![image](https://user-images.githubusercontent.com/76440648/116604448-24f20d80-a8fc-11eb-8ed3-e32f0b666fd7.png)





Here C1, C2, C3 and E are opioid concentrations in the 1st (central), 2nd (peripheral), 3rd (peripheral), and effective compartments, respectively. K12, K21, K13, and K31 are distribution rates from the central to peripheral and the peripheral to central compartments, respectively. Kout is the elimination rate, and K1 is the biophase equilibration rate constant between the central and effective compartment. 

The concentration in the effective compartment E can be used as L in equation 1 which, together with each ligand (opioid or naloxone)’s own kinetic binding parameters Kon, Koff, and n, can be used to derive the time course of the (fraction of) mu receptor -bound opioid RL.

For buprenorphine, a linear transduction model as described in Yassen et al. [1, 4] was used to link the fraction of receptor bound by buprenorphine (RL) to the ventilation response with the following equation:



![image](https://user-images.githubusercontent.com/76440648/116746607-bdef5a00-a9ca-11eb-946a-6813d753169f.png)



Here V and V0 are a patient’s minute ventilation volume (Vm) after and before the use of opioids, respectively. V0 was assumed to be 1. RL is the buprenorphine-occupied mu receptor, and Rtotal is the total amount of receptor (the sum of free, opioid-occupied, and naloxone-occupied receptors), which was assumed to be 1. The parameter α is the intrinsic activity of each opioid and takes a value between 0 and 1. The α values for buprenorphine was estimated to be 0.56 (coefficient of variation 5.6%), based on pharmacokinetic-pharmacodynamic analysis of respiratory depression in healthy volunteers [1]. Our model was able to reproduce clinical data showing buprenorphine-induced ventilation depression and naloxone-mediated reversal. See [Buprenorphine_Depression](https://github.com/FDA/Mechanistic-PK-PD-Model-to-Rescue-Opiod-Overdose/blob/main/Clinical_Comparison_all/Clinical_Comparison_Buprenorphine/figs/Buprenorphine_IV_Naloxone_IV_Full_timepoints.pdf).

For fentanyl, it was estimated that the relationship between its concentration and the ventilation is non-linear and has different parameters for naïve vs chronic users [3].


![image](https://user-images.githubusercontent.com/76440648/116605897-fffe9a00-a8fd-11eb-86b0-08e3ebc9df11.png)


Here VB and V(t) are minute ventilation volume (mL/min) at baseline and after opioid treatment, respectively. C(t) is the opioid concentration in the effective compartment (E in equation 12 and 13), and C50 is the concentration that causes 50% reduction of ventilation. The parameter α combines receptor reserve and intrinsic ligand activity, and is assumed to be 1 for both chronic and naïve users [3]. The parameter C50 is 420 and 1140 ng/L for naïve and chronic users, respectively [3].

To simulate competitive binding between opioid and naloxone we needed to reparametrize the above equation to use the fraction of opioid-bound mu receptor (LR). To achieve this goal, we took advantage of the well-known linear relationship between ventilation and carbon dioxide (CO2) at steady state [6]:


![image](https://user-images.githubusercontent.com/76440648/116606088-363c1980-a8fe-11eb-8a22-d860c59991ea.png)


Here V is the ventilation, G is the gain of the ventilatory control system, PeCO2 is the end-tidal CO2 pressure, and B is the extrapolated CO2 pressure where apnea would occur (apneic threshold) [6]. Opioids are known to be able to increase B, causing a parallel shift of the ventilation-PeCO2 curve. In addition, there are reports of opioids causing a reduction of the slope of the ventilation-PeCO2 curve, corresponding to a reduction of G [6]. In our work we found that, to fully account for the difference between naïve and chronic users, it is necessary to assume opioids have an effect on both G and B:


![image](https://user-images.githubusercontent.com/76440648/116632614-985c4500-a925-11eb-992a-efd5c25a95af.png)



![image](https://user-images.githubusercontent.com/76440648/116632658-af9b3280-a925-11eb-88c4-0138f45ec9f6.png)


Here Bmax is the maximum increase of B due to the binding of drug to the mu receptor. RL is the fraction (between 0 and 1) of mu receptor bound by the drug, and P1 and P2 are two parameters that control the increase of the drug effects with increasing RL. Incorporating equations 16 and 17 into 15, we have


![image](https://user-images.githubusercontent.com/76440648/116632799-f6892800-a925-11eb-94e6-fe0c6fa0c074.png)


Here VB and G are the baseline minute ventilation volume (L/min) and baseline slope of the ventilation-PeCO2 curve without opioids, respectively. For the clinical study we are trying to simulate, VB is fixed at ~20 L/min [3], and the baseline G was estimated to be 0.42 L/min/mmHg [6]. To estimate the parameters P1, Bmax, and P2, we sampled a wide range of fentanyl concentrations C(t) and calculated the corresponding V(t) in equation 14, and then fitted equation 18 to V(t) (RL in equation 18 was calculated by using fentanyl mu receptor binding parameters in equation 1) to estimate the pharmacodynamic (PD) parameters P1, Bmax, P2. The resulting set of parameters are P1 = 5.2 (9), Bmax = 29.65 (20) mm Hg, P2 = 1.629 (2.365), with values in parentheses for chronic opioid users, and values outside of parentheses for naïve users. For both naïve and chronic users, P1 is much greater than P2, suggesting at lower opioid doses (small RL) the main pharmacological effect is the increase of B rather than decrease of G. Compared to naïve users, chronic opioid users have a smaller Bmax, suggesting a smaller ventilation depression at such dose range (low dose, small RL). At high opioid dose (RL towards 1), the high value of P1 for chronic users causes a rapid reduction of G and abrupt ventilation depression. Such a pattern can be seen in [Ventilation_vs_Occupancy](https://github.com/FDA/Mechanistic-PK-PD-Model-to-Rescue-Opiod-Overdose/blob/main/Clinical_Comparison_all/Clinical_Comparison_Fentanyl/figs/simple_curves.pdf). This parametrized equation 18 can reproduce clinically observed ventilation data in the presence of various doses of fentanyl for both [naïve](https://github.com/FDA/Mechanistic-PK-PD-Model-to-Rescue-Opiod-Overdose/blob/main/Clinical_Comparison_all/Clinical_Comparison_Fentanyl/figs/Naive_IFV_justp4.pdf) and [chronic](https://github.com/FDA/Mechanistic-PK-PD-Model-to-Rescue-Opiod-Overdose/blob/main/Clinical_Comparison_all/Clinical_Comparison_Fentanyl/figs/Chronic_IFV_justp4.pdf) opioid users. 

Of note, these parameters and experimental results are used to predict isohypercapnic ventilation, which may differ from the scenario wherein an individual is breathing room air (real-world conditions).  Additional work is ongoing to extend these equations to better describe such conditions.  


## References

1.	Yassen, A., et al., Mechanism-based PK/PD modeling of the respiratory depressant effect of buprenorphine and fentanyl in healthy volunteers. Clin Pharmacol Ther, 2007. 81(1): p. 50-8.
2.	Chang, K.C., et al., Uncertainty Quantification Reveals the Importance of Data Variability and Experimental Design Considerations for in Silico Proarrhythmia Risk Assessment. Frontiers in Physiology, 2017. 8(917).
3.	Algera, M.H., et al., Tolerance to Opioid-Induced Respiratory Depression in Chronic High-Dose Opioid Users: A Model-Based Comparison With Opioid-Naive Individuals. Clin Pharmacol Ther, 2020.
4.	Yassen, A., et al., Mechanism-based pharmacokinetic-pharmacodynamic modelling of the reversal of buprenorphine-induced respiratory depression by naloxone : a study in healthy volunteers. Clin Pharmacokinet, 2007. 46(11): p. 965-80.
5.	FDA Label Intransal Naloxone
6.	Olofsen, E., et al., Modeling the non-steady state respiratory effects of remifentanil in awake and propofol-sedated healthy volunteers. Anesthesiology, 2010. 112(6): p. 1382-95.

