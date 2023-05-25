#last edited by: Anik Chaturbedi
#on: 2023-05-25
plottingAll<-function(){
	naloxoneClinicalStudyPaperFigureVariables<-c(
			"Minute ventilation (l/min)",
			"Arterial O2 saturation (%) alternate",
			"Brain O2 partial pressure (mm Hg)",
			"Cardiac output (l/min)",
			"Arterial O2 partial pressure (mm Hg)",
			"Arterial CO2 partial pressure (mm Hg)"
	)
	plottingSingleVariableTimeCourse(naloxoneClinicalStudyPaperFigureVariables) #final one used for paper
}