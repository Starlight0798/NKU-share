#include <bits/stdc++.h>
#define MAXN 10000
using namespace std;

int a[MAXN], t[MAXN], cnt;

// 归并两个有序数组并计算逆序对数量
void Mergearr(int* a, int begin, int mid, int end, int* t){
    int i = begin, j = mid + 1, k = begin;
    while(i <= mid && j <= end){
        if(a[i] <= a[j]) t[k++] = a[i++];
        else t[k++] = a[j++], cnt += mid - i + 1; // 如果a[i] > a[j]，则a[i...mid]都比a[j]大，逆序对数量加上mid-i+1
    }
    // 两个while循环只会执行一个
    while(i <= mid) t[k++] = a[i++]; // 将剩余元素放入数组
    while(j <= end) t[k++] = a[j++]; // 将剩余元素放入数组
    for(int i = begin; i <= end; i++) a[i] = t[i]; // 将排好序的元素放回原数组
}

// 归并排序并计算逆序对数量
void Mergesort(int* a, int begin, int end, int* t){
    if(begin >= end) return; // 数组长度为1时，直接返回
    int mid = (begin + end) / 2; // 计算中间位置
    Mergesort(a, begin, mid, t); // 递归处理左半部分
    Mergesort(a, mid + 1, end, t); // 递归处理右半部分
    Mergearr(a, begin, mid, end, t); // 合并左右两部分并计算逆序对数量
}

int main(){
    int n;
    cin >> n;
    for(int i = 0; i < n; i++) cin >> a[i];
    Mergesort(a, 0, n - 1, t); // 归并排序并计算逆序对数量
    cout << cnt; // 输出逆序对数量
    return 0;
}
