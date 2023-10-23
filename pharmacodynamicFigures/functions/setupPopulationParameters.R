#last edited by: Anik Chaturbedi
#on: 2023-05-15
populationParameters<-optimalParameters #initialize population parameter dataframe with typical/optimal parameters
populationParameters<-populationParameters[names(optimalParameters)] #parameter order very important! #NOT SURE IF THIS IS NEEDED-ANIK
populationParameters<-as.data.frame(t(populationParameters)) #convert into a dataframe of 1 row and as many columns as parameters

#create population parameter set from spreadsheets=====================================================================
population0=c()

#Pharmacokinetic parameters==============================================================================
if(inputs$opioid=="fentanyl"){
	if(inputs$useOpioidPKPopulation=="yes"){
		population0=read.csv("input/populationParameters/opioid/fentanylPKPopulation.csv")
	}
}else if(inputs$opioid == "carfentanil"){
	if(inputs$useOpioidPKPopulation=="yes"){
		population0=read.csv("input/populationParameters/opioid/fentanylPKPopulation.csv")
		population0[,"k21"]<-population0[,"k21"]*10
		population0[,"k13"]<-population0[,"k13"]/10
		population0[,"k31"]<-population0[,"k31"]*10
		population0[,"kout"]<-population0[,"kout"]/10
	}
}
if(inputs$antagonist=="naloxone"){
	#add antagonist population parameters to the opioid parameters
	if (inputs$antagonistAdministrationRouteAndDose=="IN4"){
		Naloxone_Params<-read.csv("input/populationParameters/antagonist/naloxoneIN4mgRepeatedDosingPKPopulationBLQ.csv")
		population0["F"]=Naloxone_Params["F"]
		population0["f1"]=Naloxone_Params["f1"]
		population0["f2"]=Naloxone_Params["f2"]
		population0["ktr"]=Naloxone_Params["Ktr"]
		population0["kin"]=Naloxone_Params["Kin"]
		population0["V1"]=Naloxone_Params["V1"]
		population0["kout2"]=Naloxone_Params["Kout"]
		population0["k12N"]=Naloxone_Params["k12N"]
		population0["V2"]=Naloxone_Params["V2"]		
	}else if (grepl("IV", inputs$antagonistAdministrationRouteAndDose, fixed = TRUE)){
		Naloxone_Params<-read.csv("input/populationParameters/antagonist/naloxoneIVPKPopulation.csv")
		population0["ikoutC"]=Naloxone_Params["ikoutC"]
		population0["ik12C"]=Naloxone_Params["ik12C"]
		population0["ik21C"]=Naloxone_Params["ik21C"]
		population0["ik13C"]=Naloxone_Params["ik13C"]
		population0["ik31C"]=Naloxone_Params["ik31C"]
		population0["iV2C"]=Naloxone_Params["iV2C"]					
	}
}

#Receptor binding parameters======================================================================================
if(inputs$opioid=="fentanyl"){
	ABNcorect=read.csv("input/populationParameters/opioid/fentanylReceptorBindingPopulation.csv")
}else if (inputs$opioid=="carfentanil"){
	ABNcorect=read.csv("input/populationParameters/opioid/carfentanilReceptorBindingPopulation.csv")
}
#replace old opioid receptor binding parameters with new ones
population0["A1"]=ABNcorect["A1"]#A_sample#ABNcorect["A1"]
population0["B1"]=ABNcorect["B1"]#B_sample#ABNcorect["B1"]
population0["n"]=ABNcorect["n"]#n_sample#ABNcorect["n"]
if(inputs$antagonist=="naloxone"){
	ABN_B=read.csv("input/populationParameters/antagonist/naloxoneReceptorBindingPopulation.csv")
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