#last edited by: Anik Chaturbedi
#on: 2023-06-16

plottingSingleVariableTimeCourse<-function(varvec){	
	todaysDate=Sys.Date() #creates output folder based on this
	firstNaloxoneIntroductionTime=pp[[2]]
	timeOfDeath<- (crossing(pp[[1]][[1]][,"Cardiac output (l/min)"], pp[[1]][[1]][,"time"], CABloodFlow)[[2]][1])/60
	if (inputs$simulateRenarcotization=="no"){
		outputFolder=sprintf("output/%s/optimalOutput%s/%s_%s_%s_%s,%smins",
				inputs$antagonistAdministrationRouteAndDose,
				todaysDate,
				inputs$opioid,
				inputs$opioidDose,
				inputs$subjectType,
				inputs$subjectAge,
				timeUL)
	}else{
		outputFolder=sprintf("output/%s/optimalOutput%s/%s_%s_%s_%s_%s_%s,%smins",
				inputs$antagonistAdministrationRouteAndDose,
				todaysDate,
				inputs$opioid,
				inputs$opioidDose,
				inputs$opioidInfusionRate,
				inputs$opioidAbsorptionRate,
				inputs$subjectType,
				inputs$subjectAge,
				timeUL)
	}
	system(paste0("mkdir -p ", outputFolder))
	
	outputFolder0_1=paste0(outputFolder, "/0_1dose")	
	system(paste0("mkdir -p ", outputFolder0_1))
	
	for (variableToPlot in varvec){	
		#change figure filename for incompartible variable names====
		fileName= variableToPlot
		if (variableToPlot=="Arterial O2 saturation (%)"){
			fileName="Arterial O2 saturation"
		}else if (variableToPlot=="Arterial O2 saturation (%) alternate"){
			fileName="Arterial O2 saturation alternate"
		}
		#====change figure filename for incompartible variable names
		
		plot<-plottingSingleVariableTimeCourseInternalFunction(variableToPlot, timeUL, firstNaloxoneIntroductionTime)
		p <- grid.arrange(plot, ncol=1, nrow=1)		
		ggsave(sprintf("%s/%s.svg", outputFolder, gsub("/", "_", fileName)), p, height = 4, width = 6)
		
		plot<-plottingSingleVariableTimeCourseInternalFunction0_1(variableToPlot, timeUL, firstNaloxoneIntroductionTime)
		p <- grid.arrange(plot, ncol=1, nrow=1)		
		ggsave(sprintf("%s/%s.svg", outputFolder0_1, gsub("/", "_", fileName)), p, height = 4, width = 6)
		
	}
}