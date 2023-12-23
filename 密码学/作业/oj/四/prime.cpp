#include <iostream>
#include <cmath>
#include <cstdlib>
using namespace std;

long long modular_mul(long long a, long long b, long long mod) {
    long long result = 0;
    a = a % mod;
    while (b > 0) {
        if (b & 1)
            result = (result + a) % mod;
        a = (2 * a) % mod;
        b >>= 1;
    }
    return result;
}

long long modular_pow(long long base, long long exp, long long mod) {
    long long result = 1;
    base = base % mod;
    while (exp > 0) {
        if (exp & 1)
            result = modular_mul(result, base, mod);
        exp = exp >> 1;
        base = modular_mul(base, base, mod);
    }
    return result;
}


bool miller_rabin(long long n, int iteration) {
    if (n == 2) return true;
    if (n < 2 ||( n > 2 && n & 1ULL == 0)) return false;
    int k = 0;
    long long d = n - 1;
    while (d % 2 == 0) {
        d /= 2;
        k++;
    }
    for (int i = 0; i < iteration; i++) {
        long long a = rand() % (n - 1) + 1;
        long long b = modular_pow(a, d, n);
        if (b == 1) return true;
        for (int j = 0; j < k - 1; j++) {
            if (b == n - 1) return true;
            b = modular_pow(b, 2, n);
        }
    }
    return false;
}

int main() {
    long long number;
    cin >> number;
    int iteration = 100;
    if (miller_rabin(number, iteration))
        cout << "Yes";
    else
        cout << "No";
    return 0;
}
