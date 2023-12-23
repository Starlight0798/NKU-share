#include <bits/stdc++.h>
using namespace std;

const int lena = 8;

// 双指针
// 时间复杂度：O(n)
void solve1(int* a,int t){ 
    int pl = 0, pr = lena - 1;
    while(pr>pl){
        if(a[pl]+a[pr]<t) pl++;
        else if(a[pl]+a[pr]>t) pr--;
        else{
            cout<<a[pl]<<" "<<a[pr]<<endl;
            return;
        }
    }
}

// 暴力枚举
// 时间复杂度：O(n^2)
void solve2(int* a,int t){ 
    for(int i=0;i<lena;i++){
        for(int j=i+1;j<lena;j++){
            if(a[i]+a[j]==t){
                cout<<a[i]<<" "<<a[j]<<endl;
                return;
            }
        }
    }
}

int binary_search(int* a, int val, int start, int end){
    if(start > end) return -1;
    int mid = (start+end)/2;
    if(val == a[mid]) return mid;
    else if(val < a[mid]) return binary_search(a,val,start,mid-1);
    else return binary_search(a,val,mid+1,end);
}

// 二分查找
// 时间复杂度：O(nlogn)
void solve3(int* a,int t){
    for(int i=0;i<lena-1;i++){
        int f = binary_search(a, t-a[i], i+1, lena-1);
        if(f!=-1){
            cout<<a[i]<<" "<<a[f]<<endl;
            return;
        }
    }
}

int main(){
    int a[lena], t;
    for(int i=0;i<lena;i++) cin>>a[i];
    cin>>t;
    solve1(a,t);
    solve2(a,t);
    solve3(a,t);
    return 0;
}