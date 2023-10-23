#last edited by: Anik Chaturbedi
#on: 2024-11-05

#load necessary libraries & scripts====
library(ggplot2)
library(grid)
library(dplyr)
library(optparse)

#get inputs========================================================================================================================================================================================================================================================================
parser<-OptionParser()
parser<-add_option(parser, c("-a", "--opioid"), default ="fentanyl",type="character",help="opioid used to induce respiratory depression (options: fentanyl, carfentanil, sufentanil)")
parser<-add_option(parser, c("-b", "--opioidDose"), default ="2.965",type="numeric",help="opioid concentration (in mg) (options: 1.625, 2.965, 0.012, 0.02187)")
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
parser<-add_option(parser, c("-o", "--inputDate"), default ="",type="character",help="productInputDate1")
parser<-add_option(parser, c("-p", "--opioidInfusionRate"), default ="100",type="numeric",help="opioid infusion rate (ug/hr)")
parser<-add_option(parser, c("-q", "--opioidAbsorptionRate"), default ="1",type="numeric",help="opioid absorption rate (-)")
parser<-add_option(parser, c("-t", "--fractionOfBaselineVentilationForAntagonistAdministration"), default ="0.4",type="numeric",help="fractionOfBaselineVentilationForAntagonistAdministration (-)")
inputs<-parse_args(parser)

simulationTime<- 1*60*60 #real time of simulation (in seconds)
if(inputs$inputDate==""){inputs$inputDate=Sys.Date()}
#get case names and dates to plot====
productsToPlot=c("IN3nalmefeneA", "IN3nalmefeneB", "IN3nalmefeneC", "IN4naloxone")
productInputDatesToPlot=rep(inputs$inputDate, length(productsToPlot)) #Sys.Date()
plotCases="all 4 cases" #"fentanyl only" #"carfentanil only" #"all 4 cases"

if (plotCases=="fentanyl only"){
	opioidsToPlot=c("fentanyl", "fentanyl")
	opioidDosesToPlot=c(1.625, 2.965)
	opioidCasesToPlot=c("fentanyl_1.625", "fentanyl_2.965")
	chosenColorPalette=c("#800080", "#00AFBB") 
	chosenShapePalette=c(15, 16)
}else if (plotCases=="carfentanil only"){
	opioidsToPlot=c("carfentanil", "carfentanil")
	opioidDosesToPlot=c(0.012, 0.022)
	opioidCasesToPlot=c("carfentanil_0.012", "carfentanil_0.022")
	chosenColorPalette=c("#000080", "#ff1493") 
	chosenShapePalette=c(17, 18)
}else if (plotCases=="all 4 cases"){
	opioidsToPlot=c("fentanyl", "fentanyl", "carfentanil", "carfentanil")
	opioidDosesToPlot=c(1.625, 2.965, 0.012, 0.022)
	opioidCasesToPlot=c("fentanyl_1.625", "fentanyl_2.965", "carfentanil_0.012", "carfentanil_0.022")
	chosenColorPalette=c("#800080", "#00AFBB", "#000080", "#ff1493") 
	chosenShapePalette=c(15, 16, 17, 18)
}
allOutputFolders=Sys.glob("output/*")
allOutputCases=gsub("output/", "", allOutputFolders)
allOutputCases <- allOutputCases[which(allOutputCases %in% productsToPlot)] #remove forestPlots
outputFolder=sprintf("output/forestPlots/%s", Sys.Date())
system(paste0("mkdir -p ",outputFolder))
if (inputs$antagonistAdministrationTimeCase==""){
	delayToPlot=60
}

allData=c()
for (productToPlot in productsToPlot) {	
	for (opioidCaseToPlot in opioidCasesToPlot){ #not needed if all opioid doses for each opioid are being plotted
		opioidToPlot=opioidsToPlot[match(opioidCaseToPlot, opioidCasesToPlot)]
		opioidDoseToPlot=opioidDosesToPlot[match(opioidCaseToPlot, opioidCasesToPlot)]
		
		#get all filepaths for this product====
		inputDate=productInputDatesToPlot[match(productToPlot, productsToPlot)]
		modelOutputFolder=sprintf("%s_%s_%s_%s_%s,%smins", 
				opioidToPlot, 
				opioidDoseToPlot*1e6, 
				inputs$fractionOfBaselineVentilationForAntagonistAdministration,	
				inputs$subjectType, 
				inputs$subjectAge, 
				simulationTime/60)
		
		filePath<-Sys.glob(sprintf("output/%s/populationOutput%s%s/%s/CA/IQR/numberOfSampling%s_sampledPopulationSize%s.csv",					
						productToPlot, 
						inputs$antagonistAdministrationTimeCase, 
						inputDate, 
						modelOutputFolder, 														
						inputs$numberOfSampling, 
						inputs$numberOfSubjectsSelected))
		
		data=read.csv(filePath)[,c("antagonistDosesLabels","Percentage25","Percentage50","Percentage75")]
		
		data=rbind(
				cbind(antagonistDosesLabels="No naloxone",	data[1,2:4],	antagonistRouteAndDose="No naloxone", delay="No naloxone",					opioidCaseToPlot=sprintf("%s_%s", opioidToPlot, opioidDoseToPlot), antagonistDoseIndex=1), #no antagonist row
				cbind(										data[2,1:4],	antagonistRouteAndDose=productToPlot, delay=sprintf("%s", delayToPlot/60),	opioidCaseToPlot=sprintf("%s_%s", opioidToPlot, opioidDoseToPlot), antagonistDoseIndex=2) #1 dose row
		)	
		
		#bind all data====
		allData=rbind(allData, data)
	}
}

antagonistRouteAndDoses=unique(allData$antagonistRouteAndDose)
allData$antagonistRouteAndDose <- factor(
		allData$antagonistRouteAndDose, 
		ordered=TRUE, 
		levels = c(
				"No naloxone", 
				antagonistRouteAndDoses[antagonistRouteAndDoses!="No naloxone"]))

opioidCaseToPlot=unique(allData$opioidCaseToPlot)
print(allData$opioidCaseToPlot)
allData$opioidCaseToPlot <- factor(
		allData$opioidCaseToPlot, 
		ordered=TRUE, 
		levels = c("fentanyl_1.625", "fentanyl_2.965", "carfentanil_0.012", "carfentanil_0.022"))

allData$antagonistDosesLabels <- factor(
		allData$antagonistDosesLabels, 
		ordered=TRUE, 
		levels = c(
				"1 dose", "No naloxone"))
p= ggplot(data=allData, aes(y=antagonistDosesLabels, x=Percentage50, xmin=Percentage25, xmax=Percentage75)) 
p= p + facet_grid(rows = vars(antagonistRouteAndDose), scales = "free", space = "free") 
p= p + geom_point(aes(shape= opioidCaseToPlot, col=opioidCaseToPlot)) 
p= p + geom_errorbarh(aes(col=opioidCaseToPlot), height=0.2) 
p= p + labs(x='Percent of virtual patients experiencing cardiac arrest', y = 'Naloxone dosing') 
p= p + scale_x_continuous(limits=c(0, 100), breaks=seq(0, 100, 10)) 
p= p + scale_colour_manual(values=chosenColorPalette) 
p= p + scale_shape_manual(values=chosenShapePalette) 
p= p + theme_bw()
p= p + theme(
		legend.direction = "vertical",
		legend.position = "none",    
		legend.background=element_rect(fill = alpha("white", 0)),  
		panel.background = element_rect(fill = NA, color = "black"),
		panel.border = element_blank(),
		axis.line = element_line(colour = "black"),
		axis.title.x=element_blank(),
		axis.title.y=element_blank(),
		axis.text.x = element_text(size=10,  family="Calibri", color="black"),
		axis.text.y = element_blank(),
		axis.ticks = element_line(color = "black"),
		strip.text.y = element_blank(),
		text=element_text(size=10,  family="Calibri"))
ggsave(sprintf("%s/%s.jpg", outputFolder, plotCases), p, 
		height = 2, width = 2.5) #use for manuscript figure with single dose (w/o labels)     