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

Binding paramters (Kon, Koff and n) for the opioid ligands and naloxone used in clinical simulations as well as carfentanil can be found in their corresponding folder in “Ligand_Data/”. Optimal parameters are saved in the “pars.txt” file in the ligand folder. The “boot_pars.csv” file contains the uncertainty population for these binding parameters. The script parmsAlgera2020.R contains the full set of binding and PK parameters necessary for simulating opioid overdose and subsequent rescue using intranasal naloxone. 

# Generating Clinical Simulation and Comparison Figures

## Buprenorphine Clinical Simulation
To recreate the buprenorphine clinical simulation, run “Clinical_Comparison_Buprenorphine_IV_Naloxone_IV.R” in (Clinical_Comparison_Buprenorphine/). The figure, automatically saved in figs/, will depict respiratory depression in response to 0.2mg buprenorphine followed by reversal by a 90-minute infusion of naloxone started 30 minutes after buprenorphine dosing.

## Fentanyl Clinical Simulations
To recreate the occupancy-ventilation curve and fentanyl clinical simulation figures run the script “IV_opiod.R” in “Clinical_Comparison_Fentanyl/” and set the parser argument to either “Chronic” or “Naive”.  
For example to produce the chronic figure: run Rscript IV_opiod.R -p “Chronic”. Figures will automatically be saved in figs/.
## Remifentanil Clinical Comparison 

To recreate the remifentanil clinical comparison figures run the script “IV_opiod.R” in “Clinical_Comparison_Remifentanil/”. Figures will automatically be saved in figs/ 

 

# Receptor Binding Model
In developing the mu receptor binding model, association and dissociation assays were conducted for each of the 9 opioid agonists and naloxone.  The binding model uses the following ordinary differential equation (ODE) to describe the system: 

dRL/dt=Kon* L^n*R-Koff*RL (1)


![image](https://user-images.githubusercontent.com/76440648/116600098-eb6ad380-a8f6-11eb-977d-70269713ee13.png)


where L, R, and RL are free ligands (opioids or naloxone), free (unoccupied) mu receptors, and ligand-occupied receptors, respectively. Kon, Koff, and n are the binding rate, unbinding rate, and the slope of the dose-effect relationship, respectively. The concentration of receptors is represented as fractions of the total receptor R_total. Assuming R_total is 1, it follows that R = 1 – RL, and hence no ODE is needed for the amount (fraction) of free receptor R. There is also no ODE for the ligand L, because such simplification is needed to use fraction of receptors rather than real units for receptors in the ODE system, which is required in virtual patients simulations later [1]. Such a simplification assumes  there is minimal change of the free ligand concentration due to binding, which was supported by the observation that even at the lowest ligand concentration, only ~5% ligand was lost due to binding to mu receptors in our experimental systems (data not shown). 

The parameters were estimated by fitting the model to the time course of association and dissociation data. Single point estimation of each parameter was obtained by fitting to the mean values of experimental data. The variability in experimental data and uncertainty in parameter estimation was captured and quantified by a boot strapping strategy developed earlier [2], which resulted in 2000 parameter sets that describe the joint distribution of Kon, Koff, and n based on experimental data.

# Pharmacokinetic Models

Compartmental pharmacokinetic (PK) models for fentanyl [3] and buprenorphine [1] were used in this study. Briefly, a three-compartment was used to describe the time course of plasma concentration after an intravenous bolus  injection of buprenorphine and fentanyl. A biophase equilibrium model was used to characterize the transfer of ligands from the plasma to the effective compartment. A two-compartment model developed by Yassen et al. [4] was used to describe the PK of naloxone following continuous intravenous infusion.

For the PK of naloxone following nasal administration, plasma concentration profiles after a 4 mg intranasal (IN) naloxone hydrochloride dose in a single nostril and two 4 mg IN doses (1 per nostril administered approximately at the same time), as documented in the FDA label [5], were used to construct a nasal PK model. A transit compartment model with two transition compartments was used to describe the delay between the nasal spray and plasma concentration profile. The following system of ODEs was used to characterize the system.

dT1/dt=Ktr*D*F*e^(-Ktr*t)-Ktr*T1 (2)

![image](https://user-images.githubusercontent.com/76440648/116604307-ef4d2480-a8fb-11eb-973d-129b5a32bbd5.png)


dT2/dt=Ktr*T1-Kin*T2 (3)

![image](https://user-images.githubusercontent.com/76440648/116600849-c75bc200-a8f7-11eb-8323-6c4aa5999ee2.png)


dP/dt=Kin/V*T2-CL/V*P (4)

![image](https://user-images.githubusercontent.com/76440648/116601094-0db12100-a8f8-11eb-9a73-810ad94b6aa7.png)





Here D, T1, T2, and P are the initial dose of nasal spray, and drug concentrations  in the 1st transit, the 2nd transit, and the central compartment, respectively. F, Ktr, Kin, CL and V are the bioavailability, transit rate, absorption rate, clearance, and volume of distribution, respectively. The following values were used based on model fitting: F = 0.6349, Ktr = 0.004741 s-1, Kin = 0.0001775 s-1, CL = 89 ml/s, V = 3224 ml. In line with the FDA label, the 3rd dose is administered into the same nostril as the 1st dose, and the 4th dose the 2nd. A 15% reduction in bioavailability for the 3rd and 4th doses was applied to account for likely loss of drug (e.g. overflow) and/or reduced absorption due to repeat dosing in the same nostril.

For the PK of naloxone following intramuscular injection, a model with 2 transition, 1 central, and 1 peripheral compartments was adopted.

dT1/dt=Ktr*D*F*e^(-Ktr*t)-Ktr*T1 (5)

![image](https://user-images.githubusercontent.com/76440648/116601362-6d0f3100-a8f8-11eb-9163-47251a7fedcf.png)



dT2/dt=Ktr*T1-Kin*T2 (6)

![image](https://user-images.githubusercontent.com/76440648/116601521-9af47580-a8f8-11eb-98c6-c94f709a3fee.png)



dP/dt=Kin/V*T2-CL/V*P+CLi/V*P2-CLi/V*P  (7)

![image](https://user-images.githubusercontent.com/76440648/116601922-050d1a80-a8f9-11eb-8199-ac90fc4f7729.png)


dP2/dt=CLi/V2*P-CLi/V2*P2  (8)

![image](https://user-images.githubusercontent.com/76440648/116602932-5538ac80-a8fa-11eb-9e5d-805ab62e3c38.png)



Here absorption-related parameters F, Ktr, and Kin depend on each formulation so are different among IM products: the 2 mg/0.4 mL, 0.4 mg/0.4 mL, and 2 mg/2 mL formulations have values 0.7371/0.5169/0.4226 for F, 0.007599/0.005563/0.002946 s-1 for Ktr, and 0.007603/109.5/110.8 s-1 for Kin, respectively. The other parameters, CL and V (clearance and volume distribution for the central compartment), as well as CLi and V2 (inter-compartment clearance and volume distribution for the peripheral compartment), are considered to be the same for all IM formulations and take the values 36.03 mL/s (CL), 135.4 L (V), 138.3 mL/s (CLi) and 140.3 L (V2), respectively.

# Simulate Clinical Studies for Fentanyl and Buprenorphine

The receptor binding model was combined with PK models for opioids and/or naloxone to simulate clinical ventilation studies for buprenorphine [4] and fentanyl [3]. The fentanyl and buprenorphine PK models after IV bolus injection were described by 3-compartment models [3, 4] with following equations.

dC1/dt=K21*C2 + K31*C3-K12*C1 - K13*C3 -Kout*C1 (9)

![image](https://user-images.githubusercontent.com/76440648/116604209-d2185600-a8fb-11eb-94e7-ba1dc9091989.png)




dC2/dt=K12*C1-K21*C2 (10)

![image](https://user-images.githubusercontent.com/76440648/116603638-253dd900-a8fb-11eb-964a-64b609324ce1.png)



dC3/dt=K13*C1-K31*C3 (11)


![image](https://user-images.githubusercontent.com/76440648/116604366-04c24e80-a8fc-11eb-9f5b-ff5eec969274.png)





dE/dt=K1*(C1-E) (12)

![image](https://user-images.githubusercontent.com/76440648/116604448-24f20d80-a8fc-11eb-8ed3-e32f0b666fd7.png)





Here C1, C2, C3 and E are opioid concentrations in the 1st (central), 2nd (peripheral), 3rd (peripheral), and effective compartments, respectively. K12, K21, K13, and K31 are distribution rates from the central to peripheral and the peripheral to central compartments, respectively. Kout is the elimination rate, and K1 is the biophase equilibration rate constant between the central and effective compartment. 

The concentration in the effective compartment E can be used as L in equation 1 which, together with each ligand (opioid or naloxone)’s own kinetic binding parameters Kon, Koff, and n, can be used to derive the time course of the (fraction of) mu receptor -bound opioid RL.

For buprenorphine, a linear transduction model as described in Yassen et al. [1, 4] was used to link the fraction of receptor bound by buprenorphine (RL) to the ventilation response with the following equation:

〖E= E〗_0*(1- α*(RL/R_total ) (13)

![image](https://user-images.githubusercontent.com/76440648/116604660-6aaed600-a8fc-11eb-983a-70284428cbc5.png)


Here E and E0 are a patient’s minute ventilation volume (Vm) after and before the use of opioids, respectively. E0 was assumed to be 1. RL is the buprenorphine-occupied mu receptor, and Rtotal is the total amount of receptor (the sum of free, opioid-occupied, and naloxone-occupied receptors), which was assumed to be 1. The parameter α is the intrinsic activity of each opioid and takes a value between 0 and 1. The α values for buprenorphine was estimated to be 0.56 (coefficient of variation 5.6%), based on pharmacokinetic-pharmacodynamic analysis of respiratory depression in healthy volunteers [1]. Our model was able to reproduce clinical data showing buprenorphine-induced ventilation depression and naloxone-mediated reversal (Clinical_Comparison_all/Clinical_Comparison_Buprenorphine/figs/Buprenorphine_IV_Naloxone_IV_Full_timepoints.pdf).

For fentanyl, it was estimated that the relationship between its concentration and the ventilation is non-linear and has different parameters for naïve vs chronic users [3].

V(t)=VB*(1-      (α*(C(t)/C50))⁄((1+C(t)/C50))    (14)

![image](https://user-images.githubusercontent.com/76440648/116605897-fffe9a00-a8fd-11eb-86b0-08e3ebc9df11.png)


Here VB and V(t) are minute ventilation volume (mL/min) at baseline and after opioid treatment, respectively. C(t) is the opioid concentration in the effective compartment (E in equation 12 and 13), and C50 is the concentration that causes 50% reduction of ventilation. The parameter α combines receptor reserve and intrinsic ligand activity, and is assumed to be 1 for both chronic and naïve users [3]. The parameter C50 is 420 and 1140 ng/L for naïve and chronic users, respectively [3].

To simulate competitive binding between opioid and naloxone we needed to reparametrize the above equation to use the fraction of opioid-bound mu receptor (LR). To achieve this goal, we took advantage of the well-known linear relationship between ventilation and carbon dioxide (CO2) at steady state [6]:

V=G*(PeCO2-B)   (15)

![image](https://user-images.githubusercontent.com/76440648/116606088-363c1980-a8fe-11eb-8a22-d860c59991ea.png)


Here V is the ventilation, G is the gain of the ventilatory control system, PeCO2 is the end-tidal CO2 pressure, and B is the extrapolated CO2 pressure where apnea would occur (apneic threshold) [6]. Opioids are known to be able to increase B, causing a parallel shift of the ventilation-PeCO2 curve. In addition, there are reports of opioids causing a reduction of the slope of the ventilation-PeCO2 curve, corresponding to a reduction of G [6]. In our work we found that, to fully account for the difference between naïve and chronic users, it is necessary to assume opioids have an effect on both G and B:

B(drug)=B+Bmax*〖RL〗^P1 (16)

G(drug)=G-G*〖RL〗^P2 (17)

Here Bmax is the maximum increase of B due to the binding of drug to the mu receptor. RL is the fraction (between 0 and 1) of mu receptor bound by the drug, and P1 and P2 are two parameters that control the increase of the drug effects with increasing RL. Incorporating equations 16 and 17 into 15, we have

V(drug)=(G-G*〖RL〗^P1 )*(VB/G-Bmax*〖RL〗^P2)       (18)

Here VB and G are the baseline minute ventilation volume (L/min) and baseline slope of the ventilation-PeCO2 curve without opioids, respectively. For the clinical study we are trying to simulate, VB is fixed at ~20 L/min [3], and the baseline G was estimated to be 0.42 L/min/mmHg [6]. To estimate the parameters P1, Bmax, and P2, we sampled a wide range of fentanyl concentrations C(t) and calculated the corresponding V(t) in equation 14, and then fitted equation 18 to V(t) (RL in equation 18 was calculated by using fentanyl mu receptor binding parameters in equation 1) to estimate the pharmacodynamic (PD) parameters P1, Bmax, P2. The resulting set of parameters are P1 = 5.2 (9), Bmax = 29.65 (20) mm Hg, P2 = 1.629 (2.365), with values in parentheses for chronic opioid users, and values outside of parentheses for naïve users. For both naïve and chronic users, P1 is much greater than P2, suggesting at lower opioid doses (small RL) the main pharmacological effect is the increase of B rather than decrease of G. Compared to naïve users, chronic opioid users have a smaller Bmax, suggesting a smaller ventilation depression at such dose range (low dose, small RL). At high opioid dose (LR towards 1), the high value of P1 for chronic users causes a rapid reduction of G and abrupt ventilation depression. Such a pattern can be seen in (Clinical_Comparison_all/Clinical_Comparison_Fentanyl/figs/simple_curves.pdf). This parametrized equation 18 can reproduce clinically observed ventilation data in the presence of various doses of fentanyl for both naïve (Clinical_Comparison_all/Clinical_Comparison_Fentanyl/figs/Naive_IFV_justp4.pdf) and chronic (Clinical_Comparison_all/Clinical_Comparison_Fentanyl/figs/Chronic_IFV_justp4.pdf) opioid users. 

# Predict Clinical Studies of Remifentanil
To use the model to predict the clinical ventilation data for remifentanil [7], we obtained remifentanil in vitro mu receptor binding data and estimated its binding kinetic parameters (https://github.com/FDA/Mechanistic-PK-PD-Model-to-Rescue-Opiod-Overdose/tree/main/Ligand_Data). For pharmacokinetics of remifentanil we used a 3-compartment PK model developed by Minto et al.[8]. To account for the delay between plasma concentration and clinical ventilation response, Barbenco et al. estimated a biophase equilibrium parameter Keo (corresponding to K1 in equation 12) of 0.34/min, corresponding to an apparent equilibrium half-life of ~2 min [7]. However, this equilibrium time includes two processes: the transition of remifentanil from central to effective compartment, and the binding of remifentanil to mu receptor in the effective compartment. As our in vitro data indicates that remifentanil is relatively slow (compared to fentanyl) in binding to the mu receptor (equilibrium/unbinding half-life ~ 5 min), we consider the delay between plasma concentration and observed clinical ventilation response is primarily due to the binding process, with the transit process taking very little time. We thus used an arbitrarily high K1 (6/min) in the simulation, so that the transit between central and effective compartment is very fast (equilibrium half-life ~6 seconds).

To link the fraction of receptor bound by remifentanil (RL) to the ventilation response, we used equation 18 and assumed remifentanil has the same ventilation-receptor occupancy relationship as fentanyl (by using the same PD parameters Bmax, P1, and P2 as fentanyl). We used the naïve user version of the PD parameters as Barbenco study did not recruit chronic opioid users. For the baseline minute ventilation volume (VB in equation 18), we used 13 L/min as per Figure 3 of the Barbenco study [7]. For the baseline slope of the ventilation-PeCO2 curve (G in equation 18), Barbenco study reported a two-point estimation of the baseline slope without opioids (the “0 min” line of Figure 1 of [7]), which allowed us to estimate a baseline G of 0.9 L/min/mmHg for their cohort. 

The modeling strategy above enabled us to predict the ventilation response after 0.035 mg remifentanil IV bolus injection reasonably well ( “Clinical_Comparison_all/Clinical_Comparison_Remifentanil/figs/Naive_Remifentanil_Ventilation.pdf”)

# Simulate Single Virtual Patient for Fentanyl or Carfentanil Overdose Scenarios 
## Estimation of the overdose range

The overdose scenarios were based on real world fatal overdose data. According to a study of ~500 fatal fentanyl overdose cases, the postmortem fentanyl distribution has a mean and standard deviation of 9.96 and 9.27 ng/mL, respectively [9]. We used the mean (9.96 ng/mL) and 95% percentile (25.2 ng/mL) of this fatal fentanyl overdose range and estimated the corresponding intravenous dose to be 0.93 and 1.97 mg, respectively. This estimation was based on two assumptions: significant postmortem fentanyl redistribution would not occur within this time window [10], and there was a relatively short delay between fentanyl intravenous injection and death.  As it is likely that the real-world fentanyl overdose range is lower than the fatal overdose range, we also used the lower quantile (25% percentile) of the fatal overdose range (postmortem concentration 3.7 ng/mL) and calculated the corresponding intravenous dose 0.536 mg. The carfentanil overdose range was based on a study of 17 carfentanil overdose cases, where the post postmortem carfentanil distribution has a mean of 0.387 ng/mL and we calculated the standard deviation to be 0.274 ng/mL [11]. Using the same assumptions as for fentanyl we estimated an initial intravenous dose of 0.0378, 0.06 and 0.107 mg, corresponding to the 25% (2 ng/mL), 50% (0.387 ng/mL), and 95% (0.84 ng/mL) percentile of the postmortem carfentanil fatal overdose plasma concentration range, respectively. Given that these values are based on fatal overdose cases, it is likely that the lower end of the range (25% percentile) is closer to a typical real-world opioid overdose case.

## Estimation of the time to give the first dose of naloxone

Some naloxone training materials for community members suggested respiratory rate less than 8 times/minute as one of the criteria for naloxone administration [12]. This is a 50% decrease in respiratory rate from the mean of a normal rate of 12 to 20 [13]. Since animal studies have suggested fentanyl-induced decrease of tidal volume is about half that of respiratory rate [14], we assumed a residual minute ventilation volume of roughly 40% (100*(1-0.5)*(1-0.25)) as the threshold of respiratory depression to start naloxone administration. The same threshold was used by others [15] as an “unsafe” level of respiration induced by opioids.

The choice of 40% ventilation is also supported by the following reasoning. Human beings normally need 200-300 mL oxygen per min, which can be achieved by a ventilation volume of 8-12 L/min. So, when breathing at 40% ventilation the intake of oxygen has dropped to about 100 mL/min at 3-5 L/min ventilation. Intuitively one would think this causes a drop in oxygen flux by 50%. But oxygen density (DO2) depends on the cardiac output (CO) and arterial oxygen content (CaO2). 

CaO2 = Hb (gm/dl) x 1.34 ml O2 /gm Hb x SaO2 + PaO2 x (.003 ml O2 /mm Hg/dl)

Where Hb is hemoglobin, SaO2 is hemoglobin oxygen saturation, and PaO2 is arterial oxygen pressure in millimeter of mercury (mm Hg). Hence,

DO2 = CO x ((1.38  x Hb x SpO2) + (0.003 x PaO2)) 

Which shows that an increase in cardiac output is able to compensate some part of the drop in O2 content. Since CO = HR (heart rate) x Stroke Volume, an increase in HR by 100% (e.g. from 70 to 140 beats per minute) will compensate this in large part. So, with elevated CO, even when the minute ventilation drops to 40% the oxygen density may be well above 50%.

After the minute ventilation volume drops below 40% of baseline, we assume that, there is a delay of 2.5 min to give the first dose of naloxone, accounting for potential time lost to preparing the naloxone administration kit.

## Estimation of rescue time

After naloxone administration, we simulated the ventilation time course and calculated the rescue time, which is defined as the difference between the timepoint when naloxone is first administered, and when minute ventilation volume first recovered back above certain rescue threshold. We used three levels as threshold: 20%, 40%, and 80% of the baseline minute ventilation volume. These different levels of threshold were explored because our model is based on clinical studies where the endpoint was minute ventilation volume at isohypercapnic conditions (fixed and elevated end-tidal CO2 level, leading to fixed baseline ventilation). As our pharmacodynamic equation (equation 18) allows us to adjust the baseline ventilation (VB), we set it at 15 L/min when simulating community overdose conditions. We used such an elevated baseline ventilation (compared to 6 – 8 L/min at rest) because clinical ventilation study at isohypercapnic conditions (end-tidal CO2 fixed at 50 mm Hg, leading to a constant baseline ventilation of 13 L/min) reported a remifentanil half-effect concentration C50 (see equation 14) of 1.12 – 1.36 ng/mL [7], which is slightly lower than the C50 (1.6 ng/mL) reported when remifentanil was given in real-world poikilocapnic situation [6]. As we found that the observed degree of respiratory depression is inversely correlated with the fixed baseline ventilation level in isohypercapnic conditions (see equation 18), this suggests simulating an isohypercapnic condition with a fixed baseline ventilation slightly higher than 13L/min may give an apparent C50 close to real-world poikilocapnic situation. However, this is still different from the real-world situation where, after respiratory depression had occurred, the end-tidal CO2 pressure will be increased, which can stimulate breathing and offer some spontaneous recovery of ventilation. While the exact relationship between isohypercapnic and poikilocapnic conditions are unclear, our simulation suggests that a threshold of 20% of baseline ventilation under iso(hyper)capnic conditions may correspond to about 40% of baseline ventilation under poikilocapnic conditions after about 5 minutes of equilibration which further increases thereafter. In addition, cardiac output may temporarily increase after initial respiratory depression, which can compensate some part of the drop in O2 content (see discussion about the threshold to give the 1st dose naloxone above). 

## Simulation procedure

To simulate single patient, we used best-fit parameters for receptor binding kinetics (Kon, Koff, n) and pharmacokinetics. For carfentanil, no human pharmacokinetics parameters are available, so we simply used fentanyl pharmacokinetics parameters to simulate carfentanil overdose.

At each dose, we simulated the typical patient where opioid was administered via intravenous injection, and then the minute ventilation volume was calculated continuously for up to 1 hour. When this volume dropped below 40%, we simulated naloxone administration via intranasal (IN) or intermuscular (IM) routes with a delay of 2.5 min. We then calculated the rescue time, which is defined as the difference between the timepoint when naloxone is first administered and when minute ventilation volume first recovered back above the threshold (20%, 40% or 80% of baseline ventilation). 

1.	Yassen, A., et al., Mechanism-based PK/PD modeling of the respiratory depressant effect of buprenorphine and fentanyl in healthy volunteers. Clin Pharmacol Ther, 2007. 81(1): p. 50-8.
2.	Chang, K.C., et al., Uncertainty Quantification Reveals the Importance of Data Variability and Experimental Design Considerations for in Silico Proarrhythmia Risk Assessment. Frontiers in Physiology, 2017. 8(917).
3.	Algera, M.H., et al., Tolerance to Opioid-Induced Respiratory Depression in Chronic High-Dose Opioid Users: A Model-Based Comparison With Opioid-Naive Individuals. Clin Pharmacol Ther, 2020.
4.	Yassen, A., et al., Mechanism-based pharmacokinetic-pharmacodynamic modelling of the reversal of buprenorphine-induced respiratory depression by naloxone : a study in healthy volunteers. Clin Pharmacokinet, 2007. 46(11): p. 965-80.
5.	Administration, U.F.a.D. NARCAN Nasal Spray Label. 2015; Available from: https://www.accessdata.fda.gov/drugsatfda_docs/label/2015/208411lbl.pdf.
6.	Olofsen, E., et al., Modeling the non-steady state respiratory effects of remifentanil in awake and propofol-sedated healthy volunteers. Anesthesiology, 2010. 112(6): p. 1382-95.
7.	Babenco, H.D., P.F. Conard, and J.B. Gross, The pharmacodynamic effect of a remifentanil bolus on ventilatory control. Anesthesiology, 2000. 92(2): p. 393-8.
8.	Minto, C.F., et al., Influence of age and gender on the pharmacokinetics and pharmacodynamics of remifentanil. I. Model development. Anesthesiology, 1997. 86(1): p. 10-23.
9.	System, N.D.E.W. Unintentional Fentanyl Overdoses in New Hampshire: An NDEWS HotSpot Analysis. 2017; Available from: https://ndews.org/wordpress/files/2020/07/ndews-hotspot-unintentional-fentanyl-overdoses-in-new-hampshire-final-09-11-17.pdf.
10.	Brockbals, L., et al., Time-Dependent Postmortem Redistribution of Opioids in Blood and Alternative Matrices. J Anal Toxicol, 2018. 42(6): p. 365-374.
11.	Corsi, J.N. and J.L. Dragovic, Fatal overdoses involving carfentanil: A case series. J. Forensic Science and Medicine, 2019. 5(3): p. 147-150.
12.	Health, N.O.o.S.O.o.R. Manual for Nurse Practitioners: Using a Computer-Based NaloxoneTraining Module To Prepare Community Members for Opioid-Associated Overdose Rescue. 2017.
13.	Philip, K.E., et al., The accuracy of respiratory rate assessment by doctors in a London teaching hospital: a cross-sectional study. J Clin Monit Comput, 2015. 29(4): p. 455-60.
14.	Hill, R., et al., Fentanyl depression of respiration: Comparison with heroin and morphine. Br J Pharmacol, 2020. 177(2): p. 254-266.
15.	Voscopoulos, C.J., et al., Continuous noninvasive respiratory volume monitoring for the identification of patients at risk for opioid-induced respiratory depression and obstructive breathing patterns. J Trauma Acute Care Surg, 2014. 77(3 Suppl 2): p. S208-15.

