#last edited by: Anik Chaturbedi
#on: 2023-06-16
dosingeventsRenarcotizationSlowOpioidInfusion<-function(
		eventAll= c(),
		method="old",
		totalOpioidDose= 0,
		opioidInitialBolusTime= 0,
		opioidInfusionDuration= 400, #(minutes)
		a= 20.11*0.95, #percentage of total opioid dose administered as initial bolus
		b= 96.04*5, #3#1.5
		c= 0.04427/60*0.85/6,
		fixedOpioidAbsorptionRate=(100*1e-3)/3600, #(ug/hr converted to mg/sec) 
		opioidAbsorptionRate=1
){	
	if (method=="old"){
		#based on paper that John/Iman used for NAI 10 mg==================================
		aero_t<-seq(1, (opioidInfusionDuration*60+1), by=1)
		y2<-a+(b-a)*(1-exp(-c*aero_t))
		y3<-c()
		for(i in seq(1,(opioidInfusionDuration*60+1),1)){
			if(i==1){
				y33=0
			}else{
				y33<-y2[i]-y2[i-1]
			}
			y3=rbind(y3, y33)
		}
		
		eventOpioidInfusion<-
				data.frame(
						var="PlasmaF", 
						time=opioidInitialBolusTime, 						
						value=totalOpioidDose*a/100,	
						method="add");
		eventOpioidInfusion<-rbind(eventOpioidInfusion, 
				data.frame(
						var="PlasmaF", 
						time=opioidInitialBolusTime+seq(1,(opioidInfusionDuration*60+1),1),	
						value=totalOpioidDose*y3/100,	
						method="add"));
		#==================================based on paper that John/Iman used for NAI 10 mg
	}else if (method=="new"){
		#constant rate as TTS with initial bolus=============================================
#		eventOpioidInfusion<-
#				data.frame(
#						var="PlasmaF", 
#						time=opioidInitialBolusTime, 						
#						value=totalOpioidDose,	
#						method="add");
#		eventOpioidInfusion<-rbind(eventOpioidInfusion, 
#				data.frame(
#						var="PlasmaF", 
#						time=opioidInitialBolusTime+seq(1, (opioidInfusionDuration*60+1), 1),	
#						value=fixedOpioidAbsorptionRate,	
#						method="add"));
		#=============================================constant rate as TTS with initial bolus
		#variable rate as TTS with initial bolus=================================================================================================
		eventOpioidInfusion<-
				data.frame(
						var="PlasmaF", 
						time=opioidInitialBolusTime, 						
						value=totalOpioidDose,	
						method="add");
		eventOpioidInfusion<-rbind(eventOpioidInfusion, 
				data.frame(
						var="PlasmaF", 
						time=opioidInitialBolusTime+seq(1, (opioidInfusionDuration*60+1), 1),	
						value=fixedOpioidAbsorptionRate*(1-exp(-opioidAbsorptionRate*(seq(1, (opioidInfusionDuration*60+1), 1)))),	
						method="add"));
		#=================================================================================================variable rate as TTS with initial bolus
	}	
	eventAll<-rbind(eventAll, eventOpioidInfusion) #combine infusion dataframe
	return(eventAll)
}