#last edited by: Anik Chaturbedi
#on: 2023-05-15
plottingAll<-function(){
	naloxoneClinicalStudyPaperFigureVariables<-c(
			"Opioid bound receptor fraction",
			"Minute ventilation (l/min)",
			"Brain O2 partial pressure (mm Hg)",
			"Arterial O2 partial pressure (mm Hg)",
			"Arterial CO2 partial pressure (mm Hg)",
			"Cardiac output (l/min)",
			"Blood flow to brain (l/min)")
	plottingSingleVariableTimeCourse(naloxoneClinicalStudyPaperFigureVariables) #final one used for paper
}