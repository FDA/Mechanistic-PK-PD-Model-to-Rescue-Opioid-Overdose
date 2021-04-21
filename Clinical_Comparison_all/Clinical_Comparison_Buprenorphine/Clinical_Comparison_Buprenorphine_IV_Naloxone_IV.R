proc_start<-proc.time()


drug<-"Buprenorphine_IV"
#--- load libraries
library(deSolve)
library(ggplot2)
library(FME)
print(sessionInfo())




isWindows<-Sys.info()[["sysname"]]=="Windows"
extension<-ifelse(isWindows, ".dll", ".so")
#--- process arguments

dyn.load(paste0("models/delaymymod.so"))
times<-seq(0,36000,100)


#---- Initial buprenorphine dose =.2mg
concvec<-.2

#---- Alpha distribution dictates degree of depression with increase in receptor occupancy

alpha_data0<-read.csv(paste0("Data/alpha_Max_Depression.csv"))

head(alpha_data0)
alphadata=unlist(as.vector(alpha_data0))


#----- Optim alpha value = .56
a=.56



#---- Read in optimal Parameters
parms<-source(paste0("Data/parms_B.R"))
parms<-parms[[1]]
parms<-unlist(parms)
parms["timeout"]<-60000
parms["starttime"]<-unclass(as.POSIXct(strptime(date(),"%c")))[1]



states<-source(paste0("models/delaystates.R"))
init<-states[[1]]
Sensitivity<-function(parms,init1,a=a,t){
	out=ode(init,times,
			"derivs",parms=parms,
			dllname="delaymymod",
			initfunc="initmod", nout=0, rtol=1e-3,
			atol=1e-6,events=list(data=eventdata))
	head(out)
	names(out)
	outdf=data.frame(out)
}
Occupancy<-data.frame()
Full.pat<-data.frame()

#-read in Buprenorphine and Naloxone Parameters

bootpars<-read.csv(paste0("Data/Buprenorphine_boot_pars.csv"))

#--- read in events for Naloxone administration

eventdata<-source(paste0("Events_Bup_Nal.R"))
eventdata<-as.data.frame(eventdata[[1]])

times<-sort(unique(c(times, cleanEventTimes(eventdata$time, times))))


for(conc in concvec){
init["PlasmaB"]<-conc
out=ode(init,times,
		"derivs",parms=parms,
		dllname="delaymymod",
		initfunc="initmod", nout=0, rtol=1e-12,
		atol=1e-12,events=list(data=eventdata))
outdf<-data.frame(out)
sR<-sensRange(Sensitivity,parms=parms,init1=init,t=times,sensvar="CAR",parInput=bootpars,num=nrow(bootpars))
summ.sR <-summary(sR)
nrow(summ.sR)
summ.sR[,"q02.5"]<-apply(sR[,(length(parms)-1):ncol(sR)], 2, FUN=function(x) quantile(x, probs = 0.025)) #x is the mapping value = times

summ.sR[,"q97.5"]<-apply(sR[,(length(parms)-1):ncol(sR)], 2, FUN=function(x) quantile(x, probs = 0.975))
lim<-range(times)
preddf<-as.data.frame(summ.sR[summ.sR[,"x"]>=lim[1] & summ.sR[,"x"]<=lim[2],])

head(preddf)
E0=100
Ventilation=E0*(1-a*max(outdf$CAR))
lower=E0*(1-a*max(preddf$q02.5))
upper=E0*(1-a*max(preddf$q97.5))
c_val<-conc/70*1000
Vent_full<-cbind(min(Ventilation),lower,upper,c_val)
Occupancy<-rbind(Occupancy,Vent_full)



allpatients<-cbind(bootpars,alpha_data0)
pats<-data.frame()
for(patientidx in 1:dim(allpatients)[1]){
	this.par<-unlist(allpatients[patientidx,]) #this is pars; states should have been loaded in each core
	
	truepar<-this.par[!names(this.par)=="alpha"]    #need to remove alpha from parameter
	truepar["timeout"]<-30
	
	#first simulating no naloxone
	
	truepar["starttime"]<-unclass(as.POSIXct(strptime(date(),"%c")))[1]
	out <- ode(y=init, times=times, "derivs", parms=truepar, dllname="delaymymod",initfunc="initmod", nout=0, rtol=1e-3, atol=1e-6, method="lsoda",events=list(data=eventdata))
	
	
	
	patientventi <- 1 - this.par["alpha"]*out[,"CAR"]
	pats<-rbind(pats,patientventi)
}
outdf2<-as.data.frame(out)


summ.pat<-summary(pats)

pat1<-apply(pats[,1:ncol(pats)],2,FUN=function(x) quantile(x,probs=.025))
pat2<-apply(pats[,1:ncol(pats)],2,FUN=function(x) quantile(x,probs=.25))
pat3<-apply(pats[,1:ncol(pats)],2,FUN=function(x) quantile(x,probs=.75))
pat4<-apply(pats[,1:ncol(pats)],2,FUN=function(x) quantile(x,probs=.975))
pat5<-apply(pats[,1:ncol(pats)],2,FUN=function(x) mean(x))
pat6<-apply(pats[,1:ncol(pats)],2,FUN=function(x) sd(x))
pat7<-apply(pats[,1:ncol(pats)],2,FUN=function(x) sd(x)/sqrt(2000))

sd<-pat6[which(pat5==min(pat5))]
se<-pat7[which(pat5==min(pat5))]
pat.interval<-cbind(min(Ventilation),min(pat1),min(pat2),min(pat3),min(pat4),min(pat5),sd,se)

head(pat.interval)
names(pat.interval)<-c("Vent","q0.025","q0.25","q0.75","q0.975","mean","sd","se")
Full.pat<-rbind(Full.pat,pat.interval)

Full.pat.all<-cbind(pat5,pat6)
Full.pat.all<-as.data.frame(Full.pat.all)
Full.pat.all$time<-outdf2$time
}
head(pat.interval)




#write.csv(outdf,file=paste0(drug,"/outdf2.csv"))
#write.csv(Occupancy,file=paste0(drug,"/OccupancyA222.csv"))
#write.csv(Full.pat,file=paste0(drug,"/Fullpats_SD2.csv"))
#write.csv(Full.pat.all,file=paste0(drug,"/Fullpatall2.csv"))





#--- Clinical Ventilation Data in response to Buprenorphine and subsequent Naloxone IV
Buprenorphine_Breath0<-read.csv(paste0("Data/Buprenorphine_Naloxone.csv"),header=FALSE)
missedpoint<-read.csv(paste0("Data/missedpoints.csv"),header=FALSE)
Buprenorphine_Breath1=rbind(Buprenorphine_Breath0,missedpoint)
colnames(Buprenorphine_Breath1)=c("Time","Res")
Buprenorphine_Breath1$Res<-Buprenorphine_Breath1$Res/Buprenorphine_Breath1$Res[1]*100

Buprenorphine_Breath2=Buprenorphine_Breath1

Buprenorphine_Breath2$Time=60*Buprenorphine_Breath2$Time


tR=range(Buprenorphine_Breath2$Time)
t_interval=400
t1=c(seq(tR[1]-5,8000,t_interval),seq(8000,tR[2],1000))


new1=vector()
for (i in t1) {
	
	REs_step=Buprenorphine_Breath2[i<=Buprenorphine_Breath2$Time & Buprenorphine_Breath2$Time<(i+t_interval),]
	if (0<length(REs_step$Time)) {
		new=cbind(rep(i,length(REs_step$Time)),REs_step)
		narow= quantile(new$Res, probs = c(0.25, 0.75), na.rm = FALSE, names = TRUE)
		print(narow)
		new1=rbind(new1,new)
		
	}
}






colnames(new1)=c("Steptime","Time","Res")
new1$V=new1$Res
rng3=vector()

for (r in unique(new1$Steptime)) {
	new2=new1[new1$Steptime==r,]
	
	
	rng1=range(new2$V)
	qt= quantile(new2$V, probs = c(0.025, 0.975), na.rm = FALSE, names = TRUE)
	sd=sd(new2$V)
	
	sdm=c(mean(new2$V)-sd,mean(new2$V)+sd)
	rng2=c(r,range(new2$V),qt,sdm)
	rng3=rbind(rng3,rng2)
	
	
	
}
colnames(rng3)=c("time","min","max","qL","qM","smin","smax")

rng3=data.frame(rng3,stringsAsFactors = FALSE)



#--- Plot Respiratory Depression as a function of Mu receptors bound by Buprenorphine

Buprenorphine_Breath=Buprenorphine_Breath1
names(Buprenorphine_Breath)=c("time","Ventilation")
Buprenorphine_Breath$time<-Buprenorphine_Breath$time*60
Buprenorphine_Breath$Ventilation<-Buprenorphine_Breath$Ventilation/Buprenorphine_Breath[1,"Ventilation"]*100

E0=100
#a=.56
r_e<-ggplot(data=outdf, aes(x=time/60,y=E0*(1-a*CAR)))+geom_point(size=1,color="lightblue")

r_e<-r_e+geom_ribbon(data=Full.pat.all,aes(x=time/60,ymin=pat5*100-pat6*100,ymax=pat5*100+pat6*100),fill="grey",inherit.aes=FALSE,alpha=.5)

r_e<-r_e+geom_line(data=outdf,aes(x=time/60,y=E0*(1-a*CAR)),color="red",alpha=.75,size=1.3)

r_e<-r_e+geom_errorbar(data=rng3,aes(x=time/60,ymin=smin,ymax=smax),color="black", inherit.aes=FALSE)

r_e<-r_e+scale_y_continuous(limits=c(0,150))
r_e<-r_e+scale_x_continuous(breaks=c(0,12000/60,24000/60,36000/60))
r_e<-r_e+theme_light()
r_e<-r_e+labs(x="Time (minutes)",y="Respiration (% Initial)",title=paste0("Buprenorphine .2 (mg)"))
r_e<-r_e+theme(plot.title = element_text(hjust=0.5,face="bold",color="black"))
r_e<-r_e+theme(text = element_text(size=18),axis.title.x=element_text(size=16,face="bold"),axis.title.y=element_text(size=16,face="bold"))
r_e<-r_e+theme(plot.title=element_text(hjust=0,color="black",face="bold"),
		panel.border=element_blank(),axis.line = element_line(colour = "black"),legend.position=c(.75,.75),
		text =element_text(face="bold"))
r_e<-r_e+geom_segment(aes(x = 1800/60, y = 20, xend = 7300/60, yend = 20),size=3)
r_e<-r_e+ geom_text(x=1800/60, y=10, label="Naloxone",hjust=0)
r_e<-r_e+geom_segment(aes(x=5000/60,y=125, xend =0, yend=100),size=1,arrow=arrow(length=unit(.5,"cm")),col="black")
r_e<-r_e+geom_text(x=5000/60,y=130,label="Buprenorphine")



ggsave(paste0("figs/Buprenorphine_IV_Naloxone_IV_Full_timepoints.pdf"),r_e)

