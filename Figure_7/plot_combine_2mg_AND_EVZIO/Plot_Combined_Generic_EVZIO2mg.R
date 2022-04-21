#File 		Plot_Combined_Generic_EVZIO2mg.R
#Author		John Mann
#Date 		April 2022
#Description	 Script to reproduce Figure 7 of Manuscript # 2022-329


mainfol="../population_outputs_2mg_40tsh_delays/CA_IM" #Location of Cardiac Arrest occurence data




system(paste0("mkdir -p ","results"))

mainfol2="../outputs/results"


#----- Dose conditions of interest
alllfolders<-c(
		"1.625_ligand_fentanyl_patient_chronic",
		"2.965_ligand_fentanyl_patient_chronic",
		"0.012_ligand_carfentanil_patient_chronic",
				"0.02187_ligand_carfentanil_patient_chronic")	
		

dose=c(rep(c(	"fentanyl_1.625","fentanyl_2.965",
						"carfentanil_0.012","carfentanil_0.02187"),each=1))
delay=c(rep(c(60),4))



library(ggplot2)
library(gridExtra)
i=0
p<-p2<-p3<-p4<-p5<-p6<-p7<-p8<-list()
All_doses<-c()
for (fo in alllfolders) {
	data2mg=dataEvzio2mg=c()
	i=i+1
	print("2mg")
	data2mg=read.csv(sprintf("%s/All_CADo1PKReview_naloxone_formulation_Generic_conc_%s.csv",mainfol,fo)) # CA Population Data
	Generic_1d=read.csv(sprintf("%s/Im_plot_Generic/%s_ypred1.csv",mainfol2,dose[i])) # Optimal Patient Physiology data No naloxone
	Generic_2d=read.csv(sprintf("%s/Im_plot_Generic/%s_ypred2.csv",mainfol2,dose[i])) # Optimal Patient Physiology data	One dose naloxone	
	
	data2mg$Ndose=c("No naloxone", "2mg/2ml")
	
	
	print("EVZIO")
	
	dataEvzio2mg=read.csv(sprintf("%s/All_CADo1PKReview_naloxone_formulation_EVZIO_conc_%s.csv",mainfol,fo)) # CA Population Data
	EVZIO_1d=read.csv(sprintf("%s/Im_plot_EVZIO/%s_ypred1.csv",mainfol2,dose[i])) #Optimal Patient Physiology data No naloxone
	EVZIO_2d=read.csv(sprintf("%s/Im_plot_EVZIO/%s_ypred2.csv",mainfol2,dose[i])) #Optimal Patient Physiology data One dose naloxone
	dataEvzio2mg$Ndose=c("No naloxone", "2mg/0.4ml")
	
	names(Generic_1d)<-c("x","time","Vent","O2","Blood","PaCO2","PBO2","PlasmaN","CBF") 
	names(Generic_2d)<-names(Generic_1d)
	names(EVZIO_1d)<-names(Generic_1d)
	names(EVZIO_2d)<-names(Generic_1d)
	data2mg$type="b"
	dataEvzio2mg$type="c"
	
	Generic_1d$type="a"
	Generic_2d$type="b"
	
	EVZIO_1d$type="c"
	EVZIO_2d$type="c"
	
	Generic_1d$Ndose="No naloxone"
	Generic_2d$Ndose="2mg/2ml"
	
	EVZIO_1d$Ndose="No naloxone"
	EVZIO_2d$Ndose="2mg/0.4ml"
	
	CABloodFlow<-1e-2 # Lower limit of blood flow for considering CA occurence.

	timeIndexUL_G1<-which(Generic_1d[,"time"]==max(Generic_1d[,"time"]))		
	timeIndexUL_G2=timeIndexUL_E2=timeIndexUL_G1
	
	
	#------- Cut off time course data if Cardiac Arrest occurs
	
	if (min(Generic_1d$Blood)<=CABloodFlow){
		timeIndexULL_G1<-min(which(Generic_1d[,"Blood"]<=CABloodFlow))
		timeIndexUL_G1<-which(abs(Generic_1d[,"time"]-(Generic_1d[timeIndexULL_G1,"time"]))==
						min(abs(Generic_1d[,"time"]-(Generic_1d[timeIndexULL_G1,"time"]))))}

	
	
if (min(Generic_2d$Blood)<=CABloodFlow){
	timeIndexULL_G2<-min(which(Generic_2d[,"Blood"]<=CABloodFlow))
	timeIndexUL_G2<-which(abs(Generic_2d[,"time"]-(Generic_2d[timeIndexULL_G2,"time"]))==
					min(abs(Generic_2d[,"time"]-(Generic_2d[timeIndexULL_G2,"time"]))))}


if (min(EVZIO_2d$Blood)<=CABloodFlow){
	timeIndexULL_E2<-min(which(EVZIO_2d[,"Blood"]<=CABloodFlow))
	timeIndexUL_E2<-which(abs(EVZIO_2d[,"time"]-(EVZIO_2d[timeIndexULL_E2,"time"]))==
					min(abs(EVZIO_2d[,"time"]-(EVZIO_2d[timeIndexULL_E2,"time"]))))}



	All_time<-rbind(Generic_1d,Generic_2d,EVZIO_2d) # 0 dose naloxone is same for Generic + EVZIO
	
	A_data2mg<-data2mg[data2mg$Ndose %in% c("No naloxone","2mg/2ml"),]
	A_data2mg$type[A_data2mg$Ndose=="No naloxone"]<-"a"
	A_dataEvzio2mg<-dataEvzio2mg[dataEvzio2mg$Ndose %in% c("2mg/0.4ml"),] # Only need 1 0 dose bar 
	
	both=rbind(A_data2mg,A_dataEvzio2mg)
	both$dose<-dose[i]
	both$delay<-delay[i]
	All_doses<-rbind(All_doses,both)

	gg_color_hue <- function(n) {
		hues = seq(15, 375, length = n + 1)
		hcl(h = hues, l = 65, c = 100)[1:n]
	}
	colorPalette = gg_color_hue(3)
	both$Ndose <- factor(both$Ndose, levels = c("No naloxone","2mg/2ml","2mg/0.4ml"))
	print(unique(both$type))
	
	#----- Create Population Cardiac Arrest Figures
	
	p[[i]]<-ggplot(both,aes(x = as.factor(Ndose),y = 100-rowYesCA,fill = type)) +
	geom_bar(stat = "identity",
	position = "dodge")+ylim(0, 100)+xlab("") + ylab("")+
	ggtitle("") +theme_bw()+
	geom_errorbar(aes(ymin=100-emin,ymax=100-emax),width=.5)+#+
			scale_fill_manual(name = "Naloxone Dose",values=c(a=colorPalette[1], 
						b=colorPalette[2], c=colorPalette[3]), labels = c("No naloxone","IM 2 mg/2 mL", "IM 2 mg/0.4 mL")) +
		
		theme(legend.position = "none",axis.text = element_text(size = 8))
	ggsave(sprintf("results/CA_individual_%s.png",fo), p[[i]], width = 6, height = 4.5) 
	

	#------ Single Patient Ventilation Figures

p2[[i]]<-ggplot(All_time,aes(x=time/60,y=Vent,color=type)) +
			geom_line(data=Generic_1d[1:timeIndexUL_G1,],aes(x=time/60,
							y= Vent))+
			geom_line(data=Generic_2d[1:timeIndexUL_G2,],aes(x=time/60,
							y= Vent))+
			geom_line(data=EVZIO_2d[1:timeIndexUL_E2,],aes(x=time/60,
							y= Vent))+
			geom_point(data=Generic_1d[timeIndexUL_G1[1],],aes(x=time/60,
							y= Vent),shape=4, color="red",size=5) +
			geom_point(data=Generic_2d[timeIndexUL_G2[1],],aes(x=time/60,
							y= Vent),shape=4, color="red",size=5) +
			geom_point(data=EVZIO_2d[timeIndexUL_E2[1],],aes(x=time/60,
							y= Vent),shape=4, color="red",size=5) +
			scale_color_manual(name = "",values=c(a=colorPalette[1], 
							b=colorPalette[2], c=colorPalette[3]), labels = c("No naloxone","IM 2 mg/2 mL", "IM 2 mg/0.4 mL")) +
			theme_bw()+xlab("") +
			theme(legend.position="none")+xlim(0, 15)
	ggsave(sprintf("results/plot_Ventilation_Individual_%s.png",fo), p2[[i]], width = 6, height = 4.5) 
#	
	print("p2")
	
	#----- Single Patient Arterial Oxygen Figures 
	
	p3[[i]]<-ggplot(All_time,aes(x=time/60,y=O2,color=type)) +
			geom_line(data=Generic_1d[1:timeIndexUL_G1,],aes(x=time/60,
							y= O2))+
			geom_line(data=Generic_2d[1:timeIndexUL_G2,],aes(x=time/60,
							y= O2))+
			geom_line(data=EVZIO_2d[1:timeIndexUL_E2,],aes(x=time/60,
							y= O2))+
			geom_point(data=Generic_1d[timeIndexUL_G1[1],],aes(x=time/60,
							y= O2),shape=4, color="red",size=5) +
		geom_point(data=Generic_2d[timeIndexUL_G2[1],],aes(x=time/60,
						y= O2),shape=4, color="red",size=5) +
		geom_point(data=EVZIO_2d[timeIndexUL_E2[1],],aes(x=time/60,
						y= O2),shape=4, color="red",size=5) +
		scale_color_manual(name = "",values=c(a=colorPalette[1], 
						b=colorPalette[2], c=colorPalette[3]), labels = c("No naloxone","IM 2 mg/2 mL", "IM 2 mg/0.4 mL")) +
		theme_bw()+xlab("") +
			theme(legend.position="none")+xlim(0, 15)
	ggsave(sprintf("results/plot_O2_Individual_%s.png",fo), p3[[i]], width = 6, height = 4.5) 
	
	print("p3")
	
	#------ Single Patient Total Blood Flow Figures


	p4[[i]]<-ggplot(All_time,aes(x=time/60,y=Blood,color=type)) +
			geom_line(data=Generic_1d[1:timeIndexUL_G1,],aes(x=time/60,
							y= Blood))+
			geom_line(data=Generic_2d[1:timeIndexUL_G2,],aes(x=time/60,
							y= Blood))+
			geom_line(data=EVZIO_2d[1:timeIndexUL_E2,],aes(x=time/60,
							y= Blood))+
			geom_point(data=Generic_1d[timeIndexUL_G1[1],],aes(x=time/60,
							y= Blood),shape=4, color="red",size=5) +
			geom_point(data=Generic_2d[timeIndexUL_G2[1],],aes(x=time/60,
							y= Blood),shape=4, color="red",size=5) +
			geom_point(data=EVZIO_2d[timeIndexUL_E2[1],],aes(x=time/60,
							y= Blood),shape=4, color="red",size=5) +
			scale_color_manual(name = "",values=c(a=colorPalette[1], 
							b=colorPalette[2], c=colorPalette[3]), labels = c("No naloxone","IM 2 mg/2 mL", "IM 2 mg/0.4 mL")) +
			theme_bw()+xlab("") +
			theme(legend.position="none")+xlim(0, 15)





print("p4")

	ggsave(sprintf("results/plot_Blood_Individual_%s.png",fo), p4[[i]], width = 6, height = 4.5) 

	
	#------ Single Patient Naloxone Plasma Concentration Figures 
p5[[i]]<-ggplot(All_time,aes(x=time/60,y=PlasmaN,color=type)) +
geom_line(data=Generic_1d[1:timeIndexUL_G1,],aes(x=time/60,
						y= PlasmaN))+
		geom_line(data=Generic_2d[1:timeIndexUL_G2,],aes(x=time/60,
						y= PlasmaN))+
		geom_line(data=EVZIO_2d[1:timeIndexUL_E2,],aes(x=time/60,
						y= PlasmaN))+
		geom_point(data=Generic_1d[timeIndexUL_G1[1],],aes(x=time/60,
						y= PlasmaN),shape=4, color="red",size=5) +
		geom_point(data=Generic_2d[timeIndexUL_G2[1],],aes(x=time/60,
						y= PlasmaN),shape=4, color="red",size=5) +
		geom_point(data=EVZIO_2d[timeIndexUL_E2[1],],aes(x=time/60,
						y= PlasmaN),shape=4, color="red",size=5) +
		scale_color_manual(name = "",values=c(a=colorPalette[1], 
						b=colorPalette[2], c=colorPalette[3]), labels = c("No naloxone","IM 2 mg/2 mL", "IM 2 mg/0.4 mL")) +
		theme_bw()+xlab("") +
		theme(legend.position="none")+xlim(0, 15)
	

#----- Single Patient Arterial CO2 Figures 

p6[[i]]<-ggplot(All_time,aes(x=time/60,y=PaCO2,color=type)) +
		geom_line(data=Generic_1d[1:timeIndexUL_G1,],aes(x=time/60,
						y= PaCO2))+
		geom_line(data=Generic_2d[1:timeIndexUL_G2,],aes(x=time/60,
						y= PaCO2))+
		geom_line(data=EVZIO_2d[1:timeIndexUL_E2,],aes(x=time/60,
						y= PaCO2))+
		geom_point(data=Generic_1d[timeIndexUL_G1[1],],aes(x=time/60,
						y= PaCO2),shape=4, color="red",size=5) +
		geom_point(data=Generic_2d[timeIndexUL_G2[1],],aes(x=time/60,
						y= PaCO2),shape=4, color="red",size=5) +
		geom_point(data=EVZIO_2d[timeIndexUL_E2[1],],aes(x=time/60,
						y= PaCO2),shape=4, color="red",size=5) +
		scale_color_manual(name = "",values=c(a=colorPalette[1], 
						b=colorPalette[2], c=colorPalette[3]), labels = c("No naloxone","IM 2 mg/2 mL", "IM 2 mg/0.4 mL")) +
		theme_bw()+xlab("") +
		theme(legend.position="none")+xlim(0, 15)

#----- Single Patient Cerebral Blood Flow Figures

p7[[i]]<-ggplot(All_time,aes(x=time/60,y=CBF,color=type)) +
		geom_line(data=Generic_1d[1:timeIndexUL_G1,],aes(x=time/60,
						y= CBF))+
		geom_line(data=Generic_2d[1:timeIndexUL_G2,],aes(x=time/60,
						y= CBF))+
		geom_line(data=EVZIO_2d[1:timeIndexUL_E2,],aes(x=time/60,
						y= CBF))+
		geom_point(data=Generic_1d[timeIndexUL_G1[1],],aes(x=time/60,
						y= CBF),shape=4, color="red",size=5) +
		geom_point(data=Generic_2d[timeIndexUL_G2[1],],aes(x=time/60,
						y= CBF),shape=4, color="red",size=5) +
		geom_point(data=EVZIO_2d[timeIndexUL_E2[1],],aes(x=time/60,
						y= CBF),shape=4, color="red",size=5) +
		scale_color_manual(name = "",values=c(a=colorPalette[1], 
						b=colorPalette[2], c=colorPalette[3]), labels = c("No naloxone","IM 2 mg/2 mL", "IM 2 mg/0.4 mL")) +
		theme_bw()+xlab("") +
		theme(legend.position="none")+xlim(0, 15)

p8[[i]]<-ggplot(All_time,aes(x=time/60,y=PBO2,color=type)) +
		geom_line(data=Generic_1d[1:timeIndexUL_G1,],aes(x=time/60,
						y= PBO2))+
		geom_line(data=Generic_2d[1:timeIndexUL_G2,],aes(x=time/60,
						y= PBO2))+
		geom_line(data=EVZIO_2d[1:timeIndexUL_E2,],aes(x=time/60,
						y= PBO2))+
		geom_point(data=Generic_1d[timeIndexUL_G1[1],],aes(x=time/60,
						y= PBO2),shape=4, color="red",size=5) +
		geom_point(data=Generic_2d[timeIndexUL_G2[1],],aes(x=time/60,
						y= PBO2),shape=4, color="red",size=5) +
		geom_point(data=EVZIO_2d[timeIndexUL_E2[1],],aes(x=time/60,
						y= PBO2),shape=4, color="red",size=5) +
		scale_color_manual(name = "",values=c(a=colorPalette[1], 
						b=colorPalette[2], c=colorPalette[3]), labels = c("No naloxone","IM 2 mg/2 mL", "IM 2 mg/0.4 mL")) +
		theme_bw()+xlab("") +
		theme(legend.position="none")+xlim(0, 15)




	
}


#---- Combined CA figure
ggsave(
		filename = "results/All_CA_plots.pdf", 
		plot = marrangeGrob(p, nrow=1, ncol=4), 
		width = 8, height = 4
)



library(gridExtra)

library(patchwork)
	
	
			p21<-p2[[1]]+ggtitle("Fentanyl 1.63mg \n A")+ylab("Minute Ventilation \n (L/min)")+theme(plot.title = element_text(size = 10))+
			theme(axis.title.x=element_text(size=10),axis.title.y=element_text(size=10))+  theme(#axis.ticks.x = element_blank(),
					axis.text.x = element_blank())
	p22<-p2[[2]]+ggtitle("Fentanyl 2.97mg \n ")+ylab("")+theme(plot.title = element_text(size = 10))+   theme(#axis.ticks.x = element_blank(),
					axis.text.x = element_blank()) +   theme(axis.ticks.y = element_blank(),
					axis.text.y = element_blank())
	p23<-p2[[3]]+ggtitle("Carfentanil 0.012mg \n ")+ylab("")+theme(plot.title = element_text(size = 10))+   theme(#axis.ticks.x = element_blank(),
					axis.text.x = element_blank()) +   theme(axis.ticks.y = element_blank(),
					axis.text.y = element_blank())
	p24<-p2[[4]]+ggtitle("Carfentanil 0.022mg \n ")+ylab("")+theme(plot.title = element_text(size = 10))+   theme(#axis.ticks.x = element_blank(),
					axis.text.x = element_blank()) +   theme(axis.ticks.y = element_blank(),
					axis.text.y = element_blank(),#,
					legend.position=c(.65,.85),legend.text = element_text(size=6),legend.background=element_blank(),legend.key.size= unit(.25, 'cm'))+labs(color="")
	
	patch1<-p21+p22+p23+p24+plot_layout(ncol=4)
	
	
	p31<-p3[[1]]+ylab("Arterial Oxygen \n Partial Pressure (mmHg)")+theme(axis.title.x=element_text(size=10),axis.title.y=element_text(size=10))+
			ggtitle("B")+theme(plot.title = element_text(size = 10)) +   theme(#axis.ticks.x = element_blank(),
					axis.text.x = element_blank())#+   theme(axis.ticks.y = element_blank(),
	#axis.text.y = element_blank()) ,
	p32<-p3[[2]]+ylab("")+ggtitle("")+theme(plot.title = element_text(size = 10))+   theme(#axis.ticks.x = element_blank(),
					axis.text.x = element_blank())+   theme(axis.ticks.y = element_blank(),
					axis.text.y = element_blank())
p33<-	p3[[3]]+ylab("")+ggtitle("")+theme(plot.title = element_text(size = 10))+  theme(#axis.ticks.x = element_blank(),
					axis.text.x = element_blank())+   theme(axis.ticks.y = element_blank(),
					axis.text.y = element_blank())
	p34<- p3[[4]]+ylab("")+ggtitle("")+theme(plot.title = element_text(size = 10))+  theme(#axis.ticks.x = element_blank(),
					axis.text.x = element_blank())+   theme(axis.ticks.y = element_blank(),
					axis.text.y = element_blank(),#,
	legend.position=c(.65,.85),legend.text = element_text(size=6),legend.background=element_blank(),legend.key.size= unit(.25, 'cm'))+labs(color="")
	
	p41<- p4[[1]]+ylab("Cardiac Output \n (L/min)")+xlab("Time (minutes)")+theme(axis.title.x=element_text(size=10),axis.title.y=element_text(size=10))+ggtitle("C")+theme(plot.title = element_text(size = 10))
	p42<- p4[[2]]+xlab("Time (minutes)")+ylab("")+theme(axis.title.x=element_text(size=10))+
			ggtitle("")+theme(plot.title = element_text(size = 10))+   theme(axis.ticks.y = element_blank(),
					axis.text.y = element_blank())
	p43<- p4[[3]]+xlab("Time (minutes)")+ylab("")+theme(axis.title.x=element_text(size=10))+
			ggtitle("")+theme(plot.title = element_text(size = 10))+   theme(axis.ticks.y = element_blank(),
					axis.text.y = element_blank(),legend.position=c(.35,.25),legend.text = element_text(size=6),legend.background=element_blank(),legend.key.size= unit(.2, 'cm'))+labs(color="")
	
	p44<-p4[[4]]+xlab("Time (minutes)")+ylab("")+theme(axis.title.x=element_text(size=10))+
			ggtitle("")+theme(plot.title = element_text(size = 10))+   theme(axis.ticks.y = element_blank(),
					axis.text.y = element_blank())#,
					#legend.position=c(.75,.85),legend.text = element_text(size=6),legend.background=element_blank(),legend.key.size= unit(.2, 'cm'))+labs(color="")
	
	p11<- p[[1]]+ylab("Cardiac Arrest (%)")+ggtitle("D")+
			theme(plot.title = element_text(size = 10),axis.title.y=element_text(size=10),
					axis.text.x=element_text(size=6),
					legend.position="none")+
					#legend.background=element_blank(),legend.key.size= unit(.2, 'cm'))+labs(fill="")+	
			labs(x="Naloxone Doses")
	
	p12<-p[[2]]+ggtitle("")+theme(plot.title = element_text(size = 10))+   theme(axis.ticks.y = element_blank(),
			axis.text.x=element_text(size=6),
			axis.text.y = element_blank())+labs(x="Naloxone Doses")
	
	p13<- p[[3]]+ggtitle("")+theme(plot.title = element_text(size = 10))+   theme(axis.ticks.y = element_blank(),
			axis.text.x=element_text(size=6),
			axis.text.y = element_blank())+labs(x="Naloxone Doses")
	
	p14<-p[[4]]+ggtitle("")+theme(plot.title = element_text(size = 10))+   theme(axis.ticks.y = element_blank(),
			axis.text.y = element_blank(),
			axis.text.x=element_text(size=6))+labs(x="Naloxone Doses")
	
	
	
	patch2<-p31+p32+p33+p34+plot_layout(ncol=4)
	patch3<-p41+p42+p43+p44+plot_layout(ncol=4)		
	patch4<-p11+p12+p13+p14+plot_layout(ncol=4)
	
	
	a<- theme(
			panel.background = element_rect(fill = "white"),
			plot.margin = margin(0.1, 0.1, 0.1, 0.1, "cm")
			
	)
	
	
	patchall<-patch1 + patch2 + patch3 + patch4  +plot_layout(ncol = 4,nrow=4,widths=c(1,1,1,1))
	patchall2<-p21+a+p22+a+p23+a+p24+a+
			p31+a+p32+a+p33+a+p34+a+
			p41+a+p42+a+p43+a+p44+a+
			p11+a+p12+a+p13+a+p14+a+plot_layout(ncol=4) #plot_annotation(tag_levels = 'A')
	ggsave("results/Manuscript_Figure_7.pdf",patchall2)
	

	
	
				
				p51<- p5[[1]]+ggtitle("Fentanyl 1.63mg \n A")+ylab("Plasma Naloxone \n (ng/ml)")+theme(plot.title = element_text(size = 10))+
						theme(axis.title.x=element_text(size=10),axis.title.y=element_text(size=10),axis.text.x = element_blank())+
						scale_y_continuous(breaks=seq(0,7.5,2.5),limits=c(0,10))
			p52<-	p5[[2]]+ggtitle("Fentanyl 2.97mg \n ")+ylab("")+theme(plot.title = element_text(size = 10),axis.ticks.y = element_blank(),axis.text.y = element_blank(),axis.text.x = element_blank())+
					scale_y_continuous(breaks=seq(0,7.5,2.5),limits=c(0,10))
			p53<-	p5[[3]]+ggtitle("Carfentanil 0.012mg \n ")+ylab("")+theme(plot.title = element_text(size = 10),
							axis.ticks.y = element_blank(),axis.text.y = element_blank(),axis.text.x = element_blank())+
					scale_y_continuous(breaks=seq(0,7.5,2.5),limits=c(0,10))
			p54<-	p5[[4]]+ggtitle("Carfentanil 0.022mg \n ")+ylab("")+theme(plot.title = element_text(size = 10),
							axis.ticks.y = element_blank(),axis.text.y = element_blank(),axis.text.x = element_blank(),legend.position=c(.725,.65),legend.text = element_text(size=6),legend.background=element_blank(),
							legend.key.size= unit(.2, 'cm'))+labs(color="")+
					scale_y_continuous(breaks=seq(0,7.5,2.5),limits=c(0,10))
			p61<-	p6[[1]]+ylab("Arterial Carbon Dioxide \n Partial Pressure (mmHg)")+theme(axis.title.x=element_text(size=10),axis.title.y=element_text(size=10))+
					ggtitle("B")+theme(plot.title = element_text(size = 10),axis.text.x = element_blank())+
					scale_y_continuous(breaks=seq(40,60,10),limits=c(40,70))
			
			p62<-	p6[[2]]+ylab("")+ggtitle("")+theme(plot.title = element_text(size = 10),axis.ticks.y = element_blank(),axis.text.y = element_blank(),axis.text.x = element_blank())+
					scale_y_continuous(breaks=seq(40,60,10),limits=c(40,70))
			
			p63<-	p6[[3]]+ylab("")+ggtitle("")+theme(plot.title = element_text(size = 10),axis.ticks.y = element_blank(),axis.text.y = element_blank(),axis.text.x = element_blank())+
					scale_y_continuous(breaks=seq(40,60,10),limits=c(40,70))
			
			p64<-	p6[[4]]+ylab("")+ggtitle("")+theme(plot.title = element_text(size = 10),
							axis.ticks.y = element_blank(),axis.text.y = element_blank(),axis.text.x = element_blank(),
							legend.position=c(.7,.25),legend.text = element_text(size=6),legend.background=element_blank(),
							legend.key.size= unit(.2, 'cm'))+labs(color="")+
					scale_y_continuous(breaks=seq(40,60,10),limits=c(40,70))
			p71<-	p7[[1]]+ylab("Cardiac Output \n To Brain (L/min)")+theme(axis.title.x=element_text(size=10),axis.title.y=element_text(size=10))+ggtitle("C")+
					theme(plot.title = element_text(size = 10))+
					scale_y_continuous(breaks=seq(0,2,1),limits=c(0,2.75))
			p72<-	p7[[2]]+ylab("")+ggtitle("")+theme(plot.title = element_text(size = 10),axis.ticks.y = element_blank(),axis.text.y = element_blank(),axis.text.x = element_blank())+
					scale_y_continuous(breaks=seq(0,2.5,.5),limits=c(0,2.75))
			p73<-	p7[[3]]+ylab("")+ggtitle("")+theme(plot.title = element_text(size = 10),axis.ticks.y = element_blank(),
							axis.text.y = element_blank(),axis.text.x = element_blank(),	legend.position=c(.4,.25),legend.text = element_text(size=6),legend.background=element_blank(),
							legend.key.size= unit(.2, 'cm'))+labs(color="")+
					scale_y_continuous(breaks=seq(0,2.5,.5),limits=c(0,2.75))
			p74<-	p7[[4]]+ylab("")+ggtitle("")+theme(plot.title = element_text(size = 10),
							axis.ticks.y = element_blank(),axis.text.y = element_blank(),axis.text.x = element_blank())+
					scale_y_continuous(breaks=seq(0,2.5,.5),limits=c(0,2.75))
			p81<-	p8[[1]]+ylab("Brain Oxygen \n Partial Pressure (mmHg)")+xlab("Time (minutes)")+theme(axis.title.x=element_text(size=10),axis.title.y=element_text(size=10))+ggtitle("D")+theme(plot.title = element_text(size = 10))+
					scale_y_continuous(breaks=seq(0,40,20),limits=c(0,50))
			p82<-	p8[[2]]+xlab("Time (minutes)")+ylab("")+theme(axis.title.x=element_text(size=10))+ggtitle("")+theme(axis.ticks.y = element_blank(),plot.title = element_text(size = 10),axis.text.y = element_blank())+
					scale_y_continuous(breaks=seq(0,40,20),limits=c(0,50))
			p83<-	p8[[3]]+xlab("Time (minutes)")+ylab("")+theme(axis.title.x=element_text(size=10))+ggtitle("")+
			theme(plot.title = element_text(size = 10),axis.ticks.y = element_blank(),axis.text.y = element_blank())+
					scale_y_continuous(breaks=seq(0,40,20),limits=c(0,50))
			p84<-	p8[[4]]+xlab("Time (minutes)")+ylab("")+theme(axis.title.x=element_text(size=10))+ggtitle("")+theme(axis.ticks.y = element_blank(),
							plot.title = element_text(size = 10),axis.text.y = element_blank(),
							legend.position=c(.65,.75),legend.text = element_text(size=6),legend.background=element_blank(),
							legend.key.size= unit(.2, 'cm'))+labs(color="")+
					scale_y_continuous(breaks=seq(0,40,20),limits=c(0,50))
				
				
				
			patchall3<-p51+a+p52+a+p53+a+p54+a+
					p61+a+p62+a+p63+a+p64+a+
					p71+a+p72+a+p73+a+p74+a+
					p81+a+p82+a+p83+a+p84+a+plot_layout(ncol=4) 
			ggsave("results/Supplemental_Manuscript_Figure.pdf",patchall3)
			
				

