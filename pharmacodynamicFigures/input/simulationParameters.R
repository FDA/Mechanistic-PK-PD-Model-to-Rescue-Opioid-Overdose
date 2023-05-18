#last edited by: Anik Chaturbedi
#on: 2023-05-16
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
parser<-add_option(parser, c("-m", "--OnlyUseRandomAntagonistPopulationPK"), default ="no", type="character", help="as the name suggests (options: no, yes)") #ADDED ON 2023-04-25

inputs<-parse_args(parser)
#define parameters===============================================
if (inputs$antagonistAdministrationRouteAndDose=="IN4"){
	modelFolder<-"models/modelINRepeatedDosing/" #final one used in the SCR-011 paper
	if(inputs$subjectAge=="adult"){
		antagonistDoses<-c("0", "4(R)", "4(R)+4(L)", "4(R)+4(L)+4(R)", "4(R)+4(L)+4(R)+4(L)", "4(R)4(L)", "4(R)4(L)+4(R)4(L)")
		antagonistDosesLabels<-c("No dose","1 dose","2 doses standard","3 doses standard","4 doses standard","2 doses rapid","4 doses rapid")
	}else if(inputs$subjectAge=="10YearOld"){
		antagonistDoses<-c("0", "4(R)", "4(R)")
		antagonistDosesLabels<-c("No dose", "1 scaled dose", "1 dose")
	}
	interDoseDelay<-150 #interDoseDelay between consecutive dose (in seconds)	
}else if (inputs$antagonistAdministrationRouteAndDose=="IVBoyer"){
	modelFolder<-"models/modelIV/"
	antagonistDoses<-c("0", "0.04", "0.04+0.5", "0.04+0.5+2", "0.04+0.5+2+4", "0.04+0.5+2+4+10", "0.04+0.5+2+4+10+15")
	antagonistDosesLabels<-antagonistDoses
	interDoseDelay<-150 #interDoseDelay between consecutive dose (in seconds)
}else if (inputs$antagonistAdministrationRouteAndDose=="IVMultipleDoses"){
	modelFolder<-"models/modelIV/"
	antagonistDoses<-c("0", "0.04", "0.5", "1", "2", "4", "10")
	antagonistDosesLabels<-antagonistDoses
	interDoseDelay<-150 #interDoseDelay between consecutive dose (in seconds)
}
numberOfAntagonistDosingRegimens<-length(antagonistDoses)

simultaneousOpioidAndAntagonistAdministration<-"no" #"yes" #"no"
opioidAdministrationTime<-0 #0 #5*60 #time of opioid administration (seconds)

fractionOfBaselineVentilationForAntagonistAdministration<-0.4 #name

fulltimes<-seq(0,3600,10)
simulationTime<-1.25*60*60 #1.25*60*60 #1.25*60*60 #2*60*60 #1.5*60*60 #6*60*60 #24*60*60 #real time of simulation (in seconds) #ADDED ON 2023-05-11
if (simulationTime>2*60*60){
	simulationTimeStep<-1 #0.1 #(in seconds)
}else {
	simulationTimeStep<-0.1 #(in seconds) 
}
timeUL<-10 #10 #simulationTime/60 #15 #time to plot (in minutes)

adding_threshold_CO2<-"no" #define whether collapse is PaCO2 dependent or not
adding_threshold_O2<-"yes" #define whether collapse is PaO2 dependent or not
tsh_value_o2<-15 #PaO2 threshold below which collapse happens (mm Hg)
tsh_value_co2<-52 #PaCO2 threshold above which collapse happens (mm Hg) 
delayInCardiovascularCollpase<-220 #name (seconds)
CABloodFlow<-1e-2 #1e-2 #total blood flow rate that defines cardiovascular collapse (l/min)

SThBrainO2<-20 #mm Hg
SThArterialO2<-30 #mm Hg
SThArterialCO2<-45 #mm Hg
SThArterialO2Saturation<-90 #%

set.seed(100)
antagonistDose<-as.numeric(regmatches(inputs$antagonistAdministrationRouteAndDose, gregexpr("[[:digit:]]+", inputs$antagonistAdministrationRouteAndDose)))*1e6 #ng

postmortemFentanylPlasmaConcentration=c(3.7, 9.96, 25.2) #ng/ml
postmortemCarfentanilPlasmaConcentration=c(0.2, 0.387, 0.837) #ng/ml

plotCases<-"opioid+naloxone" #"opioid only" #"opioid+naloxone"
IVInfusionDuration<-10 #seconds
IVInfusionTimeStep<-0.1 #seconds 

inputs$numberOfSubjects=20000 #10000 #2000 #10000 #ADDED ON 2023-04-25 #UPDATED ON 2023-05-11
#===============================================================