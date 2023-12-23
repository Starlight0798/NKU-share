#include <bits/stdc++.h>
#define N 10000
using namespace std;

int a[N], n;

// 输出当前解
void output(){
    for(int i = 1; i <= n; i++){
        printf("%d ", a[i]);
    }
    printf("\n");
}

// 判断当前解是否合法
bool is_valid(int cnt){
    for(int i = 1; i < cnt; i++){
        if(a[i] == a[cnt]) return false;
    }
    return true;
}

// 采用回溯法搜索1,2,...,n的全排列
void backtrack(int cnt){
    for(int i = 1; i <= n; i++){
        a[cnt] = i;
        if(is_valid(cnt)){
            if(cnt == n) output();
            else backtrack(cnt + 1);
        }
    }
}

int main(){
    scanf("%d", &n);
    backtrack(1);
    return 0;
}