#last edited by: Anik Chaturbedi
#on: 2022-11-16
if (simultaneousOpioidAndAntagonistAdministration=="yes"){
	populationFolder=sprintf("output/%s/individualSubjectsSimultaneousOpioidAndAntagonist%s/%s_%s_%s_%s",
			inputs$antagonistAdministrationRouteAndDose,
			todaysDate,
			inputs$opioid,
			inputs$opioidDose,
			inputs$subjectType,
			inputs$subjectAge)
}else {
	if (opioidAdministrationTime>0){
		populationFolder=sprintf("output/%s/individualSubjectsDelayedOpioid%s/%s_%s_%s_%s",
				inputs$antagonistAdministrationRouteAndDose,
				todaysDate,
				inputs$opioid,
				inputs$opioidDose,
				inputs$subjectType,
				inputs$subjectAge)
	}else{
		if (inputs$initialDelay==60){
			populationFolder=sprintf("output/%s/individualSubjects%s/%s_%s_%s_%s",
					inputs$antagonistAdministrationRouteAndDose,
					todaysDate,
					inputs$opioid,
					inputs$opioidDose,
					inputs$subjectType,
					inputs$subjectAge)
		}else if (inputs$initialDelay<0){
			inputs$initialDelay=60
			populationFolder=sprintf("output/%s/individualSubjectsNever%s/%s_%s_%s_%s",
					inputs$antagonistAdministrationRouteAndDose,
					todaysDate,
					inputs$opioid,
					inputs$opioidDose,
					inputs$subjectType,
					inputs$subjectAge)
		}else {
			populationFolder=sprintf("output/%s/individualSubjects_%s_%s/%s_%s_%s_%s",
					inputs$antagonistAdministrationRouteAndDose,
					inputs$initialDelay,
					todaysDate,
					inputs$opioid,
					inputs$opioidDose,
					inputs$subjectType,
					inputs$subjectAge)}
	}
}
system(paste0("mkdir -p ",populationFolder))