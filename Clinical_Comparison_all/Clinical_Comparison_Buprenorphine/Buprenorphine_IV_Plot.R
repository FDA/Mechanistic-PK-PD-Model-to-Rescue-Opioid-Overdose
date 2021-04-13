 library(ggplot2)
drug ="Buprenorphine_IV"
Full.pat.all<-read.csv(paste0("results/FullpatallUFL.csv"))
outdf<-read.csv(paste0(drug,"/outdf2.csv"))

alpha_data0<-read.csv(paste0(drug,"/alpha_Max_Depression.csv"))
names(alpha_data0)<-"alpha"


#--- Clinical Ventilation Data in response to Buprenorphine and subsequent Naloxone IV
Buprenorphine_Breath0<-read.csv(paste0(drug,"/Buprenorphine_Naloxone.csv"),header=FALSE)
missedpoint<-read.csv(paste0(drug,"/missedpoints.csv"),header=FALSE)
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
