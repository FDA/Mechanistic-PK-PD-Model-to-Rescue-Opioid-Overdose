#last edited by: Anik Chaturbedi
#on: 2024-02-08

antagonistPKParameters <- c(
		F=0.1529,
		kin=0.0003067,
		ktr=0.002176, 
		V1=88200, #ml
		V2=111500, #ml
		kout2=7.121,
		k12N=12.59,
		k2=0.001774, #(in 1/s) 
		molarMassAntagonist=339.435 #(g/mol)
)

#PK weight scaling added====
inputs$subjectWeight=79.9 #(in kg) #mean weight from table 1 in Krieter et al. 2019
Scl= (inputs$subjectWeight/70)^0.75;
Sv= (inputs$subjectWeight/70);
scale1=Scl/Sv;
antagonistPKParameters["kout2"] = antagonistPKParameters["kout2"]*scale1;
antagonistPKParameters["V1"] = antagonistPKParameters["V1"]*Sv;
antagonistPKParameters["V2"] = antagonistPKParameters["V2"]*Sv;