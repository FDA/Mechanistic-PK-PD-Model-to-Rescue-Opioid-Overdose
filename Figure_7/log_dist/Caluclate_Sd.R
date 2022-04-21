xxxx<-read.csv("fentanyl_logdis.csv")

for(i in 2:ncol(xxxx)){
sd_test<-sd(xxxx[,i])
print(i)
print(sd_test)
}