#---- Script to plot Cardiac Arrest vs dose delay for each of 
#---- 4 IV opioid doses (2 carfentanil, 2 fentanyl) in chronic users


All_CA<-read.csv("All_data.csv")
p1<-list()
for(i in 1:4){
All_list<-split(All_CA,All_CA$dose)
#Dose=CA$dose
All1<-data.frame(All_list[[i]])
Dose=All1$dose
All11<-All1[All1$Ndose==1,]
All11$delay<-All11$delay/60
All1_0<-All1[1,]
All1_0$Ndose="No_Naloxone"
All1_0$delay<-"No_Naloxone"
All11<-rbind(All11,All1_0)

write.csv(All1,"All_1_test.csv")
library(ggplot2)
All11$delay <- factor(All11$delay, levels = unique(All11$delay[order(All11$rowYesCA)]))
#All11$delay<-as.factor(All11$delay,levels=c("0","60","120","180","240","300","600","No_Naloxone"))

	gg_color_hue <- function(n) {
		hues = seq(15, 375, length = n + 1)
		hcl(h = hues, l = 65, c = 100)[1:n]
	}
	colorPalette = gg_color_hue(6)
	
p1[[i]]<-ggplot(data=All11,aes(x=as.factor(delay),y=rowYesCA,color = type))+
		geom_point(size=4.25)+
		geom_line(data=All11,aes(x=as.factor(delay),y=rowYesCA,group = type),linetype=3,size=1.5)+
		theme_bw()+
		ggtitle(sprintf("IV %s Rescue by 1 dose Naloxone",Dose))+
		ylab("Cardiac Arrest Percentage for Virtual Patients")+
		xlab("Initial Delay Before Naloxone Administration (minutes)")+
		scale_color_manual("Product", values = c("NAI 10 mg" = colorPalette[1], "NAI 2 mg" = colorPalette[2]))+
		scale_y_continuous(breaks=seq(0,100,25),limits=c(0,100))+
		#scale_shape_manual("Ndose",values=c("0"=1, "1"=2, "2"=3, "2_S"=4))+
		theme(legend.position = c(0.8, 0.25))
		

ggsave(sprintf("outputs/test_All1%s_rev3.pdf",i),p1[[i]],width=8,height=6)
}

library(gridExtra)
ggsave(
		filename = "All_plots_by_delay_rev2.pdf", 
		plot = marrangeGrob(p1, nrow=1, ncol=1), 
		width = 8, height = 6
)