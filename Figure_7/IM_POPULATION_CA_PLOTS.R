#----- All doses for 5mg plots
CARDIAC_Results<-c()

Product="5mg3" #Ether evzio or generic
dose=c(.012)
opioid="carfentanil"

source("IM_population_calcu_CA_Dose.R")
CADo_df

p2<-p1
Product="5mg3" #Ether evzio or generic
dose=c(.02187)
opioid="carfentanil"

source("IM_population_calcu_CA_Dose.R")
CADo_df
p3<-p1
Product="5mg3" #Ether evzio or generic
dose=c(1.625)
opioid="fentanyl"

source("IM_population_calcu_CA_Dose.R")
CADo_df
p4<-p1
Product="5mg3" #Ether evzio or generic
dose=c(2.965)
opioid="fentanyl"
source("IM_population_calcu_CA_Dose.R")
CADo_df
p5<-p1

#write.csv(CARDIAC_Results,"population_outputs/Manuscript/All_CA_Table_5mg.csv")			

#CARDIAC_Results<-c()
#All doses for EVZIO2 plots

Product="EVZIO2" #Ether evzio or generic
dose=c(.012)
opioid="carfentanil"

source("IM_population_calcu_CA_Dose.R")
CADo_df
p22<-p1
Product="EVZIO2" #Ether evzio or generic
dose=c(.02187)
opioid="carfentanil"

source("IM_population_calcu_CA_Dose.R")
CADo_df
p33<-p1
Product="EVZIO2" #Ether evzio or generic
dose=c(1.625)
opioid="fentanyl"

source("IM_population_calcu_CA_Dose.R")
CADo_df
p44<-p1
Product="EVZIO2" #Ether evzio or generic
dose=c(2.965)
opioid="fentanyl"
source("IM_population_calcu_CA_Dose.R")
p55<-p1
CADo_df
#write.csv(CARDIAC_Results,"population_outputs/Manuscript/All_CA_Table_EVZIO2.csv")			

#----- All doses for Generic22


Product="Generic2" #Ether evzio or generic
dose=c(.012)
opioid="carfentanil"

source("IM_population_calcu_CA_Dose.R")
p222<-p1
Product="Generic2" #Ether evzio or generic
dose=c(.02187)
opioid="carfentanil"

source("IM_population_calcu_CA_Dose.R")
p333<-p1
Product="Generic2" #Ether evzio or generic
dose=c(1.625)
opioid="fentanyl"

source("IM_population_calcu_CA_Dose.R")
p444<-p1
Product="Generic2" #Ether evzio or generic
dose=c(2.965)
opioid="fentanyl"
source("IM_population_calcu_CA_Dose.R")
p555<-p1

#---- Combined Plot

library(grid)
library(gridExtra)

p444<-p444+labs(title="A	IM (2mg/2ml)",x="")+scale_y_continuous(breaks=seq(0,60,15),limits=c(0,62.5))
p44<-p44+labs(title="IM (2mg/0.4ml)",x="",y="")+scale_y_continuous(breaks=seq(0,60,15),limits=c(0,62.5))
p4<-p4+labs(title="IM (5mg/0.5ml)",x="",y="")+scale_y_continuous(breaks=seq(0,60,15),limits=c(0,62.5))
p44<-p44+geom_text(x=3.5,y=45,label="Fentanyl 1.63mg",size=2.5)

p555<-p555+labs(title="B	IM (2mg/2ml)",x="")+scale_y_continuous(breaks=seq(0,80,20),limits=c(0,82.5))
p55<-p55+labs(title="IM (2mg/0.4ml)",x="",y="")+scale_y_continuous(breaks=seq(0,80,20),limits=c(0,82.5))
p5<-p5+labs(title="IM (5mg/0.5ml)",x="",y="")+scale_y_continuous(breaks=seq(0,80,20),limits=c(0,82.5))
p55<-p55+geom_text(x=3.5,y=60,label="Fentanyl 2.97mg",size=2.5)

p222<-p222+labs(title="C	IM (2mg/2ml)",x="")+scale_y_continuous(breaks=seq(0,60,15),limits=c(0,62.5))
p22<-p22+labs(title="IM (2mg/0.4ml)",y="",x="")+scale_y_continuous(breaks=seq(0,60,15),limits=c(0,62.5))
p2<-p2+labs(title="IM (5mg/0.5ml)",y="",x="")+scale_y_continuous(breaks=seq(0,60,15),limits=c(0,62.5))
p22<-p22+geom_text(x=3.5,y=62.5,label="Carfentanil",size=2.5)
p22<-p22+geom_text(x=3.5,y=52.5,label=".012mg",size=2.5)


p333<-p333+labs(title="D	IM (2mg/2ml)")+scale_y_continuous(breaks=seq(0,100,25),limits=c(0,102.5))
p33<-p33+labs(title="IM (2mg/0.4ml)",y="")+scale_y_continuous(breaks=seq(0,100,25),limits=c(0,102.5))
p3<-p3+labs(title="IM (5mg/0.5ml)",y="")+scale_y_continuous(breaks=seq(0,100,25),limits=c(0,102.5))
p33<-p33+geom_text(x=3.5,y=85,label="Carfentanil",size=2.5)
p33<-p33+geom_text(x=3.5,y=75,label=".022mg",size=2.5)

pall1<-grid.arrange(p444,p44,p4,
					p555,p55,p5,
					p222,p22,p2,
					p333,p33,p3,ncol=3)
			
			pall2<-grid.arrange(p444,p44,
					p555,p55,
					p222,p22,
					p333,p33,ncol=2)			
			
write.csv(CARDIAC_Results,"population_outputs/Manuscript/All_CA_Table_EVZIO2_CHANGE5_I_N_2_2_n5mg.csv")			
			ggsave(paste0("population_outputs/Manuscript/All_CA_2_2_n5mg_rev6.pdf"),pall2,width=6,height=8)		
			ggsave(paste0("population_outputs/Manuscript/All_CA_2_2_n5mg_rev6.eps"),pall2,width=6,height=8)			