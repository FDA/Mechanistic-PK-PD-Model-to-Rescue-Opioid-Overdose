drugWrapper<-function(idx, max_naloxone_doseN=6,naloxone_dose=4000000,delay=120, threshold=0.6){
 library(ggplot2) 
  #idx is the idx of the job/core; or the index of the opioid concentration
  #naloxone_doseN is the dosing number of naloxone (0-4)
  #delay is the gap between two adjacent naloxone doses (s)
  #threshold is the ventilation volume at which the first dose of naloxone will be delivered
                                                                                                                                         
  #deSolve and model should have been loaded in each core
  #opioid dose (uniqdose) should have been exported to each core
	#max_naloxone_doseN=6
  opioid_dose<-uniqdose[idx]
  recovery_mat<-matrix(0,nrow=dim(allpatients)[1],ncol=max_naloxone_doseN)  #4 doses of naloxone
  
  for(patientidx in 1:dim(allpatients)[1]){
   this.par<-unlist(allpatients[patientidx,]) #this is pars; states should have been loaded in each core
  
   truepar<-this.par[!names(this.par)=="alpha"]    #need to remove alpha from parameter
   truepar["timeout"]<-30
 
    #first simulating no naloxone
     dosingoutput<-dosingevents(opioid_dose,opioid_time=0) 
     fulltimes<-dosingoutput[[1]]; eventdata<-dosingoutput[[2]]
     truepar["starttime"]<-unclass(as.POSIXct(strptime(date(),"%c")))[1]
     out <- ode(y=states, times=fulltimes, "derivs", parms=truepar, dllname="delaymymod",initfunc="initmod", nout=0, rtol=1e-3, atol=1e-6, method="lsoda",events=list(data=eventdata))
	
      patientventi <- 1 - this.par["alpha"]*out[,"CAR"]
	  print(patientventi)
	  #CAR<-mean(out[,"CAR"])
		outdf<-data.frame(out)
	  CAR<-outdf$CAR[outdf$time==3600]
		Output<-cbind(opioid_dose,CAR)
	  write.csv(Output,paste0("Fentanyl_NWC_parameters/CARMolarMass_Last_wc_95.csv"))
	  #pdf("Fentanyl_NWC_parameters/CAR_real_D95.pdf")
	  #plot(out[,"time"],out[,"CAR"])
	  #dev.off()
      try({crossinglist <- crossing(patientventi,out[,"time"],threshold)},silent=T)
	
	  
     # print(paste("just tried patient ",patientidx))
      rm(patientventi)
      if(!exists("crossinglist")){  #no crossing
         print(paste0("pateint ",patientidx," has no initial crossing"))
         rm(out)
         next                  #this patient's row in recovery_mat is 0,0,0,0
       }else{
      #   print(paste("pateint ",patientidx," has an initial crossing"))
         crossingtime <- crossinglist[[2]][1]
         rm(out)                     #release memory
        rm(crossinglist)
       }

      for(naloxone_doseN in 1:6){
       #print(paste("try pateint ",patientidx," for naloxone dose ",naloxone_doseN))
       dosingoutput<-dosingevents(opioid_dose, opioid_time=0,naloxone_time=crossingtime, naloxone_doseN=naloxone_doseN,gap=delay)
        fulltimes<-dosingoutput[[1]]; eventdata<-dosingoutput[[2]]
        truepar["starttime"]<-unclass(as.POSIXct(strptime(date(),"%c")))[1]
		
        out <- ode(y=states, times=fulltimes, "derivs", parms=truepar, dllname="delaymymod",initfunc="initmod", nout=0, rtol=1e-3, atol=1e-6, method="lsoda",events=list(data=eventdata))
        patientventi <- 1 - this.par["alpha"]*out[,"CAR"]
		#sss
      try({crossinglist <- crossing(patientventi,out[,"time"],threshold)}) #crossinglist has to exist!
        rm(out)
		#if (length(crossinglist[[2]])==0) {next}

      if(length(crossinglist[[2]])==1){ #only initial crossing; no revoery
		  
         recovery_mat[patientidx, naloxone_doseN]<- Inf
		# dddd
        }else{
         recovery_mat[patientidx, naloxone_doseN]<- crossinglist[[2]][2]-crossinglist[[2]][1]
        }#if crossing
        rm(crossinglist); rm(patientventi);rm(eventdata)
       }#for naloxone_doseN
      }#for patient
        recovery_mat
		
}