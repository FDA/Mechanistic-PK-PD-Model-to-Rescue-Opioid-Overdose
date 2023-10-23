#last edited by: Anik Chaturbedi
#on: 2024-11-12

#loading libraries====
library(cmaes) #Covariance Matrix Adapting Evolutionary Strategy
library(deSolve) #Solvers for Initial Value Problems of Differential Equations ('ODE', 'DAE', 'DDE')
library(ggplot2) #Create Elegant Data Visualisations Using the Grammar of Graphics
library(optparse) #Command Line Option Parser
require(snowfall) #Easier Cluster Computing (Based on 'snow')
library(dplyr) #A Grammar of Data Manipulation
library(data.table) #Extension of 'data.frame'
#====loading libraries

parser<-OptionParser()
parser<-add_option(parser, c("-a", "--opioid"), default ="fentanyl", type="character", help="opioid used to induce respiratory depression (options: fentanyl, carfentanil, sufentanil)")
parser<-add_option(parser, c("-b", "--opioidDose"), default ="1.625", type="numeric", help="opioid concentration (in mg) (options: 1.625, 2.965, 0.012, 0.02187)")
parser<-add_option(parser, c("-c", "--antagonist"), default ="naloxone", type="character", help="antagonist used to rescue from opioid induced respiratory depression (options: naloxone, nalmefene)")
parser<-add_option(parser, c("-d", "--antagonistAdministrationRouteAndDose"), default ="IN4", type="character", help="antagonist administration route and dose in mg (options: IN4, IN8, IM2EVZIO, IM2Generic, IM5ZIMHI, IVMultipleDoses, IV2, IVBoyer, IM10)")
parser<-add_option(parser, c("-e", "--subjectType"), default ="chronic", type="character", help="type of subject (options: naive, chronic)")
parser<-add_option(parser, c("-f", "--subjectIndex"), default ="2001", type="numeric", help="subject index [decides what parameter set to use among population parameter sets](options: 1-2001, 2001 is the 'average' patient)")
parser<-add_option(parser, c("-g", "--varyInitialDelayInNaloxoneAdministration"), default ="no", type="character", help="whether to randomly vary the initial delay in administration among subjects in a population")
parser<-add_option(parser, c("-i", "--useOpioidPKPopulation"), default ="yes", type="character", help="whether to use opioid PK parameter distribution while simulating population")
parser<-add_option(parser, c("-j", "--initialDelay"), default ="60", type="numeric", help="delay in first dose of antagonist administration after ventilation reaches critical threshold (options: 0, 30, 60, 180, 300, 600)")
parser<-add_option(parser, c("-k", "--plottingOn"), default ="no", type="character", help="whether to generate plots or not (options: no, yes)")
parser<-add_option(parser, c("-l", "--subjectAge"), default ="adult", type="character", help="age of subject (options: adult, 10YearOld)")
parser<-add_option(parser, c("-m", "--OnlyUseRandomAntagonistPopulationPK"), default ="no", type="character", help="as the name suggests (options: no, yes)")
parser<-add_option(parser, c("-n", "--PlotForRenarcotization"), default ="no", type="character", help="as the name suggests (options: no, yes)")
parser<-add_option(parser, c("-o", "--useConditionSetting"), default ="none",type="character",help="seed number for sampling")
parser<-add_option(parser, c("-p", "--opioidInfusionRate"), default ="100",type="numeric",help="opioid infusion rate (ug/hr)")
parser<-add_option(parser, c("-q", "--opioidAbsorptionRate"), default ="1",type="numeric",help="opioid absorption rate (-)")
parser<-add_option(parser, c("-r", "--inputDate"), default ="2022-09-15",type="character",help="productInputDate1")
parser<-add_option(parser, c("-s", "--PercentCI"), default ="100",type="numeric",help="PercentCI")
parser<-add_option(parser, c("-t", "--typicalSubjectInputDate"), default ="2022-09-15",type="character",help="productInputDate1")
parser<-add_option(parser, c("-u", "--fractionOfBaselineVentilationForAntagonistAdministration"), default ="0.4",type="numeric",help="fractionOfBaselineVentilationForAntagonistAdministration (-)")
inputs<-parse_args(parser)

#inputs==================================================================================================================================================
if(inputs$inputDate==""){inputs$inputDate=Sys.Date()}
simulationTime<- 1*60 #(mins)
inputs$numberOfSubjects=2000
lowQuantile=(100-inputs$PercentCI)/100/2
if (inputs$antagonistAdministrationRouteAndDose== "IN3nalmefeneB"){
	antagonistDoseLabel="Intranasal nalmefene 3 mg B"
}else if (inputs$antagonistAdministrationRouteAndDose== "IN3nalmefeneA"){
	antagonistDoseLabel="Intranasal nalmefene 3 mg A"
}else if (inputs$antagonistAdministrationRouteAndDose== "IN3nalmefeneC"){
	antagonistDoseLabel="Intranasal nalmefene 3 mg C"
}else if (inputs$antagonistAdministrationRouteAndDose== "IN4naloxone"){
	antagonistDoseLabel="Intranasal naloxone 4 mg"
}

inputFolderAntagonistPlasmaConcentration= sprintf(
		"output/%s/individualSubjects%s/%s_%s_%s_%s_%s,%smins_antagonistPlasmaConcentration", 
		inputs$antagonistAdministrationRouteAndDose, 
		inputs$inputDate, 
		inputs$opioid, 
		inputs$opioidDose, 
		inputs$fractionOfBaselineVentilationForAntagonistAdministration,
		inputs$subjectType, 
		inputs$subjectAge,
		simulationTime) 
inputFolderAntagonistPlasmaConcentrationTypicalSubject=inputFolderAntagonistPlasmaConcentration
inputFolderPKParameters=sprintf(
		"output/%s/individualSubjects%s/%s_%s_%s_%s_%s,%smins_PKParameters", 
		inputs$antagonistAdministrationRouteAndDose, 
		inputs$inputDate, 
		inputs$opioid, 
		inputs$opioidDose, 
		inputs$fractionOfBaselineVentilationForAntagonistAdministration,
		inputs$subjectType, 
		inputs$subjectAge,
		simulationTime) 
#==================================================================================================================================================inputs

#output folders to create===============================================================================================================================
outputFolder=sprintf("output/%s/populationOutput%s/%s_%s_%s_%s", inputs$antagonistAdministrationRouteAndDose, Sys.Date(), inputs$opioid, inputs$opioidDose, inputs$subjectType, inputs$subjectAge) 
system(paste0("mkdir -p ",outputFolder))
#===============================================================================================================================output folders to create

#clinical PK timecourse data to match to============================================================
if (inputs$antagonistAdministrationRouteAndDose== "IN3nalmefeneA"){
	clinicalData=read.csv("data/nalmefeneA.csv")
	colnames(clinicalData)=c("time", "mean")
}else if (inputs$antagonistAdministrationRouteAndDose== "IN3nalmefeneB"){
	clinicalData=read.csv("data/nalmefeneB.csv")
	colnames(clinicalData)=c("time", "mean")
}else if (inputs$antagonistAdministrationRouteAndDose== "IN4naloxone"){
	clinicalData=read.csv("data/naloxone.csv")
	colnames(clinicalData)=c("time", "mean", "high")
	clinicalDataIndividualSubjects=read.csv("data/naloxoneIndividualSubjectData.csv")
}else if (inputs$antagonistAdministrationRouteAndDose== "IN3nalmefeneC"){
	clinicalData=read.csv("data/nalmefeneC.csv")
	colnames(clinicalData)=c("time", "mean", "low", "high")
	clinicalDataIndividualSubjects=read.csv("data/nalmefeneCIndividualSubjectData.csv")
}
#============================================================clinical PK timecourse data to match to

#read data for all subjects and calculate mean, median, quantiles====================================================================
print("STARTING PK TIMECOURSE PROCESSING===========================================================================================")
#read and combine plasma concentration data for all subjects====================================================
allSubjectData=c()
#faster method using rbindlist========================================================================
#function to generate your data
getAntagonistPlasmaConcentrationData <- function(inputFolder, subjectIndex){
	print(subjectIndex)
	if(file.exists(sprintf("%s/Subject%s.csv", inputFolder, subjectIndex))){
		data.frame(read.csv(sprintf("%s/Subject%s.csv", inputFolder, subjectIndex)))
	}
}
#using data table's rbindlist all at once
getAllSubjectData <- function(inputFolder, n){
	return(data.frame(rbindlist(lapply(1:n, function(x) getAntagonistPlasmaConcentrationData(inputFolder, x)))))
}
allSubjectData=getAllSubjectData(inputFolderAntagonistPlasmaConcentration, inputs$numberOfSubject)
allSubjectData=allSubjectData[c(2, 3)]
colnames(allSubjectData)=c("time", "apc")
#========================================================================faster method using rbindlist
#====================================================read and combine plasma concentration data for all subjects

#read and process typical subject data=================================================================
typicalSubjectData=getAntagonistPlasmaConcentrationData(inputFolderAntagonistPlasmaConcentrationTypicalSubject, 2001)
typicalSubjectData=typicalSubjectData[c(2, 3)]
colnames(typicalSubjectData)=c("time", "apc")
#=================================================================read and process typical subject data

#calculate mean, median, quantiles from data of all subjects=========================================================================
#faster method using dpylr=========================================
allSubjectData= allSubjectData %>% 
		group_by(time) %>% 
		summarise_at(vars(apc),
				list(
						qLow=~quantile(., probs = lowQuantile),
						qMedian= median, 
						qHigh=~quantile(., probs = 1-lowQuantile)))
#=========================================faster method using dpylr
#=========================================================================calculate mean, median, quantiles from data of all subjects
#output all subject data===================================================================================================
write.csv(allSubjectData, sprintf("%s/antagonistPlasmaConcentration_%s_%s.csv", outputFolder, inputs$numberOfSubject, inputs$PercentCI))
#===================================================================================================output all subject data
print("FINISHED PK TIMECOURSE PROCESSING===========================================================================================")
#====================================================================read data for all subjects and calculate mean, median, quantiles

#plotting all subject ribbon with median line and Krieter et al. mean points====================================================================
if (inputs$PlotForRenarcotization=="yes"){
	plotUpToTime<-function(timeToPlot=c()){
		plot<-	ggplot()
		plot<-	plot	+	geom_ribbon(data=allSubjectData, aes(x= time/3600, ymin= qLow, ymax= qHigh), alpha=0.2, fill="black")
		plot<-	plot	+	geom_line(data=allSubjectData, aes(x= time/3600, y= qMedian), size=1, alpha=1, linetype = "solid", color="black") #median line
		plot<-	plot	+	ylab(paste0("Plasma concentration, ng/mL"))
		plot<-	plot	+	xlab(paste0("Time, hours"))
		plot<-	plot	+	scale_x_continuous(limits=c(0, timeToPlot/60))	
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
		
		ggsave(sprintf("%s/antagonistPlasmaConcentration_%s_%s_%s.jpg", outputFolder, inputs$numberOfSubject, inputs$PercentCI, timeToPlot), plot, height=2.5, width=3)
	}
	plotUpToTime(timeToPlot=15*60)
}else{
	plotUpToTime<-function(timeToPlot=c()){
		plot<-	ggplot()
		plot<-	plot	+	geom_ribbon(data=allSubjectData, aes(x= time/60, ymin= qLow, ymax= qHigh), alpha=0.2, fill="black")
		plot<-	plot	+	geom_line(data=typicalSubjectData, aes(x= time/60, y= apc), size=1, alpha=1, linetype = "solid", color="black") #typical subject line
		plot<-	plot	+	geom_point(data=clinicalData, aes(x= time, y= mean), color="black", fill="black", shape=16, size=4)
		if (inputs$antagonistAdministrationRouteAndDose== "IN4naloxone"){
			plot<-	plot	+	geom_point(data=clinicalDataIndividualSubjects, aes(x= time, y= exp), color="black", fill="black", shape=16, size=1) #individual subjects
		} else	if (inputs$antagonistAdministrationRouteAndDose== "IN3nalmefeneC"){
			plot<-	plot	+	geom_point(data=clinicalDataIndividualSubjects, aes(x= time/60, y= exp), color="black", fill="black", shape=16, size=1) #individual subjects
		} 
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
		
		ggsave(sprintf("%s/antagonistPlasmaConcentration_%s_%s_%s.jpg", outputFolder, inputs$numberOfSubject, inputs$PercentCI, timeToPlot), plot, height=2.5, width=3)
	}
	plotUpToTime(timeToPlot=1*60)
}

#====================================================================plotting all subject ribbon with median line and Krieter et al. mean points
if (inputs$antagonistAdministrationRouteAndDose== "IN3nalmefeneA" | inputs$antagonistAdministrationRouteAndDose== "IN3nalmefeneB" ){
	
	#clinical PK parameter data to match to==============================================================================================================================================================================================================================
	if (inputs$antagonistAdministrationRouteAndDose== "IN3nalmefeneA"){
		clinicalPKParameterData=read.csv("data/nalmefeneAPKParameters.csv")
	}else if (inputs$antagonistAdministrationRouteAndDose== "IN3nalmefeneB"){
		clinicalPKParameterData=read.csv("data/nalmefeneBPKParameters.csv")
	}
	colnames(clinicalPKParameterData)=c("parameter", "mean_median", "sd", "CV", "min", "max")
	clinicalPKParameterData$parameter <- as.character(clinicalPKParameterData$parameter)
	clinicalPKParameterData$parameter <- factor(clinicalPKParameterData$parameter, levels=unique(clinicalPKParameterData$parameter))
	
	parameter1="CMax"
	clinicalPKParameterData[clinicalPKParameterData[,"parameter"]==parameter1,"xMin"]= clinicalPKParameterData[clinicalPKParameterData[,"parameter"]==parameter1,"mean_median"]*(1-(clinicalPKParameterData[clinicalPKParameterData[,"parameter"]==parameter1,"CV"]/100))
	clinicalPKParameterData[clinicalPKParameterData[,"parameter"]==parameter1,"xMax"]= clinicalPKParameterData[clinicalPKParameterData[,"parameter"]==parameter1,"mean_median"]*(1+(clinicalPKParameterData[clinicalPKParameterData[,"parameter"]==parameter1,"CV"]/100))
	
	parameter2="TMax"
	clinicalPKParameterData[clinicalPKParameterData[,"parameter"]==parameter2,"xMin"]= clinicalPKParameterData[clinicalPKParameterData[,"parameter"]==parameter2,"min"]
	clinicalPKParameterData[clinicalPKParameterData[,"parameter"]==parameter2,"xMax"]= clinicalPKParameterData[clinicalPKParameterData[,"parameter"]==parameter2,"max"]
	
	parameter3s=c("AUC2_5", "AUC5", "AUC10", "AUC15", "AUC20")
	for (parameter3 in parameter3s){
		#assuming Table 2 provides SD
#		clinicalPKParameterData[clinicalPKParameterData[,"parameter"]==parameter3,"xMin"]= clinicalPKParameterData[clinicalPKParameterData[,"parameter"]==parameter3,"mean_median"]-clinicalPKParameterData[clinicalPKParameterData[,"parameter"]==parameter3,"sd"]
#		clinicalPKParameterData[clinicalPKParameterData[,"parameter"]==parameter3,"xMax"]= clinicalPKParameterData[clinicalPKParameterData[,"parameter"]==parameter3,"mean_median"]+clinicalPKParameterData[clinicalPKParameterData[,"parameter"]==parameter3,"sd"]
		
		#assuming Table 2 provides CV (not %CV)
		clinicalPKParameterData[clinicalPKParameterData[,"parameter"]==parameter3,"xMin"]= clinicalPKParameterData[clinicalPKParameterData[,"parameter"]==parameter3,"mean_median"]*(1-(clinicalPKParameterData[clinicalPKParameterData[,"parameter"]==parameter3,"sd"]))
		clinicalPKParameterData[clinicalPKParameterData[,"parameter"]==parameter3,"xMax"]= clinicalPKParameterData[clinicalPKParameterData[,"parameter"]==parameter3,"mean_median"]*(1+(clinicalPKParameterData[clinicalPKParameterData[,"parameter"]==parameter3,"sd"]))
	} 
	#==============================================================================================================================================================================================================================clinical PK parameter data to match to
	
	#read PK parameter data for all subjects and calculate mean, CV%, median, min, max=======================
	print("STARTING PK PARAMETER PROCESSING================================================================")
	allSubjectPKParametersData=c()
	getAntagonistPKParametersData <- function(inputFolder, subjectIndex){
		print(subjectIndex)
		if(file.exists(sprintf("%s/Subject%s.csv", inputFolder, subjectIndex))){
			data.frame(read.csv(sprintf("%s/Subject%s.csv", inputFolder, subjectIndex)))
		}
	}
	#using data table's rbindlist all at once
	getAllSubjectPKParametersData <- function(inputFolder, n){
		return(data.frame(rbindlist(lapply(1:n, function(x) getAntagonistPKParametersData(inputFolder, x)))))
	}
	allSubjectPKParametersData=getAllSubjectPKParametersData(inputFolderPKParameters, inputs$numberOfSubject)
	allSubjectPKParametersData=allSubjectPKParametersData[c(2, 3, 4, 5, 6, 7, 8)]
	
	mysummary <- function(x){
		if (is.numeric(x)){
			c(mean(x), sd(x), mean(x)-sd(x), mean(x)+sd(x), (sd(x)/mean(x))*100, median(x), min(x), max(x))
		}else{ print("pass")}
	}
	allSubjectPKParametersData=lapply(allSubjectPKParametersData, mysummary) %>% bind_rows()
	allSubjectPKParametersData=as.data.frame(allSubjectPKParametersData)
	rownames(allSubjectPKParametersData)=c("mean", "sd", "xMin", "xMax", "CV", "median", "min", "max")
	print("FINISHED PK PARAMETER PROCESSING================================================================")
	#=======================read PK parameter data for all subjects and calculate mean, CV%, median, min, max
	
	#combine PK parameter clinical data and simulated data for plotting=============================================================================================================================
	parameters=c("CMax", "TMax", "AUC2_5", "AUC5", "AUC10", "AUC15", "AUC20")
	combinedPKParameterDataAll=c()
	for (parameter in parameters){
		if (parameter=="Tmax"){
			combinedPKParameterData=cbind(clinicalPKParameterData[clinicalPKParameterData$parameter==parameter, c(1, 2, 7, 8)], t(allSubjectPKParametersData[c("median", "min", "max"), parameter]))
		}else {
			combinedPKParameterData=cbind(clinicalPKParameterData[clinicalPKParameterData$parameter==parameter, c(1, 2, 7, 8)], t(allSubjectPKParametersData[c("mean", "xMin", "xMax"), parameter]))
		}
		combinedPKParameterDataAll=rbind(combinedPKParameterDataAll, combinedPKParameterData)
	}
	colnames(combinedPKParameterDataAll)=c("parameter" , "midData", "lowData", "highData", "midSimulated", "lowSimulated", "highSimulated")
	write.csv(combinedPKParameterDataAll, sprintf("%s/PKParameters_%s.csv", outputFolder, inputs$numberOfSubject))
	#=============================================================================================================================combine PK parameter clinical data and simulated data for plotting
	
	#plotting all subject ribbon with median line and Krieter et al. mean points====================================================================
	plot<-	ggplot()
	plot<-	plot	+	geom_point(data=subset(combinedPKParameterDataAll, parameter %in% c("CMax")), aes(y= parameter, x= midData), color="blue", fill="blue", shape=15, size=4)
	plot<-	plot	+	geom_errorbar(data=subset(combinedPKParameterDataAll, parameter %in% c("CMax")), aes(y= parameter, xmin= lowData, xmax= highData), color="blue", size=2)
	plot<-	plot	+	geom_point(data=subset(combinedPKParameterDataAll, parameter %in% c("CMax")), aes(y= parameter, x= midSimulated), color="red", fill="red", shape=16, size=4)
	plot<-	plot	+	geom_errorbar(data=subset(combinedPKParameterDataAll, parameter %in% c("CMax")), aes(y= parameter, xmin= lowSimulated, xmax= highSimulated), color="red", size=1)
	plot<-	plot	+	theme_bw()
	plot<-	plot	+	theme(
			axis.text	=	element_text(size= 16),
			axis.title	=	element_text(size= 14, face="bold"),
			plot.title	=	element_text(size = 20,	face = "bold"))
	plot<-	plot	+	ylab(paste0("Parameter"))
	plot<-	plot	+	xlab(paste0("Cmax, ng/ml"))
	plot<-	plot	+	ggtitle(sprintf("%s", antagonistDoseLabel))
	ggsave(sprintf("%s/CMax_%s.jpg", outputFolder, inputs$numberOfSubject), plot, height=4, width=6)
	
	plot<-	ggplot()
	plot<-	plot	+	geom_point(data=subset(combinedPKParameterDataAll, parameter %in% c("TMax")), aes(y= parameter, x= midData), color="blue", fill="blue", shape=15, size=4)
	plot<-	plot	+	geom_errorbar(data=subset(combinedPKParameterDataAll, parameter %in% c("TMax")), aes(y= parameter, xmin= lowData, xmax= highData), color="blue", size=2)
	plot<-	plot	+	geom_point(data=subset(combinedPKParameterDataAll, parameter %in% c("TMax")), aes(y= parameter, x= midSimulated), color="red", fill="red", shape=16, size=4)
	plot<-	plot	+	geom_errorbar(data=subset(combinedPKParameterDataAll, parameter %in% c("TMax")), aes(y= parameter, xmin= lowSimulated, xmax= highSimulated), color="red", size=1)
	plot<-	plot	+	theme_bw()
	plot<-	plot	+	theme(
			axis.text	=	element_text(size= 16),
			axis.title	=	element_text(size= 14, face="bold"),
			plot.title	=	element_text(size = 20,	face = "bold"))
	plot<-	plot	+	ylab(paste0("Parameter"))
	plot<-	plot	+	xlab(paste0("Tmax, hours"))
	plot<-	plot	+	ggtitle(sprintf("%s", antagonistDoseLabel))
	ggsave(sprintf("%s/TMax_%s.jpg", outputFolder, inputs$numberOfSubject), plot, height=4, width=6)
	
	plot<-	ggplot()
	plot<-	plot	+	geom_point(data=subset(combinedPKParameterDataAll, parameter %in% c("AUC2_5", "AUC5", "AUC10", "AUC15", "AUC20")), aes(y= parameter, x= midData), color="blue", fill="blue", shape=15, size=4)
	plot<-	plot	+	geom_errorbar(data=subset(combinedPKParameterDataAll, parameter %in% c("AUC2_5", "AUC5", "AUC10", "AUC15", "AUC20")), aes(y= parameter, xmin= lowData, xmax= highData), color="blue", size=2)
	plot<-	plot	+	geom_point(data=subset(combinedPKParameterDataAll, parameter %in% c("AUC2_5", "AUC5", "AUC10", "AUC15", "AUC20")), aes(y= parameter, x= midSimulated), color="red", fill="red", shape=16, size=4)
	plot<-	plot	+	geom_errorbar(data=subset(combinedPKParameterDataAll, parameter %in% c("AUC2_5", "AUC5", "AUC10", "AUC15", "AUC20")), aes(y= parameter, xmin= lowSimulated, xmax= highSimulated), color="red", size=1)
	plot<-	plot	+	theme_bw()
	plot<-	plot	+	theme(
			axis.text	=	element_text(size= 16),
			axis.title	=	element_text(size= 14, face="bold"),
			plot.title	=	element_text(size = 20,	face = "bold"))
	plot<-	plot	+	ylab(paste0("Parameter"))
	plot<-	plot	+	xlab(paste0("AUCs, ng.h/ml"))
	plot<-	plot	+	ggtitle(sprintf("%s", antagonistDoseLabel))
	ggsave(sprintf("%s/AUCs_%s.jpg", outputFolder, inputs$numberOfSubject), plot, height=4, width=6)
	#====================================================================plotting all subject ribbon with median line and Krieter et al. mean points
}