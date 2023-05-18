#last edited by: Anik Chaturbedi
#on: 2022-02-18
if (simultaneousOpioidAndAntagonistAdministration=="yes"){
	antagonistAdministrationTimeCase="SimultaneousOpioidAndAntagonist"
}else {
	if (opioidAdministrationTime>0){
		antagonistAdministrationTimeCase="DelayedOpioid"
	}else{
		if (inputs$initialDelay==60){
			antagonistAdministrationTimeCase=""
		}else if (inputs$initialDelay==0){
			antagonistAdministrationTimeCase="NoAntagonistDelay"
		}else{antagonistAdministrationTimeCase=paste0("_",inputs$initialDelay,"_")}
	}
}