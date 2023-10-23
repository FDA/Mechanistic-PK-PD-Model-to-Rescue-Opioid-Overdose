#last edited by: Anik Chaturbedi
#on: 2024-11-07

outputDataAll<-function(){	
	writeCardiacArrestAndRescueTime()
	
	#saving more data when plotting is on=============================================================================================================================================================================================================================================================
	if (inputs$plottingOn=="yes"){		
		write.csv(pp[[1]][[1]][,c("time", "Minute ventilation (l/min)")], paste0(optimalOutputFolder,"/MVOpioidOnly.csv"))
		write.csv(pp[[1]][[2]][,c("time", "Minute ventilation (l/min)")], paste0(optimalOutputFolder,"/MV.csv"))
		
		write.csv(pp[[1]][[1]][,c("time", "Arterial O2 saturation (%) alternate")], paste0(optimalOutputFolder,"/AOSOpioidOnly.csv"))
		write.csv(pp[[1]][[2]][,c("time", "Arterial O2 saturation (%) alternate")], paste0(optimalOutputFolder,"/AOS.csv"))
		
		write.csv(pp[[1]][[1]][,c("time", "Brain O2 partial pressure (mm Hg)")], paste0(optimalOutputFolder,"/BOPPOpioidOnly.csv"))
		write.csv(pp[[1]][[2]][,c("time", "Brain O2 partial pressure (mm Hg)")], paste0(optimalOutputFolder,"/BOPP.csv"))
		
		write.csv(pp[[1]][[1]][,c("time", "Cardiac output (l/min)")], paste0(optimalOutputFolder,"/COOpioidOnly.csv"))
		write.csv(pp[[1]][[2]][,c("time", "Cardiac output (l/min)")], paste0(optimalOutputFolder,"/CO.csv"))
		
		write.csv(pp[[1]][[2]][,c("time", "Opioid plasma concentration (ng/ml)")], paste0(optimalOutputFolder,"/opioidPlasmaConcentration.csv"))
		
		write.csv(pp[[1]][[2]][,c("time", "Antagonist plasma concentration (ng/ml)")], paste0(optimalOutputFolder,"/APC.csv"))
		write.csv(pp[[1]][[2]][,c("time", "Antagonist effect site concentration (nM)")], paste0(optimalOutputFolder,"/AESC.csv"))
		write.csv(pp[[1]][[2]][,c("time", "Antagonist bound receptor fraction")], paste0(optimalOutputFolder,"/ABRP.csv"))
	}
	#=============================================================================================================================================================================================================================================================saving more data when plotting is on
	
	#special case when trying to get the optimal subject antagonist PK with no opioid===================
	if (inputs$plottingOn=="noButOnlyAntagonistPK"){
		writeTimeCourseOfParameter(parameter="Antagonist plasma concentration (ng/ml)", doseIndices=c(2))
		calculateAndWritePKParameters(parameter="Antagonist plasma concentration (ng/ml)", doseIndices=c(2))
	}
	#===================special case when trying to get the optimal subject antagonist PK with no opioid
	
	#saving more data when varying only antagonist PK (mainly to generate antagonist PK band)===============
	if (inputs$OnlyUseRandomAntagonistPopulationPK=="yes"){
		writeTimeCourseOfParameter(parameter="Antagonist plasma concentration (ng/ml)", doseIndices=c(2))
		calculateAndWritePKParameters(parameter="Antagonist plasma concentration (ng/ml)", doseIndices=c(2))
	}
	#===============saving more data when varying only antagonist PK (mainly to generate antagonist PK band)
	
	#saving more data for renarcotization=======================================================================================================================================================================================================================================================================
	if (inputs$simulateRenarcotization=="yes"){
		system(paste0("mkdir -p ", sprintf("%s_APC", populationFolder)))
		write.csv(pp[[1]][[2]][,c("time", "Antagonist plasma concentration (ng/ml)")], sprintf("%s_APC/Subject%s.csv", populationFolder, subjectIndex))
		system(paste0("mkdir -p ", sprintf("%s_MV", populationFolder)))
		system(paste0("mkdir -p ", sprintf("%s_MVOpioidOnly", populationFolder)))
		write.csv(pp[[1]][[1]][,c("time", "Minute ventilation (l/min)")], sprintf("%s_MVOpioidOnly/Subject%s.csv", populationFolder, subjectIndex))
		write.csv(pp[[1]][[2]][,c("time", "Minute ventilation (l/min)")], sprintf("%s_MV/Subject%s.csv", populationFolder, subjectIndex))
	}
	#=======================================================================================================================================================================================================================================================================saving more data for renarcotization
}