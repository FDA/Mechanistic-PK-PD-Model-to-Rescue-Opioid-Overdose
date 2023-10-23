#last edited by: Anik Chaturbedi
#on: 2024-02-16

calculateAndWritePKParameters<-function(
		parameter=c(), 
		doseIndices=c(),
		outputFolderBase=populationFolder){	
	PKParametersAllDoses=c()
	
	#output folders to create=================================
	outputFolder=sprintf("%s_PKParameters", outputFolderBase)
	system(paste0("mkdir -p ", outputFolder))
	#=================================output folders to create
	
	for(doseIndex in doseIndices){
		CMax=max(pp[[1]][[doseIndex]][,c(parameter)]) #(in ng/ml)
		TMax=crossing(pp[[1]][[doseIndex]][,parameter], pp[[1]][[doseIndex]][,"time"], CMax)[[2]]/3600 #(in hours)
		
		AUC2_5=	sum(diff(pp[[1]][[doseIndex]][(pp[[1]][[doseIndex]][,"time"]/60<=2.5),	"time"]/3600) * (head(pp[[1]][[doseIndex]][(pp[[1]][[doseIndex]][,"time"]/60<=2.5),	parameter],-1)+tail(pp[[1]][[doseIndex]][(pp[[1]][[doseIndex]][,"time"]/60<=2.5),	parameter],-1)))/2
		AUC5=	sum(diff(pp[[1]][[doseIndex]][(pp[[1]][[doseIndex]][,"time"]/60<=5),	"time"]/3600) * (head(pp[[1]][[doseIndex]][(pp[[1]][[doseIndex]][,"time"]/60<=5),	parameter],-1)+tail(pp[[1]][[doseIndex]][(pp[[1]][[doseIndex]][,"time"]/60<=5),		parameter],-1)))/2
		AUC10=	sum(diff(pp[[1]][[doseIndex]][(pp[[1]][[doseIndex]][,"time"]/60<=10),	"time"]/3600) * (head(pp[[1]][[doseIndex]][(pp[[1]][[doseIndex]][,"time"]/60<=10),	parameter],-1)+tail(pp[[1]][[doseIndex]][(pp[[1]][[doseIndex]][,"time"]/60<=10),	parameter],-1)))/2
		AUC15=	sum(diff(pp[[1]][[doseIndex]][(pp[[1]][[doseIndex]][,"time"]/60<=15),	"time"]/3600) * (head(pp[[1]][[doseIndex]][(pp[[1]][[doseIndex]][,"time"]/60<=15),	parameter],-1)+tail(pp[[1]][[doseIndex]][(pp[[1]][[doseIndex]][,"time"]/60<=15),	parameter],-1)))/2
		AUC20=	sum(diff(pp[[1]][[doseIndex]][(pp[[1]][[doseIndex]][,"time"]/60<=20),	"time"]/3600) * (head(pp[[1]][[doseIndex]][(pp[[1]][[doseIndex]][,"time"]/60<=20),	parameter],-1)+tail(pp[[1]][[doseIndex]][(pp[[1]][[doseIndex]][,"time"]/60<=20),	parameter],-1)))/2
		AUCall=	sum(diff(pp[[1]][[doseIndex]][										 ,	"time"]/3600) * (head(pp[[1]][[doseIndex]][										  ,	parameter],-1)+tail(pp[[1]][[doseIndex]][										,	parameter],-1)))/2
		
		PKParameters= cbind(CMax, TMax, AUC2_5, AUC5, AUC10, AUC15, AUC20, AUCall)
		PKParametersAllDoses= rbind(PKParametersAllDoses, PKParameters)
	}
	write.csv(PKParametersAllDoses, sprintf("%s/Subject%s.csv", outputFolder, subjectIndex))	
}