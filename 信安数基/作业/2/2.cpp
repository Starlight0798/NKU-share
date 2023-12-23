#include <bits/stdc++.h>
using namespace std;

int gcd(int a, int b){
   if(b==0) return a;
   else return gcd(b,a%b);
}

int lcm(int a, int b){
   return a*b/gcd(a,b);
}

int inverse(int a,int m){
    int r, q, s1 = 1, s2 = 0, s3, t1 = 0, t2 = 1, t3 = 1, mt = m;
    while(1){
        r = m%a; q = m/a;
        if(!r) break;
        m = a; a = r;
        s3 = s1 - q*s2;
        t3 = t1 - q*t2;
        s1 = s2; s2 = s3;
        t1 = t2; t2 = t3;
    }
    while(t3 < 0) t3 += mt;
    return t3;
}
int main(){
    int a,b;
    printf("a="); scanf("%d", &a);
    printf("b="); scanf("%d", &b);
    int g = gcd(a, b), l = lcm(a, b);
    printf("gcd(a,b)=%d\n", g);
    printf("lcm(a,b)=%d\n", l);
    int an = inverse(a%b,b), bn = inverse(b%a,a);
    printf("a^(-1)=%d(mod %d)\n", an, b);
    printf("b^(-1)=%d(mod %d)", bn, a);
    system("pause");
    return 0;
}