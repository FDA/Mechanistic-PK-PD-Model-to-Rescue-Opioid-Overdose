isWindows<-Sys.info()[["sysname"]]=="Windows"
#--- load libraries
library(cmaes)
library(deSolve)
library(parallel)
library(ggplot2)
library(gridExtra)
plotlist = list()
mymodel<-list()

library(optparse)
parser<-OptionParser()

parser<-add_option(parser, c("-p", "--patient_case"), default=40,type="character", help="Patient opioid usage. Can be either Naive or Chronic ")

args<-parse_args(parser)

patien_case<-gsub(" ","",args$patient_case)

print(patien_case)

#patien_case="Chronic"
#patien_case="Naive"




#-----------load Experimental data-----------
expdata_Naive<-read.csv(paste0("paper_digitized/A_Naive.csv"))
expdata_Naive_Fr=expdata_Naive

expdata_Naive_Fr$LR=expdata_Naive$LR/mean(expdata_Naive$MR[expdata_Naive$time<110 & expdata_Naive$time>100])
expdata_Naive_Fr$MR=expdata_Naive$MR/mean(expdata_Naive$MR[expdata_Naive$time<110 & expdata_Naive$time>100])
expdata_Naive_Fr$HR=expdata_Naive$HR/mean(expdata_Naive$MR[expdata_Naive$time<110 & expdata_Naive$time>100])



expdata_Naive_Fr$time=expdata_Naive$time*60

#expdata_Naive$LR=
#expdata_Naive_Fr0=as.matrix(expdata_Naive[c("LR","MR","HR")])/as.vector(unlist(expdata_Naive[1,c("LR","MR","HR")]))
#expdata_Naive_Fr=cbind(time=expdata_Naive[,"time"]*60,expdata_Naive_Fr0)
#-------------------
expdata_Chronic<-read.csv(paste0("paper_digitized/B_Chronic.csv"))
expdata_Chronic_Fr=expdata_Chronic

#iman approach

expdata_Chronic_Fr$LR=expdata_Chronic$LR/mean(expdata_Chronic$MR[expdata_Chronic$time<110 & expdata_Chronic$time>100])
expdata_Chronic_Fr$MR=expdata_Chronic$MR/mean(expdata_Chronic$MR[expdata_Chronic$time<110 & expdata_Chronic$time>100])
expdata_Chronic_Fr$HR=expdata_Chronic$HR/mean(expdata_Chronic$MR[expdata_Chronic$time<110 & expdata_Chronic$time>100])



expdata_Chronic_Fr$time=expdata_Chronic$time*60


#--- load ODE model, states, and parameters
modelname<-"delaymymod"
modeldir<-"models/"
extension<-ifelse(isWindows, ".dll", ".so")
dyn.load(paste0(modeldir,modelname,extension))
source(paste0(modeldir,"delaypars.R"))
source(paste0(modeldir,"delaystates.R")) #laready K40 is 0.15

#load boots parameters------------------------------
bootpars<-read.csv(paste0("Clinical_data/boot_pars_new.csv")) #----- Default Model
#----- Change parameters to Worst CASE scenario 
bootpars_Nal<-read.csv("Clinical_data/Naloxone_boot_pars.csv") #----- Naloxone binding Parameters (Not used)
bootpars_WC<-read.csv(paste0("Clinical_data/boot_pars_refit.csv")) #---- Fentanyl binding Parameters
bootpars[c("A1","B1","n")]<-bootpars_WC
bootpars[c("A2","B2","n2")]<-bootpars_Nal

fentanylPK_Zhihua<-read.csv(paste0("Clinical_data/fentanylPK.csv")) #---- PK parameters for 3-C fentanyl
bootpars[colnames(fentanylPK_Zhihua)]=fentanylPK_Zhihua
#--------------opt---
pars["A1"]=3.08E-5
pars["B1"]=.004331
pars["n"]=.8439
pars["kout"]=0.000857
pars["k1"]=0.000703
pars["k12"]=0.003066
pars["k21"]=0.000393 
#--------------------------------------------
out_All=c()
#for (ip in 1:nrow(bootpars)) {
	for (ip in 0:2000) {
		print(ip)
		
		if(ip==0) {pars=unlist(pars)}else{
bootpars_i=bootpars[ip,]
#names(bootpars_i)=colnames(bootpars)
pidxs2=match(names(pars), names(bootpars_i), nomatch=0)
pars[pidxs2!=0]<-bootpars_i[pidxs2]
pars=unlist(pars)
}

timepoints=seq(1,370*60,50)
initstates=states
initstates["FIV"]=10^-6
pars["starttime"]<-unclass(as.POSIXct(strptime(date(),"%c")))[1]



#event
eventtimes=c(120*60,120*60+pars["Infu_t"],180*60,180*60+pars["Infu_t"],240*60,240*60+pars["Infu_t"],300*60,300*60+pars["Infu_t"]) #min Naive

	#--- Mechanistic Ventilation Model parameters are fit separately to clinical data for Naive and Chronic cases

if (patien_case=="Naive") {
	eventdose=c(75,-75,150,-150,250,-250,350,-350)*0.001 #um Naive x 0.001 to convert mg

		P1= 5.2
		P2=1.629
		Gmax= 0.42
		Bmax =29.65
		V0=20
		G0=.42
		
		
		
	vent_Fr=as.data.frame(expdata_Naive_Fr)
}
if (patien_case=="Chronic") {
	eventdose=c(250,-250,350,-350,500,-500,700,-700)*0.001 #um NaiveV x 0.001 to convert mg
	

	P1=9
	P2=2.365
	Gmax=.42
	Bmax=20
	V0=20
	G0=.42
	
	vent_Fr=as.data.frame(expdata_Chronic_Fr)
	
}
eventdata<-data.frame(var="FIV",time=eventtimes,value=eventdose,method="add")

try({out0 <- ode(initstates, timepoints, "derivs", pars, dllname=modelname,initfunc="initmod",rtol=1e-3,atol=1e-6,method="lsoda",events=list(data=eventdata))});		
	out=data.frame(out0)

out$Efr=(G0 - Gmax*(out$CAR)^P1)*(V0/G0 - Bmax*(out$CAR)^P2)/V0

	out_All=rbind(out_All,out)
	if (ip==0) {out_plot_paper=as.data.frame(out)}
	

}
#convert CAR to E/E0
Efr1=c()
for (ti1 in timepoints) {
	tout_plot1=out_All[out_All[,1]==ti1,]
	tq=(lapply(tout_plot1,quantile,probs=c(0.025,.975))) # CI 95% of 2000 samples 
	
	Efr1=rbind(Efr1,c(ti1,tq$Efr))

	
}
colnames(Efr1)=c("time","qmin","qmax")


IEfr=data.frame(Efr1)

vent_Fr=vent_Fr[vent_Fr$time<=250*60,]
IEfr=IEfr[IEfr$time<=240*60,]
out_plot_paper=out_plot_paper[out_plot_paper$time<=240*60,]

print("ploting...")
p1<-ggplot(data=out_plot_paper)
p1<-p1+geom_line(data=out_plot_paper, aes(x=time, y=FIV), size=0.85, alpha=0.8,linetype = "solid")
p2<-ggplot(data=out_plot_paper)
p2<-p2+geom_line(data=out_plot_paper, aes(x=time, y=PlasmaF), size=0.85, alpha=0.8,linetype = "solid")

p3<-ggplot(data=out_plot_paper)
p3<-p3+geom_line(data=out_plot_paper, aes(x=time, y=CAR), size=0.85, alpha=0.8,linetype = "solid")




p4<-ggplot()



p4<-p4+geom_line(data=vent_Fr, aes(x=time/60, y=MR), size=0.85, alpha=0.8,linetype = "solid",color="blue")
p4<-p4+geom_errorbar(data=vent_Fr,aes(x=time/60,ymin=LR, ymax=HR), width=3,position=position_dodge(4),col="blue")
p4<-p4+geom_ribbon(data=IEfr, aes(x=time/60, ymin=qmin,ymax=qmax ,alpha=0.3))
p4<-p4+geom_line(data=out_plot_paper, aes(x=time/60, y=Efr), size=0.85, alpha=0.8,linetype = "solid",color="green")
p4<-p4+ylab(paste0("Fractional Ventilation"))+xlab(paste0("time(min)"))+theme(legend.position = "none") 
p4<-p4+theme_light()
p4<-p4+scale_x_continuous(limits=c(90,250),breaks = seq(0, 240, by = 60))+theme(axis.text=element_text(size=16),axis.title=element_text(size=18))
#

plotlist1=list()
plotlist1[[1]] = p1
plotlist1[[2]] = p2
plotlist1[[3]] = p3
plotlist1[[4]] = p4

pall1 <- grid.arrange(grobs=plotlist1,ncol=2)
ggsave(paste0("figs/",patien_case,"_IFV_Rev01_EB_New_EQ_P2",P2,".pdf"), pall1, width=8, height=6)

ggsave(paste0( "figs/",patien_case,"_IFV_justp4_Rev01_EB_NE_EQ",P2,".pdf"), p4, width=8, height=6)

