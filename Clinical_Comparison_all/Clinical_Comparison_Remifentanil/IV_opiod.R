isWindows<-Sys.info()[["sysname"]]=="Windows"
#--- load libraries
library(cmaes)
library(deSolve)
library(parallel)
library(ggplot2)
library(gridExtra)
plotlist = list()
mymodel<-list()

patien_case="Naive"

#-----------load Experimental data-----------


#----- Remifentanil 
expdata_Naive<-read.csv(paste0("paper_digitilized/barbenco.csv"))

expdata_Naive_Fr<-expdata_Naive[,c(1:3)]
names(expdata_Naive_Fr)<-c("time","MR","HR")


expdata_Naive_Fr$MR=expdata_Naive_Fr$MR/12.9
expdata_Naive_Fr$HR=expdata_Naive_Fr$HR/12.9

expdata_Naive_Fr$time=expdata_Naive_Fr$time*60


#--- load ODE model, states, and parameters
modelname<-"delaymymod"
modeldir<-"models/"
extension<-ifelse(isWindows, ".dll", ".so")
dyn.load(paste0(modeldir,modelname,extension))
source(paste0(modeldir,"delaypars.R"))
source(paste0(modeldir,"delaystates.R")) #laready K40 is 0.15

#load boots parameters------------------------------
bootpars<-read.csv(paste0("Clinical_data/boot_pars_new.csv"))
#----- Change parameters to Worst CASE scenario 
bootpars_Nal<-read.csv("Clinical_data/Naloxone_boot_pars.csv")
bootpars_WC<-read.csv(paste0("Clinical_data/boot_pars_Remi.csv"))
bootpars[c("A1","B1","n")]<-bootpars_WC
bootpars[c("A2","B2","n2")]<-bootpars_Nal

bootpars$VF=4.98

fentanylPK_Zhihua<-read.csv(paste0("Clinical_data/PK_Sensitivity_Remifentanil_No_Cov.csv"))



bootpars$Mmass<-pars["Mmass"]

bootpars[colnames(fentanylPK_Zhihua)]=fentanylPK_Zhihua

print(head(bootpars))


#--------------opt---

#----Remifentanil Parameters
pars["A1"]= 8.078E-6
pars["B1"]= .002076 
pars["n"]= .7034 




#------ Remifetanil Optimal PK (Age + Gender  No Covariants)


pars["kout"]=0.494/60
pars["k1"]=10/60
pars["k12"]=0.339/60
pars["k21"]=.188/60
pars["k13"]=.013/60
pars["k31"]=.01/60
pars["VF"]=4.98



k1<-pars["k1"]



#--------------------------------------------
out_All=c()
#for (ip in 1:nrow(bootpars)) {
	for (ip in 0:2000) {
		print(ip)
		
		if(ip==0) {pars=unlist(pars)}else{
bootpars_i=bootpars[ip,]
pidxs2=match(names(pars), names(bootpars_i), nomatch=0)
pars[pidxs2!=0]<-bootpars_i[pidxs2]
pars=unlist(pars)
}

timepoints=seq(1,30*60,20)
initstates=states
initstates["FIV"]=10^-6
pars["starttime"]<-unclass(as.POSIXct(strptime(date(),"%c")))[1]



eventtimes=c(1)
	
	
if (patien_case=="Naive") {
	eventdose=c(35)*0.001 #um Naive x 0.001 to convert mg

	P1= 5.2
	P2=1.629
	Gmax= 0.9
	Bmax =29.65
	V0=13
	G0=.9
	
	
	
	vent_Fr=as.data.frame(expdata_Naive_Fr)
}


eventdata<-data.frame(var="PlasmaF",time=eventtimes,value=eventdose,method="add")


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
	
	#------ CI 95%
	tq=(lapply(tout_plot1,quantile,probs=c(0.025,.975)))
	
	Efr1=rbind(Efr1,c(ti1,tq$Efr))

	
}
colnames(Efr1)=c("time","qmin","qmax")


IEfr=data.frame(Efr1)

vent_Fr=vent_Fr[vent_Fr$time<=250*60,]
IEfr=IEfr[IEfr$time<=240*60,]
out_plot_paper=out_plot_paper[out_plot_paper$time<=240*60,]



print("ploting...")


p4<-ggplot()



p4<-p4+geom_line(data=vent_Fr, aes(x=time/60, y=MR), size=0.85, alpha=0.8,linetype = "solid",color="blue")
p4<-p4+geom_errorbar(data=vent_Fr,aes(x=time/60,ymin=(MR-(HR-MR)), ymax=HR), width=.1,position=position_dodge(4),col="blue")
p4<-p4+geom_ribbon(data=IEfr, aes(x=time/60, ymin=qmin,ymax=qmax ,alpha=0.3),fill="pink")
p4<-p4+geom_line(data=out_plot_paper, aes(x=time/60, y=Efr), size=0.85, alpha=0.8,linetype = "solid",color="red")
p4<-p4+ylab(paste0("Fractional Ventilation"))+xlab(paste0("time(min)")) 
p4<-p4+theme_light()
p4<-p4+ theme(legend.position="none")
p4<-p4+scale_x_continuous(limits=c(0,20),breaks = seq(0, 20, by = 5))+theme(axis.text=element_text(size=16),axis.title=element_text(size=18))
p4<-p4+scale_y_continuous(limits=c(0,1.5), breaks = seq(0,1.25,by=.25))
p4<-p4+labs(title="Remifentanil Ventilation Depression")
p4<-p4+scale_fill_manual(name = "Dose",values="pink",labels="35ug")


ggsave(paste0("figs/",patien_case,"_Remifentanil_Ventilation.pdf"), p4, width=8, height=6)

