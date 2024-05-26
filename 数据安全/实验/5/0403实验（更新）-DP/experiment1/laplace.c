#include "laplace.h"
#include <stdint.h>
#include "string.h"
#include "stdio.h"
#include <math.h>
 
/* 
函数功能：	利用混合同余法产生（a,b）区间上均匀分布的随机数
输入参数说明：
a		给定区间的下限
b		给定区间的上限
seed	长整型指针变量， *seed 为伪随机数的种子
*/
double uniform_data(double a, double b,long int * seed)
{
	double t;
	*seed = 2045.0 * (*seed) + 1;
	*seed = *seed - (*seed / 1048576) * 1048576;
	t = (*seed) / 1048576.0;
	t = a + (b - a) * t;
	return t;
}

/*
函数功能：	求解laplace分布概率累积的反函数，利用该反函数产生laplace分布的随机数
输入参数说明：
beta		拉普拉斯分布参数
seed	    长整型指针变量， *seed 为伪随机数的种子
*/
double laplace_data(double beta, long int * seed)
{
	double u1,u2, x;
	u1 = uniform_data(0.0, 1.0, seed);
	u2 = uniform_data(0.0, 1.0, seed);
	if (u1 < 0.5)
	{
		x = beta * (log(2*u1)+u2);
	}
	else
	{
		x = u2 - (beta * log(2*(1-u1)));
	}
	
	return x;
}
