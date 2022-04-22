# File:         simulateToGetOD_IM.R
# Author:       John Mann
#               Zhihua Li
# Date:         April 2022
# Version:      1.0
# 
# Description:  Rscript to calculate cardiac arrest parameters for 
#               IM Naloxone products

#define parameters==========================================================================================
modelFolder="models/modelWithSimpleVentilatoryCollapse_IM/"
figureFolder="output_individual_patients/"
system(paste0("mkdir -p ",figureFolder))		

set.seed(100)
initialdelay<- 1*60 #1 Minute delay between respiratory depression threshold and naloxone administration
useCarfentanilLikePK="yes" #"no" or "yes" Do Carfentanil PK parameters differ from fentanyl?
useFasterBiophaseEquilibriumForCarfentanil= "yes"#"no" or "yes" Does Carfentanil reach the effect site more rapidly than fentanyl
simulationTime=1.5*60*60 # Total run time in seconds
timeUnderInspection<-20 # Plotting window in minutes
CABloodFlow<-1e-2 # Minimum blood flow at cardiac arrest

SThBrainO2<-20 # Dangerous Brain O2 threshold mm Hg
SThArterialO2<-30 # Dangerous Arterial O2 threshold mm Hg
SThArterialCO2<-45 # Dangerous Arterial CO2 threshold mm Hg
SThArterialO2Saturation<-90 # Dangerous Arterial Oxygen saturation threshold %

dose_times=0 # Time of fentanyl administration: Typically 0

#--- Renaming model outputs for clearer labeling
namesyout<-c("Minute ventilation (l/min)","Residual wakefulness drive (l/min)","Chemoreflex drive (l/min)",
		"Blood flow to brain (l/min)","Blood flow to tissue (l/min)",
		"Arterial O2 partial pressure (mm Hg)","Arterial CO2 partial pressure (mm Hg)",
		"Brain O2 partial pressure (mm Hg)","Brain CO2 partial pressure (mm Hg)",
		"Opioid plasma concentration (mg)","Antagonist plasma concentration (ng/ml)",
		"Opioid effect site concentration (pM)","Antagonist effect site concentration (nM)",
		"Opioid bound receptor fraction","Antagonist bound receptor fraction","Total blood flow (l/min)",
		"Elimination Rate (1/s)","K12","K13","K21","K31","Fentanyl VoD",
		"Arterial oxygen saturation (%)", "Naloxone VoD")
#===========================================================================================================
#load required packages==================
library(deSolve)
library(optparse)
library(ggplot2)
library(gridExtra)
library(grid)
gg_color_hue <- function(n) {
	hues = seq(15, 375, length = n + 1)
	hcl(h = hues, l = 65, c = 100)[1:n]
}
colorPalette = gg_color_hue(6)
#========================================
#load required scripts====================================================
dyn.load(paste0(modelFolder,"delaymymod.so")) #Compiled opioid model
source(paste0(modelFolder,"delaypars.R"))	  #Default parameters
source(paste0(modelFolder,"delaystates.R"))
source(paste0(modelFolder,"Events.R")); 	  # Events controlling opioid/naloxone administration
source(paste0(modelFolder,"fundede.R"))		# ode function without events	
source(paste0(modelFolder,"fundedewithEvent.R")) # ode function with events
source(paste0(modelFolder,"patientWrapper.R")) # helper function to calculate Cardiac arrest and rescue time
source("functions/crossing.R");

#=========================================================================
#get inputs=====================================================================================================================================
parser<-OptionParser()
parser<-add_option(parser, c("-m", "--disP"), default ="yes",type="character",help="patient: naive or chronic")
parser<-add_option(parser, c("-n", "--disD"), default ="no",type="character",help="patient: naive or chronic")
parser<-add_option(parser, c("-q", "--disK"), default ="yes",type="character",help="patient: naive or chronic")

parser<-add_option(parser, c("-p", "--patientType"), default ="chronic",type="character",help="patient: naive or chronic")
parser<-add_option(parser, c("-o", "--opioid"), default ="fentanyl",type="character",help="Opioid used to induce respiratory depression")
parser<-add_option(parser, c("-d", "--DThBrainO2"), default ="20",type="numeric",help="dangerous brain O2 threshold")
parser<-add_option(parser, c("-e", "--DThArterialO2"), default ="15",type="numeric",help="dangerous arterial O2 threshold")
parser<-add_option(parser, c("-t", "--CRT"), default ="10",type="numeric",help="critical rescue time")
parser<-add_option(parser, c("-c", "--conc"), default ="2.965",type="numeric",help="Opioid Concentration")
parser<-add_option(parser, c("-i", "--patientid"), default ="2001",type="numeric",help="patient id")
parser<-add_option(parser, c("-a", "--formulation"), default = "EVZIO",type="character",help="Type of Naloxone IM formulation: either EVZIO or Generic")

args<-parse_args(parser)
patientTypeStr<-gsub(" ","",args$patientType)
patientType<-strsplit(patientTypeStr,",")[[1]]
opioidStr<-gsub(" ","",args$opioid)
opioid<-strsplit(opioidStr,",")[[1]]

dangerousBrainO2ThresholdStr<-gsub(" ","",args$DThBrainO2)
dangerousBrainO2Threshold<-strsplit(dangerousBrainO2ThresholdStr,",")[[1]]
dangerousArterialO2ThresholdStr<-gsub(" ","",args$DThArterialO2)
dangerousArterialO2Threshold<-strsplit(dangerousArterialO2ThresholdStr,",")[[1]]
criticalRescueTimeStr<-gsub(" ","",args$CRT)
criticalRescueTime<-strsplit(criticalRescueTimeStr,",")[[1]]
concstr<-gsub(" ","",args$conc)
concvals<-strsplit(concstr,",")[[1]]
uniqdose<-as.numeric(concvals)
DThBrainO2<-as.numeric(dangerousBrainO2Threshold)
DThArterialO2<-as.numeric(dangerousArterialO2Threshold)
CRT<-as.numeric(criticalRescueTime)*60

print(args$patientid)
consider_Par_dist=args$disP
consider_delay_dist=args$disD
consider_PK_dis=args$disK

formulation=args$formulation


print("-----Produce supplemental figures?-----")
if(args$patientid==2001){
	Plot_yn<-"yes"
}else(Plot_yn="no")
print(Plot_yn)


populationFolder=sprintf("outputs/Review_naloxone_formulation_%s_conc_%s_ligand_%s_patient_%s",formulation,concstr,opioid,patientType)

system(paste0("mkdir -p ",populationFolder))	
#===============================================================================================================================================
#parameters===============================================================================================
naloxonedoseN<-7 #number of unique naloxone dose cases
patientidx<-1 
delay<-150 # delay (s) between naloxone administrations for multi-dose cases
fulltimes<-seq(0,3600,10)
print("------------")
print(formulation)
#----- PK parameters for opioid/naloxone formulation
if(formulation=="EVZIO"){
if(opioid=="fentanyl" ){

	parms<-c(F=.5704, kin=.008198,kout=.002,ktr=.00833, kout2=31.31 ,k1=.003,
			k2=.001774,k12=.0032, 
			k13=.0036, k21=.0023, k31=.00023,
			A1=3.08E-5, B1=0.004331, n=0.8439, 	#A1=4.523E-5,B1=.004004,n=.8272,
			A2=0.000167,B2=0.03959,n2=.858,V1=124700,
			k12N=45.28, k21N =45.28, V2=108900, Mmass=336.4)
	}else if(opioid=="carfentanil"){
	parms<-c(F=.5704, kin=.008198,kout=.002,ktr=.00833, kout2=31.31 ,k1=.003,
			k2=.001774,k12=.0032,
			k13=.0036, k21=.0023, k31=.00023,
			A1=9.95E-6,B1=2.47E-4,n=1.025,
			A2=0.000167,B2=0.03959,n2=.858,V1=124700,
			k12N=45.28, k21N =45.28, V2=108900, Mmass=394.5)
	}
}

if(formulation=="Generic"){
	if(opioid=="fentanyl" ){
		parms<-c(F=.6257, kin=.005164,kout=.002,ktr=.005121, kout2=32.03 ,k1=.003,
				k2=.001774,k12=.0032, 
				k13=.0036, k21=.0023, k31=.00023,
				A1=3.08E-5, B1=0.004331, n=0.8439, 	#A1=4.523E-5,B1=.004004,n=.8272,
				A2=0.000167,B2=0.03959,n2=.858,V1=156500,
				k12N=524.6, k21N =0, V2=320000, Mmass=336.4)
		}else if(opioid=="carfentanil"){
		parms<-c(F=.6257, kin=.005164,kout=.002,ktr=.005121, kout2=32.03 ,k1=.003,
				k2=.001774,k12=.0032, 
				k13=.0036, k21=.0023, k31=.00023,
				A1=9.95E-6,B1=2.47E-4,n=1.025,
				A2=0.000167,B2=0.03959,n2=.858,V1=156500,
				k12N=524.6, k21N =0, V2=320000, Mmass=394.5)
	}
}
parmsidx<-match(names(pars), names(parms),nomatch=0)
pars[parmsidx!=0]<- parms[parmsidx]
allpars<-read.table(paste0(modelFolder,"fentanyl_pars.txt"),header=F,as.is=T)
parmsidx<-match(names(pars), allpars[,1],nomatch=0)
pars[parmsidx!=0]<- allpars[parmsidx,2]
pars["initialdelay"]<-initialdelay
allpatients<-pars
allpatients<-allpatients[names(pars)]    #parameter order very important!
#converting to carfentanil-like PK parameters
#Micro-dosing PK data indicates that carfentanil has longer residence time in plasma
if(opioid=="carfentanil"){
	if (useCarfentanilLikePK=="yes"){	
		allpatients["k21"]<-allpatients["k21"]*10
		allpatients["k13"]<-allpatients["k13"]/10
		allpatients["k31"]<-allpatients["k31"]*10
		allpatients["kout"]<-allpatients["kout"]/10}
	#}
	#In the absence of Carfentanil clinical we assume carfentanil's 
	#higher lipophilicity leads to more rapid equilibriation
	
	if (useFasterBiophaseEquilibriumForCarfentanil=="yes"){ # "no uses fentanyl k1
		allpatients["k1"]<-10/60}
}

#following parameters were hand adjusted based on fitted values
allpatients["P2"]<-0.06319
if(patientType=="naive"){
	allpatients["P1"]=2.5*1.15
	allpatients["P3"]=0.9
}else if(patientType=="chronic"){	
	allpatients["P1"]<-2.5*1.47*1.15; allpatients["P3"]<- 0.9*1.47; 
}

allpatients<-as.data.frame(t(allpatients))
allpatients_2001<-allpatients #--- patient 2001 provides the 
#=========================================================================================================
#printing===============================================================
print(paste("patientType=",patientType))
print(paste("opioid=",opioid))



#=======================================================================

random_dis="no" #<- If yes provide alternate randomization strategy


#----------built population parameters----------------------------------

initialdelayP<-rep(60,2001) #initial delay between respiratory trigger and naloxone administration 


if (random_dis=="no") { # PK populations for opioids (fentanyl or carfentanil)
	population0=c()
	if(consider_PK_dis=="yes" && opioid=="fentanyl"){
population0=read.csv("log_dist/fentanyl_logdis.csv")
}
if(opioid=="fentanyl"){
ABNcorect=read.csv("parameters/boot_pars_fentanyl.csv")
}
if(opioid == "carfentanil" && consider_PK_dis=="yes"){
		population0=read.csv("log_dist/fentanyl_logdis.csv")
		population0[,"k21"]<-population0[,"k21"]*10
		population0[,"k13"]<-population0[,"k13"]/10
		population0[,"k31"]<-population0[,"k31"]*10
		population0[,"kout"]<-population0[,"kout"]/10
		ABNcorect=read.csv("parameters/boot_pars_carfentanil.csv")
	
}

	# The population of PK  parameters for naloxone (either EVZIO or generic)
	if(formulation=="EVZIO"){
	Naloxone_Params<-read.csv("parameters/all2000_EVZIO2.csv")
}

if(formulation=="Generic"){
	Naloxone_Params<-read.csv("parameters/all2000_Generic2.csv")
}


Naloxone_Params$Kin[Naloxone_Params$Kin>10]<-10

#---- Naloxone PK
population0["F"]=Naloxone_Params["F"]
population0["kin"]=Naloxone_Params["Kin"]
population0["kout2"]=Naloxone_Params["Kout"]
population0["ktr"]=Naloxone_Params["Ktr"]
population0["V1"]=Naloxone_Params["V1"]
population0["k12N"]=Naloxone_Params["k12"]
population0["V2"]=Naloxone_Params["V2"]

#---- Fentanyl binding mechanics
population0["A1"]=ABNcorect["A1"] 
population0["B1"]=ABNcorect["B1"]
population0["n"]=ABNcorect["n"]


ABN_B<-read.csv("parameters/bootpars_Fentanyl_Naloxone_In_Vitro_PK.csv")
#---- Naloxone binding mechanics
population0["A2"]<-ABN_B["A2"]
population0["B2"]<-ABN_B["B2"]
population0["n2"]<-ABN_B["n2"]

}



if (consider_Par_dist=="yes") {
Nvec=!colnames(allpatients)%in%colnames(population0)
population1=cbind(population0,allpatients[Nvec])
allpatients=population1
allpatients=allpatients[,names(pars)]
}

allpatients<-rbind(allpatients,allpatients_2001)


#-----------------------------------------------------------------------
for (opioid_doseidx in 1:length(uniqdose)){
	print(paste("opioid dose=",uniqdose[opioid_doseidx],"mg"))
	for (ipop in as.numeric(args$patientid)) {	
if (consider_Par_dist=="yes") {patientidx=ipop}else{patientidx=1}
if (consider_delay_dist=="yes") {
	allpatients["initialdelay"]=initialdelayP[ipop]
	delay=150#delayP[ipop]
}
	this.par<-unlist(allpatients[patientidx,])
	truepar<-this.par[!names(this.par)=="initialdelay" & !names(this.par)=="Dose"] 
	truepar["timeout"]<-300

	#---- Determine ventilation threshold in absence of opioids 
	out=fundede(states=states,fulltimes=fulltimes,truepar=truepar,namesyout=namesyout)
	stateidx<-match(names(states), colnames(out),nomatch=0)
	states[stateidx!=0]<- out[dim(out)[1],stateidx]
	#---- Once ventilation hits 40% of baseline trigger naloxone administration (after initialdelay)
	threshold<-0.4*out[dim(out)[1],"Minute ventilation (l/min)"]; 
	
	#---- Call helper function
	pp<-patientWrapper(doseidx=opioid_doseidx,patientidx=patientidx,delay=delay,threshold=threshold)

	
	
		plotFolder=sprintf("outputs/results/Im_plot_%s/",formulation)
		system(paste0("mkdir -p ",plotFolder))		
		
		#Generate physiological responses for optimal patient (patientidx=2001)
		if(Plot_yn=="yes"){
			ypred1=pp[[1]][[1]][,c("time","Minute ventilation (l/min)",
							"Arterial O2 partial pressure (mm Hg)","Total blood flow (l/min)",
							"Arterial CO2 partial pressure (mm Hg)",
							"Brain O2 partial pressure (mm Hg)",
							"Antagonist plasma concentration (ng/ml)",
							"Blood flow to brain (l/min)")]
			ypred2=pp[[1]][[2]][,c("time","Minute ventilation (l/min)",
							"Arterial O2 partial pressure (mm Hg)","Total blood flow (l/min)",
							"Arterial CO2 partial pressure (mm Hg)",
							"Brain O2 partial pressure (mm Hg)",
							"Antagonist plasma concentration (ng/ml)",
							"Blood flow to brain (l/min)")]
			write.csv(ypred1,sprintf("%s/%s_%s_ypred1.csv",plotFolder,opioid,concstr))
			write.csv(ypred2,sprintf("%s/%s_%s_ypred2.csv",plotFolder,opioid,concstr))
			
		}
		
		
		
		
}
	#-----------------------------------------------------------------------------------------------------------------------------
}