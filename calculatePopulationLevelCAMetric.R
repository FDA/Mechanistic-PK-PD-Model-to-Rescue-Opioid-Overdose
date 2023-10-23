#last edited by: Anik Chaturbedi
#on: 2024-11-05

#define inputs=====================================================================
CAQuantilesToReport=c(2.5/100, 5/100, 25/100, 50/100, 1-25/100, 1-5/100, 1-2.5/100)
#==================================================================================
#load libraries==
library(ggplot2)
library(optparse)
#================
#get inputs========================================================================================================================================================================================================================================================================
parser<-OptionParser()
parser<-add_option(parser, c("-a", "--opioid"), default ="fentanyl",type="character",help="opioid used to induce respiratory depression (options: fentanyl, carfentanil, sufentanil)")
parser<-add_option(parser, c("-b", "--opioidDose"), default ="1.625",type="numeric",help="opioid concentration (in mg) (options: 1.625, 2.965, 0.012, 0.02187)")
parser<-add_option(parser, c("-c", "--antagonist"), default ="naloxone",type="character",help="antagonist used to rescue from opioid induced respiratory depression (options: naloxone, nalmefene)")
parser<-add_option(parser, c("-d", "--antagonistAdministrationRouteAndDose"), default ="IN4",type="character",help="antagonist administration route and dose in mg (options: IN4, IM2EVZIO, IM2Generic, IM5ZIMHI, IVMultipleDoses, IV2, IVBoyer, IM10)")
parser<-add_option(parser, c("-e", "--subjectType"), default ="chronic",type="character",help="type of subject (options: naive, chronic)")
parser<-add_option(parser, c("-f", "--subjectIndex"), default ="2001",type="numeric",help="subject index [decides what parameter set to use among population parameter sets](options: 1-2001, 2001 is the 'average' patient)")
parser<-add_option(parser, c("-g", "--varyInitialDelayInNaloxoneAdministration"), default ="no",type="character",help="whether to randomly vary the initial delay in administration among subjects in a population")
parser<-add_option(parser, c("-i", "--useOpioidPKPopulation"), default ="yes",type="character",help="whether to use opioid PK parameter distribution while simulating population")
parser<-add_option(parser, c("-j", "--antagonistAdministrationTimeCase"), default ="_60_",type="character",help="which antagonist administration start time case to be used (options: _30_, , _180_, _300_, _600_, SimultaneousOpioidAndAntagonist, NoAntagonistDelay, DelayedOpioid)")
parser<-add_option(parser, c("-k", "--dispersionMetric"), default ="IQR",type="character",help="what dispersion metric to use after sampling (options: IQR, 90% CI, 95% CI)")
parser<-add_option(parser, c("-l", "--numberOfSampling"), default ="2500",type="numeric",help="numberOfSampling")
parser<-add_option(parser, c("-m", "--numberOfSubjectsSelected"), default ="200",type="numeric",help="numberOfSubjectsSelected")
parser<-add_option(parser, c("-n", "--subjectAge"), default ="adult",type="character",help="age of subject (options: adult, 10YearOld)")
parser<-add_option(parser, c("-o", "--useConditionSetting"), default ="none",type="character",help="seed number for sampling")
parser<-add_option(parser, c("-p", "--opioidInfusionRate"), default ="100",type="numeric",help="opioid infusion rate (ug/hr)")
parser<-add_option(parser, c("-q", "--opioidAbsorptionRate"), default ="1",type="numeric",help="opioid absorption rate (-)")
parser<-add_option(parser, c("-r", "--inputDate"), default ="",type="character",help="productInputDate1")
parser<-add_option(parser, c("-s", "--simulateRenarcotization"), default ="no", type="character", help="as the name suggests (options: no, yes)")
parser<-add_option(parser, c("-t", "--fractionOfBaselineVentilationForAntagonistAdministration"), default ="0.4",type="numeric",help="fractionOfBaselineVentilationForAntagonistAdministration (-)")
inputs<-parse_args(parser)
#==================================================================================================================================================================================================================================================================================
set.seed(100)
if (inputs$simulateRenarcotization=="yes"){
	if (inputs$opioidDosingRoute=="transmucosal"){
		simulationTime<- 15*60*60
	}
}else{
	simulationTime<- 1*60*60 #real time of simulation (in seconds)
}
inputs$opioidDose<-inputs$opioidDose*1e6 #ng
if(inputs$inputDate==""){inputs$inputDate=Sys.Date()}
if(inputs$antagonistAdministrationTimeCase=="_60_"){inputs$antagonistAdministrationTimeCase=""}
if(inputs$subjectAge=="adult"){
	antagonistDosesLabels<-c("No dose", "1 dose")
}else if(inputs$subjectAge=="10YearOld"){
	antagonistDosesLabels<-c("No dose", "1 scaled dose", "1 dose")
}
selectedDosesToPlot<-antagonistDosesLabels
xLabel<-"Antagonist dosing"

figureHeight<-6
figureWidth<-7

selectedDoseIndices<-which(antagonistDosesLabels %in% selectedDosesToPlot)

if (inputs$useConditionSetting=="none"){
	inputFolder=	sprintf("output/%s/individualSubjects%s%s",		inputs$antagonistAdministrationRouteAndDose, inputs$antagonistAdministrationTimeCase, inputs$inputDate)
}else{
	inputFolder=	sprintf("output/%s/individualSubjects%s%s_%s",	inputs$antagonistAdministrationRouteAndDose, inputs$antagonistAdministrationTimeCase, inputs$inputDate, inputs$useConditionSetting)
}

if (inputs$simulateRenarcotization=="yes"){
	modelOutputFolder=sprintf("%s_%s_%s_%s_%s_%s_%s,%smins",	inputs$opioid, inputs$opioidDose, inputs$fractionOfBaselineVentilationForAntagonistAdministration,	inputs$opioidInfusionRate,	inputs$opioidAbsorptionRate,	inputs$subjectType, inputs$subjectAge, simulationTime/60) 
}else{
	modelOutputFolder=sprintf("%s_%s_%s_%s_%s,%smins",			inputs$opioid, inputs$opioidDose, inputs$fractionOfBaselineVentilationForAntagonistAdministration,																inputs$subjectType, inputs$subjectAge, simulationTime/60) 
}

if(inputs$dispersionMetric=="IQR"){
	if (inputs$useConditionSetting=="none"){
		outputFolder=	sprintf("output/%s/populationOutput%s%s/%s/CA/IQR", inputs$antagonistAdministrationRouteAndDose, inputs$antagonistAdministrationTimeCase, Sys.Date(), modelOutputFolder)
	}else{
		outputFolder=	sprintf("output/%s/populationOutput%s%s_%s/%s/CA/IQR", inputs$antagonistAdministrationRouteAndDose, inputs$antagonistAdministrationTimeCase, Sys.Date(), inputs$useConditionSetting, modelOutputFolder)
	}
	
}else if (inputs$dispersionMetric=="90% CI"){
	print("NEEDS TO BE UPDATED!")
}else if (inputs$dispersionMetric=="95% CI"){
	print("NEEDS TO BE UPDATED!")
}
system(paste0("mkdir -p ", outputFolder))
#========================================================================================================================================

if (inputs$simulateRenarcotization=="yes"){ #ADDED ON 2023-08-15
	source("functions/findingCommonSubjectsInPopulation.R") #ADDED ON 2023-08-15
	commonFilenames=findingCommonSubjectsInPopulation(inputs=inputs) #ADDED ON 2023-08-15
}

#calculate CA percentatge of all sample populations========================================================================================
CAPercentageAllSamples=c() #initialization
for (samplingIndex in 1:inputs$numberOfSampling){
	#get CA occurrence information for all subjects in this sample population=============================================
	CAOcurrenceAllSubjects=c();	
	
	if (inputs$simulateRenarcotization!="yes"){ #ADDED ON 2023-08-15
		totalNumberOfSubjects= 2000
		selectedSubjectIndices<-sample(c(1:totalNumberOfSubjects), inputs$numberOfSubjectsSelected, replace=T) #change replace to F to get all population case w/ -n 1 and -s 2000 
		for (selectedSubjectIndex in selectedSubjectIndices) {
			if (file.exists(sprintf("%s/%s/Subject%s.csv", inputFolder, modelOutputFolder, selectedSubjectIndex))) { #if model ran
				d0=read.csv(sprintf("%s/%s/Subject%s.csv", inputFolder, modelOutputFolder, selectedSubjectIndex), stringsAsFactors =F) #read model output
				if (ncol(d0)==14) {
					CAOcurrenceAllSubjects=cbind(CAOcurrenceAllSubjects, d0[,2])
				}
			}
		}
	}else{
		selectedFilenames<-sample(commonFilenames, inputs$numberOfSubjectsSelected, replace=T) #change replace to F to get all population case w/ -n 1 and -s 2000 
		for (selectedFilename in selectedFilenames) {
			if (file.exists(sprintf("%s/%s/%s", inputFolder, modelOutputFolder, selectedFilename))) { #if model ran
				d0=read.csv(sprintf("%s/%s/%s", inputFolder, modelOutputFolder, selectedFilename), stringsAsFactors =F) #read model output
				if (ncol(d0)==14) {
					CAOcurrenceAllSubjects=cbind(CAOcurrenceAllSubjects, d0[,2])
				}
			}	
		}
	}
	
	#calculate CA percentage for all subjects in this sample population and store===============
	CAPercentageAllSamples=cbind(CAPercentageAllSamples,
			(1-(rowSums(CAOcurrenceAllSubjects=='no', na.rm=TRUE)/inputs$numberOfSubjectsSelected))*100)
#===========================================================================================	
}
#==========================================================================================================================================
#calculate dispersion measure of all sample populations==================================
CAQuantilesAll<-c()
for(i in 1:length(antagonistDosesLabels)){
	CAQuantiles<-round(quantile(CAPercentageAllSamples[i,],probs=CAQuantilesToReport)) #calculate quantiles of RT for each antagonist dosing case and all subjects
	CAQuantilesAll<-rbind(CAQuantilesAll,CAQuantiles)	#row-bind median rescue time for each antagonist dosing case
}
#=========================================================================================
#clean and output CA ocurrence percentage data==========================================================================================================
CAPercentages<-data.frame(CAQuantilesAll) #convert into data frame
names(CAPercentages)<-paste("Percentage", as.numeric(CAQuantilesToReport*100),  sep="")
CAPercentages$antagonistDosesLabels<-antagonistDosesLabels #add column for antagonist doses
CAPercentages$antagonistDosesLabels = factor(CAPercentages$antagonistDosesLabels, levels = antagonistDosesLabels)
write.csv(CAPercentages, sprintf("%s/numberOfSampling%s_sampledPopulationSize%s.csv", outputFolder, inputs$numberOfSampling, inputs$numberOfSubjectsSelected)) #write the CA% data
#=======================================================================================================================================================
#ploting CA% barplots (newer)===============================================================================================================
CAPercentages<-CAPercentages[selectedDoseIndices,]
p<-ggplot(data = CAPercentages, aes(antagonistDosesLabels, Percentage50))
p<-p+ geom_bar(aes(x=antagonistDosesLabels, y=Percentage50), stat="identity", fill="black", alpha=0.8)
if(inputs$dispersionMetric=="IQR"){
	p<-p+ geom_text(
			aes(label = sprintf("%s (%s-%s)", round(Percentage50), round(Percentage25), round(Percentage75)), y = Percentage75+1),
			position = position_dodge(0.9),
			vjust = 0,
			size=4)
	p<-p+ geom_errorbar(
			aes(x= antagonistDosesLabels, ymin= Percentage25, ymax= Percentage75), 
			width=0.4, 
			colour="red", 
			alpha=0.9, 
			size=1.3)
}else if (inputs$dispersionMetric=="90% CI"){
	p<-p+ geom_text(
			aes(label = sprintf("%s (%s-%s)", round(Percentage50), round(Percentage5), round(Percentage95)), y = Percentage95+1),
			position = position_dodge(0.9),
			vjust = 0,
			size=4)
	p<-p+ geom_errorbar(
			aes(x=antagonistDosesLabels, ymin=Percentage5, ymax=Percentage95), 
			width=0.4, 
			colour="red", 
			alpha=0.9, 
			size=1.3)
}else if (inputs$dispersionMetric=="95% CI"){
	p<-p+ geom_text(
			aes(label = sprintf("%s (%s-%s)", round(Percentage50), round(Percentage2.5), round(Percentage97.5)), y = Percentage97.5+1),
			position = position_dodge(0.9),
			vjust = 0,
			size=4)
	p<-p+ geom_errorbar(
			aes(x=antagonistDosesLabels, ymin=Percentage2.5, ymax=Percentage97.5), 
			width=0.4, 
			colour="red", 
			alpha=0.9, 
			size=1.3)
}
p<-p+ ylim(0,100)
p<-p+ ylab("% Virtual subjects experiencing cardiac arrest")
p<-p+ xlab(xLabel)
p<-p+ theme_bw()
p<-p+theme(legend.direction = "vertical",
		legend.position = c(0.8, 0.8),    
		legend.background=element_rect(fill = alpha("white", 0)),  
		# Hide panel borders and remove grid lines
		panel.border = element_blank(),
		panel.grid.major = element_line(colour = "grey",size=0.25),
		panel.grid.minor = element_line(colour = "grey",size=0.25),
		# Change axis line
		axis.line = element_line(colour = "black"),
		axis.text.x = element_text(angle = 45, hjust=1,colour="black",size=12),
		axis.text.y = element_text(colour="black",size=10),
		axis.title=element_text(size=12,face="bold"))
ggsave(sprintf("%s/numberOfSampling%s_sampledPopulationSize%s.jpg", outputFolder, inputs$numberOfSampling, inputs$numberOfSubjectsSelected), p, height = figureHeight , width = figureWidth)
#===========================================================================================================================================
