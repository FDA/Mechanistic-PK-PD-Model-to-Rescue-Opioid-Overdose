rm(list=ls())

outdir<-paste0("results/") #read pars
system(paste0("mkdir -p ",outdir))
set.seed(100)
library(deSolve)
library(ggplot2)
library(optparse)

# IN models
modeldir<-"IN_PK_model/" 
simulationTime<-15*60 #simulation time in mins
firstNaloxoneIntroductionTime<-0

#load model and functions====================
isWindows<-Sys.info()[["sysname"]]=="Windows"
modelname<-"delaymymod"
extension<-ifelse(isWindows, ".dll", ".so")
dyn.load(paste0(modeldir,modelname,extension))
source(paste0(modeldir,"delaypars.R"))
source(paste0(modeldir,"delaystates.R"))
times=c(seq(0,65*60,1))
initstates=states

# IN NARCAN 8mg
pop_initpar0=read.csv(sprintf("IN_PK_model/all2000_IN_NARCAN_SCR_011_pars.csv"))
initstates["D"]=8e6

df<-data.frame()
print(length(df))
for (i in 2:nrow(pop_initpar0)){
	print(i)
	initpar=pop_initpar0[i,]
	F=initpar["F"]
	initstates["F"]=F[1,1] 
	initpar["weight"]=70
	initpar["timeout"]=30
	initpar["starttime"]=0
	initpar=initpar[(match(names(pars),names(initpar)))]	
	initpar["starttime"]<-unclass(as.POSIXct(strptime(date(),"%c")))[1]
	initpar=initpar[!is.na(initpar)]
	out<-c()
	try({out <- ode(initstates, times, "derivs", initpar, dllname=modelname, 
						initfunc="initmod", nout=0, rtol=1e-3, atol=1e-6, method="lsoda", 
						events=NULL)});
	out<-data.frame(out)
	outp<-data.frame(out$PlasmaN)
	df<-rbind(df, t(outp))
}

avg<-apply(df,2,mean)

df1<-cbind(times,avg)
df1<-data.frame(df1)

# write relevant data for plotting later
write.csv(df1,sprintf("%s/Avg_IN_8mg.csv",outdir))
