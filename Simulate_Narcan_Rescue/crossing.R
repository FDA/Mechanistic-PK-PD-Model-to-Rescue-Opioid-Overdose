crossing<-function(S,t,level,imeth="linear"){

#S is the signal; t is the corresponding time
#level is the threshold to declare zero crossing

  S <- S - level
  
  len<- length(S)
  
  #exact zeros
  idx0 <- which( S == 0)
  
  #zero crossing between data points
  S1 = S[1:(len-1)]*S[2:len]
  idx1 <- which(S1<0)
  
  ind <- sort(c(idx0, idx1))
  
  t0<-t[ind]
  s0<-S[ind]
 if(imeth=="linear"){
    for(ii in 1:length(t0)){
      if(abs(S[ind[ii]]) > 1e-15){
          NUM = t[ind[ii]+1] - t[ind[ii]];
            DEN = S[ind[ii]+1] - S[ind[ii]];
            DELTA =  NUM / DEN;
            t0[ii] = t0[ii] - S[ind[ii]] * DELTA;
            s0[ii]<-0
           }
          }
     }
  return(list(ind,t0))
 }
