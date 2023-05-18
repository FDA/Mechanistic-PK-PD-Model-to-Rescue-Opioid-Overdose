#include <R.h>
#include <Rinternals.h>
#include <Rdefines.h>
#include <R_ext/Rdynload.h>
#include <time.h>
static double parms[113];
#define F parms[0]
#define kin parms[1]
#define kout parms[2]
#define ktr parms[3]
#define kout2 parms[4]
#define k1 parms[5]
#define k2 parms[6]
#define k12 parms[7]
#define k13 parms[8]
#define k21 parms[9]
#define k31 parms[10]
#define A1 parms[11]
#define B1 parms[12]
#define n parms[13]
#define A2 parms[14]
#define B2 parms[15]
#define n2 parms[16]
#define V1 parms[17]
#define Mmass parms[18]
#define V_A parms[19]
#define P_I_co2 parms[20]
#define Wmax parms[21]
#define lumbda parms[22]
#define Q1 parms[23]
#define s1 parms[24]
#define z parms[25]
#define alpha_co2 parms[26]
#define C_B_hco3 parms[27]
#define C_T_hco3 parms[28]
#define alpha_o2 parms[29]
#define K1 parms[30]
#define K2 parms[31]
#define a1 parms[32]
#define a2 parms[33]
#define alpha1 parms[34]
#define beta1 parms[35]
#define alpha2 parms[36]
#define beta2 parms[37]
#define Z parms[38]
#define C1Spencer parms[39]
#define C2Spencer parms[40]
#define Qb0 parms[41]
#define Qt0 parms[42]
#define rou parms[43]
#define V_B parms[44]
#define M_B_co2 parms[45]
#define M_B_o2_0 parms[46]
#define V_T parms[47]
#define M_T_co2 parms[48]
#define M_T_o2_0 parms[49]
#define P3 parms[50]
#define offDp parms[51]
#define P1 parms[52]
#define Bmax parms[53]
#define P2 parms[54]
#define offDc parms[55]
#define Aco2 parms[56]
#define Bco2 parms[57]
#define Cco2 parms[58]
#define Dco2 parms[59]
#define P_a_co2_0 parms[60]
#define tau_co2 parms[61]
#define c1o2 parms[62]
#define c2o2 parms[63]
#define P_a_o2_0 parms[64]
#define tau_o2 parms[65]
#define K_Dp parms[66]
#define K_Dc parms[67]
#define K_fpc parms[68]
#define Bp parms [69]
#define f_pc_max parms[70]
#define f_pc_min parms[71]
#define f_pc_0 parms[72]
#define P_a_o2_c parms[73]
#define K_pc parms[74]
#define tau_Dp parms[75]
#define tau_Dc parms[76]
#define G_Dp parms[77]
#define G_Dc parms[78]
#define P_B_co2_0 parms[79]
#define theta_Hmin parms[80]
#define Gh parms[81]
#define P_B_o2_0 parms[82]
#define tau_h parms[83]
#define theta_Hmax parms[84]
#define W parms[85]
#define fL parms[86]
#define fN parms[87]
#define offCo2 parms[88]
#define offO2 parms[89]
#define Infu_t parms[90]
#define VP parms[91]
#define Cim25 parms[92]
#define Cim26 parms[93]
#define Cim27 parms[94]
#define Cim28 parms[95]
#define CA_delay_o2 parms[96]
#define CA_delay_co2 parms[97]
#define tsh_value_o2 parms[98]
#define tsh_value_co2 parms[99]
#define Shock parms[100]
#define k12N parms[101]
#define k21N parms[102]
#define V2 parms[103]
#define V3 parms[104]
#define ikoutC parms[105]
#define ik12C parms[106]
#define ik21C parms[107]
#define ik13C parms[108]
#define ik31C parms[109]
#define iV2C parms[110]
#define timeout parms[111]
#define starttime parms[112]
//double CA_co2_happen=0;

#define max(a,b) \
		({ __typeof__ (a) _a = (a); \
		__typeof__ (b) _b = (b); \
		_a > _b ? _a : _b; });
void initmod(void (* odeparms)(int *, double *)){
	int N=113;
	odeparms(&N, parms);}
void lagvalue(double T, int *nr, int N, double *yout) {
	typedef void lagvalue_t(double, int *, int, double *);
	static lagvalue_t *fun = NULL;
	if (fun == NULL) {
		fun = (lagvalue_t*) R_GetCCallable("deSolve", "lagvalue");
	}
	fun(T, nr, N, yout);
}
double* calc_intermediate(double im11,double im12,double im13,double im14,double im15,double im16,double im18,double im19,double im25,double im26,double im27){
	static double returnVec[23];
	if (im13<0) /*  y[13] = C_B_co2 */
		im13=0;
	double i_C_B_co2_dissolved = im13 - C_B_hco3;
	double i_P_B_co2= i_C_B_co2_dissolved/alpha_co2;
	double i_P_Vb_co2 =i_P_B_co2;
	if (im14<0) /* y[14] = C_B_o2 */
		im14=0;
	double i_P_B_o2 = im14/alpha_o2;
	double i_P_Vb_o2 = i_P_B_o2;
	double F2_1 =i_P_Vb_co2*(1+beta2*i_P_Vb_o2)/(K2*(1+alpha2*i_P_Vb_o2));
	double i_C_Vb_co2 = Z*C2Spencer*pow(F2_1,1.00/a2)/(1+pow(F2_1,1.00/a2));
	double F1_1 = i_P_Vb_o2*(1+beta1*i_P_Vb_co2)/(K1*(1+alpha1*i_P_Vb_co2));
	double i_C_Vb_o2 = Z*C1Spencer*pow(F1_1,1.00/a1)/(1+pow(F1_1,1.00/a1));
	if (im15<0) /* y[15] = C_T_co2 */
		im15 = 0;
	double i_C_T_co2_dissolved = im15 - C_T_hco3;
	double i_P_T_co2 = i_C_T_co2_dissolved/alpha_co2;
	double i_P_Vt_co2 = i_P_T_co2;
	if(im16<0) /*y[16] = C_T_o2 */
		im16 = 0;
	double i_P_T_o2=im16/alpha_o2;
	double i_P_Vt_o2=i_P_T_o2;
	double F2_2 = i_P_Vt_co2*(1+beta2*i_P_Vt_o2)/(K2*(1+alpha2*i_P_Vt_o2));
	double i_C_Vt_co2 = Z*C2Spencer*pow(F2_2,1.00/a2)/(1+pow(F2_2,1.00/a2));
	double F1_2 = i_P_Vt_o2*(1+beta1*i_P_Vt_co2)/(K1*(1+alpha1*i_P_Vt_co2));
	double i_C_Vt_o2 = Z*C1Spencer*pow(F1_2,1.00/a1)/(1+pow(F1_2,1.00/a1));
	if (im11<0) /* y[11] = P_A_co2 */
		im11=0;
	double i_P_e_co2=im11;
	double i_P_e_o2=im12;
	double F2_3 = i_P_e_co2*(1+beta2*i_P_e_o2)/(K2*(1+alpha2*i_P_e_o2));
	double i_C_e_co2 = Z*C2Spencer*pow(F2_3,1.00/a2)/(1+pow(F2_3,1.00/a2));
	double F1_3 = i_P_e_o2*(1+beta1*i_P_e_co2)/(K1*(1+alpha1*i_P_e_co2));
	double i_C_e_o2 = Z*C1Spencer*pow(F1_3,1.00/a1)/(1+pow(F1_3,1.00/a1));
	double i_Qb = Qb0*(1+Cim27*(im18+im19))*im25;
	double i_Qt = Qt0*(1+Cim28*rou*im19)*im26;
	if(Shock > 0){
		i_Qb = Qb0*2.9/5.1;
		i_Qt = Qt0*2.9/5.1;
	}
	double i_C_V_co2 = (i_Qb*i_C_Vb_co2+i_Qt*(i_C_Vt_co2))/(i_Qb+i_Qt);
	double i_C_V_o2 = (i_Qb*i_C_Vb_o2+i_Qt*(i_C_Vt_o2))/(i_Qb+i_Qt);
	double i_Q = i_Qb + i_Qt;
	/* Arterial co2 o2 */
	double i_C_a_co2 = (1-s1)*i_C_e_co2 + s1*i_C_V_co2;
	double i_C_a_o2 = (1-s1)*i_C_e_o2 + s1*i_C_V_o2;
	/* P_a_co2/o2 from Spensor equation */
	double D2 = K2*pow((i_C_a_co2/(Z*C2Spencer - i_C_a_co2)),a2);
	double D1 = K1*pow((i_C_a_o2/(Z*C1Spencer - i_C_a_o2)),a1);
	double S2 = -(D2 + alpha2*D2*D1)/(beta1+alpha1*beta2*D1);
	double S1 = -(D1 + alpha1*D1*D2)/(beta2+alpha2*beta1*D2);
	double r1 = -(1+beta1*D2-beta2*D1-alpha1*alpha2*D1*D2)/(2*(beta2+alpha2*beta1*D2));
	double r2 = -(1+beta2*D1-beta1*D2-alpha2*alpha1*D2*D1)/(2*(beta1+alpha1*beta2*D1));
	double i_P_a_co2 = r2+pow((pow(r2,2.00)-S2),.5);
	double i_P_a_o2 = r1+pow((pow(r1,2.00)-S1),.5);
	returnVec[0]=i_P_B_co2;returnVec[1]=i_P_Vb_co2;returnVec[2]=i_P_B_o2;returnVec[3]=i_P_Vb_o2;returnVec[4]=i_C_Vb_co2;
	returnVec[5]=i_C_Vb_o2;returnVec[6]=i_P_T_co2;returnVec[7]=i_P_Vt_co2;returnVec[8]=i_P_T_o2;returnVec[9]=i_P_Vt_o2;
	returnVec[10]=i_C_Vt_co2;returnVec[11]=i_C_Vt_o2;returnVec[12]=i_C_e_co2;returnVec[13]=i_C_e_o2;returnVec[14]=i_Qb;
	returnVec[15]=i_Qt;returnVec[16]=i_Q;returnVec[17]=i_C_V_co2;returnVec[18]=i_C_V_o2;returnVec[19]=i_C_a_co2;returnVec[20]=i_C_a_o2;
	returnVec[21]=i_P_a_co2;returnVec[22]=i_P_a_o2;
	return returnVec;
}
void derivs (int *neq, double *t, double *y, double *ydot, double *yout, int *ip){
	if (ip[0] < 0 ) error("nout not enough!");
	time_t s = time(NULL);
	if((int) s - (int) starttime > timeout) error("timeout!");
	double* intermediate_list= calc_intermediate(y[11],y[12],y[13],y[14],y[15],y[16],y[18],y[19],y[25],y[26],y[26]);
	double P_B_co2=intermediate_list[0];  double P_Vb_co2=intermediate_list[1];
	double P_B_o2=intermediate_list[2];  double P_Vb_o2=intermediate_list[3];
	double C_Vb_co2=intermediate_list[4];  double C_Vb_o2=intermediate_list[5];
	double P_T_co2=intermediate_list[6];  double P_Vt_co2=intermediate_list[7];
	double P_T_o2=intermediate_list[8];  double P_Vt_o2=intermediate_list[19];
	double C_Vt_co2=intermediate_list[10];  double C_Vt_o2=intermediate_list[11];
	double C_e_co2=intermediate_list[12];  double C_e_o2=intermediate_list[13];
	double Qb=intermediate_list[14];  double Qt=intermediate_list[15];  double Q=intermediate_list[16];
	double C_V_co2=intermediate_list[17];  double C_V_o2=intermediate_list[18];
	double C_a_co2=intermediate_list[19];  double C_a_o2=intermediate_list[20];
	double P_a_co2=intermediate_list[21];  double P_a_o2=intermediate_list[22];
	double thP_a_o2=.95;
	double imtime_L=*t;
	double Cim25_e=0;
	double Cim25_e_o2=0;
	double Cim25_e_co2=0;
	double ctr_co2=1000;
	double rcov=1;
	double CA_o2_happen=0;
	if (CA_delay_o2<=imtime_L  ) {
		Cim25_e_o2 = Cim25*0.15;
		Cim25_e_co2 = (P_a_co2)*Cim25*0.85/52;
		CA_o2_happen=1;
	}
	Cim25_e=Cim25_e_co2+Cim25_e_o2;
	/*-------they can be combined-----*/
	double Cim26_e=0;
	double Cim26_e_o2=0;
	double Cim26_e_co2=0;
	if (CA_delay_o2<=imtime_L ) {
		Cim26_e_o2 = Cim26*.15;
		Cim26_e_co2 = (P_a_co2)*Cim26*0.85/tsh_value_co2;
	}
	Cim26_e=Cim26_e_co2+Cim26_e_o2;
	double Kf = Wmax*pow(y[9],P3);
	double fracW = (W - Kf)/6.62;
	if(fracW <0){
		fracW = 0;
	}
	double M_B_co2_real=M_B_co2*pow(fracW,P2);
	double M_T_co2_real=M_T_co2*pow(fracW,P2);
	double M_B_o2_real=M_B_o2_0*pow(fracW,P2);
	double M_T_o2_real=M_T_o2_0*pow(fracW,P2);
	if(M_B_co2_real <= M_B_co2*fL){
		M_B_co2_real=M_B_co2*fL;
	}
	if(M_T_co2_real <=M_T_co2*fL){
		M_T_co2_real=M_T_co2*fL;
	}
	if(M_B_o2_real >= M_B_o2_0*fN){
		M_B_o2_real=M_B_o2_0*fN;
	}
	if(M_T_o2_real >= M_T_o2_0*fN){
		M_T_o2_real=M_T_o2_0*fN;
	}
	if(P_B_o2<=6.00){
		M_B_o2_real=1.00/6.00*M_B_o2_real*P_B_o2 ;
		M_B_co2_real=1.00/6.00*P_B_o2*M_B_co2_real;
	}
	if(P_T_o2 <= 6.00){
		M_T_o2_real = 1.00/6*M_T_o2_real*P_T_o2;
		M_T_co2_real = 1.00/6*P_T_o2*M_T_co2_real;
	}
	double ReactionFlux19=1.00/V_B*(Qb*(C_a_co2 - C_Vb_co2)+M_B_co2_real);
	double ReactionFlux20=1.00/V_B*(Qb*(C_a_o2 - C_Vb_o2)+M_B_o2_real);
	double ReactionFlux21=1.00/V_T*(Qt*(C_a_co2 - C_Vt_co2)+M_T_co2_real);
	double ReactionFlux22=1.00/V_T*(Qt*(C_a_o2 - C_Vt_o2)+M_T_o2_real);
	/* Vent Function Delay */
	double Plag_P_a_co2;
	double Plag_P_a_o2;
	double Plag_C_B_co2;
	double Clag_P_a_co2;
	double Clag_P_B_co2;
	// Loss of delay at 2% bloodflow.
	double peripherialdelay=0;
	double centraldelay=0;
	double Q_delay = Q;
	if(Q_delay < 4.9*.2/60){
		peripherialdelay=0;
		centraldelay=0;
	}
	else{
		peripherialdelay = K_Dp/(Qb+Qt);
		centraldelay = K_Dc/(Qb+Qt);
	}
	//Update PK parameters as blood flow decreases
	double koutC= kout;
	double k12C = k12;
	double k13C = k13;
	double k21C = k21;
	double k31C = k31;
	double VPC = VP;
	//double VP2 = 14.4 ;// Taken from Algera 2020
	//double VP3 = 166  ;// Taken from Algera 2020
	//double VP2C = VP2;
	//double VP3C = VP3 ;
	//double V1C = V1;
	double V2C = V2;

	// True Q_0 is blood flow at equilibrium. Not parameter baseline Qb0+Qt0
	double Q_0 = 4.87/60;//.75/60+4.25/60; //=Qb0+Qt0; Qb0=0.75/60, Qt0=4.25/60,
	// PK parameters during collapse Intercept/Slope determined by linear regression from
	//Fentanyl Pharmacokinetics in Hemorrhagic Shock Egan et al 1999.
	//	if(Q<Q_0){
	double Top = 2; // Upper limit Q scale
	double Bottom = 1; // Lower limit Q scale
	double Q_Scale = Bottom+(Top-Bottom)/(1+exp((1.6-Q/Q_0)/.05));
	VPC=VP/Q_Scale;		// VP is Fentanyl V_D basline
	//V1C = V1/Q_Scale; // V1 is Naloxone V_D baseline
	V2C = V2/Q_Scale;
	double iV2CS;
	iV2CS = iV2C/Q_Scale;
	double imtime=*t;
	double history = imtime - peripherialdelay;
	if (  history<=0){
		Plag_P_a_co2 = P_a_co2;
		Plag_P_a_o2 = P_a_o2;
		Plag_C_B_co2=y[13];
	}
	if (  0<history){
		double ytau[8] = {0,0,0,0,0,0,0,0};
		double ytau13[1] = {0};double ytau14[1] = {0};double ytau15[1] = {0};double ytau16[1] = {0};double ytau11[1] = {0};double ytau12[1] = {0};double ytau19[1] = {0};double ytau18[1] = {0};
		int Nout1 = 1;
		static int nr1[1]= {13};
		lagvalue(history,nr1,Nout1,ytau13);
		ytau[0]=ytau13[0];
		Plag_C_B_co2 = ytau13[0]; //not important
		int Nout2 = 1;
		static  int nr2[1] = {14};
		lagvalue(history, nr2, Nout2, ytau14);
		ytau[1]=ytau14[0];
		int Nout3 = 1;
		static int nr3[1] = {15};
		lagvalue(history, nr3, Nout3, ytau15);
		ytau[2]=ytau15[0];
		int Nout4 = 1;
		static int nr4[1] = {16};
		lagvalue(history, nr4, Nout4, ytau16);
		ytau[3]=ytau16[0];
		int Nout5 = 1;
		static int nr5[1] = {11};
		lagvalue(history, nr5, Nout5, ytau11);
		ytau[4]=ytau11[0];
		int Nout6 = 1;
		static int nr6[1] = {12};
		lagvalue(history, nr6, Nout6, ytau12);
		ytau[5]=ytau12[0];
		int Nout7 = 1;
		static int nr7[1] = {19};
		lagvalue(history, nr7, Nout7, ytau19);
		ytau[6]=ytau19[0];
		int Nout8 = 1;
		static int nr8[1] = {18};
		lagvalue(history, nr8, Nout8, ytau18);
		ytau[7]=ytau18[0];
		double* Plag_intermediate = calc_intermediate(ytau[4],ytau[5],ytau[0],ytau[1],ytau[2],ytau[3],ytau[7],ytau[6],y[25],y[26],y[27]);
		Plag_P_a_co2 =  Plag_intermediate[21];
		Plag_P_a_o2 =  Plag_intermediate[22];
	}
	double 	historyc = imtime - centraldelay;
	if (historyc<=0) {
		Clag_P_B_co2 = P_B_co2;
	}
	if (0<historyc) {
		double ytauc[8] = {0,0,0,0,0,0,0,0};
		int Nout1c = 1;
		static int nr1c[1]= {13};
		double ytau13c[1] = {0};
		lagvalue(historyc, nr1c,Nout1c,ytau13c);
		ytauc[0]=ytau13c[0];
		int Nout2c = 1;
		static int nr2c[1] = {14};
		double ytau14c[1] = {0};
		lagvalue(historyc, nr2c, Nout2c, ytau14c);
		ytauc[1]=ytau14c[0];
		int Nout3c = 1;
		static int nr3c[1] = {15};
		double ytau15c[1] = {0};
		lagvalue(historyc, nr3c, Nout3c, ytau15c);
		ytauc[2]=ytau15c[0];
		int Nout4c = 1;
		static int nr4c[1] = {16};
		double ytau16c[1] = {0};
		lagvalue(historyc, nr4c, Nout4c, ytau16c);
		ytauc[3]=ytau16c[0];
		int Nout5c = 1;
		static int nr5c[1] = {11};
		double ytau11c[1] = {0};
		lagvalue(history, nr5c, Nout5c, ytau11c);
		ytauc[4]=ytau11c[0];
		int Nout6c = 1;
		static int nr6c[1] = {12};
		double ytau12c[1] = {0};
		lagvalue(historyc, nr6c, Nout6c, ytau12c);
		ytauc[5]=ytau12c[0];
		int Nout7c = 1;
		static int nr7c[1] = {19};
		double ytau19c[1] = {0};
		lagvalue(historyc, nr7c, Nout7c, ytau19c);
		ytauc[6]=ytau19c[0];
		int Nout8c = 1;
		static int nr8c[1] = {18};
		double ytau18c[1] = {0};
		lagvalue(historyc, nr8c, Nout8c, ytau18c);
		ytauc[7]=ytau18c[0];
		double* Clag_intermediate = calc_intermediate(ytauc[4],ytauc[5],ytauc[0],ytauc[1],ytauc[2],ytauc[3],ytauc[7],ytauc[6],y[25],y[26],y[27]);
		Clag_P_B_co2 = Clag_intermediate[0];
	}
	double psai_co2 = ((Aco2+Bco2/(1+exp(-(P_a_co2 - Cco2)/Dco2)))*1500/100/1000/60 + Qb0)/Qb0 -1;
	double ReactionFlux24=1.00/tau_co2*(psai_co2 - y[18]);
	double psai_o2 = c1o2*(exp(-P_a_o2/c2o2)- exp(-P_a_o2_0/c2o2));
	if (psai_o2>=2 ) {
		psai_o2=2;
	}
	double ReactionFlux25=1.00/tau_o2*(psai_o2 - y[19]);
	double Plag_f_pc=K_fpc*log(Plag_P_a_co2/Bp)*(f_pc_max+f_pc_min*exp((Plag_P_a_o2 - P_a_o2_c)/K_pc))/(1+exp((Plag_P_a_o2-P_a_o2_c)/K_pc));
	double AV1=1-pow(y[9],P1);
	/*Plag drive */
	double ReactionFlux26=1.00/tau_Dp*(-y[20] + AV1*G_Dp*(Plag_f_pc - f_pc_0));
	/*Clag drive */
	double AV2 = 1 - pow(y[9],P1);
	double ReactionFlux27 = 1.00/tau_Dc*(-y[21] + AV2*G_Dc*(Clag_P_B_co2 - P_B_co2_0));
	double Hstat;
	if (P_B_o2 <= theta_Hmin) {
		Hstat =1 + Gh*((theta_Hmin - P_B_o2_0)/P_B_o2_0);
	}
	if((P_B_o2 <= theta_Hmax) && (P_B_o2 > theta_Hmin)){
		Hstat = 1 + Gh*((P_B_o2 - P_B_o2_0)/P_B_o2_0);
	}
	if(P_B_o2 > theta_Hmax){
		Hstat = 1 + Gh*((theta_Hmax - P_B_o2_0)/P_B_o2_0);
	}
	double ReactionFlux28 = 1.00/tau_h*(Hstat - y[22]);
	/*Opioid Wakefulness */
	double chemoreflex_drive = 0;
	double peripheral_drive = y[22]*y[20];
	double residualWakefulnessDrive=W - Kf;
	if(y[20]<0){
		peripheral_drive=y[20];
	}
	if(peripheral_drive +y[21] >0){
		chemoreflex_drive = peripheral_drive +y[21];
	}
	double totalVentilation = y[24] + residualWakefulnessDrive + chemoreflex_drive;
	double Venti = totalVentilation*Bmax/60.00;
	if(Venti< 0)
		Venti=0; /*ventilation can't go to negative*/
	//ventilation collpase===========================================================
	if (Q<=4.9*.2/60){
		residualWakefulnessDrive=residualWakefulnessDrive*(Q/(4.9*.2/60));
		chemoreflex_drive=chemoreflex_drive*(Q/(4.9*.2/60));
		Venti=Venti*(Q/(4.9*.2/60));
		if (Q<=4.9*0.1/60){residualWakefulnessDrive=0; chemoreflex_drive=0; Venti=0;}
	}
	//===============================================================================
	//oxygen saturation calculation========================================================================================
	//	double nSaturation=2.6;
	//	double k3=26.6; //mm Hg
	//	double PO2Virtual=P_a_o2*pow(40/P_a_o2,0.3);
	//	double SO2=pow(PO2Virtual,nSaturation)/(pow(k3,nSaturation)+pow(PO2Virtual,nSaturation));
	//	double arterialOxygenSaturation=SO2*100;
	double arterialOxygenSaturation=pow(((pow((pow(P_a_o2,3) + 150*P_a_o2),-1)*23400)+1),-1)*100; /*Severinghaus equation*/
	//=====================================================================================================================
	//very small values (both positive and negative) set to zero (WHY???)=====
	if(y[0]>-1e-9 && y[0]<1e-9) {y[0]=0;}
	if(y[1]>-1e-9 && y[1]<1e-9) {y[1]=0;}
	if(y[2]>-1e-9 && y[2]<1e-9) {y[2]=0;}
	if(y[3]>-1e-9 && y[3]<1e-9) {y[3]=0;}
	if(y[4]>-1e-9 && y[4]<1e-9) {y[4]=0;}
	if(y[5]>-1e-9 && y[5]<1e-9) {y[5]=0;}
	if(y[6]>-1e-9 && y[6]<1e-9) {y[6]=0;}
	if(y[7]>-1e-9 && y[7]<1e-9) {y[7]=0;}
	if(y[8]>-1e-9 && y[8]<1e-9) {y[8]=0;}
	if(y[9]>-1e-9 && y[9]<1e-9) {y[9]=0;}
	if(y[10]>-1e-9 && y[10]<1e-9) {y[10]=0;}
	if(y[11]>-1e-9 && y[11]<1e-9) {y[11]=0;}
	if(y[12]>-1e-9 && y[12]<1e-9) {y[12]=0;}
	if(y[13]>-1e-9 && y[13]<1e-9) {y[13]=0;}
	if(y[14]>-1e-9 && y[14]<1e-9) {y[14]=0;}
	if(y[15]>-1e-9 && y[15]<1e-9) {y[15]=0;}
	if(y[16]>-1e-9 && y[16]<1e-9) {y[16]=0;}
	if(y[17]>-1e-9 && y[17]<1e-9) {y[17]=0;}
	if(y[18]>-1e-9 && y[18]<1e-9) {y[18]=0;}
	if(y[19]>-1e-9 && y[19]<1e-9) {y[19]=0;}
	if(y[20]>-1e-9 && y[20]<1e-9) {y[20]=0;}
	if(y[21]>-1e-9 && y[21]<1e-9) {y[21]=0;}
	if(y[22]>-1e-9 && y[22]<1e-9) {y[22]=0;}
	//========================================================================
	//ODEs==============================================================================================
	//	ydot[0] = -ktr*F*y[0]; //naloxone depot //in mg/sec
	//	ydot[1] = ktr*F*y[0]-ktr*y[1]; // naloxone transfer comaprtment 1 //in mg/sec
	//	ydot[28] = ktr*y[1]-ktr*y[28]; // naloxone transfer compartment 2 //in mg/sec
	//	ydot[2] = ktr*y[28]-ktr*y[2]; //naloxone transfer compartment 3 //in mg/sec
	//	ydot[3] = 1/V2C*((ktr*y[2])-(kout2*y[3]) - (k12N*y[3]))+1/V2C*(k12N*y[29]);
	//			//ktr*y[2]-(kout2/V2C)*y[3]+(k21N/V3)*y[29]-(k12N/V2C)*y[3]; //naloxone central compartment //in mg/sec
	//	ydot[29] = 1/V3*(k12N*y[3])-(k12N/V3)*y[29]; //naloxone peripheral compartment //in mg/sec
	//	ydot[4] = (k2*(y[3])*1e3/(327.27))-(k2*y[4]); //naloxone effective compartment //in pM/sec

	//iman IV ----------
	ydot[0] = -(ikoutC*y[0])-(ik12C*y[0])+(ik21C*y[1])+(ik31C*y[2])-(ik13C*y[0]); //Naloxone in central comp ng/s
	ydot[1] = (ik12C*y[0])-(ik21C*y[1]);  //Naloxone in 1st peripheral ng/s
	ydot[2] = (ik13C*y[0])-(ik31C*y[2]);  //Naloxone in 2st peripheral ng/s
	ydot[3] = 0;
	ydot[4] = ((1/iV2CS)*(k2*(y[0])*1e3/(327.27))-(k2*y[4])); // ng/s to pM/s #2.87 paper central comp V(L)
	ydot[28] = 0;
	ydot[29] = 0;
	//End iman IV

	//iman IV ----------

	ydot[5] = -(koutC*y[5])-(k12C*y[5])+(k21C*y[6])+(k31C*y[7])-(k13C*y[5])+y[23]/Infu_t;
	ydot[6] = (k12C*y[5])-(k21C*y[6]);
	ydot[7] = (k13C*y[5])-(k31C*y[7]);
	ydot[8] = (k1*1e6*y[5]*1000.00/VPC/Mmass)-(k1*y[8]);
	ydot[9] = (A1*(1-y[9]-y[10])*(pow(y[8],n)))-(B1*y[9]);
	ydot[10] = (A2*(1-y[9]-y[10])*(pow(y[4],n2)))-(B2*y[10]);
	ydot[11] = offCo2*(1.00/V_A*(Venti*(P_I_co2 - y[11]) + lumbda*(Qb+Qt)*(1-s1)*(C_V_co2 - C_e_co2)));
	ydot[12] = offO2*(1.00/V_A*(Venti*(y[17] - y[12]) + lumbda*(Qb+Qt)*(1-s1)*(C_V_o2 - C_e_o2)));
	ydot[13] = ReactionFlux19; /* dC_B_co2 */
	ydot[14] = ReactionFlux20; /* dC_B_o2 */
	ydot[15] = ReactionFlux21; /* dC_T_co2 */
	ydot[16] = ReactionFlux22; /* dC_T_o2 */
	ydot[17] = 0;              /* P_I_o2 */
	ydot[18] =ReactionFlux24; /* dyco2 */
	ydot[19] =ReactionFlux25; /* dyo2 */
	ydot[20] =offDp*ReactionFlux26; /* Dp */
	ydot[21] =offDc*ReactionFlux27; /* Dc */
	ydot[22] =ReactionFlux28; /* dalphaH */
	ydot[23] =0; /* FIV */
	ydot[24] =0; /* counter*/
	ydot[25] =-Cim25_e*y[25]; /* */
	ydot[26] =-Cim26_e*y[26]; /* */
	ydot[27] =0; /* */
	//==================================================================================================
	//Outputs
	yout[0]=Venti*60/Bmax; /*Minute ventilation (l/min)*/
	yout[1]=residualWakefulnessDrive; /*Residual wakefulness drive (l/min)*/
	yout[2]=chemoreflex_drive; /*Chemoreflex drive (l/min)*/
	yout[3]=Qb*60; /*Blood flow to brain (l/min)*/
	yout[4]=Qt*60; /*Blood flow to tissue (l/min)*/
	yout[5]=P_a_o2; /*Arterial O2 partial pressure (mm Hg)*/
	yout[6]=P_a_co2; /*Arterial CO2 partial pressure (mm Hg)*/
	yout[7]=P_B_o2; /*Brain O2 partial pressure (mm Hg)*/
	yout[8]=P_B_co2; /*Brain CO2 partial pressure (mm Hg)*/
	yout[9]=(y[5]/VPC)*1000; /*Opioid plasma concentration (ng/mL)*/
	yout[10]=y[0]/(iV2CS*1e3); /*Antagonist plasma concentration (ng/mL)*/
	yout[11]=y[8]/1e3; /*Opioid effect site concentration (nM)*/
	yout[12]=y[4]/1e3; /*Antagonist effect site concentration (nM)*/
	yout[13]=y[9]; /*Opioid bound receptor fraction*/
	yout[14]=y[10]; /*Antagonist bound receptor fraction*/
	yout[15]=Q*60; /*Cardiac output (l/min)*/
	yout[16]=koutC; /*Elimination Rate (1/s)*/
	yout[17]=k12C;
	yout[18]=k13C;
	yout[19]=k21C;
	yout[20]=k31C;
	yout[21]=VPC; /*Opioid volume of distribution (L?)*/
	yout[22]=arterialOxygenSaturation; /*Arterial O2 saturation (%)*/
}
