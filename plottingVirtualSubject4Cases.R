#last edited by: Anik Chaturbedi
#on: 2024-11-05
rm(list = ls()) #removes all objects from the current workspace

#load required package(s)
library(deSolve)
library(optparse)
library(ggplot2)
library(gridExtra)
library(grid)
library(scales)
#========================

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
parser<-add_option(parser, c("-n", "--simulateRenarcotization"), default ="no", type="character", help="as the name suggests (options: no, yes)")
parser<-add_option(parser, c("-o", "--useConditionSetting"), default ="none",type="character",help="seed number for sampling")
parser<-add_option(parser, c("-p", "--opioidInfusionRate"), default ="100",type="numeric",help="opioid infusion rate (ug/hr)")
parser<-add_option(parser, c("-q", "--opioidAbsorptionRate"), default ="1",type="numeric",help="opioid absorption rate (-)")
parser<-add_option(parser, c("-r", "--inputDate"), default ="",type="character",help="productInputDate1")
parser<-add_option(parser, c("-s", "--variableToPlot"), default ="MV",type="character",help="productInputDate1")
parser<-add_option(parser, c("-t", "--fractionOfBaselineVentilationForAntagonistAdministration"), default ="0.4",type="numeric",help="fractionOfBaselineVentilationForAntagonistAdministration (-)")
inputs<-parse_args(parser)

simulationTime= 10 #(minutes)
timeToPlot= 15 #(minutes)
antagonistAdministrationRoutesAndDoses= c("IN3nalmefeneA", "IN3nalmefeneB", "IN3nalmefeneC", "IN4naloxone")
antagonistAdministrationRoutesAndDosesLabels= c("IN nalmefene 3 mg A", "IN nalmefene 3 mg B", "IN nalmefene 3 mg C", "IN naloxone 4 mg")
inputs$opioidDose<-inputs$opioidDose*1e6 #ng
if(inputs$inputDate==""){inputs$inputDate=Sys.Date()}

outputCase0=read.csv(sprintf("output/%s/optimalOutput%s/%s_%s_%s_%s_%s,%smins/%sOpioidOnly.csv",	antagonistAdministrationRoutesAndDoses[1], inputs$inputDate, inputs$opioid, inputs$opioidDose, inputs$fractionOfBaselineVentilationForAntagonistAdministration, inputs$subjectType, inputs$subjectAge, simulationTime, inputs$variableToPlot))
outputCase1=read.csv(sprintf("output/%s/optimalOutput%s/%s_%s_%s_%s_%s,%smins/%s.csv",				antagonistAdministrationRoutesAndDoses[1], inputs$inputDate, inputs$opioid, inputs$opioidDose, inputs$fractionOfBaselineVentilationForAntagonistAdministration, inputs$subjectType, inputs$subjectAge, simulationTime, inputs$variableToPlot))
outputCase2=read.csv(sprintf("output/%s/optimalOutput%s/%s_%s_%s_%s_%s,%smins/%s.csv",				antagonistAdministrationRoutesAndDoses[2], inputs$inputDate, inputs$opioid, inputs$opioidDose, inputs$fractionOfBaselineVentilationForAntagonistAdministration, inputs$subjectType, inputs$subjectAge, simulationTime, inputs$variableToPlot))
outputCase3=read.csv(sprintf("output/%s/optimalOutput%s/%s_%s_%s_%s_%s,%smins/%s.csv",		 		antagonistAdministrationRoutesAndDoses[3], inputs$inputDate, inputs$opioid, inputs$opioidDose, inputs$fractionOfBaselineVentilationForAntagonistAdministration, inputs$subjectType, inputs$subjectAge, simulationTime, inputs$variableToPlot))
outputCase4=read.csv(sprintf("output/%s/optimalOutput%s/%s_%s_%s_%s_%s,%smins/%s.csv",		 		antagonistAdministrationRoutesAndDoses[4], inputs$inputDate, inputs$opioid, inputs$opioidDose, inputs$fractionOfBaselineVentilationForAntagonistAdministration, inputs$subjectType, inputs$subjectAge, simulationTime, inputs$variableToPlot))

gg_color_hue <- function(n) {
	hues = seq(15, 375, length = n + 1)
	hcl(h = hues, l = 65, c = 100)[1:n]
}
colorPalette = gg_color_hue(length(antagonistAdministrationRoutesAndDoses))

plot <- ggplot()
plot <- plot+ geom_line(aes(x=outputCase0[,2]/60, y=outputCase0[,3], color="control"),	size=1) 
plot <- plot+ geom_line(aes(x=outputCase1[,2]/60, y=outputCase1[,3], color="a"),			size=1) 
plot <- plot+ geom_line(aes(x=outputCase2[,2]/60, y=outputCase2[,3], color="b"),			size=1)
plot <- plot+ geom_line(aes(x=outputCase3[,2]/60, y=outputCase3[,3], color="c"),			size=1)
plot <- plot+ geom_line(aes(x=outputCase4[,2]/60, y=outputCase4[,3], color="d"),			size=1)
plot <- plot+ scale_color_manual(
		name = "Antagonist dosing", 
		values = c(control="black", a=colorPalette[1], b=colorPalette[2], c=colorPalette[3], d=colorPalette[4]),
		labels = c("Opioid only", antagonistAdministrationRoutesAndDosesLabels))
plot <- plot+ xlim(0, timeToPlot)

if (inputs$variableToPlot=="MV"){
	plot <- plot+ ylim(0, 8)
}else if (inputs$variableToPlot=="AOS"){
	plot <- plot+ ylim(0, 100)
}else if (inputs$variableToPlot=="BOPP"){
	plot <- plot+ ylim(0, 50)
}else if (inputs$variableToPlot=="CO"){
	plot <- plot+ ylim(0, 10)
}

plot <- plot+ theme_bw()
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
for (antagonistAdministrationRouteAndDose in antagonistAdministrationRoutesAndDoses){
	outputFolder=sprintf("output/%s/optimalOutput%s/%s_%s_%s_%s_%s,%smins", antagonistAdministrationRouteAndDose, Sys.Date(), inputs$opioid, inputs$opioidDose, inputs$fractionOfBaselineVentilationForAntagonistAdministration, inputs$subjectType, inputs$subjectAge, simulationTime)
	system(paste0("mkdir -p ", outputFolder))
	ggsave(
			sprintf("%s/virtualSubjects4_%s.jpg", outputFolder, inputs$variableToPlot), 
			plot, 
			height = 2.5, width = 2.5)
}