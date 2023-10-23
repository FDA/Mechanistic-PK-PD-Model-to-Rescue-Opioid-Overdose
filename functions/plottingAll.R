#last edited by: Anik Chaturbedi
#on: 2024-06-26

plottingAll<-function(){
	opioidMainPKVariables=c("Opioid plasma concentration (ng/ml)", "Opioid effect site concentration (nM)", "Opioid bound receptor fraction")
	antagonistPKVariables=c("Antagonist plasma concentration (ng/ml)", "Antagonist effect site concentration (nM)", "Antagonist bound receptor fraction")
	mainVentilationVariables=c("Minute ventilation (l/min)","Residual wakefulness drive (l/min)","Chemoreflex drive (l/min)")
	cardiacOutputVariables=c("Cardiac output (l/min)", "Blood flow to brain (l/min)","Blood flow to tissue (l/min)")		
	O2Variables=c("Arterial O2 partial pressure (mm Hg)", "Brain O2 partial pressure (mm Hg)")
	CO2Variables=c("Brain CO2 partial pressure (mm Hg)", "Arterial CO2 partial pressure (mm Hg)")
	
	plottingMultipleVariablesInDifferentFigureInSamePDF(c(opioidMainPKVariables, antagonistPKVariables, mainVentilationVariables, cardiacOutputVariables, O2Variables, CO2Variables))
}