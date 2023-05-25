#last edited by: Anik Chaturbedi
#on: 2023-05-25
plottingSingleVariableTimeCourseInternalFunction0_2_4_2__2<-function(
		myvar, #variable to plot
		timeUL=10, #time up to which to plot (in mins)
		firstNaloxoneIntroductionTime #(in seconds)
){	
	antagonistDoseIndices<-c(1,2,3,4,5,6,7)
	
	ShiftTimeAxisBy=firstNaloxoneIntroductionTime
	for (naloxoneDoseIndex in antagonistDoseIndices){
		pp[[1]][[naloxoneDoseIndex]][,"time"]=pp[[1]][[naloxoneDoseIndex]][,"time"]-ShiftTimeAxisBy
	}
#	firstNaloxoneIntroductionTimeJoined=firstNaloxoneIntroductionTime + max(fulltimes) #(in seconds)
#	ShiftTimeAxisBy=firstNaloxoneIntroductionTimeJoined
#	ppJoined=c()
#	for (naloxoneDoseIndex in antagonistDoseIndices){
#		pp[[1]][[naloxoneDoseIndex]][,"time"]=pp[[1]][[naloxoneDoseIndex]][,"time"]+max(fulltimes)
#		ppJoined[[1]][[naloxoneDoseIndex]]<-rbind(OutputUptoSS, pp[[1]][[naloxoneDoseIndex]])
#		ppJoined[[1]][[naloxoneDoseIndex]][,"time"]=ppJoined[[1]][[naloxoneDoseIndex]][,"time"]-ShiftTimeAxisBy
#		ppJoined[[1]][[naloxoneDoseIndex]]=ppJoined[[1]][[naloxoneDoseIndex]][ppJoined[[1]][[naloxoneDoseIndex]][,"time"]>=-2.5*60,]
#	}
#	pp=ppJoined
	
	plottedAntagonistDoseIndices<-c(1,3,5,7)
	labels="off" #"on"
	
	#where to plot horizontal lines to denote critical thresholds====================================
	if (myvar=="Brain O2 partial pressure (mm Hg)"){horizontalLinePosition=SThBrainO2}
	else if (myvar=="Minute ventilation (l/min)"){horizontalLinePosition=threshold}
	else {horizontalLinePosition=-5}
	#====================================where to plot horizontal lines to denote critical thresholds
	
	#calculate timeIndex of death for each dose so that the line can be stopped there===============================================================================
	timeIndexULL<-c()
	timeIndexUL<-c()
	for (naloxoneDoseIndex in antagonistDoseIndices){		
		timeIndexUL[naloxoneDoseIndex]<-which(pp[[1]][[naloxoneDoseIndex]][,"time"]==max(pp[[1]][[naloxoneDoseIndex]][,"time"])) #maximum index for each dose		
		if (min(pp[[1]][[naloxoneDoseIndex]][,"Cardiac output (l/min)"])<=CABloodFlow){ #if the dose experiences CA
			timeIndexULL[naloxoneDoseIndex]<-min(which(pp[[1]][[naloxoneDoseIndex]][,"Cardiac output (l/min)"]<=CABloodFlow)) #timeindex at which CA occurs
			timeIndexUL[naloxoneDoseIndex]<-which(
					abs(pp[[1]][[naloxoneDoseIndex]][,"time"]-(pp[[1]][[naloxoneDoseIndex]][timeIndexULL[naloxoneDoseIndex],"time"]))==
							min(abs(pp[[1]][[naloxoneDoseIndex]][,"time"]-(pp[[1]][[naloxoneDoseIndex]][timeIndexULL[naloxoneDoseIndex],"time"]))))
		}
	}
	#===============================================================================calculate timeIndex of deathy for each dose so that the line can be stopped there
	
	plot <- ggplot()
	
	#lines for different doses==============================================================================================================================
	plot <- plot+ geom_line(aes(x=pp[[1]][[7]][1:timeIndexUL[7],"time"]/60, y=pp[[1]][[7]][1:timeIndexUL[7], myvar], color="g"), size=1, linetype="solid") #"twodash"	
	plot <- plot+ geom_line(aes(x=pp[[1]][[5]][1:timeIndexUL[5],"time"]/60, y=pp[[1]][[5]][1:timeIndexUL[5], myvar], color="e"), size=1, linetype="solid") #"dashed" @"dotdash"	
	plot <- plot+ geom_line(aes(x=pp[[1]][[3]][1:timeIndexUL[3],"time"]/60, y=pp[[1]][[3]][1:timeIndexUL[3], myvar], color="c"), size=1, linetype="dashed") #"solid" #"dashed"
	plot <- plot+ geom_line(aes(x=pp[[1]][[1]][1:timeIndexUL[1],"time"]/60, y=pp[[1]][[1]][1:timeIndexUL[1], myvar], color="a"), size=1, linetype="solid") 
	#==============================================================================================================================lines for different doses
	
	#defining line colors and labels=======================================================================================================================
	plot <- plot+ scale_color_manual(name = "Naloxone dosing (mg)", values=c(a="black",			c="#C8513B",		e="#6289C2",		g="#E6A03A"), #colorblind friendly palette
			labels = antagonistDosesLabels[plottedAntagonistDoseIndices])
	#=======================================================================================================================defining line colors and labels
	
	#"X"s to indicate cardiac arrest======================================================================================================================
	if (myvar=="Cardiac output (l/min)"){
		plot <- plot+ geom_point(aes(x=pp[[1]][[1]][timeIndexUL[1],"time"]/60,pp[[1]][[1]][timeIndexUL[1], myvar]), shape=4, color="black", size=4, stroke = 3)
		plot <- plot+ geom_point(aes(x=pp[[1]][[3]][timeIndexUL[3],"time"]/60,pp[[1]][[3]][timeIndexUL[3], myvar]), shape=4, color="black", size=4, stroke = 3)
		plot <- plot+ geom_point(aes(x=pp[[1]][[5]][timeIndexUL[5],"time"]/60,pp[[1]][[5]][timeIndexUL[5], myvar]), shape=4, color="black", size=4, stroke = 3)
		plot <- plot+ geom_point(aes(x=pp[[1]][[7]][timeIndexUL[7],"time"]/60,pp[[1]][[7]][timeIndexUL[7], myvar]), shape=4, color="black", size=4, stroke = 3)
	}
	#======================================================================================================================"X"s to indicate cardiac arrest
	
	
	plot <- plot+ geom_hline(yintercept=horizontalLinePosition, linetype="dashed", color = "black")	#horizontal line indicating critical threshold
	
	plot <- plot+ scale_x_continuous(
			name=  "Time, minutes",
#			breaks= c(-2.5, -(firstNaloxoneIntroductionTime)/60, seq(0, timeUL, 2.5)), 
#			limits= c(-2.5, timeUL),
			breaks= c(-(firstNaloxoneIntroductionTime)/60, seq(0, timeUL, 2.5)), 
			limits= c(-(firstNaloxoneIntroductionTime)/60, timeUL),
			labels = scales::number_format(accuracy = 0.1)
	)
	
	plot <- plot+ theme_bw()	
	
	if (myvar=="Minute ventilation (l/min)"){
		plot <- plot+ scale_y_continuous(
				name=  "Ventilation, L/minute",
				limits= c(0, 8),
		)
	}else if (myvar=="Cardiac output (l/min)"){
		plot <- plot+ scale_y_continuous(
				name=  "Cardiac output, L/minute",
				limits= c(0, 10),
		)
	}else if (myvar=="Brain O2 partial pressure (mm Hg)"){
		plot <- plot+ scale_y_continuous(
				name=  "Brain oxygen partial pressure, mm Hg",
				limits= c(0, 50),
		)
	}else if (myvar=="Opioid bound receptor fraction"){
		lowerLimit=0.8
		plot <- plot+ ylim(lowerLimit, 1)
	}else if (myvar=="Arterial CO2 partial pressure (mm Hg)"){
		lowerLimit=30
		upperLimit=70 #NA
		plot <- plot+ scale_y_continuous(
				name=  "Arterial carbon dioxide partial pressure, mm Hg",
				limits= c(lowerLimit, upperLimit),
		)
	}else if (myvar=="Arterial O2 partial pressure (mm Hg)"){
		lowerLimit=0
		upperLimit=100 #NA
		plot <- plot+ scale_y_continuous(
				name=  "Arterial oxygen partial pressure, mm Hg",
				limits= c(lowerLimit, upperLimit),
		)
	}else if (myvar=="Arterial O2 saturation (%) alternate"){
#		lowerLimit=30
		plot <- plot+ scale_y_continuous(
				name=  "Arterial oxygen saturation, %",
				limits= c(0, 100),
		)
	}else{
		plot <- plot+ scale_y_continuous(
				name=  myvar,
				limits= c(0, NA),
		)
	}
	if (labels=="on"){	
		plot <- plot+ theme(legend.direction = "vertical",
				legend.position = c(0.5, 0.4),    
				legend.background=element_rect(fill = alpha("white", 0)),  
				# Hide panel borders and remove grid lines
				panel.border = element_blank(),
				panel.grid.major = element_line(colour = "grey",size=0.25),
				panel.grid.minor = element_line(colour = "grey",size=0.25),
				# Change axis line
				axis.line = element_line(colour = "black"))
	}else{
		plot+ theme(legend.direction = "vertical",
				legend.position = "none",    
				legend.background=element_rect(fill = alpha("white", 0)),  
				# Hide panel borders and remove grid lines
				panel.border = element_blank(),
				panel.grid.major = element_blank(),
				panel.grid.minor = element_blank(),
				axis.title.x=element_text(color="black", face="bold", size=12),
				axis.title.y=element_text(color="black", face="bold", size=12),
				axis.text.x = element_text(color="black", size=10),
				axis.text.y = element_text(color="black", size=10),			
				axis.ticks = element_line(color = "black"),
				# Change axis line
				axis.line = element_line(colour = "black"))
	}
}