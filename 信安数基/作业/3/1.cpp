#include <bits/stdc++.h>
#define MAXN 10000
using namespace std;

int b[MAXN], m[MAXN];

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
    int n, an = 0, am = 1;
    printf("n="); scanf("%d", &n);
    for(int i=0;i<n;i++){
        printf(" b_%d=",i);
        scanf("%d", &b[i]);
    }
    for(int i=0;i<n;i++){
        printf(" m_%d=",i);
        scanf("%d", &m[i]);
        am *= m[i];
    }
    for(int i=0;i<n;i++){
        int mul = am/m[i];
        int re_mul = inverse(mul, m[i]);
        an += re_mul * mul * b[i];
    }
    printf("x¡Ô%d (mod %d)", an % am, am);
    system("pause");
    return 0;
}