dosingevents<-function(naloxoneDosing){
	#opioid dose (irrlevant here)=======================================================
	opioid_dose=2e6; 
	opioid_time=seq(0,10,1);
	eventdata<-data.frame(var="PlasmaN",time=opioid_time,value=opioid_dose/length(opioid_time),method="add")
	times=c(seq(0,10,1),seq(10,24*60*60,1))
	fulltimes<-sort(unique(c(times, cleanEventTimes(eventdata$time, times))))
	output<-list(fulltimes, eventdata)
}
