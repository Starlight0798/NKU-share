#ifndef LAPLACE_H_
#define LAPLACE_H_
 
/*
函数功能：	产生（a,b）区间上均匀分布的随机数组
输入参数说明：
a		给定区间的下限
b		给定区间的上线
seed	长整型指针变量， *seed 为伪随机数的种子
*/
double uniform_data(double a, double b, long int * seed);

/*
函数功能：	产生laplace分布的随机数
输入参数说明：
beta		拉普拉斯分布参数
seed	    长整型指针变量， *seed 为伪随机数的种子
*/
double laplace_data(double beta, long int * seed);
 
#endif // !LAPLACE_H_
