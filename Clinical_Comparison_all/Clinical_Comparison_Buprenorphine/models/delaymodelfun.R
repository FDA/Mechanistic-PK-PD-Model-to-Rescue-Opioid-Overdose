modelfun <- function(Time, State, Pars){
currenttime<-unclass(as.POSIXct(strptime(date(),"%c")))[1] 
if(currenttime - Pars["starttime"]>=Pars["timeout"])
 stop("timeout!"); 
  with(as.list(c(State, Pars)), {
ReactionFlux1=koutn*PlasmaN
ReactionFlux2=k1n*PlasmaN*1e9/(327.27*12.1)
ReactionFlux3=k12n*PlasmaN
ReactionFlux4=k21n*C2n
ReactionFlux5=koutb*PlasmaB
ReactionFlux6=k1b*PlasmaB*1e9/(5.71*467.64)
ReactionFlux7=k12b*PlasmaB
ReactionFlux8=k21b*C2b
ReactionFlux9=k13b*PlasmaB
ReactionFlux10=k31b*C3b
ReactionFlux11=k1n*N
ReactionFlux12=k1b*L
ReactionFlux13=A1*(1-CAR-CBR)*exp(n*log(L))
ReactionFlux14=B1*CAR
ReactionFlux15=A2*(1-CAR-CBR)*exp(n2*log(N))
ReactionFlux16=B2*CBR
dPlasmaN=(ReactionFlux4-ReactionFlux1-ReactionFlux3)
dN=ReactionFlux2-ReactionFlux11
dPlasmaB=-ReactionFlux5-ReactionFlux7+ReactionFlux8-ReactionFlux9+ReactionFlux10
dC2n=ReactionFlux3-ReactionFlux4
dC2b=ReactionFlux7-ReactionFlux8
dC3b=ReactionFlux9-ReactionFlux10
dL=ReactionFlux6-ReactionFlux12
dCAR=ReactionFlux13-ReactionFlux14
dCBR=ReactionFlux15-ReactionFlux16
    return(list(c(dPlasmaN,dN,dPlasmaB,dC2n,dC2b,dC3b,dL,dCAR,dCBR)))
})}