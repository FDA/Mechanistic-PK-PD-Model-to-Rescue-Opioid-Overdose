require(deSolve)
require(snowfall)
require(optparse)
ncores<-8                  #depending on the computing node
options(warn=1)

fullrecoverpcglist<-list()
fullrecovertimelist<-list(); fullinflatedlist<-list(); fulldeflatedlist<-list()
fullrecoverlimitlist<-list();

library(optparse)
parser<-OptionParser()

parser<-add_option(parser, c("-d", "--drug"), default="Fentanyl_A",type="character", help="Opioid ligand. Either Fentanyl or Carfentanil ")
parser<-add_option(parser, c("-m", "--Mmass"), default="336.4",type="character", help="Molar mass of opioid either 336.4 or 394.52 ")


args<-parse_args(parser)

drug<-gsub(" ","",args$drug)
M_Mass<-gsub(" ","",args$Mmass)
M_Mass<-as.numeric(M_Mass)
#drug<-"Fentanyl_A"
#M_Mass<-336.4
#drug<-"Carfentanil"
#M_Mass<-394.52

print(drug) 

TAR<-40

TH<-40               #threshold of 40%
DEL<- 150
print(TH)
print(DEL)

Nal_Route<-"NARCAN" #----- Declare Naloxone_Route
print(Nal_Route)
Data_Folder<-paste0("Ligand_Data/")

G0_data<-data.frame(G0=.42)
Gmax_data<-data.frame(Gmax=.42)
P1_data<-data.frame(P1=9)
P2_data<-data.frame(P2=2.365)
Bmax_data<-data.frame(Bmax=20)


#drug<-"Fentanyl_A"
#M_Mass<-336.4
#drug<-"Carfentanil"
#M_Mass<-394.52



if (drug=="Fentanyl_A"){
	concvals<-c(.44,.88,1.93,7.65) #--- Declare initial dose
	#concvals<-c(.36, .81, 1.85, 7.5) #---- If V0 = 8
}

if (drug =="Carfentanil"){
	concvals<-c(0.0362, 0.058, 0.105, 1.62)
}


  

TH<-TH/100











source(paste0(Data_Folder,drug,"_parameters/parmsAlgera2020.R"))

set.seed(100)


initialdelay<-150

conc=0
Delay=150
Threshold=.6

conditions<-cbind(conc,Delay,Threshold)

conditions0<-as.data.frame(conditions)

print(conditions0)


conditions0<-conditions0[1,]
conditions0$Delay<-DEL


print(concvals)

for(conc in concvals){
	conditions0$conc<-conc
	
	print(conc)
	
	
	
	bootpars<-read.csv(paste0(Data_Folder,drug,"_parameters/boot_pars_new.csv"))
#----- Change parameters to Worst CASE scenario 
	bootpars_Nal<-read.csv(paste0(Data_Folder,"NALOXONE/boot_pars.csv"))
	bootpars_WC<-read.csv(paste0(Data_Folder,drug,"_parameters/boot_pars.csv"))
	bootpars[c("A1","B1","n")]<-bootpars_WC
	bootpars[c("A2","B2","n2")]<-bootpars_Nal
	
	
#	--- for single point approximation. 
	bootpars$V1<-3224
	length(bootpars)
	bootpars$k13<-0
	bootpars$k31<-0
	length(parms)
	
	
	bootpars<-bootpars[,c("F1","kin","kout","ktr","kout2","k1","k2","k12","k13","k21","k31","A1","B1","n","A2","B2","n2","V1")]
	bootpars[1,]<-parms
	bootpars<-bootpars[1,]
	bootpars$Mmass<-M_Mass
	
	print(bootpars)
	
	
	
	
	
	
	#bootpars$Mmass<-M_Mass
	
	print(length(bootpars))
#---naloxone update 
	
	
	head(bootpars)
	
	
	
	allpatients<-cbind(bootpars,G0_data,Gmax_data,P1_data,P2_data,Bmax_data,initialdelay)
	
	
	
	

	
	uniqdose<-sort(unique(conditions0[,1]))
	print(uniqdose)
	
	
	
	source("newdoubledrugWrapper2.R")
	source("Events_double_dose.R"); source("crossing.R");source("models/delaystates.R");dyn.load("models/delaymymod.so")
	
	
	sfInit(parallel=T, cpus=ncores)
	sfClusterEval(dyn.load("models/delaymymod.so"))
	sfClusterEval(source("models/delaystates.R"))
	sfLibrary(deSolve)
	sfExport("conditions0","allpatients","uniqdose","dosingevents","crossing")
	totaljobs<-length(uniqdose)
	
	
	print(totaljobs)
	recoverpcglist<-list()
	recovertimelist<-list(); inflatedlist<-list(); deflatedlist<-list()
	recoverlimitlist<-list();
	recoverlimit<-1200
	
	
	x<-uniqdose
	
	
	thresholdvec<-c(TH)            #use my own thresholdvec because conditions0's threshold has a different meaning
	for(thresholdidx in 1:length(thresholdvec)){ 
		threshold<-thresholdvec[thresholdidx]
		recoverpcglist[[paste0(threshold)]]<-list()
		recovertimelist[[paste0(threshold)]]<-list() 
		for(delayidx in 1:length(unique(conditions0$Delay))){
			delay<-unique(conditions0$Delay)[delayidx]
			print(totaljobs)
			
			venti<-sfClusterApplyLB(1:totaljobs, drugWrapper,delay=delay,threshold=threshold,drug=drug)
			
			recovered<-sapply(venti,function(x) apply(x,2,function(y) sum(!is.infinite(y)&y!=0)))
			recoveredlimit<-sapply(venti,function(x) apply(x,2,function(y) sum(!is.infinite(y)&y!=0&y<recoverlimit)))
			needed<-sapply(venti,function(x) apply(x,2,function(y) sum(y!=0)))
			recovertime_mean<-sapply(venti,function(x) apply(x,2,function(y) mean(y[!is.infinite(y)&y!=0])))
			recovertime_median<-sapply(venti,function(x) apply(x,2,function(y) median(y[!is.infinite(y)&y!=0])))
			
			inflated_mean<-sapply(venti,function(x) apply(x,2,function(y) {y[is.infinite(y)]<-3600;mean(y[y!=0])}))
			
			
			recoverpcglist[[paste0(threshold)]][[paste0(delay)]]<-recovered/needed
			recoverlimitlist[[paste0(threshold)]][[paste0(delay)]]<-recoveredlimit/needed
			recovertimelist[[paste0(threshold)]][[paste0(delay)]]<-recovertime_median
			inflatedlist[[paste0(threshold)]][[paste0(delay)]]<-inflated_mean 
		}#for delayidx
		
	}#for thresholdidx
	
	
	
	
	
	
	sfStop()
	
}

  
  
  