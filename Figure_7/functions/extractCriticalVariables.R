extractCriticalVariables<-function(){
	result_Co2TP="output/result_Co2TP/"
	system(paste0("mkdir -p ",result_Co2TP))		
	Turn_p=c()
	PaCO2InflectionPointTime=c()
	saturationOutput<-c()
	for(Nconditions in c(1,2,3,4,5,6)){#1:5 corresponds to naloxone doseN 0-4 Added 2 doses as per DGS
		
		ACO2P=pp[[1]][[Nconditions]][,c("time",
						"Minute ventilation (l/min)",
						"Total blood flow (l/min)",
						"Arterial O2 partial pressure (mm Hg)",
						"Arterial CO2 partial pressure (mm Hg)",
						"Brain O2 partial pressure (mm Hg)",
						"Arterial oxygen saturation (%)")]
		
		if (min(ACO2P[,"Total blood flow (l/min)"])>1e-1){		
			ACO2P[,"time"]<-ACO2P[,"time"]/60 #Convert time to minutes
			ACO2P_S=ACO2P[,"Arterial oxygen saturation (%)"]
			ACO2P_O=ACO2P[,"Arterial CO2 partial pressure (mm Hg)"]
			ACO2P_B=ACO2P[,"Brain O2 partial pressure (mm Hg)"]
			ACO2P_Ox=ACO2P[,"Arterial O2 partial pressure (mm Hg)"]
			ACO2P_V=ACO2P[,"Minute ventilation (l/min)"]
			idTPB=which(ACO2P_B==min(ACO2P_B))
			idTPO2=which(ACO2P_Ox==min(ACO2P_Ox))
			idTPS=which(ACO2P_S==min(ACO2P_S))
			dACO2P=diff(ACO2P[,"Arterial CO2 partial pressure (mm Hg)"])
			idTP=which(diff(sign(dACO2P))!=0, arr.ind=TRUE) #id of turn point
			id_Brain_20=which(abs(ACO2P_B[c(idTPB+1):nrow(ACO2P)]-20)==min(abs(ACO2P_B[c(idTPB+1):nrow(ACO2P)]-20)))
			id_O2_30=which(abs(ACO2P_Ox[c(idTPO2+1):nrow(ACO2P)]-30)==min(abs(ACO2P_Ox[c(idTPO2+1):nrow(ACO2P)]-30)))
			id_Brain_25=which(abs(ACO2P_B[c(idTPB+1):nrow(ACO2P)]-25)==min(abs(ACO2P_B[c(idTPB+1):nrow(ACO2P)]-25)))
			id_O2_65=which(abs(ACO2P_Ox[c(idTPO2+1):nrow(ACO2P)]-65)==min(abs(ACO2P_Ox[c(idTPO2+1):nrow(ACO2P)]-65)))
			id_Pre_45=which(abs(ACO2P_O[c(idTP+1):nrow(ACO2P)]-45)==min(abs(ACO2P_O[c(idTP+1):nrow(ACO2P)]-45)))
			idSaturation90=which(abs(ACO2P_S[c(idTPS+1):nrow(ACO2P)]-90)==min(abs(ACO2P_S[c(idTPS+1):nrow(ACO2P)]-90)))			
			print(nrow(ACO2P))
			print(idTPB)
#		print(id_Brain_20)
			if (length(idTP)>1) {idTP=idTP[1]}
			Ndosen=(Nconditions-1)
			if ((Nconditions-1)==5) {Ndosen="2+2"}
			PaCO2InflectionPointTime0=c(ACO2P[idTP,c("time")]) #],
			Turn_p0=c("opioid"=args$opioid,"patientType"=args$patientType,"dose"=args$conc,"Ndose"=Ndosen,
					ACO2P[idTPB+id_Brain_20,c("time","Minute ventilation (l/min)","Arterial oxygen saturation (%)")],
					ACO2P[idTPO2+id_O2_30,c("time","Minute ventilation (l/min)","Arterial oxygen saturation (%)")],
					ACO2P[idTPB+id_Brain_25,c("time","Minute ventilation (l/min)","Arterial oxygen saturation (%)")],
					ACO2P[idTPO2+id_O2_65,c("time","Minute ventilation (l/min)","Arterial oxygen saturation (%)")],
					ACO2P[idTP+id_Pre_45,c("time","Minute ventilation (l/min)","Arterial oxygen saturation (%)")],
					ACO2P[idTPS+idSaturation90,
							c("time","Minute ventilation (l/min)","Arterial O2 partial pressure (mm Hg)","Arterial CO2 partial pressure (mm Hg)","Brain O2 partial pressure (mm Hg)")]
			)
		}
		Turn_p=rbind(Turn_p,Turn_p0)
		saturationOutput=cbind(saturationOutput,ACO2P_S)
		PaCO2InflectionPointTime=rbind(PaCO2InflectionPointTime,PaCO2InflectionPointTime0)
	}
	namecsvFile=paste0("opioid=",args$opioid," ","usePK=",args$usePK," ","patientType=",args$patientType," ","dose=",args$conc)
	write.csv(Turn_p,paste0(result_Co2TP,namecsvFile,".csv"),row.names=F)
	return(list("PaCO2InflectionPointTime"=PaCO2InflectionPointTime,"saturationData"=saturationOutput))
}