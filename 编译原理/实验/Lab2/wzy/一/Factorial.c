#include<stdio.h>
int Factorial(int n){
    int i=2;
    int f=1;
    while(i<=n){
        f =f*i;
        i++;
    }
    return f;
}
int main(){
    int n;
    printf("Please enter the number for factorial calculation: ");
    scanf("%d",&n);
    int res = Factorial(n);
    printf("The factorial of %d is: %d",n,res);
}
