#include <iostream>
#include <list>
#define ll long long
using namespace std;

const int MAXN = 2000000;
bool vis[MAXN];
list<ll> pri;
pair<ll, int> ans[100];
int lens;

void Prime(ll n){
   for(ll i=2;i<=n;i++){
      if(!vis[i]){
         pri.push_back(i);
         if(n%i==0){
            ans[lens].first = i;
            while(n%i==0){
               ans[lens].second++;
               n/=i;
            }
            lens++;
            if(n==1) break;
         }
      }
      for(ll& p:pri){
         if(i*p>n) break;
         vis[i*p] = true;
         if(i%p==0) break;
      }
   }
}

int main(){
   ll n;
   printf("Please input n(n>0): ");
   scanf("%lld",&n);
   printf("%lld=",n);
   Prime(n);
   for(int i=0;i<lens;i++){
      printf("%lld^%d", ans[i].first, ans[i].second);
      if(i<lens-1) printf("*");
   }
   system("pause");
   return 0; 
}