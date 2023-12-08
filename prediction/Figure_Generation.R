
#---- Script to Combine original/mechanistic predictions to produce Figure 3 and 4
#---- John Mann


times<-c(seq(0,300,1),seq(305,3600,5))


# Read in necessary data
All_real<-read.csv("data/real_data.csv") #Time course outputs from mechanistic simulations
All_orig<-read.csv("data/original_pred_data_2.csv") # Time course outputs from standard deep learning model
All_mech<-read.csv("data/mechanistic_pred_data_a.csv") # Time course outputs from mechanistically-inspired deep learning model



mech_loss<-read.table("../training/save_j1/lossmech.txt") #Error values mech deep learning

orig_loss<-read.table("../training/save_j1/lossorig.txt") # Error values standard deep learning

times_1<-seq(1,88,1)/88*48 # Mech model completes 88 runs in 48hrs
times_2<-seq(1,192,1)/192*48 # Standard model completes 192 runs in 48 hrs  Assuming similar run time for each epoch
times_11<-seq(1,88,1)


#----- Generate Publication Figures: 
mech_g<-data.frame(cbind(times_1,mech_loss[1:length(times_1),1]))
orig_g<-data.frame(cbind(times_2,orig_loss[1:length(times_2),1]))
names(mech_g)<-names(orig_g)<-c("times","Training_error")
mech_g$model<-"Mechanistic"
orig_g$model<-"Traditional"
library(ggplot2)
p1<-ggplot(data=mech_g,aes(x=times,y=Training_error,color=model))+geom_point()+
		geom_point(data=orig_g,aes(x=times,y=Training_error,color=model))+
		theme_bw()+
		ggtitle("A  Equal Time")+
		xlab("Time (hrs)")+
		ylab("")+
		scale_x_continuous(breaks=seq(0,48,12),limits=c(0,50))+
		scale_y_continuous(breaks=seq(0,20,10),limits=c(0,25))+
		labs(color = "Model Type")+
		theme(legend.position=c(.75,.75))

ggsave("Results/Manuscript_training_time.pdf",p1)
times_11<-seq(1,88,1)
mech_g<-data.frame(cbind(times_11,mech_loss[1:length(times_11),1]))
orig_g<-data.frame(cbind(times_11,orig_loss[1:length(times_11),1]))
names(mech_g)<-names(orig_g)<-c("times","Training_error")
mech_g$model<-"Mechanistic"
orig_g$model<-"Traditional"
library(ggplot2)
p2<-ggplot(data=mech_g,aes(x=times,y=Training_error,color=model))+geom_point()+
		geom_point(data=orig_g,aes(x=times,y=Training_error,color=model))+
		theme_bw()+
		ggtitle("B   Equal Epochs")+
		xlab("Epochs")+
		ylab("")+
		scale_x_continuous(breaks=seq(0,90,30),limits=c(0,95))+
		scale_y_continuous(breaks=seq(0,20,10),limits=c(0,25))+
		#labs(color = "Model Type")+
		theme(legend.position="none")

ggsave("Results/Manuscript_training_epochs.pdf",p2)

library(gridExtra)
library(grid)
GA<-grid.arrange(p1,p2, ncol=1,nrow=2, 
		top="Figure 3 Mechanistic Vs Traditional AI Error Comparison ",
		left="Training Error")


ggsave("Results/Combine_grid.pdf",GA,height=6,width=10)




All_real<-read.csv("data/real_data.csv")
All_orig<-read.csv("data/original_pred_data_2.csv")
All_mech<-read.csv("data/mechanistic_pred_data_a.csv")




All_real$times<-times
All_mech$times<-times
All_orig$times<-times

p1<-ggplot()

RMSE<-c()
RMSE$tradm<-(All_orig$medianpred-All_real$medianreal)^2
RMSE$mechm<-(All_mech$medianpred-All_real$medianreal)^2
RMSE$tradl<-(All_orig$lowerpred-All_real$lowerreal)^2
RMSE$mechl<-(All_mech$lowerpred-All_real$lowerreal)^2
RMSE$tradu<-(All_orig$upperpred-All_real$upperreal)^2
RMSE$mechu<-(All_mech$upperpred-All_real$upperreal)^2
x<-sqrt(sum(RMSE$tradm))
y<-sqrt(sum(RMSE$mechm))
x1<-sqrt(sum(RMSE$tradl))
y1<-sqrt(sum(RMSE$mechl))
x2<-sqrt(sum(RMSE$tradu))
y2<-sqrt(sum(RMSE$mechu))
df<-data.frame(model=rep(c("Black Box","Semi-mechanistic"), each=3),
		Metric=rep(c("2.5%","Median","97.5%"),2),
		Error=c(x1,x,x2,y1,y,y2))
p22<-ggplot(data=df,aes(x=Metric,y=Error,fill=model))+
		geom_bar(stat="identity",position=position_dodge())+
		theme_bw()+
		xlab("Percentile")+
		ylab("RMSE")+
		ggtitle("C  Predictive Error Against Simulated Results")+theme(panel.grid.major=element_blank(),panel.grid.minor=element_blank())


All_real$model<-"Simulated Results"
All_mech$model<-"Semi-mechanistic"
All_orig$model<-"Black Box"

p32<-ggplot(data=All_real,aes(x=times,y=1-medianreal,col=model))+geom_line()+
		geom_line(data=All_real,aes(x=times,y=1-lowerreal,col=model),linetype="dashed")+
		geom_line(data=All_real,aes(x=times,y=1-upperreal,col=model),linetype="dashed")+
		geom_line(data=All_orig,aes(x=times,y=1-medianpred,col=model))+
		geom_line(data=All_orig,aes(x=times,y=1-lowerpred,col=model),linetype="dashed")+
		geom_line(data=All_orig,aes(x=times,y=1-upperpred,col=model),linetype="dashed")+
		geom_line(data=All_mech,aes(x=times,y=1-medianpred,col=model))+
		geom_line(data=All_mech,aes(x=times,y=1-lowerpred,col=model),linetype="dashed")+
		geom_line(data=All_mech,aes(x=times,y=1-upperpred,col=model),linetype="dashed")+
		theme_bw()+theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())+
		xlab("Time (s)")+ ylab("Fractional Minute Ventilation")+
		ggtitle("A  Ventilation Prediction Comparison")+labs(color=NULL)+
		theme(legend.position="topright")
library(grid)
library(gridExtra)


GA2<-grid.arrange(p32,p22, ncol=2, 
		top="Figure 4 Prediction Comparison Mechanistic vs Traditional AI"
)#	left="Training Error")

#--- Change color scheme
cols <- c("Black Box" = "red", "Semi-mechanistic" = "blue", "Simulated Results" = "black")

p33<-ggplot(data=All_real,aes(x=times/60,y=1-medianreal,col=model),col="black")+geom_line()+
		geom_line(data=All_real,aes(x=times/60,y=1-lowerreal,col=model),linetype="dashed")+
		geom_line(data=All_real,aes(x=times/60,y=1-upperreal,col=model),linetype="dashed")+
		#geom_line(data=All_orig,aes(x=times,y=1-medianpred,col=model))+
		#geom_line(data=All_orig,aes(x=times,y=1-lowerpred,col=model),linetype="dashed")+
		#geom_line(data=All_orig,aes(x=times,y=1-upperpred,col=model),linetype="dashed")+
		geom_line(data=All_mech,aes(x=times/60,y=1-medianpred,col=model))+
		geom_line(data=All_mech,aes(x=times/60,y=1-lowerpred,col=model),linetype="dashed")+
		geom_line(data=All_mech,aes(x=times/60,y=1-upperpred,col=model),linetype="dashed")+
		theme_bw()+theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())+
		xlab("Time (minutes)")+ ylab("Fractional Minute Ventilation")+
		scale_x_continuous(breaks=seq(0,60,10),limits=c(0,62))+
		ggtitle("A  Semi-Mechanistic AI vs Simulated Results")+#labs(color=NULL)
		theme(legend.position=c(.75,.75),
				title =element_text(size=15, face='bold'),
				axis.text.x = element_text(face="bold",color = "grey20", size = 12),
				axis.text.y = element_text(face="bold",color = "grey20", size = 12),  
				axis.title.x = element_text(face="bold",color = "grey20", size = 15),
				axis.title.y = element_text(face="bold",color = "grey20", size = 15),
				legend.text=element_text(size=14))+
		scale_colour_manual(name=c(),values = cols)

	
p34<-ggplot(data=All_orig,aes(x=times/60,y=1-medianpred,col=model))+geom_line()+
		geom_line(data=All_orig,aes(x=times/60,y=1-lowerpred,col=model),linetype="dashed")+
		geom_line(data=All_orig,aes(x=times/60,y=1-upperpred,col=model),linetype="dashed")+
		geom_line(data=All_real,aes(x=times/60,y=1-medianreal,col=model))+
		geom_line(data=All_real,aes(x=times/60,y=1-lowerreal,col=model),linetype="dashed")+
		geom_line(data=All_real,aes(x=times/60,y=1-upperreal,col=model),linetype="dashed")+
		#geom_line(data=All_mech,aes(x=times,y=1-medianpred),col="blue")+
		#geom_line(data=All_mech,aes(x=times,y=1-lowerpred),col="blue",linetype="dashed")+
		#geom_line(data=All_mech,aes(x=times,y=1-upperpred),col="blue",linetype="dashed")+
		theme_bw()+theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())+
		scale_x_continuous(breaks=seq(0,60,10),limits=c(0,62))+
		xlab("Time (minutes)")+ ylab("")+
		ggtitle("B  Black Box AI vs Simulated Results")+#labs(color=NULL)+
	#	theme(legend.position=c(.75,.75))+
		#scale_color_manual("", values = c( "Black Box"= "red", "Semi-mechanistic" = "blue","Simulated Results"="black"))+
		theme(legend.position=c(.75,.75),
				title=element_text(size=15, face='bold'),
				axis.text.x = element_text(face="bold",color = "grey20", size = 12),
				axis.text.y = element_text(face="bold",color = "grey20", size = 12),  
				axis.title.x = element_text(face="bold",color = "grey20", size = 15),
				axis.title.y = element_text(face="bold",color = "grey20", size = 15),
				legend.text=element_text(size=14))+
		#scale_color_discrete(name=c("Black Box AI","Semi-mechanistic AI","Simulated Results"), values = c("red","blue","black"))
	scale_colour_manual(name=c(),values = cols)

	#	theme(legend.position="none")

library(grid)
library(gridExtra)

p22<-ggplot(data=df,aes(x=Metric,y=Error,fill=model))+
		geom_bar(stat="identity",position=position_dodge())+
		theme_bw()+
		xlab("Percentile")+
		ylab("RMSE")+
		ggtitle("C  Predictive Error Against Simulated Results")+theme(panel.grid.major=element_blank(),panel.grid.minor=element_blank())+
		theme( title =element_text(size=15, face='bold'),
				axis.text.x = element_text(face="bold",color = "grey20", size = 12),
				axis.text.y = element_text(face="bold",color = "grey20", size = 12),  
				axis.title.x = element_text(face="bold",color = "grey20", size = 15),
				axis.title.y = element_text(face="bold",color = "grey20", size = 15)
				)
#+
	#	scale_fill_manual("Legend", values = c( "Black Box AI"= "red", "Semi-mechanistic AI" = "blue"))

GA3<-grid.arrange(p33,p34,p22+theme(legend.position="topright"), ncol=2, 
		top="Figure 4 Prediction Comparison Mechanistic vs Traditional AI"
)#	left="Training Error")

ggsave("Results/Manuscript_Prediction_Plus_RMSE.pdf",GA3,height=10,width=12)


p22<-p22+
theme(legend.position=c(.75,.75),
		axis.text.x = element_text(face="bold",color = "grey20", size = 20),
		axis.text.y = element_text(face="bold",color = "grey20", size = 20),  
		axis.title.x = element_text(face="bold",color = "grey20", size = 30),
		axis.title.y = element_text(face="bold",color = "grey20", size = 30),
		legend.text=element_text(size=18))+
theme(legend.title=element_blank())

ggsave("Results/RMSE_alone3.pdf",p22)


