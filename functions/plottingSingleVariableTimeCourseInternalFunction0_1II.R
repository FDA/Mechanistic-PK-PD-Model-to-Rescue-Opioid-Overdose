#last edited by: Anik Chaturbedi
#on: 2023-06-13
plottingSingleVariableTimeCourseInternalFunction0_1<-function(
		myvar, #variable to plot
		timeUL=10, #time up to which to plot (in mins)
		firstNaloxoneIntroductionTime #(in seconds)
){	
	firstNaloxoneIntroductionTimeOriginal=firstNaloxoneIntroductionTime #(in seconds)
	firstNaloxoneIntroductionTime=0 #(in seconds)
	
	plottedAntagonistDoseIndices<-c(1, 2)
	labels="off" #"on"
	
	#where to plot horizontal lines to denote critical thresholds====================================
	if (myvar=="Brain O2 partial pressure (mm Hg)"){horizontalLinePosition=SThBrainO2}
	else if (myvar=="Minute ventilation (l/min)"){horizontalLinePosition=threshold}
	else {horizontalLinePosition=-5}
	#====================================where to plot horizontal lines to denote critical thresholds
	
	#defining color palette==========================================
	gg_color_hue <- function(n) {
		hues = seq(15, 375, length = n + 1)
		hcl(h = hues, l = 65, c = 100)[1:n]
	}	
	colorPalette = hue_pal()(length(plottedAntagonistDoseIndices))
	#==========================================defining color palette
	
	#calculate timeIndex of death for each dose so that the line can be stopped there===============================================================================
	timeIndexULL<-c()
	timeIndexUL<-c()
	antagonistDoseIndices<-c(1,2,3,4)
	for (naloxoneDoseIndex in antagonistDoseIndices){
		pp[[1]][[naloxoneDoseIndex]][,"time"]=pp[[1]][[naloxoneDoseIndex]][,"time"]-firstNaloxoneIntroductionTimeOriginal
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
	plot <- plot+ geom_line(aes(x=pp[[1]][[2]][1:timeIndexUL[2],"time"]/60, y=pp[[1]][[2]][1:timeIndexUL[2], myvar], color="b"), size=1.5, linetype="solid") #"dashed" @"dotdash"
	plot <- plot+ geom_line(aes(x=pp[[1]][[1]][1:timeIndexUL[1],"time"]/60, y=pp[[1]][[1]][1:timeIndexUL[1], myvar], color="a"), size=1, linetype="solid") 
	#==============================================================================================================================lines for different doses
	
	#defining line colors and labels=======================================================================================================================
	plot <- plot+ scale_color_manual(
			name = "Naloxone dosing (mg)", 
			values=c(a="black",	b="#00ba38"),
			labels = antagonistDosesLabels[plottedAntagonistDoseIndices])
	#=======================================================================================================================defining line colors and labels
	
	#"X"s to indicate cardiac arrest======================================================================================================================
	plot <- plot+ geom_point(aes(x=pp[[1]][[1]][timeIndexUL[1],"time"]/60,pp[[1]][[1]][timeIndexUL[1], myvar]), shape=4, color="black", size=4, stroke = 3)
	plot <- plot+ geom_point(aes(x=pp[[1]][[2]][timeIndexUL[2],"time"]/60,pp[[1]][[2]][timeIndexUL[2], myvar]), shape=4, color="black", size=4, stroke = 3)
	#======================================================================================================================"X"s to indicate cardiac arrest
	
	plot <- plot+ geom_hline(yintercept=horizontalLinePosition, linetype="dashed", color = "black")	#horizontal line indicating critical threshold
	
	plot <- plot+ scale_x_continuous(
			name=  "Time, minutes",
			breaks= c(-firstNaloxoneIntroductionTimeOriginal/60, seq(0, timeUL, 2.5)), 
			limits= c(-firstNaloxoneIntroductionTimeOriginal/60, timeUL),
			labels = scales::number_format(accuracy = 0.1)
	)
	
	plot <- plot+ theme_bw()	
	
	if (myvar=="Minute ventilation (l/min)"){
		plot <- plot+ scale_y_continuous(
				name=  "Ventilation, L/minute",
				limits= c(0, NA),
		)
	}else if (myvar=="Cardiac output (l/min)"){
		plot <- plot+ scale_y_continuous(
				name=  "Cardiac output, L/minute",
				limits= c(0, NA),
		)
	}else if (myvar=="Brain O2 partial pressure (mm Hg)"){
		plot <- plot+ scale_y_continuous(
				name=  "Brain oxygen partial pressure, mm Hg",
				limits= c(0, NA),
		)
	}else if (myvar=="Opioid bound receptor fraction"){
		lowerLimit=0.8
		plot <- plot+ ylim(lowerLimit, 1)
	}else if (myvar=="Arterial CO2 partial pressure (mm Hg)"){
		lowerLimit=30
		plot <- plot+ scale_y_continuous(
				name=  "Arterial carbon dioxide partial pressure, mm Hg",
				limits= c(lowerLimit, NA),
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