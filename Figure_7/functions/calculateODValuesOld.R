calculateODValues<-function(naloxone_doseN){
	ET<- crossing(pp[[1]][[1]][,"Brain O2 partial pressure (mm Hg)"], pp[[1]][[1]][,"time"], DTh)[[2]][1]
	print(paste("ET=",ET/60,"minutes"))
	print(paste("ventilationThresholdDropTime=",ventilationThresholdDropTime/60,"minutes"))
	print(paste("minimum PaO2=",min(pp[[1]][[1]][,"Arterial O2 partial pressure (mm Hg)"]),"mm Hg"))
	for(Nconditions in 1:naloxonedoseN){
		pp[[1]][[Nconditions]]<- cbind(pp[[1]][[Nconditions]],pp[[2]][[Nconditions]])
		if (min(pp[[1]][[Nconditions]][,"Brain O2 partial pressure (mm Hg)"])<DTh){
			ST<- crossing(pp[[1]][[Nconditions]][,"Brain O2 partial pressure (mm Hg)"], pp[[1]][[Nconditions]][,"time"], DTh)[[2]][2]
			RT<-ST-ET
			RTFromNA<-ST-ventilationThresholdDropTime
			if (is.na(ST)|RT>CRT){outcome<-"death"}else{outcome<-"rescue"}
			if (Nconditions==1){		
				if(opioid=="fentanyl"){#fentanyl
					OPCLT<-crossing(pp[[1]][[Nconditions]][,"PlasmaF"]*1000/7.031, pp[[1]][[Nconditions]][,"time"], 3.7)[[2]][2]
					OPCMT<-crossing(pp[[1]][[Nconditions]][,"PlasmaF"]*1000/7.031, pp[[1]][[Nconditions]][,"time"], 9.96)[[2]][2]
					OPCUT<-crossing(pp[[1]][[Nconditions]][,"PlasmaF"]*1000/7.031, pp[[1]][[Nconditions]][,"time"], 25.2)[[2]][2]
				}else if(opioid=="carfentanil"){
					OPCLT<-crossing(pp[[1]][[Nconditions]][,"PlasmaF"]*1000/10.5, pp[[1]][[Nconditions]][,"time"], 0.2)[[2]][2]
					OPCMT<-crossing(pp[[1]][[Nconditions]][,"PlasmaF"]*1000/10.5, pp[[1]][[Nconditions]][,"time"], 0.387)[[2]][2]
					OPCUT<-crossing(pp[[1]][[Nconditions]][,"PlasmaF"]*1000/10.5, pp[[1]][[Nconditions]][,"time"], 0.837)[[2]][2]
				}
				print(paste("TOPCU=",(OPCUT-ET-CRT)/60,"minutes")) #time after death for plama concentration to reach OPCU
				print(paste("TOPCM=",(OPCMT-ET-CRT)/60,"minutes"))
				print(paste("TOPCL=",(OPCLT-ET-CRT)/60,"minutes"))
			}
			print(paste("naloxone dose=",Nconditions))
			print(outcome)
			print(paste("RT=",RT/60,"minutes"))
			print(paste("RTFromNA=",RTFromNA/60,"minutes"))
		}else{print("no risk")}
	}
}

#	tryCatch(
#			{ETBrainO2<- crossing(pp[[1]][[1]][,"Brain O2 partial pressure (mm Hg)"], pp[[1]][[1]][,"time"], DThBrainO2)[[2]][1]; 
#				print(paste("ETBrainO2=",ETBrainO2/60,"minutes"))},
#			error=print("Brain O2 doesn't go below dangerous threshold"))
#	tryCatch(,error=print("Arterial O2 doesn't go below dangerous threshold"))