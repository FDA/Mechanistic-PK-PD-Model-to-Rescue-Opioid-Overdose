#last edited by: Anik Chaturbedi
#on: 2023-05-19

#load necessary libraries & scripts====
library(ggplot2)
library(optparse)

#get inputs========================================================================================================================================================================================================================================================================
parser<-OptionParser()
parser<-add_option(parser, c("-a", "--opioid"), default ="fentanyl",type="character",help="opioid used to induce respiratory depression (options: fentanyl, carfentanil)")
parser<-add_option(parser, c("-b", "--opioidDoseToPlot"), default ="2.965",type="numeric",help="opioid concentration (in mg) (options: 1.625, 2.965, 0.012, 0.02187)")
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
parser<-add_option(parser, c("-n", "--productInputDate1"), default ="2022-09-15",type="character",help="productInputDate1")
parser<-add_option(parser, c("-o", "--subjectAge"), default ="adult",type="character",help="age of subject (options: adult)")
inputs<-parse_args(parser)

#get case names and dates to plot====
productsToPlot=c(inputs$antagonistAdministrationRouteAndDose,"IVBoyer")
if (inputs$opioid=="fentanyl"){
	opioidDosesToPlot=c(1.625, 2.965)
	chosenPalette=c("#800080", "#00AFBB") 
}else if (inputs$opioid=="carfentanil"){
	opioidDosesToPlot=c(0.012, 0.02187)
	chosenPalette=c("#000080", "#ff1493") 
}
delaysToPlot=c(60)

#get all product namses for which data is avaiable in "/scratch/anik.chaturbedi/opioid/INRepeatDosingPaper/output/"====
allOutputFolders=Sys.glob("output/*")
allOutputCases=gsub("output/", "", allOutputFolders)
allOutputCases <- allOutputCases[allOutputCases != "forestPlots"] #remove forestPlots
outputFolder="output/forestPlots"
system(paste0("mkdir -p ",outputFolder))


allData=c()
for (productToPlot in productsToPlot) {	
	for (opioidDoseToPlot in opioidDosesToPlot){ #not needed if all opioid doses for each opioid are being plotted
		for (delayToPlot in delaysToPlot){ #not needed if all delays for each opioid dose case are being plotted
			#get all filepaths for this product====
			
			#read data====
			if (delayToPlot==60){
				delayPhrase=""
			}else {
				delayPhrase=paste0("_",delayToPlot)
			}
			modelOutputFolder=sprintf("%s_%s_%s_%s", inputs$opioid, opioidDoseToPlot, inputs$subjectType, inputs$subjectAge)
			
			filePath<-Sys.glob(
					sprintf("output/%s/populationOutput%s/%s/CA/IQR/tables/%s_%s_%s_numberOfSampling%s_sampledPopulationSize%s.csv", 
							productToPlot, delayPhrase, modelOutputFolder, inputs$opioid, opioidDoseToPlot, inputs$subjectType, inputs$numberOfSampling, inputs$numberOfSubjectsSelected))
			data=read.csv(filePath)[,c("antagonistDosesLabels","Percentage25","Percentage50","Percentage75")]
			
			data=rbind(cbind(antagonistDosesLabels="No naloxone",
							data[1,2:4], 
							antagonistRouteAndDose="No naloxone",
							delay="No naloxone", 
							opioid=sprintf("%s", inputs$opioid), 
							opioidDoseToPlot=sprintf("%s", opioidDoseToPlot), 
							antagonistDoseIndex=1),
					
					cbind(data[-1,1:4], 
#							antagonistRouteAndDose=as.factor(productToPlot),
							antagonistRouteAndDose=productToPlot,
							delay=sprintf("%s", delayToPlot/60), 
							opioid=sprintf("%s", inputs$opioid), 
							opioidDoseToPlot=sprintf("%s", opioidDoseToPlot), 
							antagonistDoseIndex=seq(2,nrow(data))))	
			
			#remove rows corresponsing to doses that are NOT to be plotted====
			if(productToPlot=="IN4"){
				data=data[data$antagonistDosesLabels!=c("3 doses standard"),]
			}else if(productToPlot=="IVBoyer"){
				data=data[data$antagonistDosesLabels!=c("0"),]
				data=data[data$antagonistDosesLabels!=c("0.04+0.5+2+4+10"),]
				data=data[data$antagonistDosesLabels!=c("0.04+0.5+2+4+10+15"),]
			}
			
			#bind all data====
			allData=rbind(allData, data)
		}
	} 
}

#change dosing labels====
allData$antagonistDosesLabels[allData$antagonistRouteAndDose=="IVBoyer"]=c(
		"0.04 mg",
		"0.04 + 0.5 mg",
		"0.04 + 0.5 + 2 mg",
		"0.04 + 0.5 + 2 + 4 mg"
#		,"0.04, 0.5, 2, 4 & 10 mg (gap of 2.5 mins)"
#		,"0.04, 0.5, 2, 4, 10 & 15 mg (gap of 2.5 mins)"
)

#change the product names====
allData$antagonistRouteAndDose[allData$antagonistRouteAndDose=="IN4"]="Intranasal 4 mg"
allData$antagonistRouteAndDose[allData$antagonistRouteAndDose=="IVBoyer"]="Intravenous repeat dosing"
allData$antagonistRouteAndDose[allData$antagonistRouteAndDose=="IVMultipleDoses"]="Intravenous 0.04 mg"

antagonistRouteAndDoses=unique(allData$antagonistRouteAndDose)
allData$antagonistRouteAndDose <- factor(allData$antagonistRouteAndDose, ordered=TRUE, levels = c(
				"No naloxone", 
				antagonistRouteAndDoses[antagonistRouteAndDoses!="No naloxone" & antagonistRouteAndDoses!="Intravenous repeat dosing"],
				"Intravenous repeat dosing"))

if(inputs$antagonistAdministrationRouteAndDose=="IN4"){
	allData$antagonistDosesLabels <- factor(allData$antagonistDosesLabels, ordered=TRUE, levels = c(
					"0.04 + 0.5 + 2 + 4 mg", "0.04 + 0.5 + 2 mg", "0.04 + 0.5 mg", "0.04 mg", 
					"4 doses rapid", "2 doses rapid", "4 doses standard", "2 doses standard", "1 dose", 
					"No naloxone"))
}

p=ggplot(data=allData, aes(
						y=antagonistDosesLabels, 
						x=Percentage50, xmin=Percentage25, xmax=Percentage75)) +
		facet_grid(rows = vars(antagonistRouteAndDose), scales = "free", space = "free") +
		geom_point(aes(shape= opioidDoseToPlot,col=opioidDoseToPlot)) + 
		geom_errorbarh(aes(col=opioidDoseToPlot),height=0.2) +
		labs(x='Percent of virtual patients experiencing cardiac arrest', y = 'Naloxone dosing') +
		scale_x_continuous(limits=c(0, 100), breaks=seq(0, 100, 10)) +
		scale_colour_manual(values=chosenPalette)+
		theme_bw()
if (inputs$antagonistAdministrationRouteAndDose=="IN4"){
	p= p + theme(legend.direction = "vertical",
			legend.position = "none",    
			legend.background=element_rect(fill = alpha("white", 0)),  
			panel.background = element_rect(fill = NA, color = "black"),
			panel.border = element_blank(),
			axis.line = element_line(colour = "black"),
			axis.title.x=element_text(size=10,  family="Calibri", color="black", face="bold"),
			axis.title.y=element_blank(),
			axis.text.x = element_text(size=10,  family="Calibri", color="black"),
			axis.text.y = element_blank(),
			axis.ticks = element_line(color = "black"),
			strip.text.y = element_blank(),
			text=element_text(size=10,  family="Calibri"))
	ggsave(sprintf("%s/%s_%s_Dose.svg", outputFolder, inputs$opioid, inputs$antagonistAdministrationRouteAndDose), 
			p, height = 3, width = 5)
}else {
	if (inputs$opioid=="fentanyl"){
		p= p + theme(legend.direction = "vertical",
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
		ggsave(sprintf("%s/%s_%s_Dose.svg", outputFolder, inputs$opioid, inputs$antagonistAdministrationRouteAndDose), 
				p, height = 2.5, width = 2.5) #p, height = 3, width = 5)
	}else if (inputs$opioid=="carfentanil"){
		p= p + theme(legend.direction = "vertical",
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
		ggsave(sprintf("%s/%s_%s_Dose.svg", outputFolder, inputs$opioid, inputs$antagonistAdministrationRouteAndDose), 
				p, height = 2.5, width = 2.5)
	}
}