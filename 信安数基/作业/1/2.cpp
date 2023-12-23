#include <iostream>
using namespace std;

int gcd(int a, int b){
   if(b==0) return a;
   else return gcd(b,a%b);
}

int lcm(int a, int b){
   return a*b/gcd(a,b);
}

int main(){
   int a,b;
   printf("a=");
   scanf("%d", &a);
   printf("b=");
   scanf("%d", &b);
   printf("gcd(a,b)=%d\n", gcd(a,b));
   printf("lcm(a,b)=%d", lcm(a,b));
   system("pause");
   return 0; 
}