dosingevents<-function(opioid_dose, opioid_time=0, naloxone_dose=2000000, naloxone_time,naloxone_doseN=0, gap){
	#naloxone_doses can only be 0,1,2,3,4,5,6
	#NO bioavailability loss for IM products
	eventdata<-data.frame(var="PlasmaF",time=opioid_time,value=opioid_dose,method="add")
	if(naloxone_doseN == 1){
		eventdata<-rbind(eventdata, data.frame(var="D",time=naloxone_time,value=c(naloxone_dose),method="add"))
	}else if(naloxone_doseN == 2){
		eventdata<-rbind(eventdata, data.frame(var="D",time=c(naloxone_time, naloxone_time+gap),value=c(naloxone_dose,naloxone_dose),method="add"))
	}else if(naloxone_doseN == 3){
		eventdata<-rbind(eventdata, data.frame(var="D",time=c(naloxone_time, naloxone_time+gap, naloxone_time+gap+gap),value=c(rep(naloxone_dose,2), naloxone_dose),method="add"))
	}else if(naloxone_doseN == 4){
		eventdata<-rbind(eventdata, data.frame(var="D",time=c(naloxone_time, naloxone_time+gap, naloxone_time+gap+gap, naloxone_time+gap+gap+gap),
						value=c(rep(naloxone_dose,2),rep(naloxone_dose,2)),method="add"))
	}else if(naloxone_doseN == 5){
		eventdata<-rbind(eventdata, data.frame(var="D",time=c(naloxone_time),value=c(2*naloxone_dose),method="add"))
	}else if(naloxone_doseN == 6){
		eventdata<-rbind(eventdata, data.frame(var="D",time=c(naloxone_time, naloxone_time+gap),value=c(2*naloxone_dose,2*naloxone_dose),method="add"))
	}
	#--- Additional dosing scenarios can be incorporated as needed
	time11=seq(0,1.5*60*60,.1)
#	time11=seq(0,1.5*60*60,1)
	
	times=c(time11)
	fulltimes<-sort(unique(c(times, cleanEventTimes(eventdata$time, times))))
	output<-list(fulltimes, eventdata)
}
