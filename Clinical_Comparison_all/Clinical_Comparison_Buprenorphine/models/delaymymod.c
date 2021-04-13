#include <R.h>
#include <Rinternals.h>
#include <Rdefines.h>
#include <R_ext/Rdynload.h>
#include <time.h>
static double parms[18];
#define koutb parms[0]
#define koutn parms[1]
#define k1b parms[2]
#define k1n parms[3]
#define k12b parms[4]
#define k21b parms[5]
#define k13b parms[6]
#define k31b parms[7]
#define k12n parms[8]
#define k21n parms[9]
#define A1 parms[10]
#define B1 parms[11]
#define n parms[12]
#define A2 parms[13]
#define B2 parms[14]
#define n2 parms[15]
#define timeout parms[16]
#define starttime parms[17]

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
int N=18;
odeparms(&N, parms);}

void derivs (int *neq, double *t, double *y, double *ydot, double *yout, int *ip){
if (ip[0] < 0 ) error("nout not enough!");
time_t s = time(NULL);
if((int) s - (int) starttime > timeout) error("timeout!");
ydot[0] = ((k21n*y[3])-(koutn*y[0])-(k12n*y[0]));
ydot[1] = (k1n*y[0]*1e9/(327.27*12.1))-(k1n*y[1]);
ydot[2] = -(koutb*y[2])-(k12b*y[2])+(k21b*y[4])-(k13b*y[2])+(k31b*y[5]);
ydot[3] = (k12n*y[0])-(k21n*y[3]);
ydot[4] = (k12b*y[2])-(k21b*y[4]);
ydot[5] = (k13b*y[2])-(k31b*y[5]);
ydot[6] = (k1b*y[2]*1e9/(5.71*467.64))-(k1b*y[6]);
ydot[7] = (A1*(1-y[7]-y[8])*exp(n*log(y[6])))-(B1*y[7]);
ydot[8] = (A2*(1-y[7]-y[8])*exp(n2*log(y[1])))-(B2*y[8]);
}
