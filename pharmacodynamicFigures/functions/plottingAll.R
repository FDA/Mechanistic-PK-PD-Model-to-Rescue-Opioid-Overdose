#last edited by: Anik Chaturbedi
#on: 2023-05-22
plottingAll<-function(){
	naloxoneClinicalStudyPaperFigureVariables<-c(
			"Minute ventilation (l/min)",
			"Arterial O2 saturation (%) alternate",
			"Brain O2 partial pressure (mm Hg)",
			"Cardiac output (l/min)")
	plottingSingleVariableTimeCourse(naloxoneClinicalStudyPaperFigureVariables) #final one used for paper
}