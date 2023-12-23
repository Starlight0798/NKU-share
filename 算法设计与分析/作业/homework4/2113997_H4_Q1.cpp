#include <bits/stdc++.h>
#define pii pair<int, int>
using namespace std;

int main(){
    int n, x, y;
    cin >> n;  // 输入任务数量
    priority_queue<pii, vector<pii>, greater<pii>> que;  // 小根堆，对每个任务按结束时间排序
    for(int i = 0; i < n; i++){
        cin >> x >> y;     // 输入开始时间x和结束时间y
        que.push({y, x});  // 将任务插入小根堆，插入{y,x}而不是{x,y}是由于堆对pair的排序默认按其第一个元素
    }
    int last_finish_time = -1, ans = 0;  // 初始化最后完成时间为-1，以及答案计数器
    while(!que.empty()){
        int start = que.top().second;  // 取出堆顶的开始时间
        int end = que.top().first;  // 取出堆中最小结束时间
        que.pop();  
        if(start >= last_finish_time){  // 如果当前任务的开始时间大于等于最后完成时间，就可以安排这个任务
            ans++;  
            last_finish_time = end;  // 更新最后完成时间
        }
    }
    cout << ans;  
    return 0;
}