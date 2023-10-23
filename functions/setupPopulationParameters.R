#last edited by: Anik Chaturbedi
#on: 2024-11-12

populationParameters<-optimalParameters #initialize population parameter dataframe with typical/optimal parameters
populationParameters<-populationParameters[names(optimalParameters)] #parameter order very important!
populationParameters<-as.data.frame(t(populationParameters)) #convert into a dataframe of 1 row and as many columns as parameters

#create population parameter set from spreadsheets=====================================================================
population0=c()

#Pharmacokinetic parameters==============================================================================
if(inputs$opioid=="fentanyl"){
	if(inputs$useOpioidPKPopulation=="yes"){
		population0=read.csv("parameters/populationParameters/opioid/fentanylPKPopulation.csv")
		if (inputs$simulateRenarcotization=="yes"){
			if (inputs$opioidDosingRoute=="transmucosal"){
				print("Using optimal parameters because source (Actiq label) only had mean.")
			}
		}
	}
}else if(inputs$opioid == "carfentanil"){
	if(inputs$useOpioidPKPopulation=="yes"){
		population0=read.csv("parameters/populationParameters/opioid/fentanylPKPopulation.csv")
		population0[,"k21"]<-population0[,"k21"]*10
		population0[,"k13"]<-population0[,"k13"]/10
		population0[,"k31"]<-population0[,"k31"]*10
		population0[,"kout"]<-population0[,"kout"]/10
	}
}
if(inputs$antagonist=="naloxone"){
	#add antagonist population parameters to the opioid parameters
	if(inputs$antagonistAdministrationRouteAndDose=="IN4naloxone"){
		Naloxone_Params<-read.csv("parameters/populationParameters/antagonist/naloxoneIN4mgPKPopulation.csv")
		population0["F"]=Naloxone_Params["F"]
		population0["ktr"]=Naloxone_Params["Ktr"]
		population0["kin"]=Naloxone_Params["Kin"]
		population0["V1"]=Naloxone_Params["V1"]
		population0["kout2"]=Naloxone_Params["Kout"]
	}
}else if(inputs$antagonist=="nalmefene"){
	if (grepl("IN", inputs$antagonistAdministrationRouteAndDose, fixed = TRUE)){
		if(inputs$antagonistAdministrationRouteAndDose=="IN3nalmefeneC"){
			Naloxone_Params<-read.csv("parameters/populationParameters/antagonist/nalmefeneIN3mgCPKPopulation.csv")

			population0["F"]=Naloxone_Params["F"]
			population0["ktr"]=Naloxone_Params["Ktr"]
			population0["kin"]=Naloxone_Params["Kin"]
			population0["V1"]=Naloxone_Params["V1"]
			population0["kout2"]=Naloxone_Params["Kout"]
			population0["k12N"]=Naloxone_Params["k12N"]
			population0["V2"]=Naloxone_Params["V2"]
		}else if(inputs$antagonistAdministrationRouteAndDose=="IN3nalmefeneB"){
			Naloxone_Params<-read.csv("parameters/populationParameters/antagonist/nalmefeneIN3mgBPKPopulation.csv")
			
			population0["F"]=Naloxone_Params["F"]
			population0["ktr"]=Naloxone_Params["ktr"]
			population0["kin"]=Naloxone_Params["kin"]
			population0["V1"]=Naloxone_Params["V1"]
			population0["kout2"]=Naloxone_Params["kout2"]
			population0["k12N"]=Naloxone_Params["k12N"]
			population0["V2"]=Naloxone_Params["V2"]
		}else if(inputs$antagonistAdministrationRouteAndDose=="IN3nalmefeneA"){
			Naloxone_Params<-read.csv("parameters/populationParameters/antagonist/nalmefeneIN3mgAPKPopulation.csv")
			
			population0["F"]=Naloxone_Params["F"]
			population0["ktr"]=Naloxone_Params["ktr"]
			population0["kin"]=Naloxone_Params["kin"]
			population0["V1"]=Naloxone_Params["V1"]
			population0["kout2"]=Naloxone_Params["kout2"]
			population0["k12N"]=Naloxone_Params["k12N"]
			population0["V2"]=Naloxone_Params["V2"]
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
		population0["kout"]=population0["kout"]*scalingFactor0_75 #(scalingFactor0_75/scalingFactor1_3)
	}else if (modelFolder=="models/modelINRepeatedDosing2_antagonist2opioid2/" |
			modelFolder=="models/modelINRepeatedDosing2_antagonist3opioid2/" ){
		print("Method 2 or 3 for antagonist")
		population0["kout"]=population0["kout"]*(scalingFactor0_75/scalingFactor1) #(scalingFactor0_75/scalingFactor1_3)
	}
	population0["VP"]=population0["VP"]*scalingFactor1 #scalingFactor1_3
	
	population0["kout2"]=population0["kout2"]*(scalingFactor0_75/scalingFactor1)
	population0["V1"]=population0["V1"]*scalingFactor1
	population0["V2"]=population0["V2"]*scalingFactor1	
}
#========================================================================================================

#Receptor binding parameters======================================================================================
if(inputs$opioid=="fentanyl"){
	ABNcorect=read.csv("parameters/populationParameters/opioid/fentanylReceptorBindingPopulation.csv")
}else if (inputs$opioid=="carfentanil"){
	ABNcorect=read.csv("parameters/populationParameters/opioid/carfentanilReceptorBindingPopulation.csv")
}
#replace old opioid receptor binding parameters with new ones
population0["A1"]=ABNcorect["A1"]#A_sample#ABNcorect["A1"]
population0["B1"]=ABNcorect["B1"]#B_sample#ABNcorect["B1"]
population0["n"]=ABNcorect["n"]#n_sample#ABNcorect["n"]
if(inputs$antagonist=="naloxone"){
	ABN_B=read.csv("parameters/populationParameters/antagonist/naloxoneReceptorBindingPopulation.csv")
	population0["A2"]<-ABN_B["A2"]
	population0["B2"]<-ABN_B["B2"]
	population0["n2"]<-ABN_B["n2"]
}else if(inputs$antagonist=="nalmefene"){
	ABN_B=read.csv("parameters/populationParameters/antagonist/nalmefeneReceptorBindingPopulation.csv")
	population0["A2"]<-ABN_B["A2"]
	population0["B2"]<-ABN_B["B2"]
	population0["n2"]<-ABN_B["n2"]
}
#=================================================================================================================

#Pharmacodynamic parameters
#no distribution
#==========================

#Physiological parameters
#no distribution
#========================
#======================================================================================================================

#combine parameters=================================
Nvec=!colnames(populationParameters)%in%colnames(population0) #column indices of parameters that are present in populationParameters but not in population0
population1=cbind(population0,populationParameters[Nvec]) #combind the above parameters with population0 to create population1
populationParameters=population1[,names(optimalParameters)] #only keep the parameters that are among the typical/optimal subject parameters
#===================================================

#simulation parameters======================================================================================================
#initial delay in antagonist administration================================================================================
if (inputs$varyInitialDelayInNaloxoneAdministration=="yes"){populationParameters["initialdelay"]<-sample(0:(5*60),2000,replace=TRUE)
}else{populationParameters["initialdelay"]<-rep(inputs$initialDelay,2000)}
#==========================================================================================================================
#===========================================================================================================================

populationParameters<-rbind(populationParameters,optimalParameters) #join individual subject parameters of population with the typical/optimal subject parameters