#last edited by: Anik Chaturbedi
#on: 2024-11-07

#typical subject output folder==================
if (inputs$simulateRenarcotization=="yes"){
	optimalOutputFolder=sprintf("output/%s/optimalOutput%s/%s_%s_%s_%s_%s_%s_%s_%s,%smins", 
			inputs$antagonistAdministrationRouteAndDose,
			Sys.Date(), 
			inputs$opioid, 
			inputs$opioidDose,	
			inputs$opioidDosingRoute,	
			inputs$opioidInfusionRate,	
			inputs$opioidAbsorptionRate,	
			inputs$fractionOfBaselineVentilationForAntagonistAdministration,	
			inputs$subjectType, 
			inputs$subjectAge, 
			timeUL)
}else{
	optimalOutputFolder=sprintf("output/%s/optimalOutput%s/%s_%s_%s_%s_%s,%smins",	
			inputs$antagonistAdministrationRouteAndDose, 
			Sys.Date(), 
			inputs$opioid, 
			inputs$opioidDose,																							
			inputs$fractionOfBaselineVentilationForAntagonistAdministration,	
			inputs$subjectType, 
			inputs$subjectAge, 
			timeUL)
}
system(paste0("mkdir -p ", optimalOutputFolder))
#==================typical subject output folder

#all subjects output folder===============================
if (simultaneousOpioidAndAntagonistAdministration=="yes"){
	populationFolder=sprintf("output/%s/individualSubjectsSimultaneousOpioidAndAntagonist%s/%s_%s_%s_%s",
			inputs$antagonistAdministrationRouteAndDose,
			Sys.Date(),
			inputs$opioid,
			inputs$opioidDose,
			inputs$subjectType,
			inputs$subjectAge)
}else {
	if (opioidAdministrationTime>0){
		populationFolder=sprintf("output/%s/individualSubjectsDelayedOpioid%s/%s_%s_%s_%s",
				inputs$antagonistAdministrationRouteAndDose,
				Sys.Date(),
				inputs$opioid,
				inputs$opioidDose,
				inputs$subjectType,
				inputs$subjectAge)
	}else{
		if (inputs$initialDelay==60){
			if (inputs$useConditionSetting=="none"){
				if (inputs$simulateRenarcotization=="no"){
					populationFolder=sprintf("output/%s/individualSubjects%s/%s_%s_%s_%s_%s,%smins",
							inputs$antagonistAdministrationRouteAndDose,
							Sys.Date(),
							inputs$opioid,
							inputs$opioidDose,
							inputs$fractionOfBaselineVentilationForAntagonistAdministration,	
							inputs$subjectType,
							inputs$subjectAge,
							simulationTime/60)
				}else{
					populationFolder=sprintf("output/%s/individualSubjects%s/%s_%s_%s_%s_%s_%s_%s_%s,%smins",
							inputs$antagonistAdministrationRouteAndDose,
							Sys.Date(),
							inputs$opioid,
							inputs$opioidDose,
							inputs$opioidDosingRoute,	
							inputs$opioidInfusionRate,
							inputs$opioidAbsorptionRate,
							inputs$fractionOfBaselineVentilationForAntagonistAdministration,	
							inputs$subjectType,
							inputs$subjectAge,
							simulationTime/60)
				}
			}else{
				populationFolder=sprintf("output/%s/individualSubjects%s_%s/%s_%s_%s_%s",
						inputs$antagonistAdministrationRouteAndDose,
						Sys.Date(),
						inputs$useConditionSetting,
						inputs$opioid,
						inputs$opioidDose,
						inputs$subjectType,
						inputs$subjectAge)
			}
		}else if (inputs$initialDelay<0){
			inputs$initialDelay=60
			populationFolder=sprintf("output/%s/individualSubjectsNever%s/%s_%s_%s_%s",
					inputs$antagonistAdministrationRouteAndDose,
					Sys.Date(),
					inputs$opioid,
					inputs$opioidDose,
					inputs$subjectType,
					inputs$subjectAge)
		}else {
			populationFolder=sprintf("output/%s/individualSubjects_%s_%s/%s_%s_%s_%s",
					inputs$antagonistAdministrationRouteAndDose,
					inputs$initialDelay,
					Sys.Date(),
					inputs$opioid,
					inputs$opioidDose,
					inputs$subjectType,
					inputs$subjectAge)}
	}
}
system(paste0("mkdir -p ", populationFolder))
#===============================all subjects output folder