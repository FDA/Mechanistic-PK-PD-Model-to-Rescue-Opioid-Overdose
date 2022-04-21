EmaxfVP1 <- function(ind){
	
	print("VP1")
	ind_Selected=ind[c("k1","P1","P2","P3","Wmax")]
	
#nptarget=names(truepar)%in%names(ind_Selected)
#truepar[nptarget]=ind_Selected
	nptarget=match(names(truepar), names(ind_Selected), nomatch=0)
	truepar[nptarget!=0]<- ind_Selected[nptarget]
truepar=unlist(truepar)

	patient_case="Naive" #later combine Naive and chronic
	
#-----------load Experimental data-----------
	naive<-read.csv("small data for naive occupancy curve.csv",header=T)
	chronic<-read.csv("small data for chronic occupancy curve.csv",header=T)
	colnames(naive)<-c("x","CAR","Efr")
	colnames(chronic)<-colnames(naive)
	
	

	if (patient_case=="Naive") {
		selectedrowidx<- seq(1, dim(naive)[1], by=round(dim(naive)[1]/10))
		selectedrowidx<-c(selectedrowidx,dim(naive)[1])
		selected<-naive[selectedrowidx,]
		
	}
	if (patient_case=="Chronic") {
		selectedrowidx<-seq(1, dim(chronic)[1], by=round(dim(chronic)[1]/10))
		selectedrowidx<-c(selectedrowidx,dim(chronic)[1])
		selected<-chronic[selectedrowidx,]
	}



#-------------------------------------------
#steady state by changing P_A_o2 and P_A_co2
	
fulltimes=seq(0,30*60,1)
out=fundede(states=states,fulltimes=fulltimes,truepar=truepar,namesyout=namesyout)
states1=out[nrow(out),names(states)]

#then steady state by fixing P_A_o2, P_A_co2, and CAR
truepar["offO2"]=0
truepar["offCo2"]=0

states1["P_A_co2"]=50
states1["P_A_o2"]=102

truepar["A1"]=0; truepar["B1"]=0;
fulltimes=seq(0,120*60,1)
errorvec<-rep(0, dim(selected)[1])
for(i in 1:dim(selected)[1]){
	
	#first 60 min fix CO2 and O2 without drug, 2nd 60 min fix CAR in addition
	eventdata<-data.frame(var="CAR",time=60*60,value=selected[i,"CAR"],method="rep")
	out1=fundedewithEvent(states=states1,fulltimes=fulltimes,truepar=truepar,namesyout=namesyout,eventdata=eventdata)
	thiserror<- (out1[dim(out1)[1],"Venti"]/out1[60*60,"Venti"] - selected[i,"Efr"])^2
	errorvec[i]<-thiserror
	
}


EVP1=sum(errorvec)

}