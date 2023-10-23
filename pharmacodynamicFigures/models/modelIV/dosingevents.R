#last edited by: Anik Chaturbedi
#on: 2022-04-19
dosingevents<-function(opioid_dose, opioid_time=0, naloxone_dose=0, naloxone_time, antagonistDoseIndex=0, gap, pars=truepar){
	eventdata<-data.frame(var="PlasmaF",time=opioid_time,value=opioid_dose,method="add")	
	if(!is.na(antagonistDose)){
		if(!identical(antagonistDosesLabels[antagonistDoseIndex], character(0)) && antagonistDosesLabels[antagonistDoseIndex] == "1-dose/label"){
			naloxoneTimeForInfusion<-seq(naloxone_time,naloxone_time+IVInfusionDuration,IVInfusionTimeStep);
			naloxoneDoseForInfusion<-naloxone_dose/(IVInfusionDuration*(1/IVInfusionTimeStep))
			eventdata<-rbind(eventdata, data.frame(var="PlasmaN", time=naloxoneTimeForInfusion, value=c(naloxoneDoseForInfusion), method="add"))
		}else if(!identical(antagonistDosesLabels[antagonistDoseIndex], character(0)) && antagonistDosesLabels[antagonistDoseIndex] == "2-doses/label"){
			naloxoneTimeForInfusion<-seq(naloxone_time,naloxone_time+IVInfusionDuration,IVInfusionTimeStep);
			naloxoneDoseForInfusion<-naloxone_dose/(IVInfusionDuration*(1/IVInfusionTimeStep))
			eventdata<-rbind(eventdata, data.frame(var="PlasmaN", time=c(naloxoneTimeForInfusion, naloxoneTimeForInfusion+gap), value=c(naloxoneDoseForInfusion,naloxoneDoseForInfusion), method="add"))
		}else if(!identical(antagonistDosesLabels[antagonistDoseIndex], character(0)) && antagonistDosesLabels[antagonistDoseIndex] == "3-doses/label"){
			naloxoneTimeForInfusion<-seq(naloxone_time,naloxone_time+IVInfusionDuration,IVInfusionTimeStep);
			naloxoneDoseForInfusion<-naloxone_dose/(IVInfusionDuration*(1/IVInfusionTimeStep))
			eventdata<-rbind(eventdata, data.frame(var="PlasmaN",time=c(naloxoneTimeForInfusion, naloxoneTimeForInfusion+gap, naloxoneTimeForInfusion+gap+gap),	value=c(rep(naloxoneDoseForInfusion,2), naloxoneDoseForInfusion),method="add"))
		}else if(!identical(antagonistDosesLabels[antagonistDoseIndex], character(0)) && antagonistDosesLabels[antagonistDoseIndex] == "4-doses/label"){
			naloxoneTimeForInfusion<-seq(naloxone_time,naloxone_time+IVInfusionDuration,IVInfusionTimeStep);
			naloxoneDoseForInfusion<-naloxone_dose/(IVInfusionDuration*(1/IVInfusionTimeStep))
			eventdata<-rbind(eventdata, data.frame(var="PlasmaN", time=c(naloxoneTimeForInfusion, naloxoneTimeForInfusion+gap, naloxoneTimeForInfusion+gap+gap, naloxoneTimeForInfusion+gap+gap+gap), value=c(rep(naloxoneDoseForInfusion,2),rep(naloxoneDoseForInfusion,2)), method="add"))
		}else if(!identical(antagonistDosesLabels[antagonistDoseIndex], character(0)) && antagonistDosesLabels[antagonistDoseIndex] == "2-doses/rapid"){
			naloxoneTimeForInfusion<-seq(naloxone_time,naloxone_time+IVInfusionDuration,IVInfusionTimeStep);
			naloxoneDoseForInfusion<-naloxone_dose/(IVInfusionDuration*(1/IVInfusionTimeStep))
			eventdata<-rbind(eventdata, data.frame(var="PlasmaN", time=c(naloxoneTimeForInfusion), value=c(2*naloxoneDoseForInfusion), method="add"))
		}else if(!identical(antagonistDosesLabels[antagonistDoseIndex], character(0)) && antagonistDosesLabels[antagonistDoseIndex] == "4-doses/rapid"){
			naloxoneTimeForInfusion<-seq(naloxone_time,naloxone_time+IVInfusionDuration,IVInfusionTimeStep);
			naloxoneDoseForInfusion<-naloxone_dose/(IVInfusionDuration*(1/IVInfusionTimeStep))
			eventdata<-rbind(eventdata, data.frame(var="PlasmaN", time=c(naloxoneTimeForInfusion, naloxoneTimeForInfusion+gap), value=c(2*naloxoneDoseForInfusion,2*naloxoneDoseForInfusion), method="add"))
		}
	}
	else if (inputs$antagonistAdministrationRouteAndDose=="IVBoyer"){
		if(!identical(antagonistDosesLabels[antagonistDoseIndex], character(0)) && antagonistDosesLabels[antagonistDoseIndex] == "0.04"){
			naloxoneTimeForInfusion<-seq(naloxone_time,naloxone_time+IVInfusionDuration,IVInfusionTimeStep);
			naloxoneDoseForInfusion<-rep(1/(IVInfusionDuration*(1/IVInfusionTimeStep)),length(naloxoneTimeForInfusion));
			eventdata<-rbind(eventdata, data.frame(var="PlasmaN", time=naloxoneTimeForInfusion, 
							value=c(naloxoneDoseForInfusion*0.04)*1e6, method="add"))
		}else if(!identical(antagonistDosesLabels[antagonistDoseIndex], character(0)) && antagonistDosesLabels[antagonistDoseIndex] == "0.04+0.5"){
			naloxoneTimeForInfusion<-seq(naloxone_time,naloxone_time+IVInfusionDuration,IVInfusionTimeStep);
			naloxoneDoseForInfusion<-rep(1/(IVInfusionDuration*(1/IVInfusionTimeStep)),length(naloxoneTimeForInfusion));
			eventdata<-rbind(eventdata, data.frame(var="PlasmaN", time=c(naloxoneTimeForInfusion, naloxoneTimeForInfusion+gap), 
							value=c(naloxoneDoseForInfusion*0.04, naloxoneDoseForInfusion*0.5)*1e6, method="add"))
		}else if(!identical(antagonistDosesLabels[antagonistDoseIndex], character(0)) && antagonistDosesLabels[antagonistDoseIndex] == "0.04+0.5+2"){
			naloxoneTimeForInfusion<-seq(naloxone_time,naloxone_time+IVInfusionDuration,IVInfusionTimeStep);
			naloxoneDoseForInfusion<-rep(1/(IVInfusionDuration*(1/IVInfusionTimeStep)),length(naloxoneTimeForInfusion));
			eventdata<-rbind(eventdata, data.frame(var="PlasmaN", time=c(naloxoneTimeForInfusion, naloxoneTimeForInfusion+gap, naloxoneTimeForInfusion+2*gap), 
							value=c(naloxoneDoseForInfusion*0.04, naloxoneDoseForInfusion*0.5, naloxoneDoseForInfusion*2)*1e6, method="add"))
		}else if(!identical(antagonistDosesLabels[antagonistDoseIndex], character(0)) && antagonistDosesLabels[antagonistDoseIndex] == "0.04+0.5+2+4"){
			naloxoneTimeForInfusion<-seq(naloxone_time,naloxone_time+IVInfusionDuration,IVInfusionTimeStep);
			naloxoneDoseForInfusion<-rep(1/(IVInfusionDuration*(1/IVInfusionTimeStep)),length(naloxoneTimeForInfusion));
			eventdata<-rbind(eventdata, data.frame(var="PlasmaN", time=c(naloxoneTimeForInfusion, naloxoneTimeForInfusion+gap, naloxoneTimeForInfusion+2*gap, naloxoneTimeForInfusion+3*gap), 
							value=c(naloxoneDoseForInfusion*0.04, naloxoneDoseForInfusion*0.5, naloxoneDoseForInfusion*2, naloxoneDoseForInfusion*4)*1e6, method="add"))
		}else if(!identical(antagonistDosesLabels[antagonistDoseIndex], character(0)) && antagonistDosesLabels[antagonistDoseIndex] == "0.04+0.5+2+4+10"){
			naloxoneTimeForInfusion<-seq(naloxone_time,naloxone_time+IVInfusionDuration,IVInfusionTimeStep);
			naloxoneDoseForInfusion<-rep(1/(IVInfusionDuration*(1/IVInfusionTimeStep)),length(naloxoneTimeForInfusion));
			eventdata<-rbind(eventdata, data.frame(var="PlasmaN", time=c(naloxoneTimeForInfusion, naloxoneTimeForInfusion+gap, naloxoneTimeForInfusion+2*gap, naloxoneTimeForInfusion+3*gap, naloxoneTimeForInfusion+4*gap), 
							value=c(naloxoneDoseForInfusion*0.04, naloxoneDoseForInfusion*0.5, naloxoneDoseForInfusion*2, naloxoneDoseForInfusion*4, naloxoneDoseForInfusion*10)*1e6, method="add"))
		}else if(!identical(antagonistDosesLabels[antagonistDoseIndex], character(0)) && antagonistDosesLabels[antagonistDoseIndex] == "0.04+0.5+2+4+10+15"){
			naloxoneTimeForInfusion<-seq(naloxone_time,naloxone_time+IVInfusionDuration,IVInfusionTimeStep);
			naloxoneDoseForInfusion<-rep(1/(IVInfusionDuration*(1/IVInfusionTimeStep)),length(naloxoneTimeForInfusion));
			eventdata<-rbind(eventdata, data.frame(var="PlasmaN", time=c(naloxoneTimeForInfusion, naloxoneTimeForInfusion+gap, naloxoneTimeForInfusion+2*gap, naloxoneTimeForInfusion+3*gap, naloxoneTimeForInfusion+4*gap, naloxoneTimeForInfusion+5*gap), 
							value=c(naloxoneDoseForInfusion*0.04, naloxoneDoseForInfusion*0.5, naloxoneDoseForInfusion*2, naloxoneDoseForInfusion*4, naloxoneDoseForInfusion*10, naloxoneDoseForInfusion*15)*1e6, method="add"))
		}
	}
	else if (inputs$antagonistAdministrationRouteAndDose=="IVMultipleDoses"){
		if(!identical(antagonistDosesLabels[antagonistDoseIndex], character(0)) && antagonistDosesLabels[antagonistDoseIndex] == "0.04"){
			naloxoneTimeForInfusion<-seq(naloxone_time,naloxone_time+IVInfusionDuration,IVInfusionTimeStep);
			eventdata<-rbind(eventdata, data.frame(var="PlasmaN", time=naloxoneTimeForInfusion, 
							value=c(0.04)*1e6/(IVInfusionDuration*(1/IVInfusionTimeStep)), method="add"))
		}else if(!identical(antagonistDosesLabels[antagonistDoseIndex], character(0)) && antagonistDosesLabels[antagonistDoseIndex] == "0.5"){
			naloxoneTimeForInfusion<-seq(naloxone_time,naloxone_time+IVInfusionDuration,IVInfusionTimeStep);
			eventdata<-rbind(eventdata, data.frame(var="PlasmaN", time=naloxoneTimeForInfusion, 
							value=c(0.5)*1e6/(IVInfusionDuration*(1/IVInfusionTimeStep)), method="add"))
		}else if(!identical(antagonistDosesLabels[antagonistDoseIndex], character(0)) && antagonistDosesLabels[antagonistDoseIndex] == "1"){
			naloxoneTimeForInfusion<-seq(naloxone_time,naloxone_time+IVInfusionDuration,IVInfusionTimeStep);
			eventdata<-rbind(eventdata, data.frame(var="PlasmaN", time=naloxoneTimeForInfusion, 
							value=c(1)*1e6/(IVInfusionDuration*(1/IVInfusionTimeStep)), method="add"))
		}else if(!identical(antagonistDosesLabels[antagonistDoseIndex], character(0)) && antagonistDosesLabels[antagonistDoseIndex] == "2"){
			naloxoneTimeForInfusion<-seq(naloxone_time,naloxone_time+IVInfusionDuration,IVInfusionTimeStep);
			eventdata<-rbind(eventdata, data.frame(var="PlasmaN", time=naloxoneTimeForInfusion, 
							value=c(2)*1e6/(IVInfusionDuration*(1/IVInfusionTimeStep)), method="add"))
		}else if(!identical(antagonistDosesLabels[antagonistDoseIndex], character(0)) && antagonistDosesLabels[antagonistDoseIndex] == "4"){
			naloxoneTimeForInfusion<-seq(naloxone_time,naloxone_time+IVInfusionDuration,IVInfusionTimeStep);
			eventdata<-rbind(eventdata, data.frame(var="PlasmaN", time=naloxoneTimeForInfusion, 
							value=c(4)*1e6/(IVInfusionDuration*(1/IVInfusionTimeStep)), method="add"))
		}else if(!identical(antagonistDosesLabels[antagonistDoseIndex], character(0)) && antagonistDosesLabels[antagonistDoseIndex] == "10"){
			naloxoneTimeForInfusion<-seq(naloxone_time,naloxone_time+IVInfusionDuration,IVInfusionTimeStep);
			eventdata<-rbind(eventdata, data.frame(var="PlasmaN", time=naloxoneTimeForInfusion, 
							value=c(10)*1e6/(IVInfusionDuration*(1/IVInfusionTimeStep)), method="add"))
		}
	}
	times=seq(0,simulationTime,simulationTimeStep) #timepoints for data collection from model	
	fulltimes<-sort(unique(c(times, cleanEventTimes(eventdata$time, times))))
	eventdata=eventdata[order(eventdata[,"time"]),]
	output<-list(fulltimes, eventdata)
}