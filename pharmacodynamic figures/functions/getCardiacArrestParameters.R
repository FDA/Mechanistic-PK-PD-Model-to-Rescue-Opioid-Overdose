#last edited by: Anik Chaturbedi
#on: 2023-05-16
getCardiacArrestParameters<-function(truepar,dosingoutput){	
	truepar["CA_delay_o2"]<-2*simulationTime #default time for start of cardiovascular collpase (seconds) *set to double that of simulation time so that it dosen't happen by deafult #10000
	truepar["tsh_value_o2"]=tsh_value_o2 #store PaO2 threshold in truepar so that it can be passed on to next model run
	truepar["tsh_value_co2"]=tsh_value_co2 #store PaCO2 threshold in truepar so that it can be passed on to next model run
	#defining parameters for calculation of time of cardiovascular collpase
	if (adding_threshold_CO2=="yes" & adding_threshold_O2=="yes") {
		P_a_co2_thrsh=tsh_value_co2 
		P_a_o2_thrsh=tsh_value_o2 
	}
	if (adding_threshold_CO2=="no" & adding_threshold_O2=="yes") {
		P_a_co2_thrsh=1e10 #PaCO2 threshold is set to very high value so that collpase is not PaCO2 dependent (mm Hg)
		P_a_o2_thrsh=tsh_value_o2 
	}
	if (adding_threshold_CO2=="yes" & adding_threshold_O2=="no") {
		P_a_co2_thrsh=tsh_value_co2 
		P_a_o2_thrsh=0 #PaO2 threshold is set to zero so that collpase is not PaO2 dependent (mm Hg)
	}
	#======================================================================
	#calculate time of cardiovascular collapse====================================================================================================
	truepar["starttime"]<-unclass(as.POSIXct(strptime(date(),"%c")))[1]
	Preout1=fundedewithEvent(states=states,fulltimes=dosingoutput[[1]],truepar=truepar,namesyout=namesyout,dosingoutput[[2]]) #running the model (without the collapse?)
	P_thrsh_O2=Preout1[,c("time","Arterial O2 partial pressure (mm Hg)")][Preout1[,c("Arterial O2 partial pressure (mm Hg)")]<=P_a_o2_thrsh ,] #store values of time and PaO2 for times where PaO2 < PaO2 threshold so times where collapse should happen due to PaO2 
	P_thrsh_CO2=Preout1[,c("time","Arterial CO2 partial pressure (mm Hg)")][Preout1[,c("Arterial CO2 partial pressure (mm Hg)")]>=P_a_co2_thrsh ,] #store values of time and PaCO2 for times where PaCO2 > PaCO2 threshold so times where collapse should happen due to PaCO2 
	if (length(P_thrsh_O2)!=0) { #if there are times where PaO2 can cause collapse
		truepar["CA_delay_o2"]=P_thrsh_O2[1,"time"]+delayInCardiovascularCollpase #calculate and store the time where collpase should happen due to PaO2 in truepar
	}
	if (length(P_thrsh_CO2)!=0) { #if there are times where PaCO2 can cause collapse
		truepar["CA_delay_co2"]=P_thrsh_CO2[1,"time"]+delayInCardiovascularCollpase #calculate and store the time where collpase should happen due to PaCO2 in truepar
	}
	if(length(P_thrsh_O2)!=0){ #if there are times where PaO2 can cause collapse
		colapse_p=Preout1[round(Preout1[,"time"],1)==round(truepar["CA_delay_o2"],1),"Arterial O2 partial pressure (mm Hg)"] #get PaO2 value at the time collpase is supposed to start
		if (P_a_o2_thrsh<colapse_p) {
			
			Preout2=Preout1[round(Preout1[,"time"],1)>round(truepar["CA_delay_o2"],1),]
			P_thrsh_O2=Preout2[,c("time","Arterial O2 partial pressure (mm Hg)")][Preout2[,c("Arterial O2 partial pressure (mm Hg)")]<=P_a_o2_thrsh ,] #store values of time and PaO2 for times where PaO2 < PaO2 threshold so times where collapse should happen due to PaO2 
			if (length(P_thrsh_O2)!=0) { #if there are times where PaO2 can cause collapse
				print("renarcotization induced CA")
				truepar["CA_delay_o2"]=P_thrsh_O2[1,"time"]+delayInCardiovascularCollpase #calculate and store the time where collpase should happen due to PaO2 in truepar
				print(truepar["CA_delay_o2"])
			}else {
				truepar["CA_delay_o2"]=2*simulationTime;
			}
		}  #if PaO2 at collaspse time > PaO2 threshold collapse time is set to a very late time so that collapse doesn't happen
	}
	#=============================================================================================================================================
	return(truepar)
}