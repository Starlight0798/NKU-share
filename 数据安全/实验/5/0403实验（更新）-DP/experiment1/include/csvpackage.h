#ifndef CSVPACKAGE_H_
#define CSVPACKAGE_H_
#include <stdio.h>
/*
结构体：	Animals
为zoo数据集提供结构化存储功能
成员说明：
name		对应zoo数据集的第一列，动物名称
carrots		对应zoo数据集的第二列，每日食用胡萝卜数量
*/
struct Animals{
    char* name;
    int carrots;
}Ani;

/*
结构体：	Histobuckets
为medicaldata数据集提供结构化存储功能
成员说明：
bucket		对应medicaldata数据集的第一列，分桶名称
count		对应medicaldata数据集的第二列，桶内元素数量
*/
struct Histobuckets{
    char* bucket;
    int count;
}Hb;

/*
函数功能：	根据逗号拆分并获取csv文件内一行记录的第num个属性的值
输入参数说明：
line        fgets读取到的一行数据
num         要获取的属性序号
*/
char* get_field(char *line, int num);

/*
函数功能：	去除多余的逗号并为字符串添加结尾标识
输入参数说明：
str         拆分出的含逗号的字符串
*/
char* remove_quoted(char *str);


/*
函数功能：	将zoo数据集解析为Animals格式的结构体数组
输入参数说明：
csv_in      输入的csv文件对象
*/
struct Animals * csv_parser(FILE *csv_in);

/*
函数功能：	将medicaldata数据集解析为Histobuckets格式的结构体数组
输入参数说明：
csv_in      输入的csv文件对象
*/
struct Histobuckets * hb_csv_parser(FILE *csv_in);
#endif // !CSVPACKAGE_H_
