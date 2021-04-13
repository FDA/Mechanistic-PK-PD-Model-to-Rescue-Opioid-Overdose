#include <R.h>
#include <Rinternals.h>
#include <Rdefines.h>
#include <R_ext/Rdynload.h>
#include <time.h>
static double parms[21];
#define F1 parms[0]
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
#define timeout parms[19]
#define starttime parms[20]

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
int N=21;
odeparms(&N, parms);}

void derivs (int *neq, double *t, double *y, double *ydot, double *yout, int *ip){
if (ip[0] < 0 ) error("nout not enough!");
time_t s = time(NULL);
if((int) s - (int) starttime > timeout) error("timeout!");
ydot[0] = -(ktr*F1*y[0])-((1-F1)*ktr*y[0]);
ydot[1] = (ktr*F1*y[0])-(ktr*y[1]);
ydot[2] = -(1*kin*y[2])+(ktr*y[1]);
ydot[3] = (1/V1)*((1*kin*y[2])-(kout2*y[3]));
ydot[4] = (k2*y[3]*1e6/(327.27))-(k2*y[4]);
ydot[5] = -(kout*y[5])-(k12*y[5])+(k21*y[6])+(k31*y[7])-(k13*y[5]);
ydot[6] = (k12*y[5])-(k21*y[6]);
ydot[7] = (k13*y[5])-(k31*y[7]);
ydot[8] = (k1*1e6*y[5]*1000/10.5/Mmass)-(k1*y[8]);
ydot[9] = (A1*(1-y[9]-y[10])*exp(n*log(y[8])))-(B1*y[9]);
ydot[10] = (A2*(1-y[9]-y[10])*exp(n2*log(y[4])))-(B2*y[10]);
}
