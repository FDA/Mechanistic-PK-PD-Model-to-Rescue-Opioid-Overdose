#last edited by: Anik Chaturbedi
#on: 2024-11-12

#Pharmacokinetic & receptor binding parameters========================
if(inputs$opioid=="fentanyl"){#fentanyl
	if (!is.null(inputs$simulateRenarcotization) && inputs$simulateRenarcotization=="yes"){
		if (inputs$opioidDosingRoute=="transmucosal"){
			source("parameters/optimalParameters/opioid/fentanylTransmucosalPK.R")
		}
	}else{
		source("parameters/optimalParameters/opioid/fentanylPK.R")
	}
	source("parameters/optimalParameters/opioid/fentanylReceptorBinding.R")	
}else if(inputs$opioid=="carfentanil"){
	source("parameters/optimalParameters/opioid/carfentanilPK.R")
	source("parameters/optimalParameters/opioid/carfentanilReceptorBinding.R")
}
if(inputs$antagonist=="naloxone"){	
	source("parameters/optimalParameters/antagonist/naloxoneReceptorBinding.R")
	if(inputs$antagonistAdministrationRouteAndDose=="IN4naloxone"){
		source("parameters/optimalParameters/antagonist/naloxoneIN4mgPK.R")
	}
}else if(inputs$antagonist=="nalmefene"){
	source("parameters/optimalParameters/antagonist/nalmefeneReceptorBinding.R")
	if (grepl("IN", inputs$antagonistAdministrationRouteAndDose, fixed = TRUE)){
		if(inputs$antagonistAdministrationRouteAndDose=="IN3nalmefeneC"){
			source("parameters/optimalParameters/antagonist/nalmefeneIN3mgCPK.R")
		}else if(inputs$antagonistAdministrationRouteAndDose=="IN3nalmefeneB"){
			source("parameters/optimalParameters/antagonist/nalmefeneIN3mgBPK.R")
		}else if(inputs$antagonistAdministrationRouteAndDose=="IN3nalmefeneA"){
			source("parameters/optimalParameters/antagonist/nalmefeneIN3mgAPK.R")
		}
	}
}
#further scaling based on age====
if(inputs$subjectAge!="adult"){
	ageDependentParameters=getAgeDependentParameters(inputs)	
	weightScaling=ageDependentParameters[ageDependentParameters$age==inputs$subjectAge,"weight"]/ageDependentParameters[ageDependentParameters$age=="adult","weight"]
	
	scalingFactor0_75=weightScaling^0.75
	scalingFactor1=weightScaling^1
	scalingFactor1_3=weightScaling^1.3
	
	if (modelFolder=="models/modelINRepeatedDosing2/" |
			modelFolder=="models/modelINRepeatedDosing2_antagonist1opioid2/"){
		print("Method 1 for antagonist")
		opioidPKParameters["kout"]=opioidPKParameters["kout"]*scalingFactor0_75 #(scalingFactor0_75/scalingFactor1_3)
	}else if (modelFolder=="models/modelINRepeatedDosing2_antagonist2opioid2/" |
			modelFolder=="models/modelINRepeatedDosing2_antagonist3opioid2/" ){
		print("Method 2 or 3 for antagonist")
		opioidPKParameters["kout"]=opioidPKParameters["kout"]*(scalingFactor0_75/scalingFactor1) #(scalingFactor0_75/scalingFactor1_3)
	}
	opioidPKParameters["VP"]=opioidPKParameters["VP"]*scalingFactor1 #scalingFactor1_3
	
	antagonistPKParameters["kout2"]=antagonistPKParameters["kout2"]*(scalingFactor0_75/scalingFactor1)
	antagonistPKParameters["V1"]=antagonistPKParameters["V1"]*scalingFactor1
	antagonistPKParameters["V2"]=antagonistPKParameters["V2"]*scalingFactor1	
}
#=====================================================================
#Pharmacodynamic parameters===================================================================================
if(inputs$subjectAge=="adult" & inputs$subjectType=="chronic"){	
	source("parameters/optimalParameters/subject/chronic.R")
}
#===================================================================================Pharmacodynamic parameters
#Physiological parameters================================================
if(inputs$subjectAge=="adult"){
	source("parameters/optimalParameters/physiological/physiologicalParameters.R")
}
#========================================================================

parameters=c(opioidPKParameters, opioidBindingParameters, antagonistPKParameters, antagonistBindingParameters, subjectPDParameters, physiologicalParameters)
parameterIndex<-match(names(optimalParameters), names(parameters), nomatch=0)
optimalParameters[parameterIndex!=0]<- parameters[parameterIndex]

#simulation parameters============
optimalParameters["initialdelay"]<-inputs$initialDelay
#=================================