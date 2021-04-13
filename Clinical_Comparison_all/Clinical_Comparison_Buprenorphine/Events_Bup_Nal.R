events<-data.frame(var=c("PlasmaN"),
                   time=c(seq(1800,1890,10),seq(1900,7290,10)), #time = (x,y)
                   value=c(rep(.3,10),rep(40/3600,540)), # 
                   method=c("add"))
