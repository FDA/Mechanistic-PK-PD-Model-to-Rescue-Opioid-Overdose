#include <R.h>
#include <Rinternals.h>
#include <Rdefines.h>
#include <R_ext/Rdynload.h>
#include <time.h>
static double parms[9];
#define V1 parms[0]
#define Kin parms[1]
#define Kout parms[2]
#define Ktr parms[3]
#define k12N parms[4]
#define V2 parms[5]
#define weight parms[6]
#define timeout parms[7]
#define starttime parms[8]

void lagvalue(double *T, int *nr, int N, double *yout) {
static void(*fun)(double*, int*, int, double*) = NULL;
if(fun==NULL)
fun =  (void(*)(double*, int*, int, double*))R_GetCCallable("deSolve", "lagvalue");
return fun(T, nr, N, yout);
}
void lagderiv(double *T, int *nr, int N, double *yout) {
static void(*fun)(double*, int*, int, double*) = NULL;
if (fun == NULL)
fun =  (void(*)(double*, int*, int, double*))R_GetCCallable("deSolve", "lagvalue");
return fun(T, nr, N, yout);
}

void initmod(void (* odeparms)(int *, double *)){
int N=9;
odeparms(&N, parms);}

void derivs (int *neq, double *t, double *y, double *ydot, double *yout, int *ip){
if (ip[0] < 0 ) error("nout not enough!");
time_t s = time(NULL);
if((int) s - (int) starttime > timeout) error("timeout!");
double Scl= pow((weight/70),0.75);
double Sv= (weight/70);
double scale1=Scl/Sv;
double KoutS = Kout*scale1;
double V1S = V1*Sv;
double V2S = V2*Sv;
ydot[0] = 1/V1S*((Kin*y[3])-(KoutS*y[0])+(k12N*y[4])-(k12N*y[0]));
ydot[1] = ((y[5]*y[2]*Ktr)-(Ktr*y[1]));
ydot[2] = (-(y[5]*y[2]*Ktr)-((1-y[5])*y[2]*Ktr));
ydot[3] = ((Ktr*y[1])-(Kin*y[3]));
ydot[4] = 1/V2S*(-(k12N*y[4])+(k12N*y[0]));
ydot[5] = 0;
}


//ydot[0] = -(ktr*F*y[0])-((1-F)*ktr*y[0]);
//ydot[1] = ((F*y[0]*Ktr)-(Ktr*y[1]));
//ydot[2] = ((Ktr*y[1])-(Kin*y[2]));
//ydot[3] = 1/V1S*((Kin*y[2])-(KoutS*y[3])+(k12N*y[26])-(k12N*y[3]));
//ydot[26] = 1/V2S*(-(k12N*y[26])+(k12N*y[3]));























