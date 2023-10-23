#last edited by: Anik Chaturbedi
#on: 2024-10-12

dosingevents<-function(
		opioid_dose, 
		opioid_time=0, 
		naloxone_dose=0, 
		naloxone_time, 
		antagonistDoseIndex=0, 
		gap, 
		pars=truepar){
	
	eventdata<-data.frame(var="opioidDoseCompartment", time=opioid_time, value=opioid_dose, method="add")
	eventdata<-rbind(eventdata,data.frame(var="F1",time=0,value=as.numeric(pars["F"]),method="replace"))
	
	#scale dose to get drug weight from salt weight (used because the PK parameters for the Krieter sets were estimated using drug weight unlike the previous ones)====
	if (inputs$antagonistAdministrationRouteAndDose=="IN3nalmefeneB" || 
			inputs$antagonistAdministrationRouteAndDose=="IN3nalmefeneA"){
		scalingFactorToGetDrugWeightFromSaltWeight=(339.435/(36.458+339.435)) #Nalmefene MW=339.435, HCL MW=36.458
		naloxone_dose= naloxone_dose*scalingFactorToGetDrugWeightFromSaltWeight
	}
	#====scale dose to get drug weight from salt weight (used because the PK parameters for the Krieter sets were estimated using drug weight unlike the previous ones)
	
	if(!identical(antagonistDoses[antagonistDoseIndex], character(0)) && antagonistDoses[antagonistDoseIndex] == "1 dose"){
		eventdata<-rbind(eventdata, data.frame(var="D", time=naloxone_time, value=c(naloxone_dose), method="add"))			
	}else if(!identical(antagonistDoses[antagonistDoseIndex], character(0)) && antagonistDoses[antagonistDoseIndex] == "1 scaled dose"){
		ageDependentParameters=getAgeDependentParameters(inputs)	
		weightScaling=ageDependentParameters[ageDependentParameters$age==inputs$subjectAge,"weight"]/ageDependentParameters[ageDependentParameters$age=="adult","weight"]
		eventdata<-rbind(eventdata, data.frame(var="D",time=naloxone_time, value=c(naloxone_dose*weightScaling),method="add"))
	}else if(!identical(antagonistDoses[antagonistDoseIndex], character(0)) && antagonistDoses[antagonistDoseIndex] == "2 doses standard"){
		eventdata<-rbind(eventdata, data.frame(var="D", time=c(naloxone_time, naloxone_time+gap), value=c(naloxone_dose, naloxone_dose), method="add"))			
	}else if(!identical(antagonistDoses[antagonistDoseIndex], character(0)) && antagonistDoses[antagonistDoseIndex] == "2 doses rapid"){
		eventdata<-rbind(eventdata, data.frame(var="D", time=c(naloxone_time), value=c(2*naloxone_dose), method="add"))
	}
	
	times=seq(0,simulationTime,simulationTimeStep) #timepoints for data collection from model	
	fulltimes<-sort(unique(c(times, cleanEventTimes(eventdata$time, times))))
	eventdata=eventdata[order(eventdata[,"time"]),]
	output<-list(fulltimes, eventdata)
}