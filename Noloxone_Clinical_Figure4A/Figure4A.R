rm(list=ls())

outdir<-paste0("results/")
system(paste0("mkdir -p ",outdir))
set.seed(100)
library(ggplot2)
library(optparse)
library(parallel)


# read data to plot
df0=read.csv("results/Avg_IV_p04mg.csv")
df1=read.csv("results/Avg_IV_p5mg.csv")
df3=read.csv("results/Avg_IV_2mg.csv")

df=read.csv("results/Avg_IN_4mg.csv")
df8=read.csv("results/Avg_IN_8mg.csv")

labsiz=24
numsiz=20
line_size=2
gg_color_hue <- function(n) {
	hues = seq(15, 375, length = n + 1)
	hcl(h = hues, l = 65, c = 100)[1:n]
}
cP = gg_color_hue(8)
#----------30min
p1<-ggplot()

p1<-p1+geom_line(data=df, aes(x=times/60, y=avg, color="IN 4mg"), size=line_size, alpha=1)
p1<-p1+geom_line(data=df8, aes(x=times/60, y=avg, color="IN 8mg"), size=line_size, alpha=1)
p1<-p1+geom_line(data=df0, aes(x=fulltimes/60, y=avg, color="IV 0.04mg"), size=line_size, alpha=1)
p1<-p1+geom_line(data=df1, aes(x=fulltimes/60, y=avg, color="IV 0.5mg"), size=line_size, alpha=1)
p1<-p1+geom_line(data=df3, aes(x=fulltimes/60, y=avg, color="IV 2mg"), size=line_size, alpha=1)
p1<-p1+ylab(paste0("Naloxone Plasma Concentration, ng/mL"))
p1<-p1+xlab(paste0("Time, minutes"))+theme(axis.text=element_text(size=numsiz),
										axis.title=element_text(size=labsiz,
										face="bold"),
										plot.title=element_text(size=24,face="bold"))
p1<-p1+scale_color_manual(name='Model',
			breaks=c('IV 0.04mg', 'IV 0.5mg', 'IV 2mg', 'IN 4mg', 'IN 8mg'),
			values=c("gray20", "gray50", "grey75", "#fc8d59", "#1b7837"))
		p1<-p1+xlim(0,15)
p1<-p1+ theme(legend.direction = "vertical",
		legend.text=element_text(size=12),
		legend.position = c(0.6,0.6),   
		legend.background=element_rect(fill = alpha("white", 0)),
		panel.background=element_rect(fill = alpha("white", 0)),
		panel.border = element_blank(),
		axis.line = element_line(colour = "black"))
ggsave(sprintf("%s/Figure4A.png",outdir),p1,height=8, width=12)


