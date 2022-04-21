dosingevents<-function(opioid_dose, opioid_time=0, naloxone_dose=4000000, naloxone_time,naloxone_doseN=0, gap){
         #naloxone_doses can only be 0,1,2,3,4
          
          eventdata<-data.frame(var="PlasmaF",time=opioid_time,value=opioid_dose,method="add")
         if(naloxone_doseN == 1){
         eventdata<-rbind(eventdata, data.frame(var="D",time=naloxone_time,value=naloxone_dose,method="add"))
         }else if(naloxone_doseN == 2){
         eventdata<-rbind(eventdata, data.frame(var="D",time=c(naloxone_time, naloxone_time+gap),value=naloxone_dose,method="add"))
         }else if(naloxone_doseN == 3){
          eventdata<-rbind(eventdata, data.frame(var="D",time=c(naloxone_time, naloxone_time+gap, naloxone_time+gap+gap),value=naloxone_dose,method="add"))
         }else if(naloxone_doseN == 4){
         eventdata<-rbind(eventdata, data.frame(var="D",time=c(naloxone_time, naloxone_time+gap, naloxone_time+gap+gap, naloxone_time+gap+gap+gap),value=naloxone_dose,method="add"))
         }
         
         time11=seq(0,300,5)
         time22=seq(310,3600,10)
		# time22=seq(310,20000,10)
		 
         times=c(time11,time22)
         fulltimes<-sort(unique(c(times, cleanEventTimes(eventdata$time, times))))
         
          output<-list(fulltimes, eventdata)
          
          }