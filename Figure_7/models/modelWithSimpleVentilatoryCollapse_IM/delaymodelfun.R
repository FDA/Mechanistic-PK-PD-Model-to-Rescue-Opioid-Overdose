modelfun <- function(Time, State, Pars){
currenttime<-unclass(as.POSIXct(strptime(date(),"%c")))[1] 
if(currenttime - Pars["starttime"]>=Pars["timeout"])
 stop("timeout!"); 

toosmallidx<-State<1E-9&State>-1E-9
State[toosmallidx]<-0
  with(as.list(c(State, Pars)), {
ReactionFlux1=(1-F1)*ktr*D
ReactionFlux2=ktr*F1*D
ReactionFlux3=ktr*NT1
ReactionFlux4=1*kin*NT2
ReactionFlux5=kout2*PlasmaN
ReactionFlux6=k2*PlasmaN*1e6/(327.27)
ReactionFlux7=k2*N
ReactionFlux8=kout*PlasmaF
ReactionFlux9=k12*PlasmaF
ReactionFlux90=k13*PlasmaF
ReactionFlux10=k21*C2
ReactionFlux100=k31*C3
ReactionFlux11=k1*1e6*PlasmaF*1000/10.5/Mmass
ReactionFlux12=k1*L
ReactionFlux13=A1*(1-CAR-CBR)*exp(n*log(L*fL))
ReactionFlux14=B1*CAR
ReactionFlux15=A2*(1-CAR-CBR)*exp(n2*log(N*fN))
ReactionFlux16=B2*CBR

#assisting function: given some state variables calculate intermediate variables
calc_intermediate<-function(C_B_co2=C_B_co2, C_B_o2=C_B_o2, C_T_co2=C_T_co2,C_T_o2=C_T_o2,
		P_A_co2=P_A_co2,P_A_o2=P_A_o2,yo2=yo2,yco2=yco2){
	

#prepare to calculate CO2 and O2 concentration in mixed venus: mixing brain venus and tissue venus
#first from brain
if(C_B_co2<0){C_B_co2=0}
#Use Henry's law
#dissolved CO2 in brain tissue
i_C_B_co2_dissolved=C_B_co2 - C_B_hco3  #brain HCO3 concentration in brain is said to be 26 mEq/L in 2001 paper. 
#26 mEq/L = 26 mmol/L = 22.4*26/1000 = 0.5824 L(STPD)/L
i_P_B_co2 = i_C_B_co2_dissolved/alpha_co2

#then assuming brain CO2 pressure is the same as brain venus CO2 pressure, and calculate brain venus CO2 concentration
i_P_Vb_co2=i_P_B_co2
#use Spencer 1979 equation
#need to brain venus O2 pressure too; use Henry's law directly
if(C_B_o2<0){C_B_o2=0}
i_P_B_o2=C_B_o2/alpha_o2   #no need to calculate "dissolved O2 in brain"
#then assuming brain O2 pressure is the same as brain venus O2 pressure
i_P_Vb_o2=i_P_B_o2;
F2=i_P_Vb_co2*(1+beta2*i_P_Vb_o2)/(K2*(1+alpha2*i_P_Vb_o2))
i_C_Vb_co2=Z*C2Spencer*F2^(1/a2)/(1+F2^(1/a2))
i_F1=i_P_Vb_o2*(1+beta1*i_P_Vb_co2)/(K1*(1+alpha1*i_P_Vb_co2))
i_C_Vb_o2=Z*C1Spencer*i_F1^(1/a1)/(1+i_F1^(1/a1))

#now repeat the process above to get tissue venus CO2 and O2 concentration
if(C_T_co2<0){C_T_co2=0}
i_C_T_co2_dissolved=C_T_co2 - C_T_hco3  
i_P_T_co2 = i_C_T_co2_dissolved/alpha_co2
i_P_Vt_co2=i_P_T_co2
#need tissue venus O2 pressure too; use Henry's law directly
if(C_T_o2<0){C_T_o2=0}
i_P_T_o2=C_T_o2/alpha_o2
#then assuming tissue O2 pressure is the same as tissue venus O2 pressure
i_P_Vt_o2=i_P_T_o2;
F2=i_P_Vt_co2*(1+beta2*i_P_Vt_o2)/(K2*(1+alpha2*i_P_Vt_o2))
i_C_Vt_co2=Z*C2Spencer*F2^(1/a2)/(1+F2^(1/a2))
i_F1=i_P_Vt_o2*(1+beta1*i_P_Vt_co2)/(K1*(1+alpha1*i_P_Vt_co2))
i_C_Vt_o2=Z*C1Spencer*i_F1^(1/a1)/(1+i_F1^(1/a1))

#now calculate end capillary CO2 and O2 concentration, assuming CO2 pressure here is the same as alevolar CO2 pressure
if(P_A_co2<0){P_A_co2=0}
i_P_e_co2=P_A_co2
i_P_e_o2=P_A_o2
F2=i_P_e_co2*(1+beta2*i_P_e_o2)/(K2*(1+alpha2*i_P_e_o2))
i_C_e_co2=Z*C2Spencer*F2^(1/a2)/(1+F2^(1/a2))
i_F1=i_P_e_o2*(1+beta1*i_P_e_co2)/(K1*(1+alpha1*i_P_e_co2))
i_C_e_o2=Z*C1Spencer*i_F1^(1/a1)/(1+i_F1^(1/a1))

#now need to calculate local blood flow in brain and tissue
i_Qb=Qb0*(1 + yo2 + yco2)  #yo2 and yco2 are two state variables so always have values
i_Qt=Qt0*(1+rou*yo2)
#now mix them to get mixed venus CO2 concentration
i_C_V_co2=(i_Qb*i_C_Vb_co2+i_Qt*(i_C_Vt_co2))/(i_Qb+i_Qt) #Qb + Qt = total cardiac output
i_C_V_o2=(i_Qb*i_C_Vb_o2+i_Qt*(i_C_Vt_o2))/(i_Qb+i_Qt)
i_Q=i_Qb+i_Qt                                     #Q is also pulmonary blood flow


#arterial co2 and o2 concentration
i_C_a_co2=(1-s)*i_C_e_co2+s*i_C_V_co2
i_C_a_o2=(1-s)*i_C_e_o2+s*i_C_V_o2
#arterial co2 and o2 partial pressure, clinically observable; using reverse of Spensor equation;
#co2
D2=K2*(i_C_a_co2/(Z*C2Spencer - i_C_a_co2))^a2
D1=K1*(i_C_a_o2/(Z*C1Spencer - i_C_a_o2))^a1
S2=-(D2 + alpha2*D2*D1)/(beta1+alpha1*beta2*D1)
S1=-(D1 + alpha1*D1*D2)/(beta2+alpha2*beta1*D2)
r1= -(1+beta1*D2-beta2*D1-alpha1*alpha2*D1*D2)/(2*(beta2+alpha2*beta1*D2))
r2= -(1+beta2*D1-beta1*D2-alpha2*alpha1*D2*D1)/(2*(beta1+alpha1*beta2*D1))
i_P_a_co2=r2 + (r2^2 - S2)^0.5
i_P_a_o2=r1 + (r1^2 - S1)^0.5

return(list(P_B_co2=i_P_B_co2, P_Vb_co2=i_P_Vb_co2,P_B_o2=i_P_B_o2, P_Vb_o2=i_P_Vb_o2,
			C_Vb_co2=i_C_Vb_co2, C_Vb_o2=i_C_Vb_o2,P_T_co2=i_P_T_co2, P_Vt_co2=i_P_Vt_co2,
			P_T_o2=i_P_T_o2, P_Vt_o2=i_P_Vt_o2, C_Vt_co2=i_C_Vt_co2, C_Vt_o2=i_C_Vt_o2,
			C_e_co2=i_C_e_co2, C_e_o2=i_C_e_o2,Qb=i_Qb, Qt=i_Qt, Q=i_Q,
			C_V_co2=i_C_V_co2, C_V_o2=i_C_V_o2,
			C_a_co2=i_C_a_co2,C_a_o2=i_C_a_o2,P_a_co2=i_P_a_co2,P_a_o2=i_P_a_o2))
}
intermediate_list<-calc_intermediate(C_B_co2=C_B_co2, C_B_o2=C_B_o2, C_T_co2=C_T_co2, C_T_o2=C_T_o2,
		P_A_co2=P_A_co2,P_A_o2=P_A_o2,yo2=yo2,yco2=yco2)
P_B_co2=intermediate_list[[1]]; P_Vb_co2=intermediate_list[[2]];
P_B_o2=intermediate_list[[3]]; P_Vb_o2=intermediate_list[[4]];
C_Vb_co2=intermediate_list[[5]]; C_Vb_o2=intermediate_list[[6]];
P_T_co2=intermediate_list[[7]]; P_Vt_co2=intermediate_list[[8]];
P_T_o2=intermediate_list[[9]]; P_Vt_o2=intermediate_list[[10]];
C_Vt_co2=intermediate_list[[11]]; C_Vt_o2=intermediate_list[[12]];
C_e_co2=intermediate_list[[13]]; C_e_o2=intermediate_list[[14]];
Qb=intermediate_list[[15]]; Qt=intermediate_list[[16]]; Q=intermediate_list[[17]];
C_V_co2=intermediate_list[[18]]; C_V_o2=intermediate_list[[19]];
C_a_co2=intermediate_list[[20]];C_a_o2=intermediate_list[[21]];
P_a_co2=intermediate_list[[22]]; P_a_o2=intermediate_list[[23]]
P_e_co2=P_A_co2; P_e_o2=P_A_o2


#now ODE for co2 concentration in brain
ReactionFlux19=1/V_B*(Qb*(C_a_co2 - C_Vb_co2)+M_B_co2)
#if(!is.na(C_B_co2)&C_B_co2<0){ReactionFlux19= -C_B_co2}

#now ODE for o2 concentration in brain

if(P_B_o2>6){
	M_B_o2<-M_B_o2_0
}else{
	M_B_o2<-1/6*M_B_o2_0*P_B_o2
}

ReactionFlux20=1/V_B*(Qb*(C_a_o2 - C_Vb_o2)+M_B_o2)  
#if(!is.na(C_B_o2)&C_B_o2<0){ReactionFlux20= -C_B_o2}

#now ODE for co2 concentration in tissue
ReactionFlux21=1/V_T*(Qt*(C_a_co2 - C_Vt_co2)+M_T_co2)
#if(!is.na(C_T_co2)&C_T_co2<0){ReactionFlux21= -C_T_co2}
#now ODE for o2 concentration in tissue

if(P_T_o2>6){
	M_T_o2<-M_T_o2_0
}else{
	M_T_o2<-1/6*M_T_o2_0*P_T_o2
}

ReactionFlux22=1/V_T*(Qt*(C_a_o2 - C_Vt_o2)+M_T_o2)
#if(!is.na(C_T_o2)&C_T_o2<0){ReactionFlux22= -C_T_o2}

#now the ventilation ODE
#delay func

if(1>0){
	peripherialdelay<-K_Dp/Q; centraldelay<-K_Dc/Q;
	
	history<-Time - peripherialdelay
	if(history<=0){
		Plag_P_a_co2<-P_a_co2; Plag_P_a_o2<-P_a_o2
		Plag_C_B_co2=C_B_co2
	}else{
		Plag_C_B_co2=lagvalue(history,14)
		Plag_intermediate_list<-calc_intermediate(C_B_co2=Plag_C_B_co2,
				C_B_o2=lagvalue(history,15), C_T_co2=lagvalue(history,16), C_T_o2=lagvalue(history,17),
				P_A_co2=lagvalue(history,12),P_A_o2=lagvalue(history,13),
				yo2=lagvalue(history,19),yco2=lagvalue(history,18))
		Plag_P_a_co2<-Plag_intermediate_list[[22]]; Plag_P_a_o2<-Plag_intermediate_list[[23]]
    }
	
	history<-Time - centraldelay
	if(history<=0){
		Clag_P_B_co2<- P_B_co2
	}else{
		Clag_intermediate_list<-calc_intermediate(C_B_co2=lagvalue(history,14),
				C_B_o2=lagvalue(history,15), C_T_co2=lagvalue(history,16), C_T_o2=lagvalue(history,17),
				P_A_co2=lagvalue(history,12),P_A_o2=lagvalue(history,13),
				yo2=lagvalue(history,19),yco2=lagvalue(history,18))
		Clag_P_a_co2<-Clag_intermediate_list[[22]]; Clag_P_a_o2<-Clag_intermediate_list[[23]]
		Clag_P_B_co2<-Clag_intermediate_list[[1]]
	}
}
#blood flow control
psai_co2=(Aco2+Bco2/(1+Cco2*exp(Dco2*log(P_a_co2))))/(Aco2+Bco2/(1+Cco2*exp(Dco2*log(P_a_co2_0))))-1
ReactionFlux24=1/tau_co2*(psai_co2 - yco2)
psai_o2=c1o2*(exp(-P_a_o2/c2o2)-exp(-P_a_o2_0/c2o2))
ReactionFlux25=1/tau_o2*(psai_o2-yo2)

#ventilation control
#chemoreceptor firing frequency
f_pc=K_fpc*log(P_a_co2/Bp)*(f_pc_max+f_pc_min*exp((P_a_o2 - P_a_o2_c)/K_pc))/(1+exp((P_a_o2-P_a_o2_c)/K_pc))
Plag_f_pc=K_fpc*log(Plag_P_a_co2/Bp)*(f_pc_max+f_pc_min*exp((Plag_P_a_o2 - P_a_o2_c)/K_pc))/(1+exp((Plag_P_a_o2-P_a_o2_c)/K_pc))
#peripherial drive ODE
#opioid attenuation effect
AV1=1 - CAR^P1
ReactionFlux26=1/tau_Dp*(-Dp + AV1*G_Dp*(Plag_f_pc - f_pc_0))
#note that Dp has unit L/min, but that's OK: tau_Dp has unit s, so the unit of this ODE is
# L/min/s, meaning "every second this much Dp (L/min) is changed". Eventually the total ventilation
#calculated from Dp and Dc and W has the unit L/min, but it will be converted to L/s as "Venti"
#to be coupled with the O2/CO2 dynamics (which strictly has the time unit s)
#central drive ODE
AV2=1 - CAR^P2
ReactionFlux27=1/tau_Dc*(-Dc + AV2*G_Dc*(Clag_P_B_co2 - P_B_co2_0))

#hypoxic depression
if(P_B_o2 < theta_Hmin){Hstat<-1 + Gh*((theta_Hmin - P_B_o2_0)/P_B_o2_0)}
if(P_B_o2 < theta_Hmax & P_B_o2 > theta_Hmin){Hstat<-1 + Gh*((P_B_o2 - P_B_o2_0)/P_B_o2_0)}
if(P_B_o2 > theta_Hmax){Hstat<-1 + Gh*((theta_Hmax - P_B_o2_0)/P_B_o2_0)}
ReactionFlux28=1/tau_h*(Hstat - alphaH)

#calculate alveolar ventilation
#opioid effects on wakefulness drive
Kf= K0*CAR^P3


totalVentilation=W - Kf + alphaH*Dp + Dc
Venti=totalVentilation*0.66/60         #Venti unit is L/s
if(Venti<0){Venti=0}
ReactionFlux17=1/V_A*(Venti*(P_I_co2 - P_A_co2) + lumbda*Q*(1-s)*(C_V_co2 - C_e_co2))
#if(!is.na(P_A_co2)&P_A_co2<0){ReactionFlux17= -P_A_co2}

#now we can finish the ODE for P_A_o2
ReactionFlux18=1/V_A*(Venti*(P_I_o2 - P_A_o2) + lumbda*Q*(1-s)*(C_V_o2 - C_e_o2))
#if(!is.na(P_A_o2)&P_A_o2<0){ReactionFlux18= -P_A_o2}

dD=-ReactionFlux2-ReactionFlux1
dNT1=ReactionFlux2-ReactionFlux3
dNT2=-ReactionFlux4+ReactionFlux3
dPlasmaN=(1/V1)*(ReactionFlux4-ReactionFlux5)
dN=ReactionFlux6-ReactionFlux7
dPlasmaF=-ReactionFlux8-ReactionFlux9+ReactionFlux10+ReactionFlux100-ReactionFlux90
dC2=ReactionFlux9-ReactionFlux10
dC3=ReactionFlux90-ReactionFlux100
dL=ReactionFlux11-ReactionFlux12
dCAR=ReactionFlux13-ReactionFlux14
dCBR=ReactionFlux15-ReactionFlux16
dP_A_co2=ReactionFlux17
dP_A_o2=ReactionFlux18
dC_B_co2=ReactionFlux19
dC_B_o2=ReactionFlux20
dC_T_co2=ReactionFlux21
dC_T_o2=ReactionFlux22

dyco2=ReactionFlux24
#dyco2=0
dyo2=ReactionFlux25
#dyo2=0
dDp=ReactionFlux26
dDc=ReactionFlux27
dalphaH=ReactionFlux28

#if(is.nan(P_Vb_co2)){stop(paste("NaN occurred at Time ",Time,sep=""))}
    return(list(c(dD,dNT1,dNT2,dPlasmaN,dN,dPlasmaF,dC2,dC3,dL,dCAR,dCBR,
		dP_A_co2,dP_A_o2,dC_B_co2,dC_B_o2,dC_T_co2,dC_T_o2,
		dyco2, dyo2, dDp,dDc, dalphaH)
,
c(P_a_co2=P_a_co2,C_a_co2=C_a_co2, P_a_o2=P_a_o2,C_a_o2=C_a_o2,
  C_V_o2=C_V_o2, C_V_co2=C_V_co2, C_B_o2=C_B_o2, C_B_co2=C_B_co2,
  P_e_co2=P_e_co2, P_e_o2=P_e_o2, C_e_co2=C_e_co2,C_e_o2=C_e_o2,
  C_Vb_o2=C_Vb_o2, C_Vb_co2=C_Vb_co2, P_Vb_o2=P_Vb_o2,P_Vb_co2=P_Vb_co2,
  C_Vt_o2=C_Vt_o2, C_Vt_co2=C_Vt_co2, P_Vt_o2=P_Vt_o2,P_Vt_co2=P_Vt_co2,
  P_B_co2=P_B_co2,  Qt=Qt,Venti=Venti, 
  Plag_f_pc=Plag_f_pc, Plag_P_a_co2=Plag_P_a_co2, 
  Plag_P_a_o2=Plag_P_a_o2,
  Qt=Qt,Qb=Qb, Q=Q,
  P_B_o2=P_B_o2, Clag_P_B_co2=Clag_P_B_co2,
  W=W - Kf
  )
)  #extra output for debugging
)  
})}