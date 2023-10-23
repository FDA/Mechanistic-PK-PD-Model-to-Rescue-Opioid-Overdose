#last edited by: Anik Chaturbedi
#on: 2023-05-18
if (simultaneousOpioidAndAntagonistAdministration=="yes"){
	populationFolder=sprintf("output/%s/individualSubjectsSimultaneousOpioidAndAntagonist/%s_%s_%s_%s",
			inputs$antagonistAdministrationRouteAndDose,
			inputs$opioid,
			inputs$opioidDose,
			inputs$subjectType,
			inputs$subjectAge)
}else {
	if (opioidAdministrationTime>0){
		populationFolder=sprintf("output/%s/individualSubjectsDelayedOpioid/%s_%s_%s_%s",
				inputs$antagonistAdministrationRouteAndDose,
				inputs$opioid,
				inputs$opioidDose,
				inputs$subjectType,
				inputs$subjectAge)
	}else{
		if (inputs$initialDelay==60){
			populationFolder=sprintf("output/%s/individualSubjects/%s_%s_%s_%s",
					inputs$antagonistAdministrationRouteAndDose,
					inputs$opioid,
					inputs$opioidDose,
					inputs$subjectType,
					inputs$subjectAge)
		}else if (inputs$initialDelay<0){
			inputs$initialDelay=60
			populationFolder=sprintf("output/%s/individualSubjectsNever/%s_%s_%s_%s",
					inputs$antagonistAdministrationRouteAndDose,
					inputs$opioid,
					inputs$opioidDose,
					inputs$subjectType,
					inputs$subjectAge)
		}else {
			populationFolder=sprintf("output/%s/individualSubjects_%s/%s_%s_%s_%s",
					inputs$antagonistAdministrationRouteAndDose,
					inputs$initialDelay,
					inputs$opioid,
					inputs$opioidDose,
					inputs$subjectType,
					inputs$subjectAge)}
	}
}
system(paste0("mkdir -p ",populationFolder))