#include <bits/stdc++.h>
#define MAXN 10050
#define MAXW 10050
#define pii pair<int, int>
using namespace std;

int dp[MAXN][MAXW];
pii item[MAXN];

int knapsack_dp(int n, int w) {
    for (int i = n - 1; i >= 0; i--) {
        for (int j = 0; j <= w; j++) {
            int wei = item[i].first, val = item[i].second;
            if (j < wei) {
                dp[i][j] = dp[i + 1][j];
            } else {
                dp[i][j] = max(dp[i + 1][j], dp[i + 1][j - wei] + val);
            }
        }
    }
    return dp[0][w];
}

int main(){
    ios::sync_with_stdio(0);
    cin.tie(0); cout.tie(0);
    int maxv, n;
    cin >> maxv >> n;
    for(int i=0;i<n;i++) cin >> item[i].first >> item[i].second;
    cout << knapsack_dp(n, maxv);
    return 0;
}