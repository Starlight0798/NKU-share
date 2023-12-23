#include <stdio.h>

int fibonacci(int n) {
    if (n <= 1) return n;
    int i = 1, a = 0, b = 1;
    while (i < n) {
        int sum = a + b;
        a = b;
        b = sum;
        i = i + 1;
    }
    return b;
}

int main() {
    int n;
    printf("The number of fibonacci: ");
    scanf("%d", &n);
    int ans = fibonacci(n);

    int fib_array[5] = {0}; 
    for(int i = 0; i < 5; ++i){
        fib_array[i] = i;
    }

    printf("%d", ans);
    return 0;
}