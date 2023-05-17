rm(list=ls())

outdir<-paste0("results/") #read pars
system(paste0("mkdir -p ",outdir))
set.seed(100)
library(deSolve)
library(ggplot2)
library(optparse)

# IV models
modeldir<-"IV_PK_model/" #modelMechanistic
simulationTime<-15*60 #simulation time in mins
source(paste0(modeldir,"delaypars.R"))
source(paste0(modeldir,"delaystates.R"))
source(paste0(modeldir,"events.R"))
isWindows<-Sys.info()[["sysname"]]=="Windows"
modelname<-"delaymymod"
extension<-ifelse(isWindows, ".dll", ".so")
dyn.load(paste0(modeldir,modelname,extension))

# Infusion event 10s
opioid_dose=0.04e6;
opioid_time=seq(0,10,1);
times=c(seq(0,10,1),seq(20,24*60*60,1))
eventdata<-data.frame(var="PlasmaN",time=opioid_time,value=opioid_dose/length(opioid_time),method="add")
fulltimes<-sort(unique(c(times, cleanEventTimes(eventdata$time, times))))


# IV 2mg complex model for 70kg
ppV3=70.15;ppV4=82.12;ppQ3=3.93*60;ppQ4=0.92*60;
ppV2=34.44;ppCL=3.84*60;

CL=ppCL*exp(rnorm(2000,0,sqrt(0.012)))
V2=ppV2*exp(rnorm(2000,0,sqrt(1.22)))

df<-data.frame()
for (i in 1:2000){
	print(i)
    parsmean=pars
    parsmean["koutC"]=CL[i]/V2[i]/3600
    parsmean["k12C"]= ppQ3/V2[i]/3600
    parsmean["k21C"]= ppQ3/ppV3/3600
    parsmean["k13C"]= ppQ4/V2[i]/3600
    parsmean["k31C"]= ppQ4/ppV4/3600

    #states["PlasmaN"]=2e6
    parsmean["starttime"]<-unclass(as.POSIXct(strptime(date(),"%c")))[1]	
    try({outopt1 <- ode(states, fulltimes, "derivs", parsmean, dllname=modelname,
					initfunc="initmod", nout=0, rtol=1e-3, atol=1e-6, method="lsoda",
					events=list(data=eventdata))});
    outopt1=data.frame(outopt1)
    outopt1$PlasmaNngperml=outopt1$PlasmaN/V2[i]/1000
	outp<-data.frame(outopt1$PlasmaNngperml)
	df<-rbind(df, t(outp))
}

avg<-apply(df,2,mean)

df1<-cbind(fulltimes,avg)
df1<-data.frame(df1)

# write relevant data for plotting later
write.csv(df1,sprintf("%s/Avg_IV_p04mg.csv",outdir))
