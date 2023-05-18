#last edited by: Anik Chaturbedi
#on: 2023-05-16
patientWrapper<-function(doseIndex, subjectIndex, interDoseDelay, threshold){	
	outlist<-list(); 
	crossingtimelist<-list(); #initialization
	truepar<-this.par[!names(this.par)=="initialdelay" & !names(this.par)=="Dose"]
	dosingoutput<-dosingevents(inputs$opioidDose[doseIndex],opioid_time=opioidAdministrationTime) 

	trueparOut=rbind(trueparOut, t(truepar))
	statesOut=rbind(statesOut, t(states))
	dosingeventsOut=rbind(dosingoutput[[2]], c(0,0,0,0,0))
	
	truepar<-getCardiacArrestParameters(truepar,dosingoutput)

	trueparOut=rbind(trueparOut, t(truepar))
	statesOut=rbind(statesOut, t(states))
	dosingeventsOut=rbind(dosingeventsOut, dosingoutput[[2]], c(0,0,0,0,0))
	
	out <- fundedewithEvent(states, dosingoutput[[1]], truepar, namesyout,dosingoutput[[2]])
	outlist[[1]]<- out
	try({crossinglist <- crossing(out[,"Minute ventilation (l/min)"],out[,"time"], threshold)},silent=T)	
	if(!exists("crossinglist")){  #no crossing
		return(list(outlist))
	}else{
		crossingtime <- crossinglist[[2]][1]
		rm(out)                     #release memory
		rm(crossinglist)
	}
	#simulate the cases with antagonist
	for(antagonistDoseIndex in 2:numberOfAntagonistDosingRegimens){
		if (simultaneousOpioidAndAntagonistAdministration=="yes"){
			dosingoutput<-dosingevents(
					inputs$opioidDose[doseIndex], opioid_time=opioidAdministrationTime,naloxone_dose=antagonistDose, #delayed opioid
					naloxone_time=opioidAdministrationTime, antagonistDoseIndex=antagonistDoseIndex,gap=interDoseDelay,
					pars=truepar)
		}else {
			if (opioidAdministrationTime>0){
				dosingoutput<-dosingevents(
						inputs$opioidDose[doseIndex], opioid_time=opioidAdministrationTime,naloxone_dose=antagonistDose, #delayed opioid
						naloxone_time=0, antagonistDoseIndex=antagonistDoseIndex,gap=interDoseDelay,
						pars=truepar)
			}else{				
				dosingoutput<-dosingevents(
						inputs$opioidDose[doseIndex], opioid_time=opioidAdministrationTime,naloxone_dose=antagonistDose, #delayed opioid
						naloxone_time=crossingtime+this.par["initialdelay"], antagonistDoseIndex=antagonistDoseIndex,gap=interDoseDelay,
						pars=truepar)
			}
		}
		truepar<-getCardiacArrestParameters(truepar, dosingoutput)

		trueparOut=rbind(trueparOut, t(truepar))
		statesOut=rbind(statesOut, t(states))
		dosingeventsOut=rbind(dosingeventsOut, dosingoutput[[2]], c(0,0,0,0,0))

		out <- fundedewithEvent(states, dosingoutput[[1]], truepar, namesyout, dosingoutput[[2]])
		outlist[[antagonistDoseIndex]]<-out
		rm(out)
	}#for naloxone_doseN

	list(outlist, (crossingtime+this.par["initialdelay"]))
}