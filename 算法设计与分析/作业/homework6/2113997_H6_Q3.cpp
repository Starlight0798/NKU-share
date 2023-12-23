#include <bits/stdc++.h>
#define MAXN 10000
using namespace std;

int a[MAXN], t[MAXN];

// 归并两个有序数组
void Mergearr(int* a, int begin, int mid, int end, int* t){
    int i = begin, j = mid + 1, k = begin;
    while(i <= mid && j <= end){
        if(a[i] <= a[j]) t[k++] = a[i++];
        else t[k++] = a[j++];
    }
    while(i <= mid) t[k++] = a[i++]; // 将剩余元素放入数组
    while(j <= end) t[k++] = a[j++]; 
    for(int i = begin; i <= end; i++) a[i] = t[i]; // 将排好序的元素放回原数组
}

// 归并排序
void Mergesort(int* a, int begin, int end, int* t){
    if(begin >= end) return; // 数组长度为1时，直接返回
    int mid = (begin + end) / 2; // 计算中间位置
    Mergesort(a, begin, mid, t); // 递归处理左半部分
    Mergesort(a, mid + 1, end, t); // 递归处理右半部分
    Mergearr(a, begin, mid, end, t); // 合并左右两部分
}

int main(){
    int n;
    cin >> n;
    for(int i = 0; i < n; i++) cin >> a[i];
    Mergesort(a, 0, n - 1, t); // 归并排序
    for(int i = 0; i < n; i++) cout << a[i] << " "; // 输出排序后的数组
    return 0;
}
