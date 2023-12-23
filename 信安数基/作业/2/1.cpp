#include <bits/stdc++.h>
using namespace std;

int cal(int a,int n,int m){
    if(!n) return 1;
    int x = cal(a, n>>1, m);
    x = (x * x) % m;
    if(n&1) return (x * a) % m;
    else return x;
}

int main(){
    printf("Calculate a^n(mod m)...\nPlease input:\n");
    int a,n,m;
    printf("  a="); scanf("%d",&a);
    printf("  n="); scanf("%d",&n);
    printf("  m="); scanf("%d",&m);
    int ans = cal(a,n,m);
    printf("%d^%d(mod %d)=%d",a,n,m,ans);
    system("pause");
    return 0;
}