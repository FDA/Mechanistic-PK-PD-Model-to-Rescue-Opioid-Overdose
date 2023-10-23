#last edited by: Anik Chaturbedi
#on: 2024-11-07

set.seed(100)
parser<-OptionParser()
parser<-add_option(parser, c("-a", "--opioid"), default ="fentanyl", type="character", help="opioid used to induce respiratory depression (options: fentanyl, carfentanil, sufentanil)")
parser<-add_option(parser, c("-b", "--opioidDose"), default ="1.625", type="numeric", help="opioid concentration (in mg) (options: 1.625, 2.965, 0.012, 0.02187)")
parser<-add_option(parser, c("-c", "--antagonist"), default ="naloxone", type="character", help="antagonist used to rescue from opioid induced respiratory depression (options: naloxone, nalmefene)")
parser<-add_option(parser, c("-d", "--antagonistAdministrationRouteAndDose"), default ="IN4", type="character", help="antagonist administration route and dose in mg (options: IN4, IN8, IM1NalmefeneStudy, IM2NalmefeneStudy, IM2EVZIO, IM2Generic, IM5ZIMHI, IVMultipleDoses, IV2, IVBoyer, IM10, OralMultipleDoses)")
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
parser<-add_option(parser, c("-r", "--simulateCase"), default ="opioid+antagonist",type="character",help="what to simulate (opioidOnly, antagonistOnly, opioid+antagonist)")
parser<-add_option(parser, c("-s", "--opioidDosingRoute"), default ="transdermal",type="character",help="what opioid dosing route to use (transdermal, transmucosal)")
parser<-add_option(parser, c("-t", "--fractionOfBaselineVentilationForAntagonistAdministration"), default ="0.4",type="numeric",help="fractionOfBaselineVentilationForAntagonistAdministration (-)")
inputs<-parse_args(parser)

#define parameters===============================================
if (inputs$antagonistAdministrationRouteAndDose=="IN4naloxone"){ #IN 4 mg naloxone WITHOUT repeat dosing, without peripheral compartment
	if (inputs$opioidDosingRoute=="transmucosal"){
		modelFolder<-"models/model_TM_2Tr1C1P_IN_2Tr1C/"
	}
	else {
		modelFolder<-"models/modelIN_2Tr1C/"		
	}
}else {
	if (inputs$opioidDosingRoute=="transmucosal"){
		modelFolder<-"models/model_TM_2Tr1C1P_IN_2Tr1C1P_RepeatedDosing/"
	}
	else {
		modelFolder<-"models/modelIN_2Tr1C1P_RepeatedDosing/"
	}
}
if(inputs$subjectAge=="adult"){
	if (inputs$simulateRenarcotization=="yes"){
		antagonistDoses<-c("No dose", "1 dose")
	}else{
		antagonistDoses<-c("No dose", "1 dose")
	}
}
antagonistDosesLabels= antagonistDoses
interDoseDelay<-150 #interDoseDelay between consecutive dose (in seconds)	
antagonistDose<-as.numeric(unlist(regmatches(inputs$antagonistAdministrationRouteAndDose, gregexpr("[[:digit:]]+\\.*[[:digit:]]*", inputs$antagonistAdministrationRouteAndDose))))*1e6 #ng
numberOfAntagonistDosingRegimens<-length(antagonistDoses)

#parameters related to opioid and antagonist administration
inputs$opioidDose<-inputs$opioidDose*1e6 #ng
simultaneousOpioidAndAntagonistAdministration<-"no" #"yes" #"no"
opioidAdministrationTime<-0#time of opioid administration (seconds)

IVInfusionDuration<-10 #seconds
IVInfusionTimeStep<-0.1 #seconds 

#parameters related to time and timestep of simulations
fulltimes<-seq(0,3600,10) #time-step for stabilization simulation (would be good to change names at some point)
if (inputs$OnlyUseRandomAntagonistPopulationPK=="yes"){
	simulationTime<- 1*60*60 #real time of simulation (in seconds)
}else if (inputs$simulateRenarcotization=="yes"){
	simulationTime<- 24*60*60 #24*60*60 #15*60*60 (for SimulateVirtualPopulationsRenarcotization.sh)
}else{
	simulationTime<- 1*60*60 #1*60*60 #1.25*60*60 #1.5*60*60 #2*60*60 #6*60*60 #24*60*60 #real time of simulation (in seconds)
}
if (simulationTime>2*60*60){
	simulationTimeStep<-1 #0.1 #(in seconds)
}else {
	simulationTimeStep<-0.1 #(in seconds) 
}

#parameters related to base simulation=======================
fractionOfBaselineVentilationForAntagonistAdministration<-inputs$fractionOfBaselineVentilationForAntagonistAdministration #0.4 #name

#parameters related to cardiovascular collpase and CA====
adding_threshold_O2<-"yes" #define whether collapse is PaO2 dependent or not
adding_threshold_CO2<-"no" #define whether collapse is PaCO2 dependent or not
tsh_value_o2<-15 #PaO2 threshold below which collapse happens (mm Hg), relevant only when adding_threshold_O2="yes"
tsh_value_co2<-52 #PaCO2 threshold above which collapse happens (mm Hg), relevant only when adding_threshold_CO2="yes" 
delayInCardiovascularCollpase<-220 #name (seconds)
CABloodFlow<-1e-2 #1e-2 #total blood flow rate that defines cardiovascular collapse (l/min)
#====parameters related to cardiovascular collpase and CA

#=======================parameters related to base simulation

#parameters realted to plotting
if (inputs$simulateRenarcotization=="yes"){
	timeUL= simulationTime/60 #60
}else{
	timeUL= 10 #time to plot (in minutes)
}
plotCases<-"opioid+naloxone" #"opioid only" #"opioid+naloxone"

#parameters related to output
SThBrainO2<-20 #mm Hg
SThArterialO2<-30 #mm Hg
SThArterialCO2<-45 #mm Hg
SThArterialO2Saturation<-90 #%

#parameters to calculate opioid overdose levels==============
postmortemFentanylPlasmaConcentration=c(3.7, 9.96, 25.2) #as name suggests (ng/ml)
postmortemCarfentanilPlasmaConcentration=c(0.2, 0.387, 0.837) #as name suggests (ng/ml)
#==============parameters to calculate opioid overdose levels

#POSSIBLY parameter relevant to situation where random population was generated (probably for generating Krieter populations)
inputs$numberOfSubjects=2000
#===============================================================