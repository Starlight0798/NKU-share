#include <stdio.h>
#include <string.h>
#include "laplace.h"
#include "csvpackage.h"
#include <time.h>
extern int rand();
extern void srand(unsigned);
/*
函数功能：	对传入的csv文件进行处理，提取其中数据并生成拉普拉斯分布的噪音进行加噪
输入参数说明：
path		csv文件的存储位置
beta		拉普拉斯分布参数
seed	    长整型指针变量， *seed 为伪随机数的种子
*/
// void csv_analysis(char* path, double beta, long int seed)
double csv_analysis(char* path, double beta, long int seed)
{
	FILE *original_file = fopen(path,"r+"); //读取指定路径的数据集
	struct Animals * original_data = NULL;
	original_data = csv_parser(original_file);
	int sum=0,i=0;
	double x = 0;
	while(original_data[i].name)  //循环为原始数据集内各条数据生成拉普拉斯噪音并加噪
	{
		x = laplace_data(beta,&seed); //产生拉普拉斯随机数
		// printf("Added noise:%f\t%s\t%f\n",x,original_data[i].name,original_data[i].carrots+x); 
		//此处分别列出了每条具体添加的噪音和加噪的结果。当投入较少预算时，可能会出现负数
		if(original_data[i].carrots+x>=55)
		{
			sum++;
		}
		i++;
	}
	printf("Animals which carrots cost > 55 (Under DP): %d\n",sum+(int)x); 
	// 输出加噪后的数据集中，每日食用胡萝卜大于55的动物个数
	return sum + x;
}

/*
参数表：
seed	    长整型指针变量， *seed为伪随机数的种子
sen			数据集的敏感度
x			用于储存拉普拉斯分布噪音的临时变量
beta		隐私预算，在输入后根据公式转换为拉普拉斯分布参数
*/
int main()
{
	long int seed;
	int sen = 1;  //对于一个单属性的数据集，其敏感度为1
	double eps[]={10,0.1}; //指定两类隐私预算，分别代表极小，极大
	srand((unsigned)time( NULL )); //生成基于时间的随机种子（srand方法）
	int i = 0;

	int search_times = 20;	 
	printf("Input search times is %d\n", search_times);

	while(i<2)
	{
		printf("Under privacy budget %f, sanitized original data with animal name and laplace noise:\n",eps[i]);
		double beta = sen / (eps[i] / search_times); //拉普拉斯机制下，实际公式的算子beta为敏感度/预算
		// seed = rand()%10000+10000; //随机种子产生
		// csv_analysis("./zoo.csv",beta,seed); //先调用原始数据集

		double avg_old=0;
		for(int i=0;i<search_times;i++){
			seed = rand()%10000+10000; //随机种子产生
			avg_old += csv_analysis("./zoo.csv",beta,seed); //先调用原始数据集
		}
		printf("Avg Old Search Result: \t%f\n", avg_old/search_times);

		printf("==================Using neighbour dataset==================\n");
		// seed = rand()%10000+10000; //随机种子更新
		// csv_analysis("./zoo_nb.csv",beta,seed); //再调用相邻数据集 

		double avg_new=0;
		for(int i=0;i<search_times;i++){
			seed = rand()%10000+10000; //随机种子更新
			avg_new += csv_analysis("./zoo_nb.csv",beta,seed); //再调用相邻数据集
		}
		printf("Avg New Search Result: \t%f\n", avg_new/search_times);

		printf("===========================================================\n");
		i++;
	}
	return 0;
}

