fundede<-function(states, fulltimes,truepar,namesyout){
	out=list()
	truepar["starttime"]<-unclass(as.POSIXct(strptime(date(),"%c")))[1]
	try({out <- dede(states, fulltimes, "derivs", parms=truepar, dllname="delaymymod",initfunc="initmod", nout=24,n_history = 100000, rtol=1e-14, atol=1e-14, method="adams")});
	colnames(out)[(length(states)+2):(length(states)+length(namesyout)+1)]=namesyout
	out
}