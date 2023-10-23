#last edited by: Anik Chaturbedi
#on: 2023-05-15
#Pharmacokinetic & receptor binding parameters========================
if(inputs$opioid=="fentanyl"){#fentanyl
	source("input/optimalParameters/opioid/fentanylPK.R")
	source("input/optimalParameters/opioid/fentanylReceptorBinding.R")
	
}else if(inputs$opioid=="carfentanil"){
	source("input/optimalParameters/opioid/carfentanilPK.R")
	source("input/optimalParameters/opioid/carfentanilReceptorBinding.R")
	
}
if(inputs$antagonist=="naloxone"){	
	source("input/optimalParameters/antagonist/naloxoneReceptorBinding.R")
	if (inputs$antagonistAdministrationRouteAndDose=="IN4"){
		source("input/optimalParameters/antagonist/naloxoneIN4mgRepeatedDosingPKBLQ.R")		
	}else if (grepl("IV", inputs$antagonistAdministrationRouteAndDose, fixed = TRUE)){
		source("input/optimalParameters/antagonist/naloxoneIVPK.R")		
	}
}
#further scaling based on age====
#=====================================================================
#Pharmacodynamic parameters===================================================================================
if(inputs$subjectAge=="adult" & inputs$subjectType=="chronic"){	
	source("input/optimalParameters/subject/chronic.R")
}else {
	source("input/optimalParameters/subject/naive.R")
}
#===================================================================================Pharmacodynamic parameters
#Physiological parameters================================================
if(inputs$subjectAge=="adult"){
	source("input/optimalParameters/physiological/physiologicalParameters.R")	
}
#========================================================================

parameters=c(opioidPKParameters,opioidBindingParameters,antagonistPKParameters,antagonistBindingParameters,subjectPDParameters,physiologicalParameters)
parameterIndex<-match(names(optimalParameters), names(parameters), nomatch=0)
optimalParameters[parameterIndex!=0]<- parameters[parameterIndex]

#simulation parameters============
optimalParameters["initialdelay"]<-inputs$initialDelay
#=================================