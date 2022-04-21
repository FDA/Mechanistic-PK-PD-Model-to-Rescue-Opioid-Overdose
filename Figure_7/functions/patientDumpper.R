drugWrapper<-function(idx, max_naloxone_doseN=4,naloxone_dose=4000000,delay=120, threshold=0.6){
  
  #idx is the idx of the job/core; or the index of the opioid concentration
  #naloxone_doseN is the dosing number of naloxone (0-4)
  #delay is the gap between two adjacent naloxone doses (s)
  #threshold is the ventilation volume at which the first dose of naloxone will be delivered
                                                                                                                                         
  #deSolve and model should have been loaded in each core
  #opioid dose (uniqdose) should have been exported to each core
  
  opioid_dose<-uniqdose[idx]
  stdmat<-data.frame(time=c(seq(0,300,1),seq(305,3600,5)))    #all patients need to have exactly the same output time points
  
  for(patientidx in 1:dim(allpatients)[1]){
   this.par<-unlist(allpatients[patientidx,]) #this is pars; states should have been loaded in each core
  
   truepar<-this.par[!names(this.par)=="alpha"]    #need to remove alpha from parameter
   truepar["timeout"]<-30
 
    #first simulating no naloxone
     dosingoutput<-dosingevents(opioid_dose,opioid_time=0) 
     fulltimes<-dosingoutput[[1]]; eventdata<-dosingoutput[[2]]
     
     truepar["starttime"]<-unclass(as.POSIXct(strptime(date(),"%c")))[1]
     out <- ode(y=states, times=fulltimes, "derivs", parms=truepar, dllname="delaymymod",initfunc="initmod", nout=0, rtol=1e-3, atol=1e-6, method="lsoda",events=list(data=eventdata))
     tempout<-merge(out,stdmat)                          #only keep standard time points
     #always dump control conditions
      tempdf<-data.frame(allpatients[patientidx,c("k1","k12","k21","kout",
                                                          "A1","B1","n","A2","B2","n2",
                                                          "alpha")],
                           opioid_dose=opioid_dose,naloxone_doseN=0,delay=0,threshold=0,
                           formatC(t(tempout[,"CAR"]),format="e",digits=2)) 
        outputfile<-paste0("/scratch/lizhi/opioids/",drug,"_",idx,"_",delay,"_",threshold,"_bs",bsidx)
        write.table(tempdf,outputfile,sep=",",quote=F,col.names=F,row.names=F,append=T)
      patientventi <- 1 - this.par["alpha"]*out[,"CAR"]
      try({crossinglist <- crossing(patientventi,out[,"time"],threshold)},silent=T)
    
      rm(patientventi)
      if(!exists("crossinglist")){  #no crossing
             
      
         rm(out); rm(tempout)
         next                 
                }else{
     
         crossingtime <- crossinglist[[2]][1]
         
        rm(crossinglist)
       }
        
      for(naloxone_doseN in 1:4){
      
       dosingoutput<-dosingevents(opioid_dose, opioid_time=0,naloxone_time=crossingtime, naloxone_doseN=naloxone_doseN,gap=delay)
        fulltimes<-dosingoutput[[1]]; eventdata<-dosingoutput[[2]]
        
        truepar["starttime"]<-unclass(as.POSIXct(strptime(date(),"%c")))[1]
        out <- ode(y=states, times=fulltimes, "derivs", parms=truepar, dllname="delaymymod",initfunc="initmod", nout=0, rtol=1e-3, atol=1e-6, method="lsoda",events=list(data=eventdata))
        tempout<-merge(out, stdmat)                         #only keep standard time points
        tempdf<-data.frame(allpatients[patientidx,c("k1","k12","k21","kout",
                                                          "A1","B1","n","A2","B2","n2",
                                                          "alpha")],
                           opioid_dose=opioid_dose,naloxone_doseN=naloxone_doseN,delay=delay,threshold=threshold,
                           formatC(t(tempout[,"CAR"]),format="e",digits=2)) 
        outputfile<-paste0("/scratch/lizhi/opioids/",drug,"_",idx,"_",delay,"_",threshold,"_bs",bsidx)
        write.table(tempdf,outputfile,sep=",",quote=F,col.names=F,row.names=F,append=T)
        rm(out); rm(tempout)
     
       }#for naloxone_doseN
      }#for patient
        idx
}