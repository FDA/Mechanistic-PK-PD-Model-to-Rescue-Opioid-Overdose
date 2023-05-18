#last edited by: Anik Chaturbedi
#on: 2022-02-24
getCardiacArrestAndRescueTime<-function(out){	
	CA_YN="yes"
	if(min(out[,"Cardiac output (l/min)"])>CABloodFlow){CA_YN="no"}
	
	t1Pn=out[,c("time")][out[,"Brain O2 partial pressure (mm Hg)"]<=SThBrainO2]
	tt1=t1Pn[1];tt2=t1Pn[length(t1Pn)];tt3=t1Pn[length(t1Pn)]-t1Pn[1];
	if (CA_YN=="no" & length(t1Pn)==0) { #no CA, no Pbo2>20mmhg
		tt1=0;tt2=0;tt3=0;}
	if (CA_YN=="no" & length(t1Pn)!=0) { #no CA, yes Pbo2<20mmhg
		tt1=t1Pn[1];tt2=t1Pn[length(t1Pn)]; } #tt3=t1Pn[length(t1Pn)]-t1Pn[1];	
	if (CA_YN=="yes" & length(t1Pn)==0) { #yes CA, no Pbo2>20mmhg
		tt1=0;tt2=0;tt3=60*60;}
	if (CA_YN=="yes" & length(t1Pn)!=0) { #yes CA, no Pbo2<20mmhg
		tt1=t1Pn[1];tt2=t1Pn[length(t1Pn)];tt3=60*60;}
	
	tAPn=out[,c("time")][out[,"Arterial O2 partial pressure (mm Hg)"]<=SThArterialO2]
	ttA1=tAPn[1];ttA2=tAPn[length(tAPn)];ttA3=tAPn[length(tAPn)]-tAPn[1];
	if (CA_YN=="no" & length(tAPn)==0) { #no CA, no PAo2>30mmhg
		ttA1=0;ttA2=0;ttA3=0;}
	if (CA_YN=="no" & length(tAPn)!=0) { #no CA, yes Pbo2<20mmhg
		ttA1=tAPn[1];ttA2=tAPn[length(tAPn)];}#ttA3=tAPn[length(tAPn)]-tAPn[1];
	if (CA_YN=="yes" & length(tAPn)==0) { #yes CA, no Pbo2>20mmhg
		ttA1=0;ttA2=0;ttA3=60*60;}
	if (CA_YN=="yes" & length(tAPn)!=0) { #yes CA, no Pbo2<20mmhg
		ttA1=tAPn[1];ttA2=tAPn[length(tAPn)];ttA3=60*60;}
	
	tSPn=out[,c("time")][out[,"Arterial O2 saturation (%)"]<=SThArterialO2Saturation]
	ttS1=tSPn[1];ttS2=tSPn[length(tSPn)];ttS3=tSPn[length(tSPn)]-tSPn[1];
	if (CA_YN=="no" & length(tSPn)==0) { #no CA, no PSo2<90mmhg
		ttS1=0;ttS2=0;ttS3=0;}
	if (CA_YN=="no" & length(tSPn)!=0) { #no CA, yes Pbo2<20mmhg
		ttS1=tSPn[1];ttS2=tSPn[length(tSPn)];}#ttS3=tSPn[length(tSPn)]-tSPn[1];
	if (CA_YN=="yes" & length(tSPn)==0) { #yes CA, no Pbo2>20mmhg
		ttS1=0;ttS2=0;ttS3=60*60;}
	if (CA_YN=="yes" & length(tSPn)!=0) { #yes CA, no Pbo2<20mmhg
		ttS1=tSPn[1];ttS2=tSPn[length(tSPn)];ttS3=60*60;}
	
	tCPn=out[,c("time")][out[,"Arterial CO2 partial pressure (mm Hg)"]>=SThArterialCO2]
	ttC1=tCPn[1];ttC2=tCPn[length(tCPn)];ttC3=tCPn[length(tCPn)]-tCPn[1];
	if (CA_YN=="no" & length(tCPn)==0) { #no CA, no PACo2<45mmhg
		ttC1=0;ttC2=0;ttC3=0;}
	if (CA_YN=="no" & length(tCPn)!=0) { #no CA, yes Pbo2<20mmhg
		ttC1=tCPn[1];ttC2=tCPn[length(tCPn)];}#ttC3=tCPn[length(tCPn)]-tCPn[1];
	if (CA_YN=="yes" & length(tCPn)==0) { #yes CA, no Pbo2>20mmhg
		ttC1=0;ttC2=0;ttC3=60*60;}
	if (CA_YN=="yes" & length(tCPn)!=0) { #yes CA, no Pbo2<20mmhg
		ttC1=tCPn[1];ttC2=tCPn[length(tCPn)];ttC3=60*60;}
	
	return(c(CA_YN,
					tt1,tt2,tt3,
					ttA1,ttA2,ttA3,
					ttS1,ttS2,ttS3,
					ttC1,ttC2,ttC3))
}