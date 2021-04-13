ODEs <- readChar("newODEs.txt",file.info("newODEs.txt")$size)
tokens <- strsplit(ODEs,"\n\n")
system("rm -f delaymymod.c delaymodelfun.R delaypars.R delaystates.R")

#for equations
equations <- substring(tokens[[1]][1],7)
equationvec <- strsplit(equations,"\n")
equationprocessed <- sub("d\\((.+)\\)/dt(.+)", "d\\1\\2",equationvec[[1]])
species <- sub("(d.+)=.+", "\\1", equationprocessed,perl = T)
equationsval <- sub("d(.+)=(.+)","\\2", equationprocessed, perl = T)
names(equationsval)<-species

#for fluxes
fluxes <- substring(tokens[[1]][2],9)
fluxesvec <- strsplit(fluxes,"\n")
fluxesval <- sub("(.+)\\s?=\\s?(.+)","\\2", fluxesvec[[1]], perl = T)
names(fluxesval)<-sub("(.+)\\s?=\\s?(.+)","\\1", fluxesvec[[1]], perl = T)

#for initials. Note sometimes there are more species in here than the equations
states <- substring(tokens[[1]][4],20)
statesvec <- strsplit(states, "\n")
statespecies <- sub("(.+)=.+","\\1",statesvec[[1]], perl = T)
idxlag<-regexpr("^lag\\d+.+",statespecies,perl=T) > 0
lagspecies<-statespecies[idxlag]
statespecies<-statespecies[!idxlag]
lagstatesvec<-statesvec[[1]][idxlag]
statesvec<-statesvec[[1]][!idxlag]

tempspecies<-paste("d",statespecies,sep="")
idx<-tempspecies%in%species

#for parameters. Note I added two additional parameters here
pars <- substring(tokens[[1]][3],18)
#add two additional parameters!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
pars<- paste(pars,"\ntimeout=30\nstarttime=0",sep="")
parsvec <- strsplit(pars, "\n")
parsname <- sub("(.+)\\s?=\\s?(.+)","\\1", parsvec[[1]], perl = T)

#prepare for c code

#lagged spcies
ytau<-paste("ytau[",0:(length(lagspecies)-1),"]",sep="")
names(ytau)<-lagspecies

y<-paste("y[",0:(length(tempspecies)-1),"]",sep="")
names(y)<-substring(tempspecies,2)
#replace lag species in fluxesval
for(f in 1:length(ytau)){
   replacement<-paste("\\1",ytau[f],"\\2",sep="")
   #replaced<-paste("^(.*)",names(ytau)[f],"((\\W.*$)|$)",sep="") #in case one species name is the substring of another
    replaced1<-paste("([+-/*\\(])",names(ytau)[f],"([+-/*\\)\\^])",sep="")   #use three replaced for three scenarios so that backreferences don't overlap!
    replaced2<-paste("(^)",names(ytau)[f],"([+-/*\\)\\^])",sep="")
     replaced3<-paste("([+-/*\\(])",names(ytau)[f],"($)",sep="")
  fluxesval<- gsub(replaced1, replacement, fluxesval,perl=T)
   fluxesval<- gsub(replaced2, replacement, fluxesval,perl=T)
  fluxesval<- gsub(replaced3, replacement, fluxesval,perl=T)

}
#replace species in fluxesval
for(f in 1:length(y)){
   replacement<-paste("\\1",y[f],"\\2",sep="")
    replaced1<-paste("([+-/*\\(])",names(y)[f],"([+-/*\\)\\^])",sep="") 
    replaced2<-paste("(^)",names(y)[f],"([+-/*\\)\\^\\s])",sep="")
     replaced3<-paste("([+-/*\\(])",names(y)[f],"($)",sep="")
   fluxesval<- gsub(replaced1, replacement, fluxesval,perl=T)
  fluxesval<- gsub(replaced2, replacement, fluxesval,perl=T)
  fluxesval<- gsub(replaced3, replacement, fluxesval,perl=T)

}#end replacing fluxesval



#replace equationsval
for(f in 1:length(fluxesval)){
   replacement<-paste("\\1(",fluxesval[f],")\\2",sep="")
   replaced<-paste("^(.*)",names(fluxesval)[f],"((\\D.*)|$)",sep="")
  equationsval<- gsub(replaced, replacement, equationsval,perl=T)  #if replaced is followed by a digit, it may be substring of another reactionflux (ReactionFlux2 vs ReactionFlux21)

}#end replacing


#writing files
sink("delaymodelfun.R")
cat("modelfun <- function(Time, State, Pars){", sep = "\n");
cat('currenttime<-unclass(as.POSIXct(strptime(date(),"%c")))[1] \n');
cat('if(currenttime - Pars["starttime"]>=Pars["timeout"])\n')
cat(' stop("timeout!"); \n');

cat("  with(as.list(c(State, Pars)), {",sep = "\n");
#lag definition
laglist<-strsplit(lagstatesvec,"=")
if(length(laglist)>0){
for(l in 1:length(laglist)){
 token<-strsplit(laglist[[l]],"_")[[1]][1]
 lagtime<-substr(token,4,nchar(token))
 cat(paste("if(Time<",lagtime,"){",sep=""));
 cat("\n");
 cat(paste(laglist[[l]][1],"<-",laglist[[l]][2],sep=""));
 cat("\n");
 cat("}else{\n");
 idx<-which(statespecies==strsplit(laglist[[l]],"_")[[1]][2])
 cat(paste(laglist[[l]][1],"<- lagvalue(Time - ",lagtime,",",idx,")",sep=""));
 cat("}\n");
}#for l 
}

cat(fluxes,sep = "\n")
cat(equationprocessed, sep = "\n")
for(i in tempspecies[!idx]){
cat(i)
cat("=0")
cat("\n")
}
cat("    return(list(c(");
cat(tempspecies, sep = ",");
cat(")))",sep = "\n");
cat("})}");
sink()

sink("delaymymod.c")
cat("#include <R.h>",sep="\n");
cat("#include <Rinternals.h>",sep="\n");
cat("#include <Rdefines.h>",sep="\n");
cat("#include <R_ext/Rdynload.h>",sep="\n");
cat("#include <time.h>\n");
numpars<-length(parsname);
cat(paste("static double parms[",numpars,"];",sep=""),sep="\n");
for(p in 0:(numpars-1)){
 cat(paste("#define ",parsname[p+1]," parms[",p,"]",sep=""),sep="\n");
 }#for p

cat("\n");     #lagvalue function
cat('void lagvalue(double *T, int *nr, int N, double *yout) {\nstatic void(*fun)(double*, int*, int, double*) = NULL;\nif(fun==NULL)\nfun =  (void(*)(double*, int*, int, double*))R_GetCCallable("deSolve", "lagvalue");\nreturn fun(T, nr, N, yout);\n}\n')
cat('void lagderiv(double *T, int *nr, int N, double *yout) {\nstatic void(*fun)(double*, int*, int, double*) = NULL;\nif (fun == NULL)\nfun =  (void(*)(double*, int*, int, double*))R_GetCCallable("deSolve", "lagvalue");\nreturn fun(T, nr, N, yout);\n}\n')


cat("\n");       #initializer
cat("void initmod(void (* odeparms)(int *, double *)){",sep="\n");    #note in this version it has to be initmod not inimod!
cat(paste("int N=",numpars,";",sep=""),sep="\n");
cat("odeparms(&N, parms);}",sep="\n");

cat("\n");           #derivatives
cat("void derivs (int *neq, double *t, double *y, double *ydot, double *yout, int *ip){",sep="\n");
#decided to output the lagspecies (nout=2)
cat('if (ip[0] <',length(laglist),') error("nout not enough!");\n');
cat("time_t s = time(NULL);\n");
cat('if((int) s - (int) starttime > timeout) error("timeout!");\n');


if(length(laglist)>0){
cat("double ytau[",length(laglist),"] = {", paste(sapply(laglist,function(x) x[2]),collapse=",",sep=""),"};\n",sep="");
#each lagspecies has its own set of parameters?
for(l in 1:length(laglist)){
 token<-strsplit(laglist[[l]],"_")[[1]][1]
 lagtime<-substr(token,4,nchar(token))
 idx<-which(statespecies==strsplit(laglist[[l]],"_")[[1]][2])
 cat("int Nout",l," = 1;\n",sep="");   #do lags one by one
 cat("int nr",l,"[1]= {",idx-1,"};\n",sep="");                      #only one lag now, so nr[1]
 cat("double ytau",l,"[1] = {",laglist[[l]][2],"};\n",sep="");  #use ytautemp to store individual lag species
 cat("double T",l," = *t - ",lagtime,";\n",sep="");
 cat("if (*t > ",lagtime,") {\n");
 cat("lagvalue(&T",l,", nr",l,", Nout",l,", ytau",l,");\n",sep="");
 cat("}\n");
 cat("ytau[",l-1,"] = ytau",l,"[0];\n",sep="");
 
}#for l 
}                                                         #if laglist >0

for(q in 1:length(equationsval)){
      qname<-names(equationsval)[q]
      qname<-substr(qname,2,2000)         #remove the first "d"
      yidx<-which(names(y)==qname)      
  cat(paste("ydot[",yidx-1,"] = ",equationsval[q],";",sep=""),sep="\n")
}#for q

#add species not having equations
idx<-tempspecies%in%species
if(any(!idx)){
for(i in 1:sum(!idx)){
cat(paste("ydot[",q-1+i,"] = 0;",sep=""),sep="\n")
}
}

if(length(laglist)>0){                                                 #if there are lagged species
for(l in 1:length(laglist)){
cat("yout[",l-1,"] = ytau[",l-1,"];\n",sep="")   
}
}                                                              # if laglist>0
cat("}",sep="\n");
sink(); 

#compile
system("R CMD SHLIB delaymymod.c");

sink("delaypars.R")
cat("pars <- c(",sep = "\n")
cat(parsvec[[1]], sep = ",")
cat(")")
sink()



sink("delaystates.R")
cat("states <- c(",sep ="\n")
cat(statesvec, sep = ",")
cat(")")
sink()