fVP4 <- function(ind){
#	source("fundede.R")
	
	print("VP4")
#ind_Selected=ind[c("Kout","K12","K21","K31","K13","K1","P1","P2","P3","K0")]
#ask Dr lI to check it , VP1 and Vp3 has the same parameter for fitting ?
	
#	
ind_Selected=ind[c("kout","k12","k21","k31","k13","k1","P1","P2","P3","K0","VP")]

#????? is it bolus injection? like VP3 

#print(ind)
#print(ind_Selected)
#dddd
nptarget=names(truepar)%in%names(ind_Selected)
truepar[nptarget]=(ind_Selected)	
truepar=unlist(truepar)
source("models/delaystates.R")
truepar["starttime"]<-unclass(as.POSIXct(strptime(date(),"%c")))[1]
fulltimes=seq(0,3600,10) # donot use a large time step
#print(truepar)
#print(states)
	states["PlasmaF"]=0 #double check it 
	
	dyn.load("models/delaymymod.so")
	
#	try({out <- dede(states, fulltimes, "derivs", parms=truepar, dllname="delaymymod",initfunc="initmod", nout=33, rtol=1e-9, atol=1e-9, method="lsoda")});
#	colnames(out)[(length(states)+2):(length(states)+length(namesyout)+1)]=namesyout
	out=fundede(states=states,fulltimes=fulltimes,truepar=truepar,namesyout=namesyout)
	
#out <- dede(y=states, times=fulltimes, func=modelfun, parms=truepar, rtol=1e-6, atol=1e-9, method="lsoda")
#print("VP3")
#out <- ode(y=states, times=fulltimes, "derivs", parms=truepar, dllname="delaymymod",initfunc="initmod", nout=11, rtol=1e-3, atol=1e-6, method="lsoda")
#colnames(out)[24:34]=c("C_a_co2","P_a_co2","C_a_o2","C_V_co2","C_e_co2","C_Vb_co2","C_Vt_co2","delayedP_A_o2","Dc","Dp","W") 

	
	#---- Control Slope With Fentanyl =0 
	#Co2_Res=(max(out_slop[,"Venti"])-min(out_slop[,"Venti"]))/(max(out_slop[,"P_a_co2"])-min(out_slop[,"P_a_co2"]))*100
	

	
	# Vector of states-------------------------------------
	Vstate=out[out[,"time"]==15*60 | out[,"time"]==30*60 | out[,"time"]==45*60 | out[,"time"]==60*60, ]
	# turn of d(PACO2 and dPAo2) -------------------------
	truepar["offO2"]=0
	truepar["offCo2"]=0


	eventtimes1=seq(0,4*60) 
	fulltimes=eventtimes1
	All_Co2_Res=c()
	
	#becase of bad parameter maybe "P_a_co2" is nan or na or -inf ... so here we put a if , to avoid next step oterhwise it stop 
	if (is.na(Vstate[1,"P_a_co2"]) | is.nan(Vstate[1,"P_a_co2"]) | Vstate[1,"P_a_co2"]>10000 | Vstate[1,"P_a_co2"]< -10000) {EVP4=10000} else {
for (i in 1:nrow(Vstate))	{
	# event for 20mmkg in 4 min ---------------------------------
		#double check it boss
	eventdose1=seq(Vstate[i,"P_a_co2"],(Vstate[i,"P_a_co2"]+20),5/60) #by 241 (from times) injection , (each time x+5/60) 
	#eventdose1=seq(0,20,5/60) #by 241 (from times) injection , (each time x+5/60) 
	eventdata_VP4<-data.frame(var="P_a_co2",time=eventtimes1,value=eventdose1,method="replace")
	
	statesslop=Vstate[i,names(states)]
#	print(Vstate[i,"time"])
	statesslop["PlasmaF"]=0.5 #double check it 
	
#	try({out_slop <- dede(statesslop, fulltimes, "derivs", parms=truepar, dllname="delaymymod",initfunc="initmod", nout=33, rtol=1e-9, atol=1e-9, method="lsoda",events=list(data=eventdata_VP4))});
#	colnames(out_slop)[(length(statesslop)+2):(length(statesslop)+length(namesyout)+1)]=namesyout
		out_slop=fundede(states=statesslop,fulltimes=fulltimes,truepar=truepar,namesyout=namesyout)
	
#out_slop <- dede(y=statesslop, times=fulltimes, func=modelfun, parms=truepar, rtol=1e-6, atol=1e-9, method="lsoda",events=list(data=eventdata_VP4))
	
#print(head(out_slop))
#	print(tail(out_slop))
#print(out_slop[,"P_a_co2"])
#is it always 20mmHg ?   (max(out_slop[,"P_a_co2"])-min(out_slop[,"P_a_co2"]))
Co2_Res=(max(out_slop[,"Venti"])-min(out_slop[,"Venti"]))/(max(out_slop[,"P_a_co2"])-min(out_slop[,"P_a_co2"]))*100 # divide by control slope 
All_Co2_Res=rbind(All_Co2_Res,c(Vstate[i,"time"],Co2_Res))

}
	colnames(All_Co2_Res)=c("time","Co2_Res")
#print(All_Co2_Res)
#------------slop CO2-------this should be checked by zhihua
	SlopCO2_exp=read.csv("expdata/CO2_Slope_Response_Rebreathing.csv",header=T)/100
#	print(SlopCO2_exp)
	SlopCO2_exp["time"]=round(SlopCO2_exp["time"]*60,-1)
#	print("11111")
	#SlopCO2_exp=SlopCO2_exp[SlopCO2_exp[,"time"]<=3600,]
	#idxPeaktimeSlopCO2=ypred1[,"time"]%in%SlopCO2_exp[,"time"]
	idxPeaktimeSlopCO2=SlopCO2_exp[,"time"]%in%All_Co2_Res[,"time"]
#	print("222")
	
	yexpPSlopCO2=SlopCO2_exp[idxPeaktimeSlopCO2,"Mean_Slope"]	
	print(All_Co2_Res[,"Co2_Res"])
	print(yexpPSlopCO2)
	
	ESlopCO2=sum((All_Co2_Res[,"Co2_Res"]-yexpPSlopCO2)^2)
if (length(All_Co2_Res[,"Co2_Res"])!= length(yexpPSlopCO2)) {print("VP4 has a error ! "); stopp}
#print("000000000000")
	

	EVP4=ESlopCO2
	}
}