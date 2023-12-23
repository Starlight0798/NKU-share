#include <iostream>
#include <cmath>
using namespace std;

const int N = 1000000;
bool vis[N];

void Eratosthenes(int n){
   int t = sqrt(n);
   for(int i=2;i<=t;i++){
      if(!vis[i]){
         for(int j = 2*i;j<=n;j+=i){
            vis[j] = true;
         }
      }
   }
}

int main(){
   printf("Please input the range: ");
   int a,b,cnt=0; char s;
   scanf("%d%c%d", &a, &s, &b);
   vis[0] = vis[1] = true;
   Eratosthenes(N);
   for(int i=a;i<=b;i++){
      if(!vis[i]) cnt++,printf("%d, ",i);
   }
   printf("\nTotal: %d",cnt);
   system("pause");
   return 0; 
}