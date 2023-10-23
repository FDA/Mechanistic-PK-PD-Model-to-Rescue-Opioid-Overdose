#last edited by: Anik Chaturbedi
#on: 2022-11-16

getAgeDependentParameters<-function(inputs){
	ageDependentParameters <- data.frame(
			age =						c("5YearOld",	"6YearOld",	"7YearOld",	"8YearOld",	"9YearOld",	"10YearOld",	"11YearOld",	"12YearOld",	"adult"), #(in years) 
			weight =					c(18.7,			20.7,		23.3,		26.5,		30.05,		33.95,			38,				42,				70), #(in kg) 
			height =					c(109.2,		115.5,		121.9,		128,		133.3,		138.4,			143.5,			149.1,			NA), #(in cm) 
			brainWeight =				c(1228.7,		1248.9,		1267.95,	1285.75,	1302.3,		1317.45,		1331.2,			1343.5, 		1500), #(in g)
			brainVolume =				c(NA,			NA,			NA,			NA, 		NA,			1204.651,		NA,				NA, 			3.28*1e3), #(in ml)
			steadyStateCardiacOutput =	c(NA,			NA,			NA,			NA, 		NA,			4.47,			NA,				NA,				4.87)/60, #(in l/sec)
			stringsAsFactors = FALSE
	)	
	return(ageDependentParameters)
}