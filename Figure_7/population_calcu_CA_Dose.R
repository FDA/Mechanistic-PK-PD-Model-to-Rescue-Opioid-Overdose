

library(optparse)
parser<-OptionParser()
parser<-add_option(parser, c("-t", "--case"), default ="1",type="numeric",help="critical rescue time")
args<-parse_args(parser)
caseN=args$case

#--- Each folder contains cardiac arrest and rescue time data for 2000 virtual patients and optimal case for the 
#--- given opioid concentration and naloxone formulation

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
CADo1=c()
fo1=100000 

opioid_time=0
if (opioid_time==0) {initialdelay=60}
if (opioid_time!=0) {initialdelay=0}
#caseN=3
for (iifo1 in alllfolders[caseN]) {
	print(caseN)
	print(iifo1)
	print("--------------")
	CADo_df2=c()

	#print(fo)
	folder_of_population=iifo1
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
	# read cardiac arrest data for each patient
	for (i in 1:2000) {
		if (file.exists(sprintf("%s/%s/All%s.csv",foldermain,folder_of_population,i))) {
			d0=read.csv(sprintf("%s/%s/All%s.csv",foldermain,folder_of_population,i),stringsAsFactors =F)
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
				
			}else(i2<-rbind(i2,i))
			if(d0[7,2]=="no"){
				d7<-d0
			}

			
			if (ncol(d0)==5) {
				d1=cbind(d1,d0[,2])   # 0 dose naloxone CA
				d22=cbind(d22,d2[,2]) # 1 dose naloxone CA
				d33=cbind(d33,d3[,2]) # 2 doses naloxone CA
				d44=cbind(d44,d4[,2]) # 3 doses naloxone CA
				d55=cbind(d55,d5[,2]) # 4 doses naloxone CA
				d66=cbind(d66,d6[,2]) # double dose naloxone CA (same time)
				d77=cbind(d77,d7[,2]) # two double doses naloxone CA
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
	write.csv(i2,"test_csv.csv")
	rowYesCA=rowSums(d1=='yes', na.rm=TRUE)
	print(rowYesCA)
	rowYesCA_frac=rowYesCA/2000*100 #ncol(d1)*100
	
#mean_rescue=rowMeans(t1)
	Rescue_Medians<-c()
	for(i in 1:7){
#	median_s(lapply(tout_plot1,quantile,probs=c(0.25,.75)))
		median_s<-quantile(t1_B[i,],probs=c(.05,.10,.25,.5,.75,.90,.95))
		Rescue_Medians<-rbind(Rescue_Medians,median_s)	
	}
	rownames(Rescue_Medians)<-c("0","1","2","3","4","2S","2+2")
#below is wrong
	
	system(paste0("mkdir -p ",sprintf("%s/CA_IM2",foldermainoutput)))
	system(paste0("mkdir -p ",sprintf("%s/barplots_IM2",foldermainoutput)))
	
#system(paste0("mkdir -p ","population_outputsX/barplots_IV"))
#write.csv(Rescue_Medians,sprintf("population_outputsX/CA_IV/Rescue_Times_ligand_%s_dose_%s_PK_%s_%s_V%s_k1no_opioidtime%s_initaldelay%s.csv",
#				opioid,dose,PK_yn,Type,initdelay,opioid_time,initialdelay))
	
	write.csv(Rescue_Medians,sprintf("%s/CA_IM2/Rescue_Times_ligand_%s.csv",foldermainoutput,iifo1))
	
	
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
	
	CADo=cbind(rowYesCA_frac,fo1,mean_rescue_B)
	CADo1=rbind(CADo1,CADo)
	if (file.exists(sprintf("%s/%s/All2001.csv",foldermain,folder_of_population))) {
		
		d2001=read.csv(sprintf("%s/%s/All2001.csv",foldermain,folder_of_population),stringsAsFactors =F)
		
	}else{
		d2001=c(rep("NAAA",7)) 
		
	}

	CADo_df<-data.frame(CADo1)
	names(CADo_df)<-c("rowYesCA","fo1","mean_rescue_B")
	CADo_df<-CADo_df[CADo_df$Ndose %in% c("0","1"),]
	CADo_df2<-cbind(CADo_df,d2001)
	
	CADo_df2$Ndose <- factor(CADo_df2$Ndose, levels = CADo_df2$Ndose[order(-CADo_df2$rowYesCA)])
	dev.off()
	
	write.csv(CADo_df2,sprintf("%s/CA_IM2/CADo1PK%s.csv",foldermainoutput,iifo1))
	
	
	CADo_df<-CADo_df[CADo_df$Ndose %in% c(0,1,2,"2_S"),]
	
	png(file=sprintf("%s/barplots_IM2/p0_%s.png",foldermainoutput,iifo1),width=800, height=800)
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

