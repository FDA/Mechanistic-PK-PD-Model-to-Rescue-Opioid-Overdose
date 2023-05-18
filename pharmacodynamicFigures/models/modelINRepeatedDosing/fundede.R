#last edited by: Anik Chaturbedi
#on: 2022-01-12
fundede<-function(states, fulltimes, truepar, namesyout){
	out=list()
	truepar["starttime"]<-unclass(as.POSIXct(strptime(date(),"%c")))[1]
	try({out <- dede(states, fulltimes, "derivs", parms=truepar, dllname="delaymymod",initfunc="initmod", nout=length(namesyout), rtol=1e-14, atol=1e-14, method="adams", n_history = 100000)});
	colnames(out)[(length(states)+2):(length(states)+length(namesyout)+1)]=namesyout
	out
}