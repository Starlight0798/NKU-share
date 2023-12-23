#include <bits/stdc++.h>
using namespace std;

const int lena = 8;

//二分查找函数，查找成功则返回下标，查找失败则返回最后查找的元素下标
int binary_search(int* a, int val, int start, int end){
    int mid = (start+end)/2;
    if(start == end || val == a[mid]) return mid;
    else if(val < a[mid]) return binary_search(a,val,start,mid-1);
    else return binary_search(a,val,mid+1,end);
}

//外层双指针，内层使用二分查找，时间复杂度为O(nlogn)
void solve1(int* a,int t){ 
    int pl = 0, pr = lena - 1;
    while(pr>pl){
        int f = binary_search(a,t-a[pl]-a[pr],pl+1,pr-1);
        if(a[pl]+a[pr]+a[f]<t) pl++;
        else if(a[pl]+a[pr]+a[f]>t) pr--;
        else{
            cout<<a[pl]<<" "<<a[f]<<" "<<a[pr]<<endl;
            return;
        }
    }
}

//外层遍历数组，内层双指针法，时间复杂度为O(n^2)
void solve2(int* a,int t){
    for(int i=0;i<lena-2;i++){
        int pl = i+1, pr = lena - 1;
        while(pr>pl){
            if(a[pl]+a[pr]<t-a[i]) pl++;
            else if(a[pl]+a[pr]>t-a[i]) pr--;
            else{
                cout<<a[i]<<" "<<a[pl]<<" "<<a[pr]<<endl;
                return;
            }
        }
    }
}

// 暴力枚举法，时间复杂度为 O(n^3)
void solve3(int* a,int t){ 
    for(int i=0;i<lena;i++){
        for(int j=i+1;j<lena;j++){
            for(int k=j+1;k<lena;k++){
                if(a[i]+a[j]+a[k]==t){
                    cout<<a[i]<<" "<<a[j]<<" "<<a[k]<<endl;
                    return;
                }
            }
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