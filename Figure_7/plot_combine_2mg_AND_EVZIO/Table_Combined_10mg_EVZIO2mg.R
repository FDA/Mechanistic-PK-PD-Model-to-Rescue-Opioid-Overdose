mainfol="/scratch/mohammadreza.samieegohar/John_simulations/john/inhalation"
system(paste0("mkdir -p ","results_table"))

alllfolders=c("final4_opt_yesParDis_noDelayDiss_conc0.014_PKyes_carfentanil_naive_samplingD_V_k12N_initdelay_60_simuldose_k1_no_opioid_0_Nal",
		"final4_opt_yesParDis_noDelayDiss_conc0.154_PKyes_carfentanil_naive_samplingD_V_k12N_initdelay_60_simuldose_k1_no_opioid_0_Nal",
		"final4_opt_yesParDis_noDelayDiss_conc0.294_PKyes_carfentanil_naive_samplingD_V_k12N_initdelay_0_simuldose_k1_no_opioid_1800_Nal",
		"final4_opt_yesParDis_noDelayDiss_conc0.294_PKyes_carfentanil_naive_samplingD_V_k12N_initdelay_0_simuldose_k1_no_opioid_300_Nal",
		"final4_opt_yesParDis_noDelayDiss_conc0.294_PKyes_carfentanil_naive_samplingD_V_k12N_initdelay_60_simuldose_k1_no_opioid_0_Nal",
		"final4_opt_yesParDis_noDelayDiss_conc1.617_PKyes_fentanyl_naive_samplingD_V_k12N_initdelay_60_simuldose_k1_no_opioid_0_Nal",
		"final4_opt_yesParDis_noDelayDiss_conc3.087_PKyes_fentanyl_naive_samplingD_V_k12N_initdelay_0_simuldose_k1_no_opioid_1800_Nal",
		"final4_opt_yesParDis_noDelayDiss_conc3.087_PKyes_fentanyl_naive_samplingD_V_k12N_initdelay_0_simuldose_k1_no_opioid_300_Nal",
		"final4_opt_yesParDis_noDelayDiss_conc3.087_PKyes_fentanyl_naive_samplingD_V_k12N_initdelay_60_simuldose_k1_no_opioid_0_Nal")


#alllfolders=c("Rescue_Times_ligand_final4_opt_yesParDis_noDelayDiss_conc0.014_PKyes_carfentanil_naive_samplingD_V_k12N_initdelay_60_simuldose_k1_no_opioid_0_Nal.csv",
#"Rescue_Times_ligand_final4_opt_yesParDis_noDelayDiss_conc0.154_PKyes_carfentanil_naive_samplingD_V_k12N_initdelay_60_simuldose_k1_no_opioid_0_Nal.csv",
#"Rescue_Times_ligand_final4_opt_yesParDis_noDelayDiss_conc0.294_PKyes_carfentanil_naive_samplingD_V_k12N_initdelay_0_simuldose_k1_no_opioid_1800_Nal.csv",
#"Rescue_Times_ligand_final4_opt_yesParDis_noDelayDiss_conc0.294_PKyes_carfentanil_naive_samplingD_V_k12N_initdelay_0_simuldose_k1_no_opioid_300_Nal.csv",
#"Rescue_Times_ligand_final4_opt_yesParDis_noDelayDiss_conc0.294_PKyes_carfentanil_naive_samplingD_V_k12N_initdelay_60_simuldose_k1_no_opioid_0_Nal.csv",
#"Rescue_Times_ligand_final4_opt_yesParDis_noDelayDiss_conc1.617_PKyes_fentanyl_naive_samplingD_V_k12N_initdelay_60_simuldose_k1_no_opioid_0_Nal.csv",
#"Rescue_Times_ligand_final4_opt_yesParDis_noDelayDiss_conc3.087_PKyes_fentanyl_naive_samplingD_V_k12N_initdelay_0_simuldose_k1_no_opioid_1800_Nal.csv",
#"Rescue_Times_ligand_final4_opt_yesParDis_noDelayDiss_conc3.087_PKyes_fentanyl_naive_samplingD_V_k12N_initdelay_0_simuldose_k1_no_opioid_300_Nal.csv",
#"Rescue_Times_ligand_final4_opt_yesParDis_noDelayDiss_conc3.087_PKyes_fentanyl_naive_samplingD_V_k12N_initdelay_60_simuldose_k1_no_opioid_0_Nal.csv")

labelfol=c("carfentanil_0.014mg_predoseing0","carfentanil_0.154mg_predoseing0","carfentanil_0.294mgv_predoseing1800","carfentanil_0.294mg_predoseing300","carfentanil_0.294mg_predoseing0",
		"fentanyl_1.617mg_predoseing0","fentanyl_3.087mg_predoseing1800","fentanyl_3.087mg_predoseing300","fentanyl_3.087mg_predoseing0")

i=0
for (fo in alllfolders) {
	data10mg=dataEVzio2mg=c()
	i=i+1
	data10mg=read.csv(sprintf("%s/main_10mg_predoseANDnormal/population_outputsX/CA_Aero/Rescue_Times_ligand_%s.csv",mainfol,fo))
	dataEVzio2mg=read.csv(sprintf("%s/main_EVZIO_predoseANDnormal/population_outputsX/CA_Aero/Rescue_Times_ligand_%s.csv",mainfol,fo))
#	aaaaaaa
	data10mg$type="NAI 10 mg"
	dataEVzio2mg$type="NAI 2 mg"
	
	A_data10mg<-data10mg[data10mg$X %in% c(0,1,2,"2S"), c("X","X25.","X50.","X75.")]
	A_dataEVzio2mg<-dataEVzio2mg[dataEVzio2mg$X %in% c(0,1,2,"2S"), c("X","X25.","X50.","X75.")]
	
	A_data10mg[2:4]=round(A_data10mg[2:4]/60,1)
	A_dataEVzio2mg[2:4]=round(A_dataEVzio2mg[2:4]/60,1)
	
	A_data10mg[A_data10mg==60]="NR"
	A_dataEVzio2mg[A_dataEVzio2mg==60]="NR"
	
	
	for (im in 1:4) {
	A_data10mg$comb[im]=paste0(A_data10mg$X50.[im]," (",A_data10mg$X25.[im],"-",A_data10mg$X75.[im],")")
	A_dataEVzio2mg$comb[im]<-paste0(A_dataEVzio2mg$X50.[im]," (",A_dataEVzio2mg$X25.[im],"-",A_dataEVzio2mg$X75.[im],")")
}
A_data10mg$X[4]="2_S"
tableiman=cbind(A_data10mg$X,A_data10mg$comb,A_dataEVzio2mg$comb)
namess=c("Naloxone Dose","NAI 2 mg Median [IQR]","NAI 10 mg Median [IQR]")
tableiman1=rbind(namess,tableiman)
colnames(tableiman1)=namess
write.csv(tableiman1,sprintf("results_table/Table_%s.csv",fo))

	
	


}
