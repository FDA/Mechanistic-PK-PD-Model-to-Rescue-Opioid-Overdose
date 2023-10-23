#last edited by: Anik Chaturbedi
#on: 2024-10-12

dosingevents<-function(
		opioid_dose=0, #(mg)
		opioid_time=0, 
		naloxone_dose=0, 
		naloxone_time=0, 
		antagonistDoseIndex=0, 
		gap, 
		pars=truepar, 
		infusionScheme=c(), 
		leakPercent=c(), 
		leakPercent2=c(), 
		WIncrease=0, 
		WDecrease=0){
	
	#opioid IV infusion=====================================	
	#new version with constant rate TTS=========================
	eventAll<-dosingeventsRenarcotizationSlowOpioidInfusion(
			eventAll= c(),
			method="new",
			totalOpioidDose= opioid_dose,
			opioidInitialBolusTime= opioid_time,
			opioidInfusionDuration= 24*60, #(hours converted to minutes) #infusion time for Zernikow et al. 2007 data
			fixedOpioidAbsorptionRate=(inputs$opioidInfusionRate*1e-3)/3600, #0 #(5*100*1e-3)/3600 #(ug/hr converted to mg/sec) 
			opioidAbsorptionRate=inputs$opioidAbsorptionRate
	)
	#=========================new version with constant rate TTS
	#=====================================opioid IV infusion
	
	#Antagonist dose====
	eventAll<-rbind(eventAll, data.frame(var="F1", time=0,value=as.numeric(pars["F"]), method="replace"))

	#scale dose to get drug weight from salt weight (used because the PK parameters for the Krieter sets were estimated using drug weight unlike the previous ones)====
	if (inputs$antagonistAdministrationRouteAndDose=="IN3nalmefeneB" || 
			inputs$antagonistAdministrationRouteAndDose=="IN3nalmefeneA"){
		scalingFactorToGetDrugWeightFromSaltWeight=(339.435/(36.458+339.435)) #Nalmefene MW=339.435, HCL MW=36.458
		naloxone_dose= naloxone_dose*scalingFactorToGetDrugWeightFromSaltWeight
	}
	#====scale dose to get drug weight from salt weight (used because the PK parameters for the Krieter sets were estimated using drug weight unlike the previous ones)
	
	if(!identical(antagonistDoses[antagonistDoseIndex], character(0)) && antagonistDoses[antagonistDoseIndex] == "1 dose"){
		eventAll<-rbind(eventAll, data.frame(var="D", time=naloxone_time, value=c(naloxone_dose), method="add"))			
	}else if(!identical(antagonistDoses[antagonistDoseIndex], character(0)) && antagonistDoses[antagonistDoseIndex] == "1 scaled dose"){
		ageDependentParameters=getAgeDependentParameters(inputs)	
		weightScaling=ageDependentParameters[ageDependentParameters$age==inputs$subjectAge,"weight"]/ageDependentParameters[ageDependentParameters$age=="adult","weight"]
		eventAll<-rbind(eventAll, data.frame(var="D",time=naloxone_time, value=c(naloxone_dose*weightScaling),method="add"))
	}else if(!identical(antagonistDoses[antagonistDoseIndex], character(0)) && antagonistDoses[antagonistDoseIndex] == "2 doses standard"){
		eventAll<-rbind(eventAll, data.frame(var="D", time=c(naloxone_time, naloxone_time+gap), value=c(naloxone_dose, naloxone_dose), method="add"))			
	}else if(!identical(antagonistDoses[antagonistDoseIndex], character(0)) && antagonistDoses[antagonistDoseIndex] == "2 doses rapid"){
		eventAll<-rbind(eventAll, data.frame(var="D", time=c(naloxone_time), value=c(2*naloxone_dose), method="add"))
	}
	
	eventAll[,"time"]=round(eventAll[,"time"], 1)
	times=seq(0,simulationTime,simulationTimeStep) #timepoints for data collection from model	
	fulltimes<-sort(c(times, cleanEventTimes(times, eventAll[,"time"]))) #Find Nearest Event for Each Time Step and Clean Time Steps to Avoid Doubles
	eventAll<-eventAll[order(eventAll[,"time"]),] #order all rows according to "time"
	output<-list(fulltimes, eventAll)
}