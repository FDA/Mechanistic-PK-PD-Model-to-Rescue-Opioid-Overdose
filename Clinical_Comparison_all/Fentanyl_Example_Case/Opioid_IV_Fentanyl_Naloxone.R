isWindows<-Sys.info()[["sysname"]]=="Windows"
#--- load libraries

print(sessionInfo())

#import libraries----
library(ggplot2)
library(gridExtra)
library(colorspace)

#define color palette----
gg_color_hue <- function(n) {
	hues = seq(15, 375, length = n + 1)
	hcl(h = hues, l = 65, c = 100)[1:n]
}
colorPalette = gg_color_hue(6)

library(deSolve)
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


print(sessionInfo())

#-----------load Experimental data-----------
expdata_Naive<-read.csv(paste0("paper_digitized/A_Naive.csv"))
expdata_Naive_Fr=expdata_Naive

expdata_Naive_Fr$LR=expdata_Naive$LR/mean(expdata_Naive$MR[expdata_Naive$time<110 & expdata_Naive$time>100])
expdata_Naive_Fr$MR=expdata_Naive$MR/mean(expdata_Naive$MR[expdata_Naive$time<110 & expdata_Naive$time>100])
expdata_Naive_Fr$HR=expdata_Naive$HR/mean(expdata_Naive$MR[expdata_Naive$time<110 & expdata_Naive$time>100])



expdata_Naive_Fr$time=expdata_Naive$time*60



#--- load ODE model, states, and parameters
modelname<-"delaymymod"
modeldir<-"models/"
extension<-ifelse(isWindows, ".dll", ".so")
dyn.load(paste0(modeldir,modelname,extension))
source(paste0(modeldir,"delaypars.R"))
source(paste0(modeldir,"delaystates.R")) #laready K40 is 0.15

#load boots parameters------------------------------
bootpars<-read.csv(paste0("Clinical_data/boot_pars_new.csv")) #----- Default Model
#----- Change parameters to Specific scenario 
bootpars_Nal<-read.csv("Clinical_data/Naloxone_boot_pars.csv") #----- Naloxone binding Parameters
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
timepoints=seq(1,370*60,50)
vent_Fr=as.data.frame(expdata_Naive_Fr)
#--------------------------------------------


out_All=c()
	for (ip in 0:2000) {
		print(ip)
		
		if(ip==0) {pars=unlist(pars)}else{
bootpars_i=bootpars[ip,]
pidxs2=match(names(pars), names(bootpars_i), nomatch=0)
pars[pidxs2!=0]<-bootpars_i[pidxs2]
pars=unlist(pars)
}

timepoints=seq(1,370*60,50)
initstates=states
initstates["FIV"]=10^-6
pars["starttime"]<-unclass(as.POSIXct(strptime(date(),"%c")))[1]



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

eventdata<-data.frame(var="FIV",time=eventtimes,value=eventdose,method="add")
		

timepoints<-sort(unique(c(timepoints, cleanEventTimes(eventdata$time, timepoints))))
		

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

print("ploting Fentanyl Only...")
#
colorPalette = gg_color_hue(3)

label_df_F<-data.frame(xL=c(125,185),
		yL=c(1.25,1),
		text=c("75ug_Fen","150ug_Fen"))

p4<-ggplot()



p4<-p4+geom_point(data=vent_Fr,aes(x=time/60, y = MR,color="b"),size=3,shape=15)
p4<-p4+geom_line(data=out_plot_paper, aes(x=time/60, y=Efr,color="a"), size=1)
p4<-p4+scale_color_manual(name = "Data",values=c(a=colorPalette[1], b=colorPalette[3], c=colorPalette[2], d=colorPalette[4]),labels = c("Simulated", "Clinical"))
p4<-p4+geom_errorbar(data=vent_Fr,aes(x=time/60,ymin=LR, ymax=HR), width=.005,position=position_dodge(0),col=colorPalette[3])
p4<-p4+geom_ribbon(data=IEfr, aes(x=time/60, ymin=qmin,ymax=qmax ,alpha=0.1),show.legend=FALSE)
p4<-p4+ylab(paste0("Fractional Ventilation"))+xlab(paste0("time(min)"))+theme(legend.position = "none") 
p4<-p4+theme_light() + xlim(100,250)
p4<-p4+scale_x_continuous(limits=c(90,250),breaks = seq(0, 240, by = 60))+theme(axis.text=element_text(size=16),axis.title=element_text(size=18))
p4<-p4+ylab("Ventilation (% of baseline)") +
		xlab("Time (minutes)") +
		theme_bw() +
		theme(legend.direction = "vertical",
				legend.position = c(0.8, 0.8),
				legend.background=element_rect(fill = alpha("white", 0)),
				# Hide panel borders and remove grid lines
				panel.border = element_blank(),
				panel.grid.major = element_blank(),
				panel.grid.minor = element_blank(),
				# Change axis line
				axis.line = element_line(colour = "black")) +  ggtitle("Naive Users Fentanyl")
p4<-p4+geom_segment(aes(x=120,y=1.3, xend = 120, yend=1.05),size=1,arrow=arrow(length=unit(.5,"cm")),col="black")
p4<-p4+geom_segment(aes(x=180,y=1.05, xend = 180, yend=.8),size=1,arrow=arrow(length=unit(.5,"cm")),col="black")
p4<-p4+geom_text(data=label_df_F, aes(x=xL,y=yL,label=text),color="black",hjust=0)


out_All_N<-c()
for (ip in 0:2000) {
	print(ip)
	
	if(ip==0) {pars=unlist(pars)}else{
		bootpars_i=bootpars[ip,]
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

	eventdata1<-data.frame(var="FIV",time=eventtimes,value=eventdose,method="add")
	
	eventdataN<-data.frame(var="D",time=c(150*60,210*60,270*60,330*60),value=c(4E6,4E6,4E6,4E6),method="add")
	
	eventdata<-rbind(eventdata1,eventdataN)
	timepoints<-sort(unique(c(timepoints, cleanEventTimes(eventdata$time, timepoints))))
	
	
	try({out0 <- ode(initstates, timepoints, "derivs", pars, dllname=modelname,initfunc="initmod",rtol=1e-3,atol=1e-6,method="lsoda",events=list(data=eventdata))});		
	out=data.frame(out0)
	
	out$Efr=(G0 - Gmax*(out$CAR)^P1)*(V0/G0 - Bmax*(out$CAR)^P2)/V0
	
	out_All_N=rbind(out_All_N,out)
	if (ip==0) {out_plot_paper2=as.data.frame(out)}
	
	
}

Efr2=c()
for (ti1 in timepoints) {
	tout_plot1=out_All_N[out_All_N[,1]==ti1,]
	tq=(lapply(tout_plot1,quantile,probs=c(0.025,.975))) # CI 95% of 2000 samples 
	
	Efr2=rbind(Efr2,c(ti1,tq$Efr))
	
	
}
colnames(Efr2)=c("time","qmin","qmax")


IEfr2=data.frame(Efr2)

vent_Fr=vent_Fr[vent_Fr$time<=250*60,]
IEfr2=IEfr2[IEfr2$time<=240*60,]
out_plot_paper2=out_plot_paper2[out_plot_paper2$time<=240*60,]


str(IEfr2)

print("ploting Fentanyl Plus Naloxone...")

colorPalette = gg_color_hue(3)

p5<-ggplot()



label_df<-data.frame(xL=c(155,215),
					yL=c(.1,.1),
					text=c("4mg_Nal","4mg_Nal"))

p5<-p5+geom_line(data=out_plot_paper2, aes(x=time/60, y=Efr,color="a"), size=0.85, alpha=0.8)
p5<-p5+scale_color_manual(name = "Simulated Data",values=c(a=colorPalette[1], b=colorPalette[3], c=colorPalette[2], d=colorPalette[4]),labels = c("Fentanyl+Naloxone", "Clinical"))
p5<-p5+geom_ribbon(data=IEfr2, aes(x=time/60, ymin=qmin,ymax=qmax ,alpha=0.1),show.legend=FALSE)
p5<-p5+xlab(paste0("time(min)"))+theme(legend.position = "none") 
p5<-p5+theme_light() + xlim(100,250)
p5<-p5+scale_x_continuous(limits=c(90,250),breaks = seq(0, 240, by = 60))+theme(axis.text=element_text(size=16),axis.title=element_text(size=18))
p5<-p5+scale_y_continuous(limits=c(-.1,1.5))
p5<-p5+xlab("Time (minutes)") +
		theme_bw() +
		theme(axis.title.y=element_blank())+
		theme(legend.direction = "vertical",
				legend.position = c(0.8, 0.8),
				legend.background=element_rect(fill = alpha("white", 0)),
				# Hide panel borders and remove grid lines
				panel.border = element_blank(),
				panel.grid.major = element_blank(),
				panel.grid.minor = element_blank(),
				# Change axis line
				axis.line = element_line(colour = "black")) + ggtitle("Naive Users Fentanyl + Naloxone")		
p5<-p5+geom_segment(aes(x=150,y=0, xend = 150, yend=.3),size=1,arrow=arrow(length=unit(.5,"cm")),col="black")
p5<-p5+geom_segment(aes(x=210,y=0, xend = 210, yend=.3),size=1,arrow=arrow(length=unit(.5,"cm")),col="black")
p5<-p5+geom_text(data=label_df, aes(x=xL,y=yL,label=text),color="black",hjust=0)


plotlist1=list()
plotlist1[[1]] = p4
plotlist1[[2]] = p5

pall1<-grid.arrange(grobs=plotlist1,ncol=2)

ggsave(paste0("figs/",patien_case,"IFV_Fentanyl_Naloxone_Lab.pdf"),pall1,width=8,height=6)




