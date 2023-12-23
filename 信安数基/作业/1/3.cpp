#include <iostream>
using namespace std;

const int MAXN = 2000000;
bool vis[MAXN];
pair<int, int> ans[200];
int lens;

void Eratosthenes(int n){
    for(int i=2;i<=n;i++){
        if(!vis[i]){
            if(n%i==0){
                ans[lens].first = i;
                while(n%i==0){
                    ans[lens].second++;
                    n/=i;
                }
                lens++;
                if(n==1) break;
            }
            for(int j = 2*i;j <= n;j += i) vis[j] = true;
        }
    }
}

int main(){
   int n;
   printf("Please input n(n>0): ");
   scanf("%d",&n);
   printf("%d=",n);
   Eratosthenes(n);
   for(int i=0;i<lens;i++){
      printf("%d^%d", ans[i].first, ans[i].second);
      if(i<lens-1) printf("*");
   }
   system("pause");
   return 0; 
}