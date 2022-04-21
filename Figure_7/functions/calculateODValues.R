calculateODValues<-function(){
	for(Nconditions in c(1)){
		pp[[1]][[Nconditions]]<- cbind(pp[[1]][[Nconditions]],pp[[2]][[Nconditions]])
		print(paste("naloxone dose=",Nconditions,"+++++++++++++++++++++++++++++++"))
		#just checking plasma concentration===================================================================================================================================================
#		if (Nconditions==1){	
#			if(opioid=="fentanyl"){#fentanyl
#				OPCLT<-crossing(pp[[1]][[1]][,"PlasmaF"]*1000/10.5, pp[[1]][[1]][,"time"], 3.7)[[2]][2]
#				OPCMT<-crossing(pp[[1]][[1]][,"PlasmaF"]*1000/10.5, pp[[1]][[1]][,"time"], 9.96)[[2]][2]
#				OPCUT<-crossing(pp[[1]][[1]][,"PlasmaF"]*1000/10.5, pp[[1]][[1]][,"time"], 25.2)[[2]][2]
#			}else if(opioid=="carfentanil"){
#				OPCLT<-crossing(pp[[1]][[1]][,"PlasmaF"]*1000/10.5, pp[[1]][[1]][,"time"], 0.2)[[2]][2]
#				OPCMT<-crossing(pp[[1]][[1]][,"PlasmaF"]*1000/10.5, pp[[1]][[1]][,"time"], 0.387)[[2]][2]
#				OPCUT<-crossing(pp[[1]][[1]][,"PlasmaF"]*1000/10.5, pp[[1]][[1]][,"time"], 0.837)[[2]][2]
#			}
#			print(paste("TOPCUBloodFlow=",(OPCUT)/60,"minutes")) #time after death for plama concentration to reach OPCU
#			print(paste("TOPCMBloodFlow=",(OPCMT)/60,"minutes"))
#			print(paste("TOPCLBloodFlow=",(OPCLT)/60,"minutes"))
#		}
		#===============================================================================================================================================================================================
		#death definition according to cardiac arrest===================================================================================================================================================
		##		collapseArterialO2Threshold<-15 #mm Hg
		##		print(min(pp[[1]][[Nconditions]][,"Arterial O2 partial pressure (mm Hg)"]))
		##		print(crossing(pp[[1]][[Nconditions]][,"Arterial O2 partial pressure (mm Hg)"], pp[[1]][[Nconditions]][,"time"], collapseArterialO2Threshold)[[2]][1]/60)
		##		print(pp[[1]][[Nconditions]][which(pp[[1]][[Nconditions]][,"Total blood flow (l/min)"]==max(pp[[1]][[Nconditions]][,"Total blood flow (l/min)"])),"time"]/60)	
		##		print((min(pp[[1]][[Nconditions]][,"Total blood flow (l/min)"])/pp[[1]][[Nconditions]][1,"Total blood flow (l/min)"])*100)
#		if (min(pp[[1]][[Nconditions]][,"Total blood flow (l/min)"])<=CABloodFlow){
#			ETBloodFlow<- crossing(pp[[1]][[Nconditions]][,"Blood flow to brain (l/min)"]+pp[[1]][[Nconditions]][,"Blood flow to tissue (l/min)"], pp[[1]][[Nconditions]][,"time"], CABloodFlow)[[2]][1]
#			print(paste("ETBloodFlow=",ETBloodFlow/60,"minutes"))
#			if (Nconditions==1){	
#				if(opioid=="fentanyl"){#fentanyl
#					OPCLT<-crossing(pp[[1]][[1]][,"PlasmaF"]*1000/10.5, pp[[1]][[1]][,"time"], 3.7)[[2]][2]
#					OPCMT<-crossing(pp[[1]][[1]][,"PlasmaF"]*1000/10.5, pp[[1]][[1]][,"time"], 9.96)[[2]][2]
#					OPCUT<-crossing(pp[[1]][[1]][,"PlasmaF"]*1000/10.5, pp[[1]][[1]][,"time"], 25.2)[[2]][2]
#				}else if(opioid=="carfentanil"){
#					OPCLT<-crossing(pp[[1]][[1]][,"PlasmaF"]*1000/10.5, pp[[1]][[1]][,"time"], 0.2)[[2]][2]
#					OPCMT<-crossing(pp[[1]][[1]][,"PlasmaF"]*1000/10.5, pp[[1]][[1]][,"time"], 0.387)[[2]][2]
#					OPCUT<-crossing(pp[[1]][[1]][,"PlasmaF"]*1000/10.5, pp[[1]][[1]][,"time"], 0.837)[[2]][2]
#				}
#				print(paste("TOPCUBloodFlowTotal=",(OPCUT)/60,"minutes")) #time after death for plama concentration to reach OPCU
#				print(paste("TOPCMBloodFlowTotal=",(OPCMT)/60,"minutes"))
#				print(paste("TOPCLBloodFlowTotal=",(OPCLT)/60,"minutes"))
#				print(paste("TOPCUBloodFlow=",(OPCUT-ETBloodFlow)/60,"minutes")) #time after death for plama concentration to reach OPCU
#				print(paste("TOPCMBloodFlow=",(OPCMT-ETBloodFlow)/60,"minutes"))
#				print(paste("TOPCLBloodFlow=",(OPCLT-ETBloodFlow)/60,"minutes"))
#			}
#		}
		#===============================================================================================================================================================================================
		#death definition according to cardiac arrest and new calculation===================================================================================================================================================
#		print(min(pp[[1]][[Nconditions]][,"Arterial O2 partial pressure (mm Hg)"]))
#		print(crossing(pp[[1]][[Nconditions]][,"Arterial O2 partial pressure (mm Hg)"], pp[[1]][[Nconditions]][,"time"], collapseArterialO2Threshold)[[2]][1]/60)
#		print(pp[[1]][[Nconditions]][which(pp[[1]][[Nconditions]][,"Total blood flow (l/min)"]==max(pp[[1]][[Nconditions]][,"Total blood flow (l/min)"])),"time"]/60)	
#		print((min(pp[[1]][[Nconditions]][,"Total blood flow (l/min)"])/pp[[1]][[Nconditions]][1,"Total blood flow (l/min)"])*100)
		if (min(pp[[1]][[Nconditions]][,"Total blood flow (l/min)"])<=CABloodFlow){
			ETBloodFlow<- crossing(pp[[1]][[Nconditions]][,"Blood flow to brain (l/min)"]+pp[[1]][[Nconditions]][,"Blood flow to tissue (l/min)"], pp[[1]][[Nconditions]][,"time"], CABloodFlow)[[2]][1]
			print(paste("ETBloodFlow=",ETBloodFlow/60,"minutes"))
			if (Nconditions==1){	
				if(opioid=="fentanyl"){#fentanyl
					OPCLT<-crossing(pp[[1]][[1]][,"PlasmaF"]*1000/pp[[1]][[1]][,"Fentanyl VoD"], pp[[1]][[1]][,"time"], 3.7)[[2]][2]
					OPCMT<-crossing(pp[[1]][[1]][,"PlasmaF"]*1000/pp[[1]][[1]][,"Fentanyl VoD"], pp[[1]][[1]][,"time"], 9.96)[[2]][2]
					OPCUT<-crossing(pp[[1]][[1]][,"PlasmaF"]*1000/pp[[1]][[1]][,"Fentanyl VoD"], pp[[1]][[1]][,"time"], 25.2)[[2]][2]
				}else if(opioid=="carfentanil"){
					OPCLT<-crossing(pp[[1]][[1]][,"PlasmaF"]*1000/pp[[1]][[1]][,"Fentanyl VoD"], pp[[1]][[1]][,"time"], 0.2)[[2]][2]
					OPCMT<-crossing(pp[[1]][[1]][,"PlasmaF"]*1000/pp[[1]][[1]][,"Fentanyl VoD"], pp[[1]][[1]][,"time"], 0.387)[[2]][2]
					OPCUT<-crossing(pp[[1]][[1]][,"PlasmaF"]*1000/pp[[1]][[1]][,"Fentanyl VoD"], pp[[1]][[1]][,"time"], 0.837)[[2]][2]
				}
				print(paste("TOPCUBloodFlowTotal=",(OPCUT)/60,"minutes")) #time after death for plama concentration to reach OPCU
				print(paste("TOPCMBloodFlowTotal=",(OPCMT)/60,"minutes"))
				print(paste("TOPCLBloodFlowTotal=",(OPCLT)/60,"minutes"))
				print(paste("TOPCUBloodFlow=",(OPCUT-ETBloodFlow)/60,"minutes")) #time after death for plama concentration to reach OPCU
				print(paste("TOPCMBloodFlow=",(OPCMT-ETBloodFlow)/60,"minutes"))
				print(paste("TOPCLBloodFlow=",(OPCLT-ETBloodFlow)/60,"minutes"))
			}
		}
		#===============================================================================================================================================================================================
		
#death definition according to brain O2====================================================================================================
#		if (min(pp[[1]][[Nconditions]][,"Brain O2 partial pressure (mm Hg)"])<DThBrainO2){
#			ETBrainO2<- crossing(pp[[1]][[Nconditions]][,"Brain O2 partial pressure (mm Hg)"], pp[[1]][[Nconditions]][,"time"], DThBrainO2)[[2]][1]
#			STBrainO2<- crossing(pp[[1]][[Nconditions]][,"Brain O2 partial pressure (mm Hg)"], pp[[1]][[Nconditions]][,"time"], DThBrainO2)[[2]][2]
#			TUTBrainO2<-STBrainO2-ETBrainO2
#			if (is.na(STBrainO2)|TUTBrainO2>CRT){outcome<-"death"}else{outcome<-"rescue"}
#			if (Nconditions==1){	
#				if(opioid=="fentanyl"){#fentanyl
#					OPCLT<-crossing(pp[[1]][[1]][,"PlasmaF"]*1000/10.5, pp[[1]][[1]][,"time"], 3.7)[[2]][2]
#					OPCMT<-crossing(pp[[1]][[1]][,"PlasmaF"]*1000/10.5, pp[[1]][[1]][,"time"], 9.96)[[2]][2]
#					OPCUT<-crossing(pp[[1]][[1]][,"PlasmaF"]*1000/10.5, pp[[1]][[1]][,"time"], 25.2)[[2]][2]
#				}else if(opioid=="carfentanil"){
#					OPCLT<-crossing(pp[[1]][[1]][,"PlasmaF"]*1000/10.5, pp[[1]][[1]][,"time"], 0.2)[[2]][2]
#					OPCMT<-crossing(pp[[1]][[1]][,"PlasmaF"]*1000/10.5, pp[[1]][[1]][,"time"], 0.387)[[2]][2]
#					OPCUT<-crossing(pp[[1]][[1]][,"PlasmaF"]*1000/10.5, pp[[1]][[1]][,"time"], 0.837)[[2]][2]
#				}
		##				print(paste("ETBrainO2=",ETBrainO2/60,"minutes"))
		##				print(paste("TOPCUBrainO2=",(OPCUT)/60,"minutes")) #time after death for plama concentration to reach OPCU
		##				print(paste("TOPCMBrainO2=",(OPCMT)/60,"minutes"))
		##				print(paste("TOPCLBrainO2=",(OPCLT)/60,"minutes"))
#				print(paste("TOPCUBrainO2=",(OPCUT-ETBrainO2-CRT)/60,"minutes")) #time after death for plama concentration to reach OPCU
#				print(paste("TOPCMBrainO2=",(OPCMT-ETBrainO2-CRT)/60,"minutes"))
#				print(paste("TOPCLBrainO2=",(OPCLT-ETBrainO2-CRT)/60,"minutes"))
#			}
#			print(paste("Outcome based on Brain O2=",outcome))
#			print(paste("TUTBrainO2=",TUTBrainO2/60,"minutes"))
		##			print(paste("RTBrainO2=",RTBrainO2/60,"minutes"))
#		}
		#==========================================================================================================================================
		#death definition according to arterial O2==========================================================================================================
#		if (min(pp[[1]][[Nconditions]][,"Arterial O2 partial pressure (mm Hg)"])<DThArterialO2){
#			ETArterialO2<- crossing(pp[[1]][[Nconditions]][,"Arterial O2 partial pressure (mm Hg)"], pp[[1]][[Nconditions]][,"time"], DThArterialO2)[[2]][1]
#			STArterialO2<- crossing(pp[[1]][[Nconditions]][,"Arterial O2 partial pressure (mm Hg)"], pp[[1]][[Nconditions]][,"time"], DThArterialO2)[[2]][2]
#			TUTArterialO2<-STArterialO2-ETArterialO2
#			if (is.na(STArterialO2)|TUTArterialO2>CRT){outcome<-"death"}else{outcome<-"rescue"}
#			if (Nconditions==1){	
#				if(opioid=="fentanyl"){#fentanyl
#					OPCLT<-crossing(pp[[1]][[1]][,"PlasmaF"]*1000/10.5, pp[[1]][[1]][,"time"], 3.7)[[2]][2]
#					OPCMT<-crossing(pp[[1]][[1]][,"PlasmaF"]*1000/10.5, pp[[1]][[1]][,"time"], 9.96)[[2]][2]
#					OPCUT<-crossing(pp[[1]][[1]][,"PlasmaF"]*1000/10.5, pp[[1]][[1]][,"time"], 25.2)[[2]][2]
#				}else if(opioid=="carfentanil"){
#					OPCLT<-crossing(pp[[1]][[1]][,"PlasmaF"]*1000/10.5, pp[[1]][[1]][,"time"], 0.2)[[2]][2]
#					OPCMT<-crossing(pp[[1]][[1]][,"PlasmaF"]*1000/10.5, pp[[1]][[1]][,"time"], 0.387)[[2]][2]
#					OPCUT<-crossing(pp[[1]][[1]][,"PlasmaF"]*1000/10.5, pp[[1]][[1]][,"time"], 0.837)[[2]][2]
#				}
		##				print(paste("ETArterialO2=",ETArterialO2/60,"minutes"))
		##				print(paste("TOPCUArterialO2=",(OPCUT)/60,"minutes")) #time after death for plama concentration to reach OPCU
		##				print(paste("TOPCMArterialO2=",(OPCMT)/60,"minutes"))
		##				print(paste("TOPCLArterialO2=",(OPCLT)/60,"minutes"))
#				print(paste("TOPCUArterialO2=",(OPCUT-ETArterialO2-CRT)/60,"minutes")) #time after death for plama concentration to reach OPCU
#				print(paste("TOPCMArterialO2=",(OPCMT-ETArterialO2-CRT)/60,"minutes"))
#				print(paste("TOPCLArterialO2=",(OPCLT-ETArterialO2-CRT)/60,"minutes"))
#			}
#			print(paste("Outcome based on Arterial O2=",outcome))
#			print(paste("TUTArterialO2=",TUTArterialO2/60,"minutes"))
#		}
		#====================================================================================================================================================
		else{print("no risk")}
	}		
}