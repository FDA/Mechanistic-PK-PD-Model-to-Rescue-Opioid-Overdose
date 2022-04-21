
CADo1=c()
#dose=c(.014,.154,.294)
#Product="5mg" #Ether evzio or generic
#dose=c(.02187)
#opioid="carfentanil"
#dose=(.014)
#opioid="carfentanil"
#Product="EVZIO"
PK_yn="yes"
#for (fo1 in dose) {
fo1=dose
#	opioid="carfentanil"
	Type="chronic"
	if(Product=="EVZIO2"){
	fo=sprintf("Review_naloxone_formulation_EVZIO_conc_1.625_ligand_fentanyl_patient_chronic")
}else(fo=sprintf("final4_%s_opt_yesParDis_noDelayDiss_conc%s_PK%s_%s_%s_samplingD_log_Nal",Product,fo1,PK_yn,opioid,Type))
	#	fo= "final4_EVZIO_opt_yesParDis_noDelayDiss_conc1.625_PKyes_fentanyl_chronic_samplingD_log_Nal"	
#if(Product=="EVZIO"){
	#fo=sprintf("final4_%s_opt_yesParDis_noDelayDiss_conc%s_PK%s_%s_%s_samplingD_V_log",Product,fo1,PK_yn,opioid,Type)
	
#}
	print(fo)
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
	i2<-c()
	k1111<-0
for (i in 1:2000) {
	if (file.exists(sprintf("a_outputs/%s/All%s.csv",folder_of_population,i))) {
	d0=read.csv(sprintf("a_outputs/%s/All%s.csv",folder_of_population,i),stringsAsFactors =F)
	k1111<-k1111+1
	if(d0[2,2]=="no"){
	d2<-d0
	
}
if(d0[3,2]=="no"){
	d3<-d0
	
}
if(d0[4,2]=="no"){
	d4<-d0
	
}
if(d0[5,2]=="no"){
	d5<-d0
	
}
if(d0[6,2]=="no"){
	d6<-d0
	
	
}else(i2<-rbind(i,i2))
if(d0[7,2]=="no"){
	d7<-d0
}
	#d2=read.csv(sprintf("MCMC_outputs/%s/All_Pre%s.csv",folder_of_population,i),stringsAsFactors =F)
	#library(plyr)
	#if(isFALSE(all.equal(d0,d2))){
	#	print("i")
		
#}

	if (ncol(d0)==5) {
d1=cbind(d1,d0[,2])
d22=cbind(d22,d2[,2])
d33=cbind(d33,d3[,2])
d44=cbind(d44,d4[,2])
d55=cbind(d55,d5[,2])
d66=cbind(d66,d6[,2])
d77=cbind(d77,d7[,2])
#d22=cbind(d22,d2[,2])
#t1=cbind(t1,d0[,3])
				
t1_B=cbind(t1_B,(d0[,5]))
t2_B=cbind(t2_B,(d2[,5]))
t3_B=cbind(t3_B,(d3[,5]))
t4_B=cbind(t4_B,(d4[,5]))
t5_B=cbind(t5_B,(d5[,5]))
t6_B=cbind(t6_B,(d6[,5]))
t7_B=cbind(t7_B,(d7[,5]))
}
}
}
print(k1111)
rowYesCA=rowSums(d1=='yes', na.rm=TRUE)
print(rowYesCA)
rowYesCA_frac=rowYesCA/2000*100#ncol(d1)*100 # /2000

#mean_rescue=rowMeans(t1)
Rescue_Medians<-c()
for(i in 1:7){
#	median_s(lapply(tout_plot1,quantile,probs=c(0.25,.75)))
	median_s<-quantile(t1_B[i,],probs=c(.25,.5,.75))
	Rescue_Medians<-rbind(Rescue_Medians,median_s)	
}
rownames(Rescue_Medians)<-c("0","1","2","3","4","2S","2+2")
write.csv(Rescue_Medians,sprintf("population_outputs/CA/Rescue_Times_Product_%s_ligand_%s_dose_%s_PK_%s_%s_VNal_I.csv",Product,opioid,dose,PK_yn,Type))

	
#medians<-lapply(t1_B,quantile,probs=c(.25,.5,.75))
mean_rescue_B=rowMeans(t1_B)
mean_rescue_2B=try(rowMeans(t2_B))
if(length(t2_B)==0){
	mean_rescue_2B<-rep(3600,6)
}
mean_rescue_3B=try(rowMeans(t3_B))
if(length(t3_B)==0){
	mean_rescue_3B<-rep(3600,6)
}
mean_rescue_4B=try(rowMeans(t4_B))
if(length(t4_B)==0){
	mean_rescue_4B<-rep(3600,6)
}
mean_rescue_5B=try(rowMeans(t5_B))
if(length(t5_B)==0){
	mean_rescue_5B<-rep(3600,6)
}

mean_rescue_6B=try(rowMeans(t6_B))
if(length(t6_B)==0){
	mean_rescue_6B<-rep(3600,6)
}
mean_rescue_7B=try(rowMeans(t7_B))
if(length(t7_B)==0){
	mean_rescue_7B<-rep(3600,6)
}

Rescues<-cbind(mean_rescue_B,mean_rescue_2B)
Rescue_All<-cbind(mean_rescue_B,mean_rescue_2B,
		mean_rescue_3B,mean_rescue_4B,
		mean_rescue_5B,mean_rescue_6B, mean_rescue_7B)
print(mean_rescue_B)
print(mean_rescue_2B)
#mean_rescue_final=rowMeans(t1_B)

both_tCA=cbind(rowYesCA_frac,mean_rescue_B)
colnames(both_tCA)=c("CA_percentage","mean_rescue_time")
rownames(both_tCA)=c("N0","N1","N2","N3","N4","N2_S","N2+2")
populationFolder=sprintf("a_outputs/%s/results/",folder_of_population)
system(paste0("mkdir -p ","a_outputs/final2"))
system(paste0("mkdir -p ",populationFolder))
#write.csv(both_tCA,sprintf("%s/%s.csv",populationFolder,"CAandRT"))
#write.csv(both_tCA,sprintf("MCMC_outputs/final2/%s.csv",fo))

#write.csv(d1,sprintf("%s/%s.csv",populationFolder,"AllCA"))
#write.csv(t1_B,sprintf("%s/%s.csv",populationFolder,"AllRT"))
#write.csv(Rescues,sprintf("%s/%s.csv",populationFolder,"AllRT_allrescue"))
#write.csv(Rescue_All,sprintf("%s/%s.csv",populationFolder,"AllRT_all_calculations"))

CADo=cbind(rowYesCA_frac,fo1,mean_rescue_B)
CADo1=rbind(CADo1,CADo)
#d2001=read.csv(sprintf("MCMC_outputs/%s/All2001.csv",folder_of_population),stringsAsFactors =F)
#print(d2001)



write.csv(i2,"MCMC_outputs3/test_outs2.csv")
CADo_df<-data.frame(CADo1)
names(CADo_df)<-c("rowYesCA","fo1","mean_rescue_B")
CADo_df$Ndose<-c(0:4,"2_S","2+2")
#dose=1.625
write.csv(CADo_df,sprintf("population_outputs/CA/Product_%s_CADo1PK%s_%s_samplingD_PK%s_%sNal_I.csv",Product,opioid,dose,PK_yn,Type))
#write.csv(CADo1,sprintf("%s/CADo1PK%s_%s_samplingD_PK%s.csv",populationFolder,opioid,dose,PK_yn))

png(file=sprintf("population_outputs/barplots/Product_%s_p0_dose%s_%s_PK%s_%s_VNal_I.png",Product,dose,opioid,PK_yn,Type),width=800, height=800)
par(mar = c(6, 8, 2, 2))
p1=barplot(CADo_df$rowYesCA,ylim=c(0,100),
		names=CADo_df$Ndose,cex.axis=2,cex.names=2,cex.lab=3,col=c("darkblue"),las = 1)
#axis(side=1,at=4,pos=-2,tick=FALSE)
title(ylab="Cardiac Arrest Percentage", cex.lab = 3.5,
		line = 4.5,col.lab ="darkblue")
title(xlab="Number of Naloxone doses", cex.lab = 3.5,
		line = 4.5)

CADo_df<-CADo_df[CADo_df$Ndose %in% c("0","1"),]
CADo_df$Ndose <- factor(CADo_df$Ndose, levels = CADo_df$Ndose[order(-CADo_df$rowYesCA)])
dev.off()
library(ggplot2)
p1<-ggplot()
p1<-ggplot(CADo_df,aes(x=Ndose,y=rowYesCA))+
		geom_bar(stat="identity", position=position_dodge(),fill="black")
p1<-p1 + theme_light()
p1<-p1 + scale_fill_brewer(palette="Paired") + theme_minimal()
p1<-p1 + labs(title=sprintf("CA %s %s",Product, dose), 
				x="Naloxone Dose", y = "Cardiac Arrest (Percent)")
#p1<-p1+scale_y_continuous(limits=c(0,1.05*max(rowYesCA)))		
		
write.csv(CADo_df,sprintf("output_2_21/CA_Results/%s_%s_CA_DF.csv",Product,dose))
#data=read.csv(sprintf("MCMC_outputs/final2/CADo1PK%s_samplingDtest_Pre%s.csv",opioid,dose))
#X J_YN2  X.1    X.2    X.3
#1 V0   yes 88.2 5400.0 5311.8
#2       no 88.2  226.1  137.9
#3       no 88.2  226.1  137.9
#4       no 88.2  226.1  137.9
#5       no 88.2  226.1  137.9
#6       no 88.2  226.0  137.8


#--------------------plotting OD
names(CADo_df)<-c("CA_Percent","Dose","Rescue","Ndose")
CADo_df<-CADo_df[,-3]
CADo_df$Drug<-Product
CARDIAC_Results<-rbind(CARDIAC_Results,CADo_df)
