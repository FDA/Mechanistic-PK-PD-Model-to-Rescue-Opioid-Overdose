calculateRescueTimes<-function(){
	rescueTimes="output/rescueTimes/"
	SThBrainO2<-20 #mm Hg
	SThArterialO2<-30 #mm Hg
	SThArterialCO2<-45 #mm Hg
	SThArterialO2Saturation<-90 #%
	output<-c()
	for(Nconditions in c(1,2,3,4,5,6)){
		print(paste("naloxone dose=",Nconditions,"+++++++++++++++++++++++++++++++"))
		PaCO2InflectionTime<- outputForRTCalculation$PaCO2InflectionPointTime
		BrainO2AboveThresholdTime<- crossing(pp[[1]][[Nconditions]][,"Brain O2 partial pressure (mm Hg)"], pp[[1]][[Nconditions]][,"time"], SThBrainO2)[[2]][2]
		ArterialO2AboveThresholdTime<- crossing(pp[[1]][[Nconditions]][,"Arterial O2 partial pressure (mm Hg)"], pp[[1]][[Nconditions]][,"time"], SThArterialO2)[[2]][2]
		ArterialO2SaturationAboveThresholdTime<- crossing(outputForRTCalculation$saturationData[,Nconditions], pp[[1]][[Nconditions]][,"time"], SThArterialO2Saturation)[[2]][2]
		ArterialCO2BelowThresholdTime<-crossing(pp[[1]][[Nconditions]][,"Arterial CO2 partial pressure (mm Hg)"], pp[[1]][[Nconditions]][,"time"], SThArterialCO2)[[2]][2]
		PaCO2InflectionRT<-PaCO2InflectionTime[Nconditions]-firstNaloxoneIntroductionTime/60
		BrainO2AboveThresholdRT<-BrainO2AboveThresholdTime-firstNaloxoneIntroductionTime
		ArterialO2AboveThresholdRT<-ArterialO2AboveThresholdTime-firstNaloxoneIntroductionTime
		ArterialO2SaturationAboveThresholdRT<-ArterialO2SaturationAboveThresholdTime/60-firstNaloxoneIntroductionTime/60
		ArterialCO2BelowThresholdRT<-ArterialCO2BelowThresholdTime-firstNaloxoneIntroductionTime
		print(paste("PaCO2InflectionRT=",PaCO2InflectionRT,"minutes"))
		print(paste("BrainO2AboveThresholdRT=",BrainO2AboveThresholdRT/60,"minutes"))
		print(paste("ArterialO2AboveThresholdRT=",ArterialO2AboveThresholdRT/60,"minutes"))
		print(paste("ArterialO2SaturationAboveThresholdRT=",ArterialO2SaturationAboveThresholdRT,"minutes"))
		print(paste("ArterialCO2BelowThresholdRT=",ArterialCO2BelowThresholdRT/60,"minutes"))
		output0<-cbind(firstNaloxoneIntroductionTime/60,PaCO2InflectionRT,BrainO2AboveThresholdRT/60,ArterialO2AboveThresholdRT/60,ArterialO2SaturationAboveThresholdRT,ArterialCO2BelowThresholdRT/60)
		output<-rbind(output,output0)
	}	
	namecsvFile=paste0("opioid=",args$opioid," ","patientType=",args$patientType," ","dose=",args$conc)
	write.csv(output,paste0(rescueTimes,namecsvFile,".csv"),col.names = c("firstNaloxoneIntroductionTime","PaCO2InflectionRT","BrainO2AboveThresholdRT","ArterialO2AboveThresholdRT","ArterialO2SaturationAboveThresholdRT","ArterialCO2BelowThresholdRT"),row.names=c("0","1","2","3","4","2+2"))
}	