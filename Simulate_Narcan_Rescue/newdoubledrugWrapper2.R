drugWrapper<-function(idx, max_naloxone_doseN=4,naloxone_dose=4000000,delay=150, threshold=0.4,target=0.4,drug=drug){
	naloxone_dose=4000000 
	
  #idx is the idx of the job/core; or the index of the opioid concentration
  #naloxone_doseN is the dosing number of naloxone (0-4)
  #delay is the gap between two adjacent naloxone doses (s)
  #threshold is the ventilation volume at which the first dose of naloxone will be delivered
  #target is the ventilation volume targeted by naloxone to call a "rescue"                                                                                                                                     
  #deSolve and model should have been loaded in each core
  #opioid dose (uniqdose) should have been exported to each core
  
  opioid_dose<-uniqdose[idx]
  recovery_mat<-matrix(0,nrow=dim(allpatients)[1],ncol=max_naloxone_doseN)  #4 doses of naloxone
  recovery_mat11<-matrix(0,nrow=dim(allpatients)[1],ncol=max_naloxone_doseN)  #4 doses of naloxone
  patientventi1=c()
  Nal_Plasma=c()
  Naloxone_Peripheral=c()

  V0=12

	  
	  for(patientidx in 1:1){
		  
   this.par<-unlist(allpatients[patientidx,]) #this is pars; states should have been loaded in each core

   truepar<-this.par[!names(this.par)=="G0" & !names(this.par)=="Gmax" & !names(this.par)=="P1" & 
				   !names(this.par)=="P2" & !names(this.par)=="Bmax" & !names(this.par)=="initialdelay"]    #need to remove alpha EC50 Nclin from parameter
   write.csv(truepar,"truepar.csv")
   
   truepar["timeout"]<-30
   
    #first simulating no naloxone
     dosingoutput<-dosingevents(opioid_dose,opioid_time=0) 
     fulltimes<-dosingoutput[[1]]; eventdata<-dosingoutput[[2]]
     truepar["starttime"]<-unclass(as.POSIXct(strptime(date(),"%c")))[1]
     out <- ode(y=states, times=fulltimes, "derivs", parms=truepar, dllname="delaymymod",initfunc="initmod", nout=0, rtol=1e-3, atol=1e-6, method="lsoda",events=list(data=eventdata))

	 patientventi <- (this.par["G0"] - this.par["Gmax"]*(out[,"CAR"])^this.par["P1"])*(V0/this.par["G0"] - this.par["Bmax"]*(out[,"CAR"])^this.par["P2"])/V0
		
		
		patientventi[patientventi<0]<-0
	
	   patientventiN=patientventi

	 
      try({crossinglist <- crossing(patientventi,out[,"time"],threshold)},silent=T)
   
		rm(patientventi)
		
      if(!exists("crossinglist")){  #no crossing
  
		
         rm(out)
         next                  #this patient's row in recovery_mat is 0,0,0,0
       }else{
         crossingtime <- crossinglist[[2]][1]
         rm(out)                     #release memory
        rm(crossinglist)
       }
	   
      for(naloxone_doseN in 1:max_naloxone_doseN){
    
       dosingoutput<-dosingevents(opioid_dose, opioid_time=0,naloxone_time=crossingtime+this.par["initialdelay"], naloxone_doseN=naloxone_doseN,gap=delay)
        fulltimes<-dosingoutput[[1]]; eventdata<-dosingoutput[[2]]
        truepar["starttime"]<-unclass(as.POSIXct(strptime(date(),"%c")))[1]
		
		out <- ode(y=states, times=fulltimes, "derivs", parms=truepar, dllname="delaymymod",initfunc="initmod", nout=0, rtol=1e-3, atol=1e-6, method="lsoda",events=list(data=eventdata))

	patientventi <- (this.par["G0"] - this.par["Gmax"]*(out[,"CAR"])^this.par["P1"])*(V0/this.par["G0"] - this.par["Bmax"]*(out[,"CAR"])^this.par["P2"])/V0
	
	
	patientventi[patientventi<0]<-0
	   Nal_P<-out[,c("PlasmaN")]
	   
      try({crossinglist <- crossing(patientventi,out[,"time"],target)}) #crossinglist has to exist!
        rm(out)
      if(length(crossinglist[[2]])==1){ #only initial crossing; no revoery
         recovery_mat[patientidx, naloxone_doseN]<- Inf
         
        }else{
         recovery_mat[patientidx, naloxone_doseN]<- crossinglist[[2]][2]-(crossinglist[[2]][1]+this.par["initialdelay"])
        }#if crossing

		
		
			patientventi1=cbind(patientventi1,patientventi)
			Nal_Plasma=cbind(Nal_Plasma,Nal_P)
		
	
        rm(crossinglist); rm(patientventi);rm(eventdata)
		
		
       }#for naloxone_doseN
	   patientventi1=cbind(fulltimes/60,patientventiN,patientventi1)
	   Nal_Plasma=cbind(fulltimes/60,patientventiN,Nal_Plasma)
	   
	   write.csv(patientventi1,sprintf("Figure_Generation/Data/NARCAN_NEW_D%s_%s_order2_two_N%s_OD%s_Nc%sEX_V0_%s.csv",delay,drug,naloxone_doseN,opioid_dose,naloxone_dose/1000000,V0))


      }#for patient
        recovery_mat
}