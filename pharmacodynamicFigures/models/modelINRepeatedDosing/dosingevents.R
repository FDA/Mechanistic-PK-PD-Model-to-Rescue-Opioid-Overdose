#last edited by: Anik Chaturbedi
#on: 2023-05-16
dosingevents<-function(opioid_dose, opioid_time=0, naloxone_dose=0, naloxone_time, antagonistDoseIndex=0, gap, pars=truepar){
	eventdata<-data.frame(var="PlasmaF",time=opioid_time,value=opioid_dose,method="add")
	eventdata<-rbind(eventdata,data.frame(var="F1",time=0,value=as.numeric(pars["F"]),method="replace"))
	if (inputs$antagonistAdministrationRouteAndDose=="IN4"){
		if(!identical(antagonistDoses[antagonistDoseIndex], character(0)) && antagonistDoses[antagonistDoseIndex] == "4(R)"){
			if (antagonistDosesLabels[antagonistDoseIndex] == "1-scaled-dose/label"){
				ageDependentParameters=getAgeDependentParameters(inputs)	
				weightScaling=ageDependentParameters[ageDependentParameters$age==inputs$subjectAge,"weight"]/ageDependentParameters[ageDependentParameters$age=="adult","weight"]
				eventdata<-rbind(eventdata, data.frame(var="D",time=naloxone_time, value=c(naloxone_dose*weightScaling),method="add"))
			}else {
				eventdata<-rbind(eventdata, data.frame(var="D",time=naloxone_time, value=c(naloxone_dose),method="add"))
			}
		}else if(!identical(antagonistDoses[antagonistDoseIndex], character(0)) && antagonistDoses[antagonistDoseIndex] == "4(R)+4(L)"){
			eventdata<-rbind(eventdata, data.frame(var="D",time=c(naloxone_time, naloxone_time+gap),value=c(naloxone_dose,naloxone_dose),method="add"))
		}else if(!identical(antagonistDoses[antagonistDoseIndex], character(0)) && antagonistDoses[antagonistDoseIndex] == "4(R)+4(L)+4(R)"){
			eventdata<-rbind(eventdata, data.frame(var="D",time=c(naloxone_time, naloxone_time+gap, naloxone_time+gap+gap),	value=c(rep(naloxone_dose,2), naloxone_dose),method="add"))
			eventdata<-rbind(eventdata,data.frame(var="F1",time=naloxone_time+gap+gap,value=as.numeric(pars["f1"]),method="replace")) #Bioavailability drop
		}else if(!identical(antagonistDoses[antagonistDoseIndex], character(0)) && antagonistDoses[antagonistDoseIndex] == "4(R)+4(L)+4(R)+4(L)"){
			eventdata<-rbind(eventdata, data.frame(var="D", time=c(naloxone_time, naloxone_time+gap, naloxone_time+gap+gap, naloxone_time+gap+gap+gap), value=c(rep(naloxone_dose,2),rep(naloxone_dose,2)), method="add"))
			eventdata<-rbind(eventdata,data.frame(var="F1",time=naloxone_time+gap+gap,value=as.numeric(pars["f1"]),method="replace"))
		}else if(!identical(antagonistDoses[antagonistDoseIndex], character(0)) && antagonistDoses[antagonistDoseIndex] == "4(R)4(L)"){
			eventdata<-rbind(eventdata, data.frame(var="D", time=c(naloxone_time), value=c(2*naloxone_dose), method="add"))
		}else if(!identical(antagonistDoses[antagonistDoseIndex], character(0)) && antagonistDoses[antagonistDoseIndex] == "4(R)4(L)+4(R)4(L)"){
			eventdata<-rbind(eventdata, data.frame(var="D", time=c(naloxone_time, naloxone_time+gap), value=c(2*naloxone_dose,2*naloxone_dose), method="add"))
			eventdata<-rbind(eventdata,	data.frame(var="F1", time=naloxone_time+gap,value=as.numeric(pars["f2"]), method="replace")) #Alternate bioavailability drop double dosing
		}		
	}
	times=seq(0,simulationTime,simulationTimeStep) #timepoints for data collection from model	
	fulltimes<-sort(unique(c(times, cleanEventTimes(eventdata$time, times))))
	eventdata=eventdata[order(eventdata[,"time"]),]
	output<-list(fulltimes, eventdata)
}