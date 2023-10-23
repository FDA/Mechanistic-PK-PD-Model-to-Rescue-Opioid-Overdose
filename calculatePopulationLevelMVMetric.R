#last edited by: Anik Chaturbedi
#on: 2024-11-08

#define inputs=====================================================================
MVQuantilesToReport=c(2.5/100, 5/100, 25/100, 50/100, 1-25/100, 1-5/100, 1-2.5/100)
#==================================================================================
#loading libraries====
library(cmaes) #Covariance Matrix Adapting Evolutionary Strategy
library(deSolve) #Solvers for Initial Value Problems of Differential Equations ('ODE', 'DAE', 'DDE')
library(ggplot2) #Create Elegant Data Visualisations Using the Grammar of Graphics
library(optparse) #Command Line Option Parser
require(snowfall) #Easier Cluster Computing (Based on 'snow')
library(dplyr) #A Grammar of Data Manipulation
library(data.table) #Extension of 'data.frame'
#====loading libraries
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
parser<-add_option(parser, c("-r", "--inputDate"), default ="2022-09-15",type="character",help="productInputDate1")
parser<-add_option(parser, c("-s", "--simulateRenarcotization"), default ="no", type="character", help="as the name suggests (options: no, yes)")
parser<-add_option(parser, c("-t", "--PercentCI"), default ="100",type="numeric",help="PercentCI")
parser<-add_option(parser, c("-u", "--typicalSubjectInputDate"), default ="2022-09-15",type="character",help="productInputDate1")
parser<-add_option(parser, c("-v", "--opioidDosingRoute"), default ="transdermal",type="character",help="what opioid dosing route to use (transdermal, transmucosal)")
parser<-add_option(parser, c("-w", "--fractionOfBaselineVentilationForAntagonistAdministration"), default ="0.4",type="numeric",help="fractionOfBaselineVentilationForAntagonistAdministration (-)")
inputs<-parse_args(parser)
#==================================================================================================================================================================================================================================================================================
#inputs==================================================================================================================================================
if(inputs$inputDate==""){inputs$inputDate=Sys.Date()}
if(inputs$typicalSubjectInputDate==""){inputs$typicalSubjectInputDate=Sys.Date()}
inputs$opioidDose<-inputs$opioidDose*1e6 #ng
inputs$numberOfSubjects=2000
simulationTime= 24*60 #(minutes)
timeToPlot= 15*60 #(minutes)
lowQuantile=(100-inputs$PercentCI)/100/2
highQuantile= 1-lowQuantile
if (inputs$antagonistAdministrationRouteAndDose== "IN3nalmefeneB"){
	antagonistDoseLabel="Intranasal nalmefene 3 mg B"
}else if (inputs$antagonistAdministrationRouteAndDose== "IN3nalmefeneA"){
	antagonistDoseLabel="Intranasal nalmefene 3 mg A"
}else if (inputs$antagonistAdministrationRouteAndDose== "IN3nalmefeneC"){
	antagonistDoseLabel="Intranasal nalmefene 3 mg C"
}else if (inputs$antagonistAdministrationRouteAndDose== "IN4naloxone"){
	antagonistDoseLabel="Intranasal naloxone 4 mg"
}else if (inputs$antagonistAdministrationRouteAndDose== "OpioidOnly"){
	antagonistDoseLabel="Opioid only"
}

#input folder=======================================================================================================================================================================================================================================================================
if (inputs$antagonistAdministrationRouteAndDose== "OpioidOnly"){
	inputs$antagonistAdministrationRouteAndDoseTemp= "IN3nalmefeneB"
	inputFolderMinuteVentilation= sprintf("output/%s/individualSubjects%s/%s_%s_%s_%s_%s_%s_%s_%s,%smins_MVOpioidOnly", 
			inputs$antagonistAdministrationRouteAndDoseTemp, 
			inputs$inputDate,					
			inputs$opioid, 
			inputs$opioidDose, 
			inputs$opioidDosingRoute,	
			inputs$opioidInfusionRate, 
			inputs$opioidAbsorptionRate, 
			inputs$fractionOfBaselineVentilationForAntagonistAdministration,	
			inputs$subjectType, 
			inputs$subjectAge,
			simulationTime) 
	inputFolderMinuteVentilationTypicalSubject= sprintf("output/%s/individualSubjects%s/%s_%s_%s_%s_%s_%s_%s_%s,%smins_MVOpioidOnly", 
			inputs$antagonistAdministrationRouteAndDoseTemp, 
			inputs$typicalSubjectInputDate,	
			inputs$opioid, 
			inputs$opioidDose, 
			inputs$opioidDosingRoute,	
			inputs$opioidInfusionRate, 
			inputs$opioidAbsorptionRate, 
			inputs$fractionOfBaselineVentilationForAntagonistAdministration,	
			inputs$subjectType, 
			inputs$subjectAge,
			simulationTime)
}else{
	inputFolderMinuteVentilation= sprintf("output/%s/individualSubjects%s/%s_%s_%s_%s_%s_%s_%s_%s,%smins_MV", 
			inputs$antagonistAdministrationRouteAndDose, 
			inputs$inputDate,					
			inputs$opioid, 
			inputs$opioidDose, 
			inputs$opioidDosingRoute,	
			inputs$opioidInfusionRate, 
			inputs$opioidAbsorptionRate, 
			inputs$fractionOfBaselineVentilationForAntagonistAdministration,	
			inputs$subjectType, 
			inputs$subjectAge,
			simulationTime) 
	inputFolderMinuteVentilationTypicalSubject= sprintf("output/%s/individualSubjects%s/%s_%s_%s_%s_%s_%s_%s_%s,%smins_MV", 
			inputs$antagonistAdministrationRouteAndDose, 
			inputs$typicalSubjectInputDate,		
			inputs$opioid, 
			inputs$opioidDose, 
			inputs$opioidDosingRoute,	
			inputs$opioidInfusionRate, 
			inputs$opioidAbsorptionRate, 
			inputs$fractionOfBaselineVentilationForAntagonistAdministration,	
			inputs$subjectType, 
			inputs$subjectAge,
			simulationTime)
}
#=======================================================================================================================================================================================================================================================================input folder
#==================================================================================================================================================inputs

#output folders to create===============================================================================================================================
if (inputs$antagonistAdministrationRouteAndDose== "OpioidOnly"){
	inputs$antagonistAdministrationRouteAndDoseTemp= "IN3nalmefeneB"
	outputFolder=sprintf("output/%s/populationOutput%s/%s_%s_%s_%s_%s_%s_%s_%s,%smins_MVOpioidOnly", 
			inputs$antagonistAdministrationRouteAndDoseTemp, 
			Sys.Date(), 
			inputs$opioid, 
			inputs$opioidDose, 
			inputs$opioidDosingRoute,	
			inputs$opioidInfusionRate, 
			inputs$opioidAbsorptionRate,
			inputs$fractionOfBaselineVentilationForAntagonistAdministration,	
			inputs$subjectType, 
			inputs$subjectAge,
			simulationTime) 
}else{
	outputFolder=sprintf("output/%s/populationOutput%s/%s_%s_%s_%s_%s_%s_%s_%s,%smins_MV", 
			inputs$antagonistAdministrationRouteAndDose, 
			Sys.Date(), 
			inputs$opioid, 
			inputs$opioidDose, 
			inputs$opioidDosingRoute,	
			inputs$opioidInfusionRate, 
			inputs$opioidAbsorptionRate, 
			inputs$fractionOfBaselineVentilationForAntagonistAdministration,	
			inputs$subjectType, 
			inputs$subjectAge,
			simulationTime) 
}
system(paste0("mkdir -p ", outputFolder))
#===============================================================================================================================output folders to create

#read data for all subjects and calculate mean, median, quantiles====================================================================
print("STARTING MV TIMECOURSE PROCESSING===========================================================================================")
#read and combine plasma concentration data for all subjects====================================================
allSubjectData=c()
allSubjectDataProcessed=c()
#faster method using rbindlist========================================================================
#function to generate your data
getMinuteVentilationData <- function(inputFolder, subjectIndex){
	print(subjectIndex)
	if(file.exists(sprintf("%s/Subject%s.csv", inputFolder, subjectIndex))){
		data= data.frame(read.csv(sprintf("%s/Subject%s.csv", inputFolder, subjectIndex)))
		data= data %>%
				filter(row_number() %% 600 == 1)
		return(cbind(data, subjectIndex= subjectIndex))	
	}
}
#using data table's rbindlist all at once
getAllSubjectData <- function(inputFolder, n){
	return(data.frame(rbindlist(lapply(1:n, function(x) getMinuteVentilationData(inputFolder, x)))))
}
allSubjectData=getAllSubjectData(inputFolderMinuteVentilation, inputs$numberOfSubjects)
allSubjectData=allSubjectData[c(2, 3, 4)]
colnames(allSubjectData)=c("time", "mv", "subjectIndex")
#========================================================================faster method using rbindlist
#====================================================read and combine plasma concentration data for all subjects

#read and process typical subject data=================================================================
typicalSubjectData=getMinuteVentilationData(inputFolderMinuteVentilationTypicalSubject, 2001)
typicalSubjectData=typicalSubjectData[c(2, 3, 4)]
colnames(typicalSubjectData)=c("time", "mv", "subjectIndex")
#=================================================================read and process typical subject data

#calculate mean, median, quantiles from data of all subjects=========================================================================
#faster method using dpylr=========================================
allSubjectDataProcessed= allSubjectData %>% 
		group_by(time) %>% 
		summarise_at(vars(mv), list(qLow=~quantile(., probs = lowQuantile), qMedian= median, qHigh=~quantile(., probs = highQuantile)))
#=========================================faster method using dpylr
#combinedTypicalAndPopulationData= cbind(typicalSubjectData[,c(-3)], allSubjectDataProcessed[,c(-1)])
combinedTypicalAndPopulationData= merge(typicalSubjectData[,c(-3)], allSubjectDataProcessed)
write.csv(combinedTypicalAndPopulationData, sprintf("%s/minuteVentilation2_%s_%s.csv", outputFolder, inputs$numberOfSubjects, inputs$PercentCI))
#=========================================================================calculate mean, median, quantiles from data of all subjects
print("FINISHED MV TIMECOURSE PROCESSING===========================================================================================")
#====================================================================read data for all subjects and calculate mean, median, quantiles

#plotting all subject ribbon with median line/typical subject line=======================================================================================
plotUpToTime<-function(timeToPlot=c()){
	plot<-	ggplot()
	plot<-	plot	+	geom_line(data=combinedTypicalAndPopulationData, aes(x= time/60, y= mv), size=1, alpha=1, linetype = "solid", color="black") #typical subject line
	plot<-	plot	+	geom_ribbon(data=combinedTypicalAndPopulationData, aes(x= time/60, ymin= qLow, ymax= qHigh), alpha=0.2, fill="black")
	plot<-	plot	+	ylim(0, 7)
	plot<-	plot	+	ylab(paste0("Plasma concentration, ng/mL"))
	plot<-	plot	+	xlab(paste0("Time, minutes"))
	plot<-	plot	+	scale_x_continuous(limits=c(0, timeToPlot))	
	plot<-	plot	+	theme_bw()
	plot <- plot+ theme(
			legend.direction = "vertical",
			legend.position = "none", #use when also adding labels to the figure   
			legend.background=element_rect(fill = alpha("white", 0)),  
			panel.background = element_rect(fill = NA, color = "black"),
			panel.border = element_blank(),
			axis.line = element_line(colour = "black"),
			axis.title.x=element_blank(),
			axis.title.y=element_blank(),
			axis.text.x = element_text(size=12,  family="Calibri", color="black"),
			axis.text.y = element_text(size=12,  family="Calibri", color="black"),
			axis.ticks = element_line(color = "black"),
			strip.text.y = element_blank(),
			text=element_text(size=10,  family="Calibri"))
	ggsave(sprintf("%s/minuteVentilation2_%s_%s_%s.jpg", outputFolder, inputs$numberOfSubjects, inputs$PercentCI, timeToPlot), plot, height=2.5, width=3)
}
#plotUpToTime(timeToPlot= timeToPlot)
#=======================================================================================plotting all subject ribbon with median line/typical subject line