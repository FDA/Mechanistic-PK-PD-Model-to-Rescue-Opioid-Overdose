Route<-"NARCAN"
dose<-4
V0<-12



library(optparse)
parser<-OptionParser()

parser<-add_option(parser, c("-d", "--drug"), default="Fentanyl_A",type="character", help="Opioid ligand. Either Fentanyl or Carfentanil ")


args<-parse_args(parser)

drugnames<-gsub(" ","",args$drug)

for(drug in drugnames){

if(drug=="Fentanyl_A"){
conc_vals<-	c(.44,.88,1.93,7.65)
}

if(drug=="Carfentanil"){
	conc_vals <- c(0.0362, 0.058, 0.105, 1.62)
}



pdf(sprintf("figs/%s_NARCAN_Ventilation.pdf",drug))

Temp_F<-data.frame(matrix(NA, nrow = 4, ncol = 1))
#drug<-"Carfentanil"
for (i in conc_vals ) { 	
temp2<-read.csv(sprintf("Data/%s_NEW_D150_%s_order2_two_N4_OD%s_Nc%sEX_V0_%s.csv",Route,drug,i,dose,V0))
	
	

		colnames(temp2)=c("t","time","N0","N1","N2","N3","N4")
	temptt2<-temp2[temp2$time<20,]
		O3=which(abs(temptt2$N0-.4)==min(abs(temptt2$N0-.4)))
		temp2$time=temp2$time-temp2$time[O3]-2.5
		
		print(temp2$time[O3])
		
		print("-----Fent------")
		Temp_Set2<-c()
		for (kk in 1:3) {
			thre=c(.2,.4,.8)
			threi=thre[kk]
			Temp_Vals2<-c()
			for (j in 1:4) {
				temp21=temp2[temp2$time>2,]
				O4=which(abs(temp21[,(j+3)]-threi)==min(abs(temp21[,(j+3)]-threi)))

				print(paste0("thresh_",threi))
				print(temp21$time[O4])
				Temp_Vals2<-rbind(Temp_Vals2,temp21$time[O4])
				
			}
			
			Temp_Set2<-cbind(Temp_Set2,Temp_Vals2)
		}
		
		Temp_Set2<-data.frame(Temp_Set2)
		names(Temp_Set2)<-c(sprintf("TH_20__conc_%s",i),sprintf("TH_40_conc_%s",i),sprintf("TH_80_conc_%s",i))
		
		
		Temp_F<-cbind(Temp_F,Temp_Set2)

	temp2=temp2[temp2$time<20,]
	temp2=temp2[,-1]
	
	colvec<-c("cyan","orange","green","blue","purple","black")
	
	
	temper=which(abs(temp2$time-2.5)==min(abs(temp2$time-2.5)))
	temper2=which(abs(temp2$time-5)==min(abs(temp2$time-5)))
	temper3=which(abs(temp2$time-7.5)==min(abs(temp2$time-7.5)))
	temper4=which(abs(temp2$time-0)==min(abs(temp2$time-0)))
	
	
	plot(temp2$time,temp2$N0*100, col="cyan", pch="19",type="l",lty=1, ylim=c(0,100),main=paste0("Fentanyl ","dose=",i,"mg IV"),
			ylab="Ventilation(% of baseline)",xlab="Time (min)")
	lines(temp2$time,temp2$N1*100, col="orange")
	points(x=temp2$time[temper],0,col="black",pch=19,cex=1.5)  # First Naloxone Administration
	lines(temp2$time,temp2$N2*100, col="green")
	points(x=temp2$time[temper2],0,col="black",pch=19,cex=1.5) # Second Naloxone Administration
	
	lines(temp2$time,temp2$N3*100,col="blue")
	points(x=temp2$time[temper3],0,col="black",pch=19,cex=1.5) # Third Naloxone Administration
	
	lines(temp2$time,temp2$N4*100,col="purple")
	points(x=temp2$time[temper4],0,col="black",pch=19,cex=1.5) # Fourth Naloxone Administration
	
	abline(h = 40, col="black", lwd=3, lty=2)
legend("topleft",legend=c("No Naloxone",paste0("1 dose of ",Route), paste0("2 doses of ",Route),
				paste0("3 doses of ",Route), paste0("4 doses of ",Route)),fill=colvec[1:5])

print(temp2$time[temper])
}

dev.off()

Temp_F[,1]<-c("One","Two","Three","Four")
colnames(Temp_F)[1]<-c("Naloxone Doses")

write.csv(Temp_F,file=sprintf("results/%s_Full_Rescue_Time_%s.csv",drug,Route))

}