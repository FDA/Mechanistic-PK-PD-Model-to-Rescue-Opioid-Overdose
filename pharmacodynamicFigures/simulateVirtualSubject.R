#last edited by: Anik Chaturbedi
#on: 2023-05-18

rm(list = ls()) #removes all objects from the current workspace

#load required package(s)
library(deSolve)
library(optparse)
library(ggplot2)
library(gridExtra)
library(grid)
library(scales)
#========================

#load required scripts===================================================
source("input/simulationParameters.R") #get simulation related inputs
dyn.load(paste0(modelFolder,"delaymymod.so"))
source(paste0(modelFolder,"delaypars.R"))
source(paste0(modelFolder,"delaystates.R"))
source(paste0(modelFolder,"dosingevents.R")); 
source(paste0(modelFolder,"fundede.R"))
source(paste0(modelFolder,"fundedewithEvent.R"))
source(paste0(modelFolder,"patientWrapper.R"))
source(paste0(modelFolder,"setModelOutputVariables.R"))
source("functions/createOutputFolder.R") #creates output folder based on simulation settings *has to be called after "functions/optionParsing.R"
source("functions/crossing.R");
source("functions/getAntagonistAdministrationTimeCase.R")
source("functions/getCardiacArrestAndRescueTime.R") 
source("functions/getCardiacArrestParameters.R")
source("functions/outputDataAll.R")
source("functions/plottingAll.R")
source("functions/plottingSingleVariableTimeCourse.R")
source("functions/plottingSingleVariableTimeCourseInternalFunction0_2_4_2__2II.R")
source("functions/setupOptimalParameters.R") #set up population parameters dataframe
source("functions/setupPopulationParameters.R") #set up population parameters dataframe
source("functions/writeCardiacArrestAndRescueTime.R") 
#========================================================================
print(inputs$subjectIndex)
for (doseIndex in 1:length(inputs$opioidDose)){
	for (subjectIndex in as.numeric(inputs$subjectIndex)) {	
		this.par<-unlist(populationParameters[subjectIndex,])
		truepar<-this.par[!names(this.par)=="initialdelay" & !names(this.par)=="Dose"] 
		trueparOut=t(truepar)
		statesOut=t(states)
		out=fundede(states=states, fulltimes=fulltimes, truepar=truepar, namesyout=namesyout)
		OutputUptoSS=out
		stateidx<-match(names(states), colnames(out), nomatch=0)
		states[stateidx!=0]<- out[dim(out)[1], stateidx]
		threshold<-fractionOfBaselineVentilationForAntagonistAdministration*out[dim(out)[1],"Minute ventilation (l/min)"]; #calculate ventilation threshold for antagonist administration based on the SS ventilation
		
		pp<-patientWrapper(doseIndex=doseIndex, subjectIndex=subjectIndex, interDoseDelay=interDoseDelay, threshold=threshold)
		
		outputDataAll()
		if (inputs$plottingOn=="yes"){
			plottingAll()}
	}	
}