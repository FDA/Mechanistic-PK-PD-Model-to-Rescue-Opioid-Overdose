#last edited by: Anik Chaturbedi
#on: 2024-11-08

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
parser<-add_option(parser, c("-d", "--antagonistAdministrationRouteAndDose"), default ="IN4", type="character", help="antagonist administration route and dose in mg ")
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
parser<-add_option(parser, c("-s", "--opioidDosingRoute"), default ="transdermal",type="character",help="what opioid dosing route to use (transdermal, transmucosal)")
parser<-add_option(parser, c("-t", "--fractionOfBaselineVentilationForAntagonistAdministration"), default ="0.4",type="numeric",help="fractionOfBaselineVentilationForAntagonistAdministration (-)")
inputs<-parse_args(parser)

clinicalData= read.csv("data/transmucosalfentanylPK.csv")
simulationTime=24*60 #(minutes)
inputs$opioidDose<-inputs$opioidDose*1e6 #ng
antagonistAdministrationRoutesAndDoses= c("IN3nalmefeneB")
antagonistAdministrationRoutesAndDosesLabels= c("IN nalmefene 3 mg B")
outputCase1=read.csv(sprintf("output/%s/optimalOutput%s/%s_%s_%s_%s_%s_%s_%s_%s,%smins/opioidPlasmaConcentration.csv", antagonistAdministrationRoutesAndDoses[1], Sys.Date(), inputs$opioid, inputs$opioidDose, inputs$opioidDosingRoute, inputs$opioidInfusionRate, inputs$opioidAbsorptionRate, inputs$fractionOfBaselineVentilationForAntagonistAdministration, inputs$subjectType, inputs$subjectAge, simulationTime))
gg_color_hue <- function(n) {
	hues = seq(15, 375, length = n + 1)
	hcl(h = hues, l = 65, c = 100)[1:n]
}
colorPalette = gg_color_hue(length(antagonistAdministrationRoutesAndDoses))

plot <- ggplot()
plot <- plot+ geom_line(aes(x=outputCase1[,2]/3600,	y=outputCase1[,3]), size=1) 
plot <- plot+ geom_point(aes(x=clinicalData[,1],	y=clinicalData[,2]), size=3) 
plot <- plot+ scale_color_manual(
		name = "Antagonist dosing", 
		values=c(a=colorPalette[1]),
		labels = antagonistAdministrationRoutesAndDosesLabels)
plot <- plot+ xlim(0, simulationTime/60)
plot <- plot+ ylim(0, NA)
plot <- plot+ ylab("Opioid plasma concentration, ug/L")
plot <- plot+ xlab("Time, hours")
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
	ggsave(
			sprintf("output/%s/optimalOutput%s/%s_%s_%s_%s_%s_%s_%s_%s,%smins/renarcotizationPlasmaConcentration.jpg",	antagonistAdministrationRouteAndDose, Sys.Date(), inputs$opioid, inputs$opioidDose, inputs$opioidDosingRoute, inputs$opioidInfusionRate, inputs$opioidAbsorptionRate, inputs$fractionOfBaselineVentilationForAntagonistAdministration, inputs$subjectType, inputs$subjectAge, simulationTime), 
			plot, 
			height = 2.5, width = 5)
}