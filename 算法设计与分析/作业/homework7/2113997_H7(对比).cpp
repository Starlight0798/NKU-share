#include <bits/stdc++.h>
#define MAXN 1050
#define MAXW 1050
#define ll long long
#define pii pair<int, int>
using namespace std;

ll dp[MAXN][MAXW];
pii item[MAXN];
int n_values[100];
int w_values[100];

ll knapsack_bruteforce(int n, int w) {
    ll ans = 0, one = 1;
    for (ll i = 0; i < (one << n); i++) {
        ll current_weight = 0, current_value = 0;
        for (int j = 0; j < n; j++) {
            if (i & (one << j)) {
                current_weight += item[j].first;
                current_value += item[j].second;
            }
        }
        if (current_weight <= w) {
            ans = max(ans, current_value);
        }
    }
    return ans;
}

ll knapsack_dp(int n, int w) {
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

void generate_items(int n) {
    srand(time(0));
    for (int i = 0; i < n; ++i) {
        item[i].first = rand() % 100 + 1;
        item[i].second = rand() % 100 + 1;
    }
}

int main() {
    int lens = 2;
    int test_runs = 5;
    n_values[0] = 4; w_values[0] = 200;
    n_values[1] = 25; w_values[1] = 1000;
    ll ans1 = 0, ans2 = 0;
    for (int k = 0; k < lens; k++) {
        int n = n_values[k], w = w_values[k];
        generate_items(n);
        auto start_bruteforce = chrono::high_resolution_clock::now();
        for (int i = 0; i < test_runs; i++) {
            ans1 = knapsack_bruteforce(n, w);
        }
        auto end_bruteforce = chrono::high_resolution_clock::now();
        auto duration_bruteforce = chrono::duration_cast<chrono::microseconds>(end_bruteforce - start_bruteforce);

        auto start_dp = chrono::high_resolution_clock::now();
        for (int i = 0; i < test_runs; i++) {
            ans2 = knapsack_dp(n, w);
        }
        auto end_dp = chrono::high_resolution_clock::now();
        auto duration_dp = chrono::duration_cast<chrono::microseconds>(end_dp - start_dp);

        cout << "物品数量: " << n << "\n";
        cout << "枚举法平均时间: " << duration_bruteforce.count() / (double)test_runs << " μs ";
        cout << "结果: " << ans1 << "\n";
        cout << "动态规划平均时间: " << duration_dp.count() / (double)test_runs << " μs ";
        cout << "结果: " << ans2 << "\n" << "\n";
    }
    return 0;
}
