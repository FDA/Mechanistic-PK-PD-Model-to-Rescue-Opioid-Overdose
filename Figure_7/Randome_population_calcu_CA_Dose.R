#Script to calculate Cardiac Arrest rates with random sampling for all
#naloxone dose and opioid combinations



library(optparse)
parser<-OptionParser()
parser<-add_option(parser, c("-t", "--case"), default ="1",type="numeric",help="which naloxone opioid combination to use")
args<-parse_args(parser)
caseN=args$case 

#----- caseN selects row 1 to 8 of allfolders
print(caseN)
#ddddddd
alllfolders=c("Review_naloxone_formulation_EVZIO_conc_1.625_ligand_fentanyl_patient_chronic",
		"Review_naloxone_formulation_EVZIO_conc_2.965_ligand_fentanyl_patient_chronic",
		"Review_naloxone_formulation_EVZIO_conc_0.012_ligand_carfentanil_patient_chronic",
		"Review_naloxone_formulation_EVZIO_conc_0.02187_ligand_carfentanil_patient_chronic",
		"Review_naloxone_formulation_Generic_conc_1.625_ligand_fentanyl_patient_chronic",
		"Review_naloxone_formulation_Generic_conc_2.965_ligand_fentanyl_patient_chronic",
		"Review_naloxone_formulation_Generic_conc_0.012_ligand_carfentanil_patient_chronic",
		"Review_naloxone_formulation_Generic_conc_0.02187_ligand_carfentanil_patient_chronic" )


foldermain="outputs"
i2<-c()

foldermainoutput="population_outputs_2mg_40tsh_delays"
				
				labells= labelfol=c("fentanyl_1.625mg_60",
						"fentanyl_2.965mg_60",
						"carfentanil_0.012mg_60",		
						"carfentanil_0.02187mg_60",
						"fentanyl_1.625mg_60",
						"fentanyl_2.965mg_60",
						"carfentanil_0.012mg_60",		
						"carfentanil_0.02187mg_60"
				)
CADo_df2all=c()
for (iran in 1:2500) {
	totalVP=2000
isam=sample (seq(1,totalVP),400, replace =T)

if (iran==1) {isam=seq(1,totalVP)} # mean of 2000 cases
#totalindividuals=2000
totalindividuals=length(isam)
foldermain="outputs"
i2<-c()
foldermainoutput="population_outputs_2mg_40tsh_delays"
#if (file.exists(sprintf("%s/%s/All%s.csv",foldermain,folder_of_population,i))) {
	
CADo1=c()
fo1=100000 #dont have effect
#fo1=dose=.014
#initdelay="yes"
#PK_yn="yes"
opioid_time=0
if (opioid_time==0) {initialdelay=60}
if (opioid_time!=0) {initialdelay=0}
#caseN=3
for (iifo1 in alllfolders[caseN]) {
	labellsi=labells[caseN]


	CADo_df2=c()
		fo=iifo1

	folder_of_population=fo
	d1=c()
	d2=c(); d3=c(); d4=c(); d5=c(); d6=c(); d7=c()
	d22=c()
	d33=c()
	d44=c()
	d55=c()
	d66=c()
	d77=c()
	
	t1=c()
	t1_B=c()
	t2_B=c()
	t3_B=c()
	t4_B=c()
	t5_B=c()
	t6_B=c()
	t7_B=c()
	k1111<-0
	for (i in isam) {
		
	if (file.exists(sprintf("%s/%s/All%s.csv",foldermain,folder_of_population,i))) {
	d0=read.csv(sprintf("%s/%s/All%s.csv",foldermain,folder_of_population,i),stringsAsFactors =F)
	

	
	k1111<-k1111+1
	if(d0[2,2]=="no"){
	d2<-d0
	
}
if(d0[3,2]=="no"){
	d3<-d0
	
}


#	if (ncol(d0)==5) {
d1=cbind(d1,d0[,2])
d22=cbind(d22,d2[,2])
d33=cbind(d33,d3[,2])

d0[,5][d0[,2]=="yes"]=NA
d2[,5][d2[,2]=="yes"]=NA

t1_B=cbind(t1_B,(d0[,5]))


t2_B=cbind(t2_B,(d2[,5]))

}

}

rowYesCA=rowSums(d1=='yes', na.rm=TRUE)

rowYesCA_frac=100-rowYesCA/totalindividuals*100 #ncol(d1)*100

Rescue_Medians<-c()

for(i in 1:2){
	median_s<-quantile(t1_B[i,],probs=c(.025,.5,.975),na.rm=TRUE)
	Rescue_Medians<-rbind(Rescue_Medians,median_s)	
}
rownames(Rescue_Medians)<-c("0","1")


system(paste0("mkdir -p ",sprintf("%s/CA_AERO",foldermainoutput)))
system(paste0("mkdir -p ",sprintf("%s/barplots_AERO",foldermainoutput)))
system(paste0("mkdir -p ",sprintf("%s/barplots_Errorbar",foldermainoutput)))


mean_rescue_B=rowMeans(t1_B)
mean_rescue_2B=try(rowMeans(t2_B))
if(length(t2_B)==0){
	mean_rescue_2B<-rep(3600,6)
}


Rescues<-cbind(mean_rescue_B,mean_rescue_2B)
Rescue_All<-cbind(mean_rescue_B,mean_rescue_2B)


both_tCA=cbind(rowYesCA_frac[c(1,2)],mean_rescue_B[c(1,2)])
colnames(both_tCA)=c("CA_percentage","mean_rescue_time")
rownames(both_tCA)=c("N0","N1")


CADo=cbind(rowYesCA_frac,fo1)
CADo1=rbind(CADo1,CADo)

if (file.exists(sprintf("%s/%s/All2001.csv",foldermain,folder_of_population))) {
	

	d2001=read.csv(sprintf("%s/%s/All2001.csv",foldermain,folder_of_population),stringsAsFactors =F)
	
}else{
	d2001=c(rep("NAAA",2)) 
}
CADo_df<-data.frame(CADo1)
CADo_df<-CADo_df[c(1,2),]
names(CADo_df)<-c("rowYesCA","fo1")
CADo_df$Ndose<-c("No dose","1-dose")
d2001<-d2001[c(1,2),]
CADo_df2<-cbind(CADo_df,d2001)

CADo_df2$rnnum=iran
CADo_df2all=rbind(CADo_df2all,CADo_df2)






CADo_df<-CADo_df[CADo_df$Ndose %in% c("No dose","1-dose"),]


if (iran==1) {
	
	CADo_dfmean=CADo_df
	write.csv(Rescue_Medians,sprintf("%s/CA_AERO/%s_Rescue_Times_ligand_2_%s.csv",foldermainoutput,iran,iifo1))
	write.csv(CADo_df2,sprintf("%s/CA_AERO/%s_CADo1PK%s.csv",foldermainoutput,iran,iifo1))
	

png(file=sprintf("%s/barplots_AERO/%s_p0_%s.png",foldermainoutput,iran,iifo1),width=800, height=800)
par(mar = c(6, 8, 2, 2))
p1=barplot(CADo_df$rowYesCA,ylim=c(0,100),
		names=CADo_df$Ndose,cex.axis=2,cex.names=2,cex.lab=3,col=c("darkblue"),las = 1)
#axis(side=1,at=4,pos=-2,tick=FALSE)
title(ylab="Cardiac Arrest Percentage", cex.lab = 3.5,
		line = 4.5,col.lab ="darkblue")
title(xlab="Number of Naloxone doses", cex.lab = 3.5,
		line = 4.5)
dev.off()
}
}
}

CADo_dfmean$emin=-1000
CADo_dfmean$emax=1000


for (indos in unlist(unique(CADo_dfmean["Ndose"]))) {
extr0=CADo_df2all[CADo_df2all["Ndose"]==indos,]

CIt=quantile(extr0$rowYesCA, probs = c(0.025, 0.975))

CADo_dfmean$emin[CADo_dfmean["Ndose"]==indos]=CIt[1]
CADo_dfmean$emax[CADo_dfmean["Ndose"]==indos]=CIt[2]

print("-----CA-------")

print(CADo_df)

write.csv(CADo_dfmean,sprintf("%s/CA_AERO/All_CADo1PK%s.csv",foldermainoutput,iifo1))


}
CADo_dfmean$txtt=sprintf("%s (%s-%s)",round(CADo_dfmean$rowYesCA,0),round(CADo_dfmean$emin,0),round(CADo_dfmean$emax),0)

library("ggplot2")
CADo_dfmean$Ndose <- factor(CADo_dfmean$Ndose, levels = CADo_dfmean$Ndose)
p1<- ggplot(CADo_dfmean, aes(x=Ndose, y=rowYesCA, fill="black")) + 
		geom_bar(stat="identity", color="black", fill="black",alpha=.8,
				position=position_dodge()) +
		geom_errorbar(aes(ymin=emin, ymax=emax), width=.2,
				position=position_dodge(.9),color="red")+
		geom_text(aes(label = txtt),  position = position_dodge(0.9),vjust =-2 ,size=2.4)
p1<-p1+ggtitle(sprintf("%s",labellsi))+ylim(0,100)+ theme(legend.position="none")+theme(plot.title = element_text(size = 12, face = "bold"))+
		labs(x = "Naloxone dose (mg)",y = "Recovered % of virtual subjects")+ theme_bw()+theme(axis.line = element_line(colour = "black"),panel.border = element_blank())+  theme(axis.text.x = element_text(angle = 45, hjust=1))
ggsave(sprintf("%s/barplots_Errorbar/%s_dose.png",foldermainoutput,iifo1), p1, width=3.5, height=3.8)
