#include <bits/stdc++.h>
#define MAXM 10000
using namespace std;
using namespace chrono;

string a, b;
int dp[MAXM][MAXM], m;

// 动态规划求最长公共子序列
int find_dp(){
    for(int i=1;i<=m;i++){
        for(int j=1;j<=m;j++){
            if(a[i-1] == b[j-1]) dp[i][j] = dp[i-1][j-1] + 1;
            else dp[i][j] = max(dp[i-1][j], dp[i][j-1]);
        }
    }
    return dp[m][m];
}

// 枚举法求最长公共子序列
int find_list() {
    int m = b.length();
    int ans = 0;
    for (long long int i = 0; i < (1 << m); i++) {
        int current_length = 0;
        int last_position = -1;
        for (int j = 0; j < m; j++) {
            if (i & (1 << j)) {
                int pos = a.find_first_of(b[j], last_position + 1);
                if (pos == string::npos) break;
                else {
                    current_length++;
                    last_position = pos;
                }
            }
        }
        ans = max(ans, current_length);
    }
    return ans;
}

// 随机生成字符串
string generate_random_string(int length) {
    string result;
    for (int i = 0; i < length; i++) {
        result.push_back('A' + rand() % 26);
    }
    return result;
}

int main(){
    ios::sync_with_stdio(false);
    srand(time(NULL));
    int lens[] = {5, 25};
    for (int size : lens) {
        a = generate_random_string(size);
        b = generate_random_string(size);
        m = a.size();

        auto start1 = high_resolution_clock::now();
        int ans1 = find_dp();
        auto end1 = high_resolution_clock::now();
        auto time1 = duration_cast<microseconds>(end1 - start1);

        auto start2 = high_resolution_clock::now();
        int ans2 = find_list();
        auto end2 = high_resolution_clock::now();
        auto time2 = duration_cast<microseconds>(end2 - start2);
        cout << "字符串1: " << a << endl;
        cout << "字符串2: " << b << endl;
        cout << "长度: " << size << endl;
        cout << "动态规划: " << ans1 << ", 耗时: " << time1.count() << " μs" << endl;
        cout << "枚举法: " << ans2 << ", 耗时: " << time2.count() << " μs" << endl;
        cout << "---------------------------------------" << endl;
    }
    return 0;
}
