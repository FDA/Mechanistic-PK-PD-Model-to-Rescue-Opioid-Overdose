#last edited by: Anik Chaturbedi
#on: 2023-05-19
#define inputs===============================================================================================================================================
rescueTimeQuantilesToReport=c(50/100, 25/100, 1-25/100)
#============================================================================================================================================================
#load libraries==
library(ggplot2)
library(optparse)
#================
#get inputs========================================================================================================================================================================================================================================================================
parser<-OptionParser()
parser<-add_option(parser, c("-a", "--opioid"), default ="fentanyl",type="character",help="opioid used to induce respiratory depression (options: fentanyl, carfentanil)")
parser<-add_option(parser, c("-b", "--opioidDose"), default ="1.625",type="numeric",help="opioid concentration (in mg) (options: 1.625, 2.965, 0.012, 0.02187)")
parser<-add_option(parser, c("-c", "--antagonist"), default ="naloxone",type="character",help="antagonist used to rescue from opioid induced respiratory depression (options: naloxone)")
parser<-add_option(parser, c("-d", "--antagonistAdministrationRouteAndDose"), default ="IN4",type="character",help="antagonist administration route and dose in mg (options: IN4, IVMultipleDoses, IVBoyer)")
parser<-add_option(parser, c("-e", "--subjectType"), default ="chronic",type="character",help="type of subject (options: naive, chronic)")
parser<-add_option(parser, c("-f", "--subjectIndex"), default ="2001",type="numeric",help="subject index [decides what parameter set to use among population parameter sets](options: 1-2001, 2001 is the 'average' patient)")
parser<-add_option(parser, c("-g", "--varyInitialDelayInNaloxoneAdministration"), default ="no",type="character",help="whether to randomly vary the initial delay in administration among subjects in a population")
parser<-add_option(parser, c("-i", "--useOpioidPKPopulation"), default ="yes",type="character",help="whether to use opioid PK parameter distribution while simulating population")
parser<-add_option(parser, c("-j", "--antagonistAdministrationTimeCase"), default ="",type="character",help="which antagonist administration start time case to be used (options: _30_, , _180_, _300_, _600_, SimultaneousOpioidAndAntagonist, NoAntagonistDelay, DelayedOpioid)")
parser<-add_option(parser, c("-k", "--dispersionMetric"), default ="IQR",type="character",help="what dispersion metric to use after sampling (options: IQR, 90% CI, 95% CI)")
parser<-add_option(parser, c("-l", "--numberOfSampling"), default ="2500",type="numeric",help="numberOfSampling")
parser<-add_option(parser, c("-m", "--numberOfSubjectsSelected"), default ="200",type="numeric",help="numberOfSubjectsSelected")
parser<-add_option(parser, c("-n", "--subjectAge"), default ="adult",type="character",help="age of subject (options: adult)")
inputs<-parse_args(parser)
#==================================================================================================================================================================================================================================================================================
set.seed(100)
if(inputs$antagonistAdministrationTimeCase=="_60_"){
	inputs$antagonistAdministrationTimeCase=""
}
if (inputs$antagonistAdministrationRouteAndDose=="IN4"){
	if(inputs$subjectAge=="adult"){
		antagonistDosesLabels<-c("No dose","1 dose","2 doses standard","3 doses standard","4 doses standard","2 doses rapid","4 doses rapid")
		selectedDosesToPlot<-c("No dose", "1 dose")
	}
	xLabel<-"Naloxone dosing"
	
}else if (inputs$antagonistAdministrationRouteAndDose=="IVBoyer"){
	antagonistDosesLabels<-c("0",
			"0.04",
			"0.04+0.5",
			"0.04+0.5+2",
			"0.04+0.5+2+4",
			"0.04+0.5+2+4+10",
			"0.04+0.5+2+4+10+15")
	selectedDosesToPlot<-antagonistDosesLabels
	xLabel<-"Naloxone dosing (mg)"
}else if (inputs$antagonistAdministrationRouteAndDose=="IVMultipleDoses"){
	antagonistDosesLabels<-c("0",
			"0.04",
			"0.5",
			"1",
			"2",
			"4",
			"10")
	selectedDosesToPlot<-antagonistDosesLabels
	xLabel<-"Naloxone dosing (mg)"
}
selectedDoseIndices<-which(antagonistDosesLabels %in% selectedDosesToPlot)
inputFolder=paste0("output/",inputs$antagonistAdministrationRouteAndDose,"/","individualSubjects",inputs$antagonistAdministrationTimeCase)
modelOutputFolder=sprintf("%s_%s_%s_%s", inputs$opioid, inputs$opioidDose, inputs$subjectType, inputs$subjectAge)
outputFolder=paste0("output/",inputs$antagonistAdministrationRouteAndDose,"/","populationOutput",inputs$antagonistAdministrationTimeCase, "/", modelOutputFolder, "/RT")
system(paste0("mkdir -p ",outputFolder))
#============================================================
#collate data from model output folder======================================================================================= 
t1_B=c() # Brain time
t1_A=c() # Arterial O2 time
t1_S=c() # O2 Sat time
t1_C=c() # Arterial CO2 time
for (selectedSubjectIndex in 1:2000) {
	if (file.exists(sprintf("%s/%s/Subject%s.csv",inputFolder,modelOutputFolder,selectedSubjectIndex))) { #if model ran
		d0=read.csv(sprintf("%s/%s/Subject%s.csv",inputFolder,modelOutputFolder,selectedSubjectIndex),stringsAsFactors =F) #read model output
		if (ncol(d0)==14) {
			t1_B=cbind(t1_B,(d0[,5]))
			t1_A=cbind(t1_A,(d0[,8]))
			t1_S=cbind(t1_S,(d0[,11]))
			t1_C=cbind(t1_C,(d0[,14]))
		}
	}
}
Rescue_Medians_B<-c()
Rescue_Medians_A<-c()
Rescue_Medians_S<-c()
Rescue_Medians_C<-c()
for(i in 1:length(antagonistDosesLabels)){
	median_sB<-quantile(t1_B[i,],probs=rescueTimeQuantilesToReport)
	median_sA<-quantile(t1_A[i,],probs=rescueTimeQuantilesToReport)
	median_sS<-quantile(t1_S[i,],probs=rescueTimeQuantilesToReport)
	median_sC<-quantile(t1_C[i,],probs=rescueTimeQuantilesToReport)		
	Rescue_Medians_B<-rbind(Rescue_Medians_B,median_sB)
	Rescue_Medians_A<-rbind(Rescue_Medians_A,median_sA)	
	Rescue_Medians_S<-rbind(Rescue_Medians_S,median_sS)	
	Rescue_Medians_C<-rbind(Rescue_Medians_C,median_sC)	
}
rownames(Rescue_Medians_B)<-antagonistDosesLabels
rownames(Rescue_Medians_A)<-antagonistDosesLabels
rownames(Rescue_Medians_S)<-antagonistDosesLabels
rownames(Rescue_Medians_C)<-antagonistDosesLabels
write.csv(round(Rescue_Medians_B/60,digits = 1),sprintf("%s/RescueTimes_%s_dose_%s_PK_%s_BO2.csv",outputFolder,inputs$opioid,inputs$opioidDose,inputs$subjectType))
write.csv(round(Rescue_Medians_A/60,digits = 1),sprintf("%s/RescueTimes_%s_dose_%s_PK_%s_AO2.csv",outputFolder,inputs$opioid,inputs$opioidDose,inputs$subjectType))
write.csv(round(Rescue_Medians_S/60,digits = 1),sprintf("%s/RescueTimes_%s_dose_%s_PK_%s_Sat.csv",outputFolder,inputs$opioid,inputs$opioidDose,inputs$subjectType))
write.csv(round(Rescue_Medians_C/60,digits = 1),sprintf("%s/RescueTimes_%s_dose_%s_PK_%s_ACO2.csv",outputFolder,inputs$opioid,inputs$opioidDose,inputs$subjectType))