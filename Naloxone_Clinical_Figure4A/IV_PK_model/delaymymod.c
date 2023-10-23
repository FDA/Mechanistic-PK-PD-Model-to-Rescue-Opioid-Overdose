#include <R.h>
#include <Rinternals.h>
#include <Rdefines.h>
#include <R_ext/Rdynload.h>
#include <time.h>
static double parms[7];
#define koutC parms[0]
#define k12C parms[1]
#define k21C parms[2]
#define k13C parms[3]
#define k31C parms[4]
#define timeout parms[5]
#define starttime parms[6]

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
int N=7;
odeparms(&N, parms);}

void derivs (int *neq, double *t, double *y, double *ydot, double *yout, int *ip){
if (ip[0] < 0 ) error("nout not enough!");
time_t s = time(NULL);
if((int) s - (int) starttime > timeout) error("timeout!");


ydot[0] = -(koutC*y[0])-(k12C*y[0])+(k21C*y[1])+(k31C*y[2])-(k13C*y[0]);
ydot[1] = (k12C*y[0])-(k21C*y[1]);
ydot[2] = (k13C*y[0])-(k31C*y[2]);
}
