#include <bits/stdc++.h>
#define MAXN 100000
using namespace std;

bool vis[MAXN];
vector<int> primeList;

// 线性筛选法生成素数
void Prime(int n){
    for (int i = 2; i <= n; i++){
        if(!vis[i]) primeList.push_back(i);  // 如果i未被标记，说明i是素数，将其添加到素数列表中
        for(int &p : primeList){
            if (i * p > n) break;  // 如果i*p超过n，则跳出当前循环
            vis[i * p] = true;  // 标记所有的i*p（其中p为素数）为非素数
            if (i % p == 0) break;  // 如果i能被p整除，说明i*p之后的数已经被标记过了，所以跳出循环
        }
    }
}

// 计算字符串指纹，使用模p取余确保结果在有限范围内
int getIP(const string& x, int p){
    int ans = 0, base = 1;
    for(int i = (int)x.length() - 1; i >= 0; i--){
        ans = (ans + (x[i] - 'a' + 1) * base) % p;  // 计算字符串的指纹值
        base = (base * 2) % p;  // 更新基数
    }
    return ans;
}


// x为被匹配串，y为匹配串
int solve(const string& x, const string& y){
    int m = y.size(), n = x.size(), j = 0;
    Prime(n * n * m);  // 预先生成素数表
    int p = primeList[rand() % primeList.size()];  // 随机选择一个素数作为模数
    int w = 1;
    for (int i = 0; i < m; i++) w = (w * 2) % p;  // 计算2^m mod p的值，存储为w
    int IPy = getIP(y, p);  // 计算匹配串的指纹
    int IPx = getIP(x.substr(0, m), p);  // 计算被匹配串的前m个字符的指纹
    while(j <= n - m){
        if(IPx == IPy) return j;  // 如果两个指纹相同，则返回当前的起始位置
        // 更新被匹配串的指纹，同时处理负数的情况
        IPx = (IPx * 2 - (x[j] - 'a' + 1) * w + (x[j + m] - 'a' + 1)) % p;
        while(IPx < 0) IPx += p;
        j++;
    }
    return -1;  // 如果没有找到匹配，返回-1
}

int main(){
    srand(time(NULL));
    string x, y;
    cin >> x >> y;
    cout << solve(x, y);
    return 0;
}
