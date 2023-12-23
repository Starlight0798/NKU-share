#include <bits/stdc++.h>
#define N 30050
using namespace std;

int n;
double x, y;

struct spot{
    double x, y;
} X[N], Y[N];

vector<spot> strip;

double Dis(const spot& s1,const spot& s2){ return (s1.x-s2.x)*(s1.x-s2.x)+(s1.y-s2.y)*(s1.y-s2.y);}
bool cmpx(const spot& s1,const spot& s2){ return s1.x < s2.x;}
bool cmpy(const spot& s1,const spot& s2){ return s1.y < s2.y;}

double getminDis(int left,int right){
    if(left >= right) return FLT_MAX;
    if(right - left == 1) return Dis(X[left],X[right]);
    int xmid = (left+right) / 2;
    double d1 = getminDis(left, xmid);
    double d2 = getminDis(xmid+1, right);
    double d = min(d1,d2);
    for(int i = left; i < right; i++){
        if(fabs(X[i].x - X[xmid].x) < d) strip.push_back(X[i]);
    }
    sort(strip.begin(), strip.end(), cmpy);
    for(size_t i = 0; i < strip.size(); i++){
        for(size_t j = i+1; j < strip.size() && strip[j].y - strip[i].y < d; j++){
            double dis = Dis(strip[i], strip[j]);
            d = min(d,dis);
        }
    }
    return d;
}
int main(){
    scanf("%d",&n);
    for(int i=0;i<n;i++){
        scanf("%lf%lf", &x, &y);
        X[i] = {x, y};
        Y[i] = {x, y};
    }
    sort(X, X+n, cmpx);
    sort(Y, Y+n, cmpy);
    printf("%.2lf", getminDis(0,n-1));
    return 0;
}