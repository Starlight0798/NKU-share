#include <bits/stdc++.h>
#define MAXM 10000
using namespace std;

string a, b;
int dp[MAXM][MAXM], n, m;

// 动态规划求最长公共子序列
int find_dp(){
    for(int i=1;i<=n;i++){
        for(int j=1;j<=m;j++){
            if(a[i-1] == b[j-1]) dp[i][j] = dp[i-1][j-1] + 1;
            else dp[i][j] = max(dp[i-1][j], dp[i][j-1]);
        }
    }
    return dp[n][m];
}

int main(){
    ios::sync_with_stdio(false);
    cin >> a >> b;
    n = a.size();
    m = b.size();
    cout << find_dp();
    return 0;
}