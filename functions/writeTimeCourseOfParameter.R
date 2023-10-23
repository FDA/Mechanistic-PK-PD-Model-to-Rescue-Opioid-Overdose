#last edited by: Anik Chaturbedi
#on: 2023-04-26

writeTimeCourseOfParameter<-function(parameter=c(), doseIndices=c()){
	antagonistPlasmaConcentrationTimeCourse=c()
	
	#output folders to create=================================
	outputFolder=sprintf("%s_antagonistPlasmaConcentration", populationFolder)
	system(paste0("mkdir -p ",outputFolder))
	#=================================output folders to create
	
	for(doseIndex in doseIndices){	
		antagonistPlasmaConcentrationTimeCourse<-cbind(antagonistPlasmaConcentrationTimeCourse,	pp[[1]][[doseIndex]][,c("time", parameter)])
	}
	write.csv(antagonistPlasmaConcentrationTimeCourse, sprintf("%s/Subject%s.csv", outputFolder, subjectIndex))	
}