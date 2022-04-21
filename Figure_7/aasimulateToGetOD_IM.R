#define parameters==========================================================================================
modelFolder="models/modelWithSimpleVentilatoryCollapse_IM/"
#figureFolder="output/figures/OD_2021_8_28/"
figureFolder="output_1_18/figures/Im_plot_IM_EVZIO/"
system(paste0("mkdir -p ",figureFolder))		

set.seed(100)
initialdelay<- 1*60 #2.5 Minute delay
useCarfentanilLikePK="yes" #"no" #"yes"
useFasterBiophaseEquilibriumForCarfentanil= "yes"#"no" #"no" #"yes"
simulationTime=1.5*60*60 #seconds
timeUnderInspection<-20 #minutes
CABloodFlow<-1e-2 #l/min

SThBrainO2<-20 #mm Hg
SThArterialO2<-30 #mm Hg
SThArterialCO2<-45 #mm Hg
SThArterialO2Saturation<-90 #%

dose_times=0


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
dyn.load(paste0(modelFolder,"delaymymod.so"))
source(paste0(modelFolder,"delaypars.R"))
source(paste0(modelFolder,"delaystates.R"))
source(paste0(modelFolder,"Events.R")); 
source(paste0(modelFolder,"fundede.R"))
source(paste0(modelFolder,"fundedewithEvent.R"))
source(paste0(modelFolder,"patientWrapper.R")) #--- test
source("functions/calculateODValues.R")
source("functions/calculateRescueTimes.R")
source("functions/crossing.R");
source("functions/extractCriticalVariables.R")
#source("functions/plottingBrainO2PP.R")
#source("functions/plottingMultipleVariablesDavidFormat.R")
#source("functions/plottingMultipleVariablesDavidFormatII.R")
#source("functions/plottingMultipleVariablesInDifferentFigureInSamePDF.R")
#source("functions/plottingOD.R")
#source("functions/plottingODInternalFunction.R")
#=========================================================================
#get inputs=====================================================================================================================================
parser<-OptionParser()
parser<-add_option(parser, c("-m", "--disP"), default ="yes",type="character",help="patient: naive or chronic")
parser<-add_option(parser, c("-n", "--disD"), default ="no",type="character",help="patient: naive or chronic")
parser<-add_option(parser, c("-q", "--disK"), default ="yes",type="character",help="patient: naive or chronic")

parser<-add_option(parser, c("-p", "--patientType"), default ="chronic",type="character",help="patient: naive or chronic")
parser<-add_option(parser, c("-o", "--opioid"), default ="fentanyl",type="character",help="Opioid used to induce respiratory depression")
parser<-add_option(parser, c("-k", "--usePK"), default ="old",type="character",help="whether to use new PK parameters or not")
parser<-add_option(parser, c("-d", "--DThBrainO2"), default ="20",type="numeric",help="dangerous brain O2 threshold")
parser<-add_option(parser, c("-e", "--DThArterialO2"), default ="15",type="numeric",help="dangerous arterial O2 threshold")
parser<-add_option(parser, c("-t", "--CRT"), default ="10",type="numeric",help="critical rescue time")
parser<-add_option(parser, c("-c", "--conc"), default ="2.965",type="numeric",help="Opioid Concentration")
parser<-add_option(parser, c("-i", "--patientid"), default ="2001",type="numeric",help="patient id")
#parser<-add_option(parser,c("-f", "--SupplementalPlot"),defaul="no",type="character",help="yes/no Plot optimal case Bloodflow, Antagonist Plasma Concentration and Ventilation")
#90% 3.35 50% 1.625
	

args<-parse_args(parser)
patientTypeStr<-gsub(" ","",args$patientType)
patientType<-strsplit(patientTypeStr,",")[[1]]
opioidStr<-gsub(" ","",args$opioid)
opioid<-strsplit(opioidStr,",")[[1]]
usePKStr<-gsub(" ","",args$usePK)
usePK<-strsplit(usePKStr,",")[[1]]
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


#Plotstr<-gsub(" ","",args$SupplementalPlot)
#Plot_yn<-strsplit(Plotstr,",")[[1]]
print("-----Produce supplemental figures?-----")
if(args$patientid==2001){
	Plot_yn<-"yes"
}else(Plot_yn="no")
print(Plot_yn)

print(consider_Par_dist)
#consider_Par_dist="yes"
#consider_delay_dist="yes"
populationFolder=sprintf("MCMC_outputs3/final4_EVZIO2_opt_%sParDis_%sDelayDiss_conc%s_PK%s_%s_%s_samplingD_log_Nal0_I",consider_Par_dist,consider_delay_dist,concstr,consider_PK_dis,opioid,patientType)

system(paste0("mkdir -p ",populationFolder))	
#===============================================================================================================================================
#parameters===============================================================================================
naloxonedoseN<-7
patientidx<-1 
delay<-150
#fulltimes<-0:3600
fulltimes<-seq(0,3600,10)
if(opioid=="fentanyl"){#fentanyl
	parms<-c(F=.5704, kin=.008198,kout=.002,ktr=.00833, kout2=31.31 ,k1=.003,
			k2=.001774,k12=.0032, 
			k13=.0036, k21=.0023, k31=.00023,
			A1=3.08E-5, B1=0.004331, n=0.8439, 	#A1=4.523E-5,B1=.004004,n=.8272,
			A2=0.000167,B2=0.03959,n2=.858,V1=124700,
			k12N=45.28, k21N =45.28, V2=108900, Mmass=336.4)
	Mmass<-  336.4}else if(opioid=="carfentanil"){
	parms<-c(F=.5704, kin=.008198,kout=.002,ktr=.00833, kout2=31.31 ,k1=.003,
			k2=.001774,k12=.0032,
			k13=.0036, k21=.0023, k31=.00023,
			A1=9.95E-6,B1=2.47E-4,n=1.025,
			A2=0.000167,B2=0.03959,n2=.858,V1=124700,
			k12N=45.28, k21N =45.28, V2=108900, Mmass=394.5)
	Mmass<-  394.5}
parmsidx<-match(names(pars), names(parms),nomatch=0)
pars[parmsidx!=0]<- parms[parmsidx]
allpars<-read.table(paste0(modelFolder,"fentanyl_pars.txt"),header=F,as.is=T)
parmsidx<-match(names(pars), allpars[,1],nomatch=0)
pars[parmsidx!=0]<- allpars[parmsidx,2]
#so PK is using VP3&VP4
pars["initialdelay"]<-initialdelay
allpatients<-pars
allpatients<-allpatients[names(pars)]    #parameter order very important!
allpatients["k1"]<-0.003
#converting to carfentanil-like PK parameters
if(opioid=="carfentanil" & usePK=="old"){
	if (useCarfentanilLikePK=="yes"){	
		#allpatients["k12"]<-7.478e-5
		allpatients["k21"]<-allpatients["k21"]*10
		allpatients["k13"]<-allpatients["k13"]/10
		allpatients["k31"]<-allpatients["k31"]*10
		allpatients["kout"]<-allpatients["kout"]/10}
	#}
	if (useFasterBiophaseEquilibriumForCarfentanil=="yes"){
		allpatients["k1"]<-10/60}
}
if(usePK=="new"){
	allpatients["kout"]<- 2.109e-4;allpatients["k12"]<- 1.473e-3;
	allpatients["k21"]<- 2.214e-4; allpatients["k31"]<- 1.932e-5;
	allpatients["k13"]<- 4.924e-3; allpatients["k1"]<- 2.142e-3;
	allpatients["VP"]<- 6.655;
#following PK parameters were used when fitting VP3&VP4 (fentanyl bolus injection)
	allpatients["kout"]<- 4.313e-3;allpatients["k12"]<- 3.171e-3;
	allpatients["k21"]<- 1.569e-2; allpatients["k31"]<- 9.777e-5;
	allpatients["k13"]<- 1.92e-3; allpatients["VP"]<- 7.031;
}
#following parameters were hand adjusted based on fitted values
allpatients["P2"]<-0.06319
if(patientType=="naive"){
	#allpatients["k1"]<-0.003
	allpatients["P1"]=2.5*1.15#*.85#.85
	allpatients["P3"]=0.9#*.85#.85
}else if(patientType=="chronic"){	
	allpatients["P1"]<-2.5*1.47*1.15; allpatients["P3"]<- 0.9*1.47; #for 1.3 mg
	#allpatients["k1"]<-0.003
}
#allpatients["k1"]<-10/60

allpatients<-as.data.frame(t(allpatients))
allpatients_2001<-allpatients
#=========================================================================================================
#printing===============================================================
#print(paste("usePK=",usePK))
print(paste("patientType=",patientType))
print(paste("opioid=",opioid))
#print(allpatients["k1"])
#print(allpatients["kout"])


#=======================================================================
#make random dis
iman_random_dis="no"
if (iman_random_dis=="yes") {
population0=read.csv("../parameters/bootpars_Fentanyl_Naloxone_In_Vitro_PK.csv")
Nvec=colnames(allpatients)%in%colnames(population0)
optpar0=allpatients[,Nvec]
rkk1=c()
for (ij in 1:length(optpar0)) {
	rkk=runif(n=2000,min=optpar0[,ij]*.9,max=optpar0[,ij]*1.1)	
	if (ij==8 | ij==11) {
		rkk=runif(n=2000,min=optpar0[,ij]*1,max=optpar0[,ij]*1)
	}

	rkk1=cbind(rkk1,rkk)
	
}
colnames(rkk1)=colnames(population0)
#ssss
#xxxxxxx
population0=rkk1
}

#----------built population parameters----------------------------------

initialdelayP<-rep(60,2001)
#dose delay
#delayP<-sample((1.5*60):(3.5*60),2000,replace=TRUE)

if (iman_random_dis=="no") {
	population0=c()
	if(consider_PK_dis=="yes" && opioid=="fentanyl"){
#population0=read.csv("../parameters/bootpars_Fentanyl_Naloxone_In_Vitro_PK.csv")
population0=read.csv("log_dist/fentanyl_logdis.csv")
print(names(population0))
}
if(opioid=="fentanyl"){
ABNcorect=read.csv("parameters/boot_pars_fentanyl.csv")
}
if(opioid == "carfentanil" && consider_PK_dis=="yes"){
	#population0=read.csv("../parameters/Carfentanil_PK_VAR.csv")
		population0=read.csv("log_dist/fentanyl_logdis.csv")
		population0[,"k21"]<-population0[,"k21"]*10
		population0[,"k13"]<-population0[,"k13"]/10
		population0[,"k31"]<-population0[,"k31"]*10
		population0[,"kout"]<-population0[,"kout"]/10
		ABNcorect=read.csv("parameters/boot_pars_carfentanil.csv")
	
}

#Naloxone_Params<-read.csv("../parameters/all2000_EVZIO.csv")
	
#	Naloxone_Params<-read.csv("../parameters/IMAN_BHM/EVZIO_all2000.csv")
	Naloxone_Params<-read.csv("/scratch/john.mann/Iman_inhalation_IV/inhalation/parameters/all2000_EVZIO2.csv")
	Naloxone_Params$Kin[Naloxone_Params$Kin>10]<-10

population0["F"]=Naloxone_Params["F"]
population0["kin"]=Naloxone_Params["Kin"]
population0["kout2"]=Naloxone_Params["Kout"]
population0["ktr"]=Naloxone_Params["Ktr"]
population0["V1"]=Naloxone_Params["V1"]
population0["k12N"]=Naloxone_Params["k12"]
population0["V2"]=Naloxone_Params["V2"]

population0["A1"]=ABNcorect["A1"]#A_sample#ABNcorect["A1"]
population0["B1"]=ABNcorect["B1"]#B_sample#ABNcorect["B1"]
population0["n"]=ABNcorect["n"]#n_sample#ABNcorect["n"]


ABN_B<-read.csv("parameters/bootpars_Fentanyl_Naloxone_In_Vitro_PK.csv")

population0["A2"]<-ABN_B["A2"]
population0["B2"]<-ABN_B["B2"]
population0["n2"]<-ABN_B["n2"]

}
#ssssss
#read other parameters


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
#	delay
if (consider_delay_dist=="yes") {
	allpatients["initialdelay"]=initialdelayP[ipop]
	delay=150#delayP[ipop]
}
#	this.par<-unlist(allpatients[1,])
	this.par<-unlist(allpatients[patientidx,])
	truepar<-this.par[!names(this.par)=="initialdelay" & !names(this.par)=="Dose"] 
	truepar["timeout"]<-300
	#write.csv(truepar,"population_outputs/EVZIO_pars.csv")
		write.csv(truepar,file="test_old.csv")
		
	out=fundede(states=states,fulltimes=fulltimes,truepar=truepar,namesyout=namesyout)
	stateidx<-match(names(states), colnames(out),nomatch=0)
	states[stateidx!=0]<- out[dim(out)[1],stateidx]
	threshold<-0.4*out[dim(out)[1],"Minute ventilation (l/min)"];
	pp<-patientWrapper(doseidx=opioid_doseidx,patientidx=patientidx,delay=delay,threshold=threshold)
#
#	if(Plot_yn=="yes"){
#	ypred1=pp[[1]][[1]][,c("time","Minute ventilation (l/min)","Opioid plasma concentration (mg)")]
#	ypred2=pp[[1]][[1]][,c("time","Minute ventilation (l/min)","Opioid plasma concentration (mg)")]
		plotFolder="output_2_21/results/Im_plot_IM_EVZIO/"
		system(paste0("mkdir -p ",plotFolder))		
		
		
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