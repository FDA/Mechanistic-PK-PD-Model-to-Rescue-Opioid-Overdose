#last edited by: Anik Chaturbedi
#on: 2023-05-18
plottingSingleVariableTimeCourse<-function(varvec){	
	firstNaloxoneIntroductionTime=pp[[2]]
	timeOfDeath<- (crossing(pp[[1]][[1]][,"Cardiac output (l/min)"], pp[[1]][[1]][,"time"], CABloodFlow)[[2]][1])/60
	outputFolder=paste0("output/",
			inputs$antagonistAdministrationRouteAndDose,"/",
			"optimalOutput",antagonistAdministrationTimeCase,"/",
			inputs$subjectType,",",inputs$opioidDose,"mg",inputs$opioid,",",timeUL,"mins")	
	outputFolder0_2_4_2__2=paste0(outputFolder,"/0_2_4_2__2dose")	
	system(paste0("mkdir -p ",outputFolder0_2_4_2__2))
	
	for (variableToPlot in varvec){	
		plot<-plottingSingleVariableTimeCourseInternalFunction0_2_4_2__2(variableToPlot, timeUL, firstNaloxoneIntroductionTime)
		p <- grid.arrange(plot, ncol=1, nrow=1)		
		ggsave(sprintf("%s/%s.svg",outputFolder0_2_4_2__2,gsub("/", "_", variableToPlot)), p, height = 4, width = 5)
		ggsave(sprintf("%s/%s.svg",outputFolder0_2_4_2__2,gsub("/", "_", variableToPlot)), p, height = 4, width = 7)		
	}
}