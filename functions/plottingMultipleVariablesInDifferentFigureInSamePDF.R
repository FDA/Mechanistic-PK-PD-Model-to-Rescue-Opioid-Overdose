#last edited by: Anik Chaturbedi
#on: 2024-07-03

plottingMultipleVariablesInDifferentFigureInSamePDF<-function(varvec){
	gg_color_hue <- function(n) {
		hues = seq(15, 375, length = n + 1)
		hcl(h = hues, l = 65, c = 100)[1:n]
	}
	firstNaloxoneIntroductionTime=pp[[2]]
		
	colorPalette = gg_color_hue(numberOfAntagonistDosingRegimens)	
	pdf(paste0(optimalOutputFolder, "/all variables.pdf"))
	
	for(myvar in varvec){
		minx<-0
		maxx <- timeUL
		if (myvar=="Opioid bound receptor fraction" | myvar=="Antagonist bound receptor fraction"){
			miny= 0
			maxy<- 1
		}else{
			miny= 0
			maxy<- max(c(pp[[1]][[numberOfAntagonistDosingRegimens]][,myvar]))*1.4
		}
		plot.new()
		plot.window(xlim=c(minx,maxx),ylim=c(miny,maxy))
		axis(side=1); axis(side=2)
		title(main=paste(myvar),
				xlab=paste0("Time (mins)"))
		for(Nconditions in 1:numberOfAntagonistDosingRegimens){#1:5 corresponds to naloxone doseN 0-4
			x <- pp[[1]][[Nconditions]][,"time"]
			x <- x/60
			y <- pp[[1]][[Nconditions]][,myvar]
			lines(x, y,col=colorPalette[Nconditions],lty=Nconditions,cex=1.1,lwd=2)
			if (Nconditions!=1){
				points(c(firstNaloxoneIntroductionTime/60,(firstNaloxoneIntroductionTime/60)+2.5), c(0,0), pch = 19)
			}
		}
		legend(0.4*maxx, 0.3*maxy, legend=antagonistDosesLabels,
				col=colorPalette, lty=1:6, cex=0.8,
				title=paste0(inputs$antagonist, ", ",inputs$antagonistAdministrationRouteAndDose, ", dosing"), text.font=4)
	}
	dev.off()
}