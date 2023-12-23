#include <bits/stdc++.h>
#define pii pair<int, int>
using namespace std;

int main(){
    int n, x, y;
    cin >> n;
    priority_queue<pii, vector<pii>, greater<pii>> que; // 使用小根堆对任务按截止时间进行排序
    for(int i = 0; i < n; i++){
        cin >> x >> y;
        que.push({y, x}); // 任务的截止时间 y 放在前面，保证小根堆按截止时间从小到大排序
    }
    int cur_time = 0, max_lateness = 0;
    while(!que.empty()){
        // 取出队首的任务进行处理
        int end = cur_time + que.top().second; // 计算任务的完成时间
        int lateness = end - que.top().first; // 计算任务的延迟时间
        que.pop();
        cur_time = end; // 更新当前时间
        max_lateness = max(max_lateness, lateness); // 更新最大延迟时间
    }
    cout << max_lateness; // 输出最大延迟时间
    return 0;
}
