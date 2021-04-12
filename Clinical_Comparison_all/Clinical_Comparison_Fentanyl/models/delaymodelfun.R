modelfun <- function(Time, State, Pars){
currenttime<-unclass(as.POSIXct(strptime(date(),"%c")))[1] 
if(currenttime - Pars["starttime"]>=Pars["timeout"])
 stop("timeout!"); 
  with(as.list(c(State, Pars)), {
ReactionFlux1=(1-F1)*ktr*D
ReactionFlux2=ktr*F1*D
ReactionFlux3=ktr*NT1
ReactionFlux4=1*kin*NT2
ReactionFlux5=kout2*PlasmaN
ReactionFlux6=k2*PlasmaN*1e6/(327.27)
ReactionFlux7=k2*N
ReactionFlux8=kout*PlasmaF
ReactionFlux9=k12*PlasmaF
ReactionFlux90=k13*PlasmaF
ReactionFlux10=k21*C2
ReactionFlux100=k31*C3
ReactionFlux11=k1*1e6*PlasmaF*1000/10.5/Mmass
ReactionFlux12=k1*L
ReactionFlux13=A1*(1-CAR-CBR)*exp(n*log(L))
ReactionFlux14=B1*CAR
ReactionFlux15=A2*(1-CAR-CBR)*exp(n2*log(N))
ReactionFlux16=B2*CBR
ReactionFlux17=FIV/Infu_t
dD=-ReactionFlux2-ReactionFlux1
dNT1=ReactionFlux2-ReactionFlux3
dNT2=-ReactionFlux4+ReactionFlux3
dPlasmaN=(1/V1)*(ReactionFlux4-ReactionFlux5)
dN=ReactionFlux6-ReactionFlux7
dPlasmaF=-ReactionFlux8-ReactionFlux9+ReactionFlux10+ReactionFlux100-ReactionFlux90+ReactionFlux17
dC2=ReactionFlux9-ReactionFlux10
dC3=ReactionFlux90-ReactionFlux100
dL=ReactionFlux11-ReactionFlux12
dCAR=ReactionFlux13-ReactionFlux14
dCBR=ReactionFlux15-ReactionFlux16
dFIV=0
    return(list(c(dD,dNT1,dNT2,dPlasmaN,dN,dPlasmaF,dC2,dC3,dL,dCAR,dCBR,dFIV)))
})}