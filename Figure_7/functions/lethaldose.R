patientWrapper<-function(patientidx,doseidx, max_naloxone_doseN=4,naloxone_dose=4000000,delay=120, threshold=0.6,truepar=truepar,states=states){
	#source("Events.R"); source("crossing.R");
  #idx is the idx of the job/core; or the index of the opioid concentration
  #naloxone_doseN is the dosing number of naloxone (0-4)
  #delay is the gap between two adjacent naloxone doses (s)
  #threshold is the ventilation volume at which the first dose of naloxone will be delivered
                                                                                                                                         
  #deSolve and model should have been loaded in each core
  #opioid dose (uniqdose) should have been exported to each core

  opioid_dose<-uniqdose[doseidx]
 
  outlist<-list(); crossingtimelist<-list(); ventilist<-list();
  this.par<-unlist(allpatients[patientidx,]) #this is pars; states should have been loaded in each core
  
  #truepar<-this.par[!names(this.par)=="initialdelay" & !names(this.par)=="Dose"] 
  
 
    #first simulating no naloxone
     dosingoutput<-dosingevents(opioid_dose,opioid_time=0) 
#	 print(dosingoutput)
#	 print("ssssssss")
     fulltimes<-dosingoutput[[1]]; eventdata<-dosingoutput[[2]]
     #truepar["starttime"]<-unclass(as.POSIXct(strptime(date(),"%c")))[1]
     #out <- ode(y=states, times=fulltimes, "derivs", parms=truepar, dllname="delaymymod",initfunc="initmod", nout=0, rtol=1e-3, atol=1e-6, method="lsoda",events=list(data=eventdata))

#print(truepar)
#    print("------------------------------")
#	print(truepar)
#	print("pppppppppppppppp")
#	print(states)
	truepar["starttime"]<-unclass(as.POSIXct(strptime(date(),"%c")))[1]
	
	#fdfd
	#out <- dede(y=states, times=fulltimes, "derivs", parms=truepar, dllname="delaymymod",initfunc="initmod", nout=11, rtol=1e-6, atol=1e-9, method="lsoda",events=list(data=eventdata))
#	out <- dede(y=states, times=fulltimes, func=modelfun, parms=truepar, rtol=1e-6, atol=1e-12, method="lsoda",events=list(data=eventdata))
	dyn.load("models/delaymymod.so")
#	print(states)
	fulltimes=seq(0,3600,1) #donot use large time step
	states["PlasmaF"]=2 #check by Zhihua 
#	try({out <- dede(states, fulltimes, "derivs", parms=truepar, dllname="delaymymod",initfunc="initmod", nout=33, rtol=1e-9, atol=1e-9, method="lsoda")});
#	colnames(out)[(length(states)+2):(length(states)+length(namesyout)+1)]=namesyout
	out=fundede(states=states,fulltimes=fulltimes,truepar=truepar,namesyout=namesyout)
	
	#print("ssss")
#	print(tail(out))
	
#	ssskkkkkkk
	
	#	print(head(out))
#	print("eeeee")
	#colnames(out)[24:34]=c("C_a_co2","P_a_co2","C_a_o2","C_V_co2","C_e_co2","C_Vb_co2","C_Vt_co2","delayedP_A_o2","Dc","Dp","W") 

#	sss

	#out <- ode(y=states, times=fulltimes, func=modelfun, parms=truepar, rtol=1e-6, atol=1e-9, method="lsoda",events=list(data=eventdata))
	 patientventi<-out[,"Venti"]

	 patientventi[patientventi<0]<-0
      try({crossinglist <- crossing(patientventi,out[,"time"],threshold)},silent=T)
      ventilist[[1]]<- patientventi
      
      rm(patientventi)
      outlist[[1]]<- out
      if(!exists("crossinglist")){  #no crossing
      # crossingtimelist[[1]]<- Inf
       
        return(list(outlist,ventilist))
       }else{
         
         crossingtime <- crossinglist[[2]][1]
         crossingtimelist[[1]]<-crossingtime
         rm(out)                     #release memory
        rm(crossinglist)
       }
#	   print(head(out))
#	   print("000000000000")
iman="xxx"
if (iman=="no") {
      for(naloxone_doseN in 1:max_naloxone_doseN){
       #print(paste("try pateint ",patientidx," for naloxone dose ",naloxone_doseN))
       dosingoutput<-dosingevents(opioid_dose, opioid_time=0,naloxone_time=crossingtime+this.par["initialdelay"], naloxone_doseN=naloxone_doseN,gap=delay)
        fulltimes<-dosingoutput[[1]]; eventdata<-dosingoutput[[2]]
        truepar["starttime"]<-unclass(as.POSIXct(strptime(date(),"%c")))[1]
        #out <- ode(y=states, times=fulltimes, "derivs", parms=truepar, dllname="delaymymod",initfunc="initmod", nout=0, rtol=1e-3, atol=1e-6, method="lsoda",events=list(data=eventdata))
	out <- dede(y=states, times=fulltimes, "derivs", parms=truepar, dllname="delaymymod",initfunc="initmod", nout=11, rtol=1e-6, atol=1e-9, method="lsoda",events=list(data=eventdata))
	#colnames(out)[24:30]=c("C_a_co2","P_a_co2","C_a_o2","C_V_co2","C_e_co2","C_Vb_co2","C_Vt_co2","delayedP_A_o2")	
		colnames(out)[24:34]=c("C_a_co2","P_a_co2","C_a_o2","C_V_co2","C_e_co2","C_Vb_co2","C_Vt_co2","delayedP_A_o2","Dc","Dp","W") 
		
	#out <- dede(y=states, times=fulltimes, func=modelfun, parms=truepar, rtol=1e-6, atol=1e-9, method="lsoda",events=list(data=eventdata))
		patientventi<-out[,"Venti"]
		
		patientventi[patientventi<0]<-0
       
        ventilist[[naloxone_doseN+1]]<-patientventi
      try({crossinglist <- crossing(patientventi,out[,"time"],threshold)}) #crossinglist has to exist!
        outlist[[naloxone_doseN+1]]<-out
        rm(out)
      if(length(crossinglist[[2]])==1){ #only initial crossing; no revoery
       #  crossingtimelist[[naloxone_doseN+1]]<- Inf
         
        }else{
         crossingtimelist[[naloxone_doseN+1]]<- crossinglist[[2]][2]-crossinglist[[2]][1]+this.par["initialdelay"]
        }#if crossing
        rm(crossinglist); rm(patientventi);rm(eventdata)
       }#for naloxone_doseN
   }
        list(outlist,ventilist)
}