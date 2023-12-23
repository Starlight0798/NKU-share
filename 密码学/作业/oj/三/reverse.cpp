#include <iostream>
using namespace std;

int inverse(int a,int m){
    while(a < 0) a += m;
    a %= m;
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
    int a, p;
    scanf("%d", &a);
    scanf("%d", &p);
    printf("%d", inverse(a, p));
    return 0;
}