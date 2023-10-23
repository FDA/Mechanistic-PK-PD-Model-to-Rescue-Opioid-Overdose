#last edited by: Anik Chaturbedi
#on: 2023-07-07
plottingAll<-function(){
	naloxoneClinicalStudyPaperFigureVariables<-c(
			"Minute ventilation (l/min)",
			"Arterial O2 saturation (%) alternate",
			"Brain O2 partial pressure (mm Hg)",
			"Cardiac output (l/min)",
			"Arterial CO2 partial pressure (mm Hg)",
			"Arterial O2 partial pressure (mm Hg)",
			"Blood flow to brain (l/min)"
	)
	plottingSingleVariableTimeCourse(naloxoneClinicalStudyPaperFigureVariables) #final one used for paper
}