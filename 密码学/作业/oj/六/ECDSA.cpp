#include <bits/stdc++.h>
using namespace std;

#define int long long
int a = 1, b = 6, p = 11, q = 13;

int modular_mul(int a, int b, int mod) {
    int result = 0;
    a = a % mod;
    while (b > 0) {
        if (b & 1)
            result = (result + a) % mod;
        a = (2 * a) % mod;
        b >>= 1;
    }
    return result;
}

int Hash(int base, int exp, int mod) {
    int result = 1;
    while (exp > 0) {
        if (exp & 1)
            result = modular_mul(result, base, mod);
        exp = exp >> 1;
        base = modular_mul(base, base, mod);
    }
    return result;
}

struct Point {
    int x, y;
    bool inf; // 是否为无穷远点
    Point(int x, int y) : x(x), y(y), inf(false) {}
    Point(bool inf) : x(0), y(0), inf(inf) {}  // 用于创建无穷远点
    bool operator==(const Point& other) const {
        if(inf != other.inf) return false;
        if(inf && other.inf) return true;
        return x == other.x && y == other.y;
    }
    bool operator!=(const Point& other) const { return !(*this == other); }
};


class EllipticCurve {
public:
    int a, b, p;
    Point ZERO; // 定义无穷远点
    EllipticCurve(int a, int b, int p) : a(a), b(b), p(p), ZERO(true) {}

    // 求最大公约数
    int gcd(int a, int b) { return b ? gcd(b, a % b) : a; }

    // 扩展欧几里得算法求逆元
    int inverse(int a,int m){
        while(a < 0) a += m; 
        assert(gcd(a, m) == 1);
        int r, q, s1 = 1, s2 = 0, s3, t1 = 0, t2 = 1, t3 = 1, mt = m;
        while(1){
            r = m % a; q = m / a;
            if(!r) break;
            m = a; a = r;
            s3 = s1 - q * s2;
            t3 = t1 - q * t2;
            s1 = s2; s2 = s3;
            t1 = t2; t2 = t3;
        }
        while(t3 < 0) t3 += mt;
        return t3 % mt;
    }

    // 计算P+P
    Point doublePoint(const Point& P) {
        if (P.y == 0) return ZERO;
        int s = ((3 * P.x * P.x + a) * inverse(2 * P.y, p)) % p;
        while(s < 0) s += p;
        int xR = (s * s - 2 * P.x) % p;
        while(xR < 0) xR += p;
        int yR = (s * (P.x - xR) - P.y) % p;
        while(yR < 0) yR += p;
        return Point(xR, yR);
    }

    // 计算两点之和
    Point addPoints(const Point& P, const Point& Q) {
        if (P == ZERO) return Q;
        if (Q == ZERO) return P;
        if (P == Q) return doublePoint(P);
        if (P.x == Q.x) return ZERO;
        int s = ((Q.y - P.y) * inverse(Q.x - P.x, p)) % p;
        while(s < 0) s += p; 
        int xR = (s * s - P.x - Q.x) % p;
        while(xR < 0) xR += p;
        int yR = (s * (P.x - xR) - P.y) % p;
        while(yR < 0) yR += p;
        return Point(xR, yR);
    }

    // 计算mP 
    Point multiplyPoint(const Point& P, int m) {
        if (m == 0) return ZERO;
        Point R = P;
        for (int i = 1; i < m; i++) {
            R = addPoints(R, P);
        }
        return R;
    }
};


signed main() {
    int xA, yA;
    cin >> xA >> yA;
    int m, x, k;
    cin >> m >> x >> k;
    EllipticCurve ec(a, b, p);
    Point A = Point(xA, yA);
    Point kA = ec.multiplyPoint(A, k);
    int r = kA.x % q;
    int s = modular_mul(ec.inverse(k, q), Hash(2, x, q) + m * r, q);
    cout << r << " " << s;
    return 0;
}