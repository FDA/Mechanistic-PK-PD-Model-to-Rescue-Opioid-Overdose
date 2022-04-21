patientWrapper<-function(patientidx,doseidx, max_naloxone_doseN=6,naloxone_dose,delay, threshold){
	#idx is the idx of the job/core; or the index of the opioid concentration
	#naloxone_doseN is the dosing number of naloxone (0-4)
	#delay is the gap between two adjacent naloxone doses (s)
	#threshold is the ventilation volume at which the first dose of naloxone will be delivered
	#deSolve and model should have been loaded in each core
	#opioid dose (uniqdose) should have been exported to each core
	opioid_dose<-uniqdose[doseidx] #setting opioid dose from vector containing multiple opioid doses (uniqdose)
	outlist<-list(); 
	crossingtimelist<-list(); 
	ventilist<-list();
	print(patientidx)
	print(allpatients[patientidx,])
	this.par<-unlist(allpatients[patientidx,]) #this is pars; states should have been loaded in each core
	truepar<-this.par[!names(this.par)=="initialdelay" & !names(this.par)=="Dose"] 
	#first simulating no naloxone
	dosingoutput<-dosingevents(opioid_dose,opioid_time=0) 
	fulltimes<-dosingoutput[[1]]; 
	eventdata<-dosingoutput[[2]]
	truepar["starttime"]<-unclass(as.POSIXct(strptime(date(),"%c")))[1]
	#calculate time of cardiovascular collapse================================================================================================================================================================================================================================
	#defining parameters for calculation of time of cardiovascular collpase================================================
	adding_threshold_CO2="no" #define whether collapse is PaCO2 dependent or not
	adding_threshold_O2="yes" #define whether collapse is PaO2 dependent or not
	tsh_value_o2=15 #mm Hg #PaO2 threshold below which collapse happens
	tsh_value_co2=52 #mm Hg #PaCO2 threshold above which collapse happens 
	delaytime=220
	truepar["tsh_value_o2"]=tsh_value_o2 #store PaO2 threshold in truepar so that it can be passed on to next model run
	truepar["tsh_value_co2"]=tsh_value_co2 #store PaCO2 threshold in truepar so that it can be passed on to next model run
	if (adding_threshold_CO2=="yes" & adding_threshold_O2=="yes") {
		P_a_co2_thrsh=tsh_value_co2 
		P_a_o2_thrsh=tsh_value_o2 
	}
	if (adding_threshold_CO2=="no" & adding_threshold_O2=="yes") {
		P_a_co2_thrsh=1000 #PaCO2 threshold is set to very high value so that collpase is not PaCO2 dependent
		P_a_o2_thrsh=tsh_value_o2
	}
	if (adding_threshold_CO2=="yes" & adding_threshold_O2=="no") {
		P_a_co2_thrsh=tsh_value_co2 
		P_a_o2_thrsh=0 #PaO2 threshold is set to zero so that collpase is not PaO2 dependent
	}
	#======================================================================================================================
	Preout1=fundedewithEvent(states=states,fulltimes=fulltimes,truepar=truepar,namesyout=namesyout,eventdata) #running the model (without the collapse?)
	P_thrsh_O2=Preout1[,c("time","Arterial O2 partial pressure (mm Hg)")][Preout1[,c("Arterial O2 partial pressure (mm Hg)")]<=P_a_o2_thrsh ,] #store values of time and PaO2 for times where PaO2 < PaO2 threshold so times where collapse should happen due to PaO2 
	P_thrsh_CO2=Preout1[,c("time","Arterial CO2 partial pressure (mm Hg)")][Preout1[,c("Arterial CO2 partial pressure (mm Hg)")]>=P_a_co2_thrsh ,] #store values of time and PaCO2 for times where PaCO2 > PaCO2 threshold so times where collapse should happen due to PaCO2 
	
#	print(P_thrsh_O2)
	
	if (length(P_thrsh_O2)!=0) { #if there are times where PaO2 can cause collapse
		truepar["CA_delay_o2"]=P_thrsh_O2[1,"time"]+delaytime #calculate and store the time where collpase should happen due to PaO2 in truepar
	}else{print("O2 doesn't cross the threshold")}
	if (length(P_thrsh_CO2)!=0) { #if there are times where PaCO2 can cause collapse
		truepar["CA_delay_co2"]=P_thrsh_CO2[1,"time"]+delaytime #calculate and store the time where collpase should happen due to PaCO2 in truepar
	} #else{print("CO2 doesn't cross the threshold")}
	CA_YN0="yes"
	if(length(P_thrsh_O2)!=0){ #if there are times where PaO2 can cause collapse
		colapse_p=Preout1[round(Preout1[,"time"],1)==round(truepar["CA_delay_o2"],1),"Arterial O2 partial pressure (mm Hg)"] #get PaO2 value at the time collpase is supposed to start
		if (P_a_o2_thrsh<colapse_p) {truepar["CA_delay_o2"]=10000;CA_YN0="no"}  #if PaO2 at collaspse time > PaO2 threshold collapse time is set to a very late time so that collapse doesn't happen
	}
	J_YN0P=CA_YN0;
#	names(J_YN0)="V0"
	#=========================================================================================================================================================================================================================================================================
CA_YN0="yes"
out <- fundedewithEvent(states, fulltimes, truepar, namesyout,eventdata)
if(min(out[,"Total blood flow (l/min)"])>4){
	CA_YN0="no"
}
J_YN0=CA_YN0;
#out <- fundedewithEvent(states, fulltimes, truepar, namesyout,eventdata)
	patientventi<-out[,"Minute ventilation (l/min)"]
	patientventi[patientventi<0]<-0
	try({crossinglist <- crossing(patientventi,out[,"time"],threshold)},silent=T)
	ventilist[[1]]<- patientventi
	rm(patientventi)
	outlist[[1]]<- out
	#----------Rescue mean time calculation----------------------------------
	t1P=out[,c("time")][out[,"Brain O2 partial pressure (mm Hg)"]<=20]
	tt1=t1P[1];tt2=t1P[length(t1P)];tt3=t1P[length(t1P)]-t1P[1];
	
	if (CA_YN0=="no" & length(t1P)==0) { #no CA, no Pbo2>20mmhg
		print("dd")
		tt1=0;tt2=0;tt3=0;
	}
	if (CA_YN0=="no" & length(t1P)!=0) { #no CA, yes Pbo2<20mmhg
		tt1=t1P[1];tt2=t1P[length(t1P)];tt3=t1P[length(t1P)]-t1P[1];
	}
	if (CA_YN0=="yes" & length(t1P)==0) { #yes CA, no Pbo2>20mmhg
		tt1=0;tt2=0;tt3=60*60;
	}
	if (CA_YN0=="yes" & length(t1P)!=0) {
		tt1=t1P[1];tt2=t1P[length(t1P)];tt3=60*60; #yes CA, no Pbo2<20mmhg
	}
	
	t1PV=c(tt1,tt2,tt3)
	
	
	
#	print(t1P)
	#-------------------------------------------------------------------------
	if(!exists("crossinglist")){  #no crossing
		return(list(outlist,ventilist))
	}else{
		crossingtime <- crossinglist[[2]][1]
		crossingtimelist[[1]]<-crossingtime
		rm(out)                     #release memory
		rm(crossinglist)
	}
	J_YN1=c()
	J_YN1P=c()
			t1PVn=c()
	for(naloxone_doseN in 1:max_naloxone_doseN){
		truepar["CA_delay_o2"]<-10000

		dosingoutput<-dosingevents(opioid_dose, opioid_time=0,naloxone_dose=2000000,naloxone_time=crossingtime+this.par["initialdelay"], naloxone_doseN=naloxone_doseN,gap=delay)
		fulltimes<-dosingoutput[[1]]; eventdata<-dosingoutput[[2]]
		truepar["starttime"]<-unclass(as.POSIXct(strptime(date(),"%c")))[1]
		#calculate time of cardiovascular collapse================================================================================================================================================================================================================================
#	print(truepar)	
#	print("---------------")
	Preout1=fundedewithEvent(states=states,fulltimes=fulltimes,truepar=truepar,namesyout=namesyout,eventdata) #running the model (without the collapse?)
		P_thrsh_O2=Preout1[,c("time","Arterial O2 partial pressure (mm Hg)")][Preout1[,c("Arterial O2 partial pressure (mm Hg)")]<=P_a_o2_thrsh ,] #store values of time and PaO2 for times where PaO2 < PaO2 threshold so times where collapse should happen due to PaO2 
		P_thrsh_CO2=Preout1[,c("time","Arterial CO2 partial pressure (mm Hg)")][Preout1[,c("Arterial CO2 partial pressure (mm Hg)")]>=P_a_co2_thrsh ,] #store values of time and PaCO2 for times where PaCO2 > PaCO2 threshold so times where collapse should happen due to PaCO2 
		if (length(P_thrsh_O2)!=0) { #if there are times where PaO2 can cause collapse
			truepar["CA_delay_o2"]=P_thrsh_O2[1,"time"]+delaytime #calculate and store the time where collpase should happen due to PaO2 in truepar
		}else{print("O2 doesn't cross the threshold")}
		
		if (length(P_thrsh_CO2)!=0) { #if there are times where PaCO2 can cause collapse
			truepar["CA_delay_co2"]=P_thrsh_CO2[1,"time"]+delaytime #calculate and store the time where collpase should happen due to PaCO2 in truepar
		}else{print("CO2 doesn't cross the threshold")}
		CA_YN="yes"
		if(length(P_thrsh_O2)!=0){ #if there are times where PaO2 can cause collapse
			colapse_p=Preout1[round(Preout1[,"time"],1)==round(truepar["CA_delay_o2"],1),"Arterial O2 partial pressure (mm Hg)"] #get PaO2 value at the time collpase is supposed to start
#			colapse_p=Preout1[(Preout1[,"time"])==(truepar["CA_delay_o2"]),"Arterial O2 partial pressure (mm Hg)"] #get PaO2 value at the time collpase is supposed to start
#			
#			print(colapse_p)
			if (P_a_o2_thrsh<colapse_p) {truepar["CA_delay_o2"]=10000;CA_YN="no"}  #if PaO2 at collaspse time > PaO2 threshold collapse time is set to a very late time so that collapse doesn't happen
		}
		J_YN1P[naloxone_doseN]=CA_YN
		
		#=========================================================================================================================================================================================================================================================================
	CA_YN="yes"
	out <- fundedewithEvent(states, fulltimes, truepar, namesyout,eventdata)
		if(min(out[,"Total blood flow (l/min)"])>4){
			CA_YN="no"
		}
		J_YN1[naloxone_doseN]=CA_YN
		patientventi<-out[,"Minute ventilation (l/min)"]
		patientventi[patientventi<0]<-0
		ventilist[[naloxone_doseN+1]]<-patientventi
		try({crossinglist <- crossing(patientventi,out[,"time"],threshold)}) #crossinglist has to exist!
		outlist[[naloxone_doseN+1]]<-out
		#----------Rescue mean time calculation
		t1Pn=out[,c("time")][out[,"Brain O2 partial pressure (mm Hg)"]<=20]
		tt1=t1Pn[1];tt2=t1Pn[length(t1Pn)];tt3=t1Pn[length(t1Pn)]-t1Pn[1];
		
#		print(t1Pn)
#		print(length(t1Pn))
		print("---------")
#		print(out[,c("Brain O2 partial pressure (mm Hg)")][out[,"Brain O2 partial pressure (mm Hg)"]<=20])
		if (CA_YN=="no" & length(t1Pn)==0) { #no CA, no Pbo2<20mmhg
			print("dd")
			tt1=0;tt2=0;tt3=0;
		}
		if (CA_YN=="no" & length(t1Pn)!=0) { #no CA, yes Pbo2<20mmhg
			tt1=t1Pn[1];tt2=t1Pn[length(t1Pn)];tt3=t1Pn[length(t1Pn)]-t1Pn[1];
		}
		if (CA_YN=="yes" & length(t1Pn)==0) { #yes CA, no Pbo2>20mmhg
			tt1=0;tt2=0;tt3=60*60;
		}
		if (CA_YN=="yes" & length(t1Pn)!=0) {
			tt1=t1Pn[1];tt2=t1Pn[length(t1Pn)];tt3=60*60; #yes CA, no Pbo2<20mmhg
		}
		
		t1PVn=rbind(t1PVn,c(tt1,tt2,tt3))
		print(CA_YN)
		
		print(t1PVn)
		print(tt1)
		print(tt2)
		print(tt3)
		#--------------------------------------
		rm(out)
		if(length(crossinglist[[2]])==1){ #only initial crossing; no revoery
		}else{
			crossingtimelist[[naloxone_doseN+1]]<- crossinglist[[2]][2]-crossinglist[[2]][1]+this.par["initialdelay"]
		}#if crossing
		rm(crossinglist); rm(patientventi);rm(eventdata)
	}#for naloxone_doseN
	J_YNP2=c(J_YN0P,J_YN1P)
	J_YN2=c(J_YN0,J_YN1)
	t1PVtot=rbind(t1PV,t1PVn)
	Tot=cbind(J_YN2,t1PVtot)
	TotP=cbind(J_YN2,t1PVtot)
#	J_YN22=cbind(J_YN0,J_YN1)
#	J_YN222=rbind(J_YN0,J_YN1)
#	colnames(J_YN2)=c(patientidx,"dose")
#	write.csv(J_YN2,sprintf("output/population90/J%s.csv",patientidx))
#	write.csv(t1PVtot,sprintf("output/population90/T%s.csv",patientidx))

	write.csv(Tot,sprintf("%s/All%s.csv",populationFolder,ipop))
#	write.csv(TotP,sprintf("%s/All_Pre%s.csv",populationFolder,ipop))
	
#	write.csv(J_YN22,"J_YN22.csv")
#	
#	write.csv(J_YN222,"J_YN222.csv")
	
	list(outlist,ventilist,(crossingtime+this.par["initialdelay"]))
}