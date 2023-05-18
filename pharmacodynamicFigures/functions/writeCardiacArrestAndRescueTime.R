#last edited by: Anik Chaturbedi
#on: 2023-05-16
writeCardiacArrestAndRescueTime<-function(){
	cardiacArrestAndRescueTimeAll<-getCardiacArrestAndRescueTime(pp[[1]][[1]])
	try({crossinglist <- crossing(pp[[1]][[1]][,"Minute ventilation (l/min)"],pp[[1]][[1]][,"time"],threshold)},silent=T)

	if(!exists("crossinglist")){  #no crossing
		for(naloxone_doseN in 2:numberOfAntagonistDosingRegimens){
			cardiacArrestAndRescueTimeAll<-rbind(cardiacArrestAndRescueTimeAll,getCardiacArrestAndRescueTime(pp[[1]][[1]]))
		}
	}else{		
		for(naloxone_doseN in 2:numberOfAntagonistDosingRegimens){			
			cardiacArrestAndRescueTimeAll<-rbind(cardiacArrestAndRescueTimeAll,	getCardiacArrestAndRescueTime(pp[[1]][[naloxone_doseN]]))
		}
	}
	write.csv(cardiacArrestAndRescueTimeAll,sprintf("%s/Subject%s.csv", populationFolder, subjectIndex))
}