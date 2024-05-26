#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include "csvpackage.h"

struct Animals read_in[182];
struct Histobuckets hb_read_in[10];

/*
函数功能：	根据逗号拆分并获取csv文件内一行记录的第num个属性的值
输入参数说明：
line        fgets读取到的一行数据
num         要获取的属性序号
*/
char* get_field(char *line, int num)
{
    char *tok;
    tok = strtok(line, ",");
    for (int i = 1; i != num; i++) {
        tok = strtok(NULL, ",");
    }
    char *result = remove_quoted(tok);

    return result;
}

/*
函数功能：	去除多余的逗号并为字符串添加结尾标识
输入参数说明：
str         拆分出的含逗号的字符串
*/
char* remove_quoted(char *str)
{
    int length = strlen(str);
    char *result = malloc(length + 1);
    int index = 0;
    for (int i = 0; i < length; i++) {
        if (str[i] != '\"') {
            result[index] = str[i];
            index++;
        }
    }
    result[index] = '\0';
    return result;
}

/*
函数功能：	将zoo数据集解析为Animals格式的结构体数组
输入参数说明：
csv_in      输入的csv文件对象
*/
struct Animals * csv_parser(FILE *csv_in)
{
    memset(read_in,0,sizeof(read_in));
    if (csv_in == NULL) {
        fprintf(stderr, "fopen() failed.\n");
        exit(EXIT_FAILURE);
    }
    
    char row[100];
    char *token;

    char *tmp;
    int sum=0;
    int i=0;
    while (fgets(row, 100, csv_in) != NULL) {
        tmp = get_field(strdup(row), 1);
        read_in[i].name =strdup(tmp);
        tmp = get_field(strdup(row), 2);
        read_in[i].carrots = atoi(tmp);
        if(read_in[i].carrots>=55)
            sum+=1;
        i++;
    }
    printf("Animals which carrots cost > 55 (original): %d\n",sum);
    fclose(csv_in);
    return &read_in[0];
}

/*
函数功能：	将medicaldata数据集解析为Histobuckets格式的结构体数组
输入参数说明：
csv_in      输入的csv文件对象
*/
struct Histobuckets * hb_csv_parser(FILE *csv_in)
{
    memset(hb_read_in,0,sizeof(hb_read_in));
    if (csv_in == NULL) {
        fprintf(stderr, "fopen() failed.\n");
        exit(EXIT_FAILURE);
    }
    
    char row[100];
    char *token;

    char *tmp;
    int sum=0;
    int i=0;
    while (fgets(row, 100, csv_in) != NULL) {
        tmp = get_field(strdup(row), 1);
        hb_read_in[i].bucket =strdup(tmp);
        tmp = get_field(strdup(row), 2);
        hb_read_in[i].count = atoi(tmp);
        i++;
    }
    fclose(csv_in);
    return &hb_read_in[0];
}
