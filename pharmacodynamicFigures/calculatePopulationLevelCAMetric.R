#last edited by: Anik Chaturbedi
#on: 2023-05-16
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
parser<-add_option(parser, c("-j", "--antagonistAdministrationTimeCase"), default ="",type="character",help="which antagonist administration start time case to be used (options: _30_, , _180_, _300_, _600_, SimultaneousOpioidAndAntagonist, NoAntagonistDelay, DelayedOpioid)")
parser<-add_option(parser, c("-k", "--dispersionMetric"), default ="IQR",type="character",help="what dispersion metric to use after sampling (options: IQR, 90% CI, 95% CI)")
parser<-add_option(parser, c("-l", "--numberOfSampling"), default ="2500",type="numeric",help="numberOfSampling")
parser<-add_option(parser, c("-m", "--numberOfSubjectsSelected"), default ="200",type="numeric",help="numberOfSubjectsSelected")
parser<-add_option(parser, c("-n", "--subjectAge"), default ="adult",type="character",help="age of subject (options: adult, 10YearOld)")
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
	}else if(inputs$subjectAge=="10YearOld"){
		antagonistDosesLabels<-c("No dose", "1 scaled dose", "1 dose")
		selectedDosesToPlot<-antagonistDosesLabels
	}
	xLabel<-"Antagonist dosing"
	
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
figureHeight<-6
figureWidth<-7

selectedDoseIndices<-which(antagonistDosesLabels %in% selectedDosesToPlot)
todaysDate=Sys.Date() #creates output folder based on this
inputFolder=paste0("output/",inputs$antagonistAdministrationRouteAndDose,"/","individualSubjects",inputs$antagonistAdministrationTimeCase, todaysDate) #"2023-03-23" #todaysDate
modelOutputFolder=sprintf("%s_%s_%s_%s", inputs$opioid, inputs$opioidDose, inputs$subjectType, inputs$subjectAge)
if(inputs$dispersionMetric=="IQR"){
	outputFolder=paste0("output/",inputs$antagonistAdministrationRouteAndDose,"/","populationOutput",inputs$antagonistAdministrationTimeCase,todaysDate, "/", modelOutputFolder, "/CA/IQR")
}else if (inputs$dispersionMetric=="90% CI"){
	outputFolder=paste0("output/",inputs$antagonistAdministrationRouteAndDose,"/","populationOutput",inputs$antagonistAdministrationTimeCase,todaysDate, "/", modelOutputFolder, "/CA/90CI")
}else if (inputs$dispersionMetric=="95% CI"){
	outputFolder=paste0("output/",inputs$antagonistAdministrationRouteAndDose,"/","populationOutput",inputs$antagonistAdministrationTimeCase,todaysDate, "/", modelOutputFolder, "/CA/95CI")
}
system(paste0("mkdir -p ",outputFolder))
system(paste0("mkdir -p ",paste0(outputFolder,"/figures")))	
system(paste0("mkdir -p ",paste0(outputFolder,"/tables")))	
#========================================================================================================================================
#calculate CA percentatge of all sample populations========================================================================================
CAPercentageAllSamples=c() #initialization
for (samplingIndex in 1:inputs$numberOfSampling){
	#get CA occurrence information for all subjects in this sample population=============================================
	CAOcurrenceAllSubjects=c();	
	selectedSubjectIndices<-sample(c(1:2000), inputs$numberOfSubjectsSelected, replace=T) #change replace to F to get all population case w/ -n 1 and -s 2000 
	for (selectedSubjectIndex in 1:inputs$numberOfSubjectsSelected) {
		selectedSubjectIndex<-selectedSubjectIndices[selectedSubjectIndex]		
		if (file.exists(sprintf("%s/%s/Subject%s.csv",inputFolder,modelOutputFolder,selectedSubjectIndex))) { #if model ran
			d0=read.csv(sprintf("%s/%s/Subject%s.csv",inputFolder,modelOutputFolder,selectedSubjectIndex),stringsAsFactors =F) #read model output
			if (ncol(d0)==14) {#not sure why this is here???????????????????????
				CAOcurrenceAllSubjects=cbind(CAOcurrenceAllSubjects,d0[,2]) #[numberOfantagonistDoses,numberOfSubjectsSelected] #column-bind CA occurrence information for all antagonist dosing of subjects
			}
		}
	}
	#=====================================================================================================================
	#calculate CA percentage for all subjects in this sample population and store===============
	CAPercentageAllSamples=cbind(CAPercentageAllSamples,
			(1-(rowSums(CAOcurrenceAllSubjects=='no', na.rm=TRUE)/dim(CAOcurrenceAllSubjects)[2]))*100) #[numberOfantagonistDoses,numberOfSampling] #not sure why this is necessary???????????????????????		
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
write.csv(CAPercentages,sprintf("%s/tables/%s_%s_%s_numberOfSampling%s_sampledPopulationSize%s.csv",outputFolder,inputs$opioid,inputs$opioidDose,inputs$subjectType,inputs$numberOfSampling,inputs$numberOfSubjectsSelected)) #write the CA% data
#=======================================================================================================================================================
#ploting CA% barplots (newer)===============================================================================================================
CAPercentages<-CAPercentages[selectedDoseIndices,]
p<-ggplot(data = CAPercentages, aes(antagonistDosesLabels, Percentage50))
p<-p+ geom_bar(aes(x=antagonistDosesLabels, y=Percentage50), stat="identity", fill="black", alpha=0.8)
if(inputs$dispersionMetric=="IQR"){
	p<-p+ geom_text(aes(label = sprintf("%s (%s-%s)",round(Percentage50),round(Percentage25),round(Percentage75)), y = Percentage75+1),
			position = position_dodge(0.9),
			vjust = 0,
			size=4)
	p<-p+ geom_errorbar(aes(x=antagonistDosesLabels, ymin=Percentage25, ymax=Percentage75), width=0.4, colour="red", alpha=0.9, size=1.3)
}else if (inputs$dispersionMetric=="90% CI"){
	p<-p+ geom_text(aes(label = sprintf("%s (%s-%s)",round(Percentage50),round(Percentage5),round(Percentage95)), y = Percentage95+1),
			position = position_dodge(0.9),
			vjust = 0,
			size=4)
	p<-p+ geom_errorbar(aes(x=antagonistDosesLabels, ymin=Percentage5, ymax=Percentage95), width=0.4, colour="red", alpha=0.9, size=1.3)
}else if (inputs$dispersionMetric=="95% CI"){
	p<-p+ geom_text(aes(label = sprintf("%s (%s-%s)",round(Percentage50),round(Percentage2.5),round(Percentage97.5)), y = Percentage97.5+1),
			position = position_dodge(0.9),
			vjust = 0,
			size=4)
	p<-p+ geom_errorbar(aes(x=antagonistDosesLabels, ymin=Percentage2.5, ymax=Percentage97.5), width=0.4, colour="red", alpha=0.9, size=1.3)
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
ggsave(sprintf("%s/figures/%s_%s_%s_numberOfSampling%s_sampledPopulationSize%s.svg",outputFolder,inputs$opioid,inputs$opioidDose,inputs$subjectType,inputs$numberOfSampling,inputs$numberOfSubjectsSelected), p,height = figureHeight , width = figureWidth)
#===========================================================================================================================================
