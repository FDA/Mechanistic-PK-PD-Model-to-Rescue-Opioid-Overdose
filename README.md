#Update In Progress

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

[Fentanyl_parms](https://github.com/FDA/Mechanistic-PK-PD-Model-to-Rescue-Opiod-Overdose/blob/main/Ligand_Data/Fentanyl_A_parameters/parmsAlgera2020.R) contains the full set of binding and PK parameters necessary for simulating opioid overdose and subsequent rescue using intramuscular naloxone for the optimal scenario. 

## Carfentanil

Carfentanil optimal binding parameters can be found here: [Carfentanil](https://github.com/FDA/Mechanistic-PK-PD-Model-to-Rescue-Opiod-Overdose/blob/main/Ligand_Data/Carfentanil_parameters/CARFENTANIL_pars.txt). The full probability distribution of parameters estimated through uncertainty quantification for Carfentanil can be found in [boot_pars.csv](https://github.com/FDA/Mechanistic-PK-PD-Model-to-Rescue-Opiod-Overdose/blob/main/Ligand_Data/Carfentanil_parameters/boot_pars.csv) 

Carfentanil PK parameters utilized fentanyl parameters as a baseline and were modified to match the long half-life (~45 minutes) seen in clinical studies

## Naloxone 
Naloxone optimal binding parameters can be found here: [Naloxone](https://github.com/FDA/Mechanistic-PK-PD-Model-to-Rescue-Opiod-Overdose/blob/main/Ligand_Data/NALOXONE/NALOXONE_pars.txt). While the full probability distribution of parameters estimated through uncertainty quantification for Naloxone can be found in [boot_pars.csv](https://github.com/FDA/Mechanistic-PK-PD-Model-to-Rescue-Opiod-Overdose/blob/main/Ligand_Data/NALOXONE/boot_pars.csv)
 


# Generating Opioid Overdose and Rescue Figures


# Receptor Binding Model
In developing the mu receptor binding model, association and dissociation assays were conducted for each of the 9 opioid agonists and naloxone.  The binding model uses the following ordinary differential equation (ODE) to describe the system: 

dRL/dt=Kon* L^n*R-Koff*RL (1)


where L, R, and RL are free ligands (opioids or naloxone), free (unoccupied) mu receptors, and ligand-occupied receptors, respectively. Kon, Koff, and n are the association rate, dissociation rate, and the slope of the dose-effect relationship, respectively. The concentration of receptors is represented as fractions of the total receptor R_total. Assuming R_total is 1, it follows that R = 1 – RL, and, as such, no ODE is needed for the amount (fraction) of free receptor R. There is also no ODE for the ligand L, a simplification necessary to use fraction of receptors rather than real units for receptors in the ODE system, which is a requirement for virtual patients simulations [1]. Such a simplification assumes  there is minimal change of the free ligand concentration due to binding, which was supported by the observation that even at the lowest ligand concentration, only ~5% ligand was lost due to binding to mu receptors in our experimental systems (data not shown). 

The parameters were estimated by fitting the model to the time course of association and dissociation data. Single point estimation of each parameter was obtained by fitting to the mean values of experimental data. The variability in experimental data and uncertainty in parameter estimation were captured and quantified by a boot strapping strategy developed earlier [2]. This resulted in 2000 parameter sets that describe the joint distribution of Kon, Koff, and n based on experimental data.

# Pharmacokinetic Models

Compartmental pharmacokinetic (PK) models for fentanyl [3] and carfentanil were used in this study. Briefly, a three-compartment was used to describe the time course of plasma concentration after an intravenous bolus injection of fentanyl and carfentanil. A biophase equilibrium model was used to characterize the transfer of ligands from the plasma to the effective compartment. 

For the PK of naloxone following intramuscular (IM) administration, plasma concentration profiles after a 2 mg IM naloxone dose as documented in the FDA labels [x,xx], were used to construct a IM PK model for formulations of 2mg/2ml and 2mg/0.4ml naloxone. A transit compartment model with two transition compartments, 1 central and 1 peripheral compartment was used to describe the delay between the tissue and plasma concentration profile. 
 The following system of ODEs was used to characterize the system.


dT1/dt=Ktr*D*F*e^(-Ktr*t)-Ktr*T1 (2)

dT2/dt=Ktr*T1-Kin*T2 (3)

dP/dt=Kin/V*T2-CL/V*P+CLi/V*P2-CLi/V*P  (4)

dP2/dt=CLi/V2*P-CLi/V2*P2  (5)






Here D, T1, T2, P and P2 are the initial dose of IM naloxone, and drug concentrations in the 1st transit, the 2nd transit, the central compartment, and the peripheral compartment, respectively. F, Ktr, Kin, CL, CLi V and V2 are the bioavailability, transit rate, absorption rate, clearance, intercompartmental clearance, central volume of distribution, and peripheral volume of distribution respectively. The following optimal values were used based on model fitting: (insert optimal parameters)

#Physiological Models

The physiological component combines gas oxygen and carbon dioxide storage, metabolism, and exchange, as well as ventilatory control and blood flow control. It was implemented primarily based on the work of Magosso, Ursino and colleagues [x-x] with a few modifications to better recapitulate clinical data. These include:

Preventing the combined ventilatory drives from being zero to better match hyperoxic and normocapnic scenarios

Reproducing ventilation responses to hypoxia under hypercapnia and normocapnia

Matching changes in cerebral blood flow due to changes in carbon dioxide partial pressure

Allowing prolonged hypoxia to result in decreased cardiac output and eventual cardiac arrest.   	

#Pharmacodynamic Models



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

