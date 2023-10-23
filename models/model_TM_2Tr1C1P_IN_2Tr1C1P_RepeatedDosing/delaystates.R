#last edited by: Anik Chaturbedi
#on: 2024-07-01
states <- c(
		D=0, #0
		NT1=0, #1
		NT2=0, #2
		PlasmaN=0, #3
		N=0, #4
		
		opioidDoseCompartment=0, #0->5
		opioidTransferCompartment1=0, #1->6
		opioidTransferCompartment2=0, #2->7
		PlasmaF=0, #opioidCentralCompartment #3->8
		
		CAR=0, #9
		CBR=0, #10
		P_A_co2=40.28, #11
		P_A_o2=100.2, #12
		C_B_co2=0.645, #13
		C_B_o2=9.78E-4, #14
		C_T_co2=0.605, #15
		C_T_o2=13E-4, #16
		P_I_o2=149, #17
		yco2=0, #18
		yo2=0, #19
		Dp=0, #20
		Dc=0, #21
		alphaH=1, #22
		FIV=0, #23
		iman=0, #24
		im25=1, #25
		im26=1, #26
		im27=1, #27
		C2N=0, #28
		yo2Child=0, #29
		F1=0.2609, #30
		
		opioidPeripheralCompartment=0, #4->31
		opioidEffectSite=0, #5->32
		opioidBioavailability=1 #6->33
)